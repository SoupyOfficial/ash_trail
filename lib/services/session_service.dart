import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/log_record.dart';
import '../repositories/session_repository.dart';
import 'database_service.dart';
import 'log_record_service.dart';

/// SessionService manages logging sessions
/// Provides operations for starting, ending, and tracking sessions
class SessionService {
  late final SessionRepository _repository;
  final Uuid _uuid = const Uuid();
  final LogRecordService _logRecordService = LogRecordService();

  SessionService() {
    // Initialize repository with Hive database
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;

    _repository = createSessionRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
    );
  }

  /// Get device ID (platform-specific, simplified here)
  String _getDeviceId() {
    // TODO: Implement platform-specific device ID retrieval
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get app version (simplified)
  String _getAppVersion() {
    // TODO: Get from package_info_plus
    return '1.0.0';
  }

  /// Start a new session
  Future<Session> startSession({
    required String accountId,
    String? profileId,
    String? name,
    String? notes,
    List<String>? tags,
    String? location,
  }) async {
    final sessionId = _uuid.v4();
    final now = DateTime.now();

    final session = Session.create(
      sessionId: sessionId,
      accountId: accountId,
      profileId: profileId,
      startedAt: now,
      name: name,
      notes: notes,
      tagsString: tags?.join(','),
      location: location,
      createdAt: now,
      updatedAt: now,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      isActive: true,
    );

    return await _repository.create(session);
  }

  /// End a session and compute metrics
  Future<Session> endSession(Session session) async {
    if (!session.isOngoing) {
      throw StateError('Session is not active or already ended');
    }

    // End the session
    session.end();

    // Get all log records for this session
    final records = await _logRecordService.getLogRecordsBySession(
      session.sessionId,
    );

    // Compute metrics
    if (records.isNotEmpty) {
      final values =
          records.where((r) => r.value != null).map((r) => r.value!).toList();

      session.updateMetrics(
        count: records.length,
        total: values.isEmpty ? null : values.reduce((a, b) => a + b),
        average:
            values.isEmpty
                ? null
                : values.reduce((a, b) => a + b) / values.length,
        min: values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b),
        max: values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b),
        avgInterval: _calculateAverageInterval(records),
      );
    }

    return await _repository.update(session);
  }

  /// Calculate average interval between log entries
  double? _calculateAverageInterval(List<LogRecord> records) {
    if (records.length < 2) return null;

    records.sort((a, b) => a.eventAt.compareTo(b.eventAt));

    double totalSeconds = 0;
    int intervalCount = 0;

    for (int i = 1; i < records.length; i++) {
      final interval = records[i].eventAt.difference(records[i - 1].eventAt);
      totalSeconds += interval.inSeconds;
      intervalCount++;
    }

    return intervalCount > 0 ? totalSeconds / intervalCount : null;
  }

  /// Update session metadata
  Future<Session> updateSession(
    Session session, {
    String? name,
    String? notes,
    List<String>? tags,
    String? location,
  }) async {
    final updated = session.copyWith(
      name: name,
      notes: notes,
      tagsString: tags?.join(','),
      location: location,
      updatedAt: DateTime.now(),
    );

    return await _repository.update(updated);
  }

  /// Delete a session (soft delete)
  Future<void> deleteSession(Session session) async {
    session.softDelete();
    await _repository.update(session);
  }

  /// Hard delete a session
  Future<void> hardDeleteSession(Session session) async {
    await _repository.delete(session.sessionId);
  }

  /// Get session by sessionId
  Future<Session?> getSession(String sessionId) async {
    return await _repository.getBySessionId(sessionId);
  }

  /// Get all sessions for an account
  Future<List<Session>> getSessions({
    required String accountId,
    String? profileId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
    bool activeOnly = false,
  }) async {
    // Get sessions from repository and filter in memory
    List<Session> sessions;

    if (startDate != null && endDate != null) {
      sessions = await _repository.getByDateRange(
        accountId,
        startDate,
        endDate,
      );
    } else {
      sessions = await _repository.getByAccount(accountId);
    }

    // Apply additional filters
    return sessions.where((session) {
      if (!includeDeleted && session.isDeleted) return false;
      if (activeOnly && !session.isActive) return false;
      if (profileId != null && session.profileId != profileId) return false;
      return true;
    }).toList();
  }

  /// Get active session for an account
  Future<Session?> getActiveSession({
    required String accountId,
    String? profileId,
  }) async {
    final session = await _repository.getActiveSession(accountId);
    if (session != null &&
        profileId != null &&
        session.profileId != profileId) {
      return null;
    }
    return session;
  }

  /// Refresh session metrics
  Future<Session> refreshMetrics(Session session) async {
    final records = await _logRecordService.getLogRecordsBySession(
      session.sessionId,
    );

    if (records.isNotEmpty) {
      final values =
          records.where((r) => r.value != null).map((r) => r.value!).toList();

      session.updateMetrics(
        count: records.length,
        total: values.isEmpty ? null : values.reduce((a, b) => a + b),
        average:
            values.isEmpty
                ? null
                : values.reduce((a, b) => a + b) / values.length,
        min: values.isEmpty ? null : values.reduce((a, b) => a < b ? a : b),
        max: values.isEmpty ? null : values.reduce((a, b) => a > b ? a : b),
        avgInterval: _calculateAverageInterval(records),
      );

      await _repository.update(session);
    }

    return session;
  }

  /// Watch sessions for real-time updates
  Stream<List<Session>> watchSessions({
    required String accountId,
    String? profileId,
    bool activeOnly = false,
  }) {
    final stream = _repository.watchByAccount(accountId);

    return stream.map((sessions) {
      return sessions.where((session) {
        if (session.isDeleted) return false;
        if (profileId != null && session.profileId != profileId) return false;
        if (activeOnly && !session.isActive) return false;
        return true;
      }).toList();
    });
  }

  /// Watch active session
  Stream<Session?> watchActiveSession({
    required String accountId,
    String? profileId,
  }) {
    final stream = _repository.watchActiveSession(accountId);

    if (profileId == null) {
      return stream;
    }

    return stream.map((session) {
      if (session != null && session.profileId != profileId) {
        return null;
      }
      return session;
    });
  }

  /// Get session statistics
  Future<Map<String, dynamic>> getSessionStatistics({
    required String accountId,
    String? profileId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final sessions = await getSessions(
      accountId: accountId,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
      activeOnly: false,
    );

    // Filter out ongoing sessions for average calculations
    final completedSessions = sessions.where((s) => !s.isOngoing).toList();

    final totalSessions = completedSessions.length;
    final totalDuration = completedSessions.fold<int>(
      0,
      (sum, s) => sum + (s.durationSeconds ?? 0),
    );

    final avgDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;

    final totalEntries = completedSessions.fold<int>(
      0,
      (sum, s) => sum + s.entryCount,
    );

    final avgEntriesPerSession =
        totalSessions > 0 ? totalEntries / totalSessions : 0;

    return {
      'totalSessions': totalSessions,
      'totalDuration': totalDuration,
      'averageDuration': avgDuration,
      'totalEntries': totalEntries,
      'averageEntriesPerSession': avgEntriesPerSession,
      'activeSessions': sessions.where((s) => s.isOngoing).length,
    };
  }
}
