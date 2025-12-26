import '../models/log_record.dart';
import '../models/enums.dart';
import 'log_record_repository_stub.dart'
    if (dart.library.io) 'log_record_repository_native.dart'
    if (dart.library.js_interop) 'log_record_repository_web.dart';

/// Abstract repository interface for LogRecord data access
/// Platform-specific implementations handle Isar (native) or Hive (web)
abstract class LogRecordRepository {
  /// Create a new log record
  Future<LogRecord> create(LogRecord record);

  /// Update an existing log record
  Future<LogRecord> update(LogRecord record);

  /// Delete a log record by logId
  Future<void> delete(String logId);

  /// Get log record by logId
  Future<LogRecord?> getByLogId(String logId);

  /// Get all log records for an account
  Future<List<LogRecord>> getByAccount(String accountId);

  /// Get log records by session
  Future<List<LogRecord>> getBySession(String sessionId);

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

  /// Watch all log records for account
  Stream<List<LogRecord>> watchByAccount(String accountId);

  /// Watch log records by date range
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  );
}

/// Factory to create platform-specific LogRecordRepository
LogRecordRepository createLogRecordRepository([dynamic context]) {
  // For native platforms, use Isar-based implementation
  // For web, use Hive-based implementation
  // The conditional import handles platform selection automatically
  return LogRecordRepositoryNative();
}
