import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';
import 'package:ash_trail/services/legacy_data_adapter.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/services/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Minimal in-memory repository to drive sync tests without Hive
class _InMemoryLogRecordRepository implements LogRecordRepository {
  final List<LogRecord> _records = [];

  @override
  Future<LogRecord> create(LogRecord record) async {
    _records.add(record);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record;
    }
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    _records.removeWhere((r) => r.logId == logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    try {
      return _records.firstWhere((r) => r.logId == logId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    return _records
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .toList();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _records
        .where(
          (r) =>
              r.accountId == accountId &&
              !r.isDeleted &&
              r.eventAt.isAfter(start) &&
              r.eventAt.isBefore(end),
        )
        .toList();
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    return _records
        .where(
          (r) =>
              r.accountId == accountId &&
              r.eventType == eventType &&
              !r.isDeleted,
        )
        .toList();
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    return _records.where((r) => r.syncState != SyncState.synced).toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return _records
        .where((r) => r.accountId == accountId && r.isDeleted)
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _records
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    _records.removeWhere((r) => r.accountId == accountId);
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    return Stream.value(
      _records.where((r) => r.accountId == accountId && !r.isDeleted).toList(),
    );
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return Stream.value(
      _records
          .where(
            (r) =>
                r.accountId == accountId &&
                !r.isDeleted &&
                r.eventAt.isAfter(start) &&
                r.eventAt.isBefore(end),
          )
          .toList(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncService account scoping', () {
    test('uploads pending records into account-scoped collections', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final repo = _InMemoryLogRecordRepository();
      final logService = LogRecordService(repository: repo);
      final fakeLegacyAdapter = LegacyDataAdapter(firestore: fakeFirestore);
      final syncService = SyncService(
        firestore: fakeFirestore,
        logRecordService: logService,
        legacyAdapter: fakeLegacyAdapter,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final recordA = await logService.createLogRecord(
        accountId: 'account-a',
        eventType: EventType.inhale,
        duration: 1,
      );
      final recordB = await logService.createLogRecord(
        accountId: 'account-b',
        eventType: EventType.note,
        duration: 2,
      );

      final result = await syncService.syncPendingRecords();
      expect(result.success, 2);

      final docA =
          await fakeFirestore
              .collection('accounts')
              .doc('account-a')
              .collection('logs')
              .doc(recordA.logId)
              .get();
      final docB =
          await fakeFirestore
              .collection('accounts')
              .doc('account-b')
              .collection('logs')
              .doc(recordB.logId)
              .get();

      expect(docA.exists, isTrue);
      expect(docB.exists, isTrue);
      expect(docA.data()?['accountId'], 'account-a');
      expect(docB.data()?['accountId'], 'account-b');
    });

    test('pullRecordsForAccount only imports the requested account', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final repo = _InMemoryLogRecordRepository();
      final logService = LogRecordService(repository: repo);
      final fakeLegacyAdapter = LegacyDataAdapter(firestore: fakeFirestore);
      final syncService = SyncService(
        firestore: fakeFirestore,
        logRecordService: logService,
        legacyAdapter: fakeLegacyAdapter,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final now = DateTime.now();

      Future<void> seedRemote(String accountId, String logId) async {
        await fakeFirestore
            .collection('accounts')
            .doc(accountId)
            .collection('logs')
            .doc(logId)
            .set({
              'logId': logId,
              'accountId': accountId,
              'eventAt': now.toIso8601String(),
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
              'eventType': EventType.vape.name,
              'duration': 10,
              'unit': Unit.seconds.name,
              'source': Source.manual.name,
              'timeConfidence': TimeConfidence.high.name,
              'isDeleted': false,
              'revision': 0,
            });
      }

      await seedRemote('account-a', 'remote-a-1');
      await seedRemote('account-a', 'remote-a-2');
      await seedRemote('account-b', 'remote-b-1');

      final result = await syncService.pullRecordsForAccount(
        accountId: 'account-a',
      );

      expect(result.success, 2);
      final accountARecords = await repo.getByAccount('account-a');
      final accountBRecords = await repo.getByAccount('account-b');

      expect(accountARecords.length, 2);
      expect(accountARecords.every((r) => r.accountId == 'account-a'), isTrue);
      expect(accountBRecords, isEmpty);
    });
  });
}
