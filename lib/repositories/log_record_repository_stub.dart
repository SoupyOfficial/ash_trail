import '../models/log_record.dart';
import '../models/enums.dart';
import 'log_record_repository.dart';

class LogRecordRepositoryStub implements LogRecordRepository {
  @override
  Future<LogRecord> create(LogRecord record) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<LogRecord> update(LogRecord record) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> delete(String logId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<LogRecord?> getByLogId(String logId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getBySession(String sessionId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getPendingSync() {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<int> countByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    throw UnsupportedError('Platform not supported');
  }
}
