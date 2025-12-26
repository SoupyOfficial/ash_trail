import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../models/log_entry.dart';
import '../services/isar_service.dart';

class LoggingService {
  final Isar _isar = IsarService.instance;
  final _uuid = const Uuid();

  /// Create a new log entry
  Future<LogEntry> createLogEntry({
    required String userId,
    DateTime? timestamp,
    String? notes,
    double? amount,
    String? sessionId,
  }) async {
    final entry = LogEntry.create(
      entryId: _uuid.v4(),
      userId: userId,
      timestamp: timestamp ?? DateTime.now(),
      notes: notes,
      amount: amount,
      sessionId: sessionId,
      syncState: SyncState.pending,
    );

    await _isar.writeTxn(() async {
      await _isar.logEntrys.put(entry);
    });

    return entry;
  }

  /// Quick log for active account (primary use case)
  Future<LogEntry> quickLog({
    required String userId,
    String? notes,
    double? amount,
  }) async {
    return await createLogEntry(userId: userId, notes: notes, amount: amount);
  }

  /// Get log entries for a user in a date range
  Future<List<LogEntry>> getLogEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = _isar.logEntrys.filter().userIdEqualTo(userId);

    if (startDate != null) {
      query = query.timestampGreaterThan(startDate);
    }

    if (endDate != null) {
      query = query.timestampLessThan(endDate);
    }

    return await query.sortByTimestampDesc().findAll();
  }

  /// Get all entries for a user
  Future<List<LogEntry>> getAllEntriesForUser(String userId) async {
    return await _isar.logEntrys
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Get entries by session
  Future<List<LogEntry>> getEntriesBySession(String sessionId) async {
    return await _isar.logEntrys
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByTimestamp()
        .findAll();
  }

  /// Update log entry
  Future<void> updateLogEntry(LogEntry entry) async {
    entry.updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.logEntrys.put(entry);
    });
  }

  /// Delete log entry
  Future<void> deleteLogEntry(int id) async {
    await _isar.writeTxn(() async {
      await _isar.logEntrys.delete(id);
    });
  }

  /// Get pending sync entries
  Future<List<LogEntry>> getPendingSyncEntries(String userId) async {
    return await _isar.logEntrys
        .filter()
        .userIdEqualTo(userId)
        .syncStateEqualTo(SyncState.pending)
        .findAll();
  }

  /// Mark entry as synced
  Future<void> markAsSynced(LogEntry entry, String firestoreDocId) async {
    entry.syncState = SyncState.synced;
    entry.firestoreDocId = firestoreDocId;
    entry.lastSyncAttempt = DateTime.now();
    entry.syncError = null;
    await updateLogEntry(entry);
  }

  /// Mark entry sync as failed
  Future<void> markSyncFailed(LogEntry entry, String error) async {
    entry.syncState = SyncState.error;
    entry.syncError = error;
    entry.lastSyncAttempt = DateTime.now();
    await updateLogEntry(entry);
  }

  /// Watch log entries for a user
  Stream<List<LogEntry>> watchLogEntries(String userId) {
    return _isar.logEntrys
        .filter()
        .userIdEqualTo(userId)
        .watch(fireImmediately: true);
  }

  /// Get statistics for date range
  Future<Map<String, dynamic>> getStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entries = await getLogEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'totalEntries': entries.length,
      'totalAmount': entries.fold<double>(
        0,
        (sum, entry) => sum + (entry.amount ?? 0),
      ),
      'firstEntry': entries.isEmpty ? null : entries.last.timestamp,
      'lastEntry': entries.isEmpty ? null : entries.first.timestamp,
    };
  }
}
