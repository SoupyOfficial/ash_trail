import 'package:isar/isar.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../services/isar_service.dart';
import 'log_record_repository.dart';

/// Native implementation of LogRecordRepository using Isar
class LogRecordRepositoryNative implements LogRecordRepository {
  final Isar _isar = IsarService.instance;

  @override
  Future<LogRecord> create(LogRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    await _isar.writeTxn(() async {
      final record = await getByLogId(logId);
      if (record != null) {
        await _isar.logRecords.delete(record.id);
      }
    });
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    return await _isar.logRecords.filter().logIdEqualTo(logId).findFirst();
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    return await _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByEventAtDesc()
        .findAll();
  }

  @override
  Future<List<LogRecord>> getBySession(String sessionId) async {
    return await _isar.logRecords
        .filter()
        .sessionIdEqualTo(sessionId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByEventAt()
        .findAll();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return await _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .eventAtBetween(start, end)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByEventAtDesc()
        .findAll();
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    return await _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .eventTypeEqualTo(eventType)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortByEventAtDesc()
        .findAll();
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    return await _isar.logRecords
        .filter()
        .syncStateEqualTo(SyncState.pending)
        .or()
        .syncStateEqualTo(SyncState.error)
        .findAll();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return await _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .isDeletedEqualTo(true)
        .findAll();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return await _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .count();
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    return _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return _isar.logRecords
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .eventAtBetween(start, end)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true);
  }
}
