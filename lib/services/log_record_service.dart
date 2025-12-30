import 'package:uuid/uuid.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../repositories/log_record_repository.dart';
import 'validation_service.dart';

/// LogRecordService handles all CRUD operations for log records
/// Implements offline-first with sync queue management
class LogRecordService {
  late final LogRecordRepository _repository;
  final Uuid _uuid = const Uuid();

  LogRecordService({LogRecordRepository? repository}) {
    // Use injected repository for testing, or create platform-specific one
    _repository = repository ?? createLogRecordRepository(null);
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

  /// Create a new log record
  /// This is the main entry point for logging events
  Future<LogRecord> createLogRecord({
    required String accountId,
    required EventType eventType,
    DateTime? eventAt,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    Source source = Source.manual,
    double? moodRating,
    double? physicalRating,
    LogReason? reason,
    double? latitude,
    double? longitude,
  }) async {
    final logId = _uuid.v4();
    final now = DateTime.now();

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt ?? now,
      createdAt: now,
      updatedAt: now,
      duration: duration,
      unit: unit,
      note: note,
      source: source,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      moodRating: moodRating,
      physicalRating: physicalRating,
      reason: reason,
      latitude: latitude,
      longitude: longitude,
    );

    return await _repository.create(record);
  }

  /// Import a log record from remote source (e.g., Firestore)
  /// This preserves the remote logId and metadata
  Future<LogRecord> importLogRecord({
    required String logId,
    required String accountId,
    required EventType eventType,
    required DateTime eventAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    Source source = Source.imported,
    String? deviceId,
    String? appVersion,
  }) async {
    final record = LogRecord.create(
      logId: logId, // Use provided logId instead of generating new one
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      duration: duration,
      unit: unit,
      note: note,
      source: source,
      deviceId: deviceId ?? _getDeviceId(),
      appVersion: appVersion ?? _getAppVersion(),
      syncState: SyncState.synced, // Mark as synced since it came from remote
    );

    return await _repository.create(record);
  }

  /// Update an existing log record
  Future<LogRecord> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? duration,
    Unit? unit,
    String? note,
  }) async {
    if (eventType != null && eventType != record.eventType) {
      record.eventType = eventType;
    }

    if (eventAt != null && eventAt != record.eventAt) {
      record.eventAt = eventAt;
    }

    if (duration != null && duration != record.duration) {
      record.duration = duration;
    }

    if (unit != null && unit != record.unit) {
      record.unit = unit;
    }

    if (note != null && note != record.note) {
      record.note = note;
    }

    // Mark as dirty
    record.markDirty();

    return await _repository.update(record);
  }

  /// Soft delete a log record
  Future<void> deleteLogRecord(LogRecord record) async {
    record.softDelete();
    await _repository.update(record);
  }

  /// Hard delete a log record (use with caution)
  Future<void> hardDeleteLogRecord(LogRecord record) async {
    await _repository.delete(record.logId);
  }

  /// Get a log record by its logId
  Future<LogRecord?> getLogRecordByLogId(String logId) async {
    return await _repository.getByLogId(logId);
  }

  /// Get all log records for an account
  Future<List<LogRecord>> getLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    List<EventType>? eventTypes,
    bool includeDeleted = false,
  }) async {
    // Get base records from repository
    List<LogRecord> records;

    if (startDate != null && endDate != null) {
      records = await _repository.getByDateRange(accountId, startDate, endDate);
    } else {
      records = await _repository.getByAccount(accountId);
    }

    // Apply additional filters in memory
    return records.where((record) {
      if (!includeDeleted && record.isDeleted) return false;
      if (eventTypes != null && !eventTypes.contains(record.eventType)) {
        return false;
      }
      if (startDate != null && record.eventAt.isBefore(startDate)) return false;
      if (endDate != null && record.eventAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Get log records that need syncing
  Future<List<LogRecord>> getPendingSync({int limit = 100}) async {
    final records = await _repository.getPendingSync();
    return records.take(limit).toList();
  }

  /// Count log records for an account
  Future<int> countLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );
    return records.length;
  }

  /// Watch log records for real-time updates
  Stream<List<LogRecord>> watchLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) {
    // Use repository watch and filter in stream
    Stream<List<LogRecord>> stream;

    if (startDate != null && endDate != null) {
      stream = _repository.watchByDateRange(accountId, startDate, endDate);
    } else {
      stream = _repository.watchByAccount(accountId);
    }

    return stream.map((records) {
      return records.where((record) {
        if (!includeDeleted && record.isDeleted) return false;
        return true;
      }).toList();
    });
  }

  /// Mark a record as synced
  Future<void> markSynced(LogRecord record, DateTime remoteUpdateTime) async {
    record.markSynced(remoteUpdateTime);
    await _repository.update(record);
  }

  /// Mark a record as having a sync error
  Future<void> markSyncError(LogRecord record, String error) async {
    record.markSyncError(error);
    await _repository.update(record);
  }

  /// Batch create multiple log records
  Future<List<LogRecord>> batchCreateLogRecords(
    List<Map<String, dynamic>> recordData,
  ) async {
    final records = <LogRecord>[];

    for (final data in recordData) {
      final logId = _uuid.v4();
      final now = DateTime.now();

      final record = LogRecord.create(
        logId: logId,
        accountId: data['accountId'] as String,
        eventType: data['eventType'] as EventType,
        eventAt: data['eventAt'] as DateTime? ?? now,
        createdAt: now,
        updatedAt: now,
        duration: (data['duration'] as num?)?.toDouble() ?? 0,
        unit: data['unit'] as Unit? ?? Unit.seconds,
        note: data['note'] as String?,
        source: data['source'] as Source? ?? Source.manual,
        deviceId: _getDeviceId(),
        appVersion: _getAppVersion(),
        syncState: SyncState.pending,
      );

      records.add(record);
    }

    // Batch create using repository
    for (final record in records) {
      await _repository.create(record);
    }

    return records;
  }

  /// Get statistics for an account
  Future<Map<String, dynamic>> getStatistics({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
    );

    final totalCount = records.length;
    final totalDuration = records.fold<double>(
      0,
      (sum, record) => sum + record.duration,
    );

    final eventTypeCounts = <EventType, int>{};
    for (final record in records) {
      eventTypeCounts[record.eventType] =
          (eventTypeCounts[record.eventType] ?? 0) + 1;
    }

    return {
      'totalCount': totalCount,
      'totalDuration': totalDuration,
      'averageDuration': totalCount > 0 ? totalDuration / totalCount : 0,
      'eventTypeCounts': eventTypeCounts,
      'firstEvent': records.isNotEmpty ? records.first.eventAt : null,
      'lastEvent': records.isNotEmpty ? records.last.eventAt : null,
    };
  }

  // ===== NEW LOGGING OPERATIONS =====

  /// Quick log: One-tap logging with minimal input
  Future<LogRecord> quickLog({
    required String accountId,
    EventType? eventType,
    double? duration,
    Unit? unit,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate and clamp duration
    final clampedDuration =
        duration != null && unit != null
            ? (ValidationService.clampValue(duration, unit) ?? 0)
            : duration ?? 0;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType ?? EventType.inhale,
      eventAt: now,
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: unit ?? Unit.seconds,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: TimeConfidence.high,
    );

    return await _repository.create(record);
  }

  /// Backdate log: Create a log entry for a past time
  Future<LogRecord> backdateLog({
    required String accountId,
    required DateTime eventAt,
    required EventType eventType,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate backdate time
    if (!ValidationService.isValidBackdateTime(eventAt)) {
      throw ArgumentError('Backdate time is too far in the past (max 30 days)');
    }

    // Detect clock skew and set time confidence
    final timeConfidence = ValidationService.detectClockSkew(eventAt);

    // Validate and clamp duration
    final clampedDuration = ValidationService.clampValue(duration, unit) ?? 0;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: unit,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: timeConfidence,
    );

    await _repository.create(record);

    return record;
  }

  /// Duration log: Create a log entry with measured duration from hold-to-record
  /// The duration is captured from press-and-hold interaction
  Future<LogRecord> recordDurationLog({
    required String accountId,
    required int durationMs,
    EventType? eventType,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Convert milliseconds to seconds with decimal precision
    final durationSeconds = durationMs / 1000.0;

    // Validate minimum threshold (e.g., 1 second minimum)
    if (durationSeconds < 1.0) {
      throw ArgumentError('Duration too short (minimum 1 second)');
    }

    // Clamp duration to reasonable maximum (e.g., 1 hour)
    final clampedDuration =
        ValidationService.clampValue(durationSeconds, Unit.seconds) ??
        durationSeconds;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType ?? EventType.inhale,
      eventAt: now, // Release timestamp
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: Unit.seconds,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence:
          TimeConfidence.high, // High confidence for measured duration
    );

    return await _repository.create(record);
  }

  /// Restore a soft-deleted record
  Future<void> restoreDeleted(LogRecord record) async {
    record.isDeleted = false;
    record.deletedAt = null;
    record.markDirty();

    await _repository.update(record);
  }

  /// Find potential duplicates for a given record
  Future<List<LogRecord>> findPotentialDuplicates(
    LogRecord record, {
    Duration timeTolerance = const Duration(minutes: 1),
  }) async {
    // Find records within time tolerance
    final startTime = record.eventAt.subtract(timeTolerance);
    final endTime = record.eventAt.add(timeTolerance);

    // Get all records in date range for the account
    final candidates = await _repository.getByDateRange(
      record.accountId,
      startTime,
      endTime,
    );

    // Filter using duplicate detection logic
    return candidates
        .where(
          (candidate) =>
              candidate.logId != record.logId &&
              candidate.eventType == record.eventType &&
              !candidate.isDeleted &&
              ValidationService.isPotentialDuplicate(
                eventAt1: record.eventAt,
                eventAt2: candidate.eventAt,
                value1: record.duration,
                value2: candidate.duration,
                eventType1: record.eventType.name,
                eventType2: candidate.eventType.name,
                timeTolerance: timeTolerance,
              ),
        )
        .toList();
  }

  /// Update record with context fields (location, ratings)
  Future<LogRecord> updateContext(
    LogRecord record, {
    double? latitude,
    double? longitude,
    double? moodRating,
    double? physicalRating,
  }) async {
    bool changed = false;

    if (latitude != null && longitude != null) {
      record.latitude = latitude;
      record.longitude = longitude;
      changed = true;
    }

    if (moodRating != null) {
      final validatedMood = ValidationService.validateMood(moodRating);
      if (validatedMood != record.moodRating) {
        record.moodRating = validatedMood;
        changed = true;
      }
    }

    if (physicalRating != null) {
      final validatedPhysical = ValidationService.validateCraving(
        physicalRating,
      );
      if (validatedPhysical != record.physicalRating) {
        record.physicalRating = validatedPhysical;
        changed = true;
      }
    }

    if (changed) {
      record.markDirty();
      await _repository.update(record);
    }

    return record;
  }
}
