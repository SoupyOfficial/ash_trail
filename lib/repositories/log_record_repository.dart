import '../models/log_record.dart';
import '../models/enums.dart';
import 'log_record_repository_hive.dart';

/// Abstract repository interface for LogRecord data access
/// Uses Hive for local storage on all platforms (web, iOS, Android, desktop)
abstract class LogRecordRepository {
  /// Create a new log record
  Future<LogRecord> create(LogRecord record);

  /// Update an existing log record
  Future<LogRecord> update(LogRecord record);

  /// Delete a log record by logId
  Future<void> delete(String logId);

  /// Get log record by logId
  Future<LogRecord?> getByLogId(String logId);

  /// Get all log records (for integrity checks)
  Future<List<LogRecord>> getAll();

  /// Get all log records for an account
  Future<List<LogRecord>> getByAccount(String accountId);

  /// Get log records by date range
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );

  /// Get log records by event type
  Future<List<LogRecord>> getByEventType(String accountId, EventType eventType);

  /// Get log records pending sync
  Future<List<LogRecord>> getPendingSync();

  /// Get deleted log records (tombstones)
  Future<List<LogRecord>> getDeleted(String accountId);

  /// Count log records for account
  Future<int> countByAccount(String accountId);

  /// Delete all log records for an account
  Future<void> deleteByAccount(String accountId);

  /// Watch all log records for account
  Stream<List<LogRecord>> watchByAccount(String accountId);

  /// Watch log records by date range
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );
}

/// Factory to create LogRecordRepository using Hive
LogRecordRepository createLogRecordRepository([dynamic context]) {
  if (context == null) {
    throw ArgumentError(
      'Database context cannot be null. Ensure DatabaseService is initialized.',
    );
  }
  return LogRecordRepositoryHive(context as Map<String, dynamic>);
}
