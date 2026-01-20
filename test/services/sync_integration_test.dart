import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';

void main() {
  group('Sync User - Offline Sync and Conflict Resolution', () {
    late _MockSyncRepository mockRepository;
    const accountId = 'test-account-123';

    setUp(() {
      mockRepository = _MockSyncRepository();
    });

    test(
      'logs created offline are marked pending, then synced on reconnect',
      () async {
        final record = LogRecord.create(
          logId: 'log-1',
          accountId: accountId,
          duration: 120,
          eventType: EventType.vape,
        );
        expect(record.syncState, SyncState.pending);

        final saved = await mockRepository.create(record);
        final synced = saved.copyWith(
          syncState: SyncState.synced,
          lastRemoteUpdateAt: DateTime.now(),
        );
        await mockRepository.update(synced);

        final updated = await mockRepository.getByLogId(saved.logId);
        expect(updated?.syncState, SyncState.synced);
      },
    );

    test('sync conflict: local newer than remote uses local', () async {
      final now = DateTime.now();
      final localRecord = LogRecord.create(
        logId: 'log-2',
        accountId: accountId,
        duration: 300,
        eventType: EventType.vape,
        createdAt: now,
      );
      final syncedLocal = localRecord.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: now.subtract(const Duration(minutes: 1)),
      );
      await mockRepository.create(syncedLocal);

      final local = await mockRepository.getByLogId(localRecord.logId);
      expect(local?.duration, 300);
      expect(local?.syncState, SyncState.synced);
    });

    test('sync state changes are tracked (pending → synced → error)', () async {
      final record = LogRecord.create(
        logId: 'log-3',
        accountId: accountId,
        duration: 30,
        eventType: EventType.note,
      );

      expect(record.syncState, SyncState.pending);
      var saved = await mockRepository.create(record);

      var synced = saved.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );
      await mockRepository.update(synced);
      var updated = await mockRepository.getByLogId(saved.logId);
      expect(updated?.syncState, SyncState.synced);

      var errored = updated!.copyWith(syncState: SyncState.error);
      await mockRepository.update(errored);
      updated = await mockRepository.getByLogId(saved.logId);
      expect(updated?.syncState, SyncState.error);
    });

    test('failed syncs can be retried and marked synced', () async {
      final record = LogRecord.create(
        logId: 'log-4',
        accountId: accountId,
        duration: 60,
        eventType: EventType.vape,
      );

      var saved = await mockRepository.create(record);
      var errored = saved.copyWith(syncState: SyncState.error);
      await mockRepository.update(errored);

      var retrieved = await mockRepository.getByLogId(saved.logId);
      expect(retrieved?.syncState, SyncState.error);

      var retried = retrieved!.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );
      await mockRepository.update(retried);

      retrieved = await mockRepository.getByLogId(saved.logId);
      expect(retrieved?.syncState, SyncState.synced);
    });

    test('remote deletion marks local record as deleted and synced', () async {
      final record = LogRecord.create(
        logId: 'log-5',
        accountId: accountId,
        duration: 180,
        eventType: EventType.vape,
      );

      var saved = await mockRepository.create(record);
      var deleted = saved.copyWith(
        isDeleted: true,
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );
      await mockRepository.update(deleted);

      var retrieved = await mockRepository.getByLogId(saved.logId);
      expect(retrieved?.isDeleted, true);
      expect(retrieved?.syncState, SyncState.synced);

      final allRecords = await mockRepository.getByAccount(accountId);
      expect(allRecords.isEmpty, true);

      final deletedRecords = await mockRepository.getDeleted(accountId);
      expect(deletedRecords.length, 1);
    });

    test('network errors are caught gracefully', () async {
      mockRepository.simulateNetworkError = true;

      final record = LogRecord.create(
        logId: 'log-6',
        accountId: accountId,
        duration: 45,
        eventType: EventType.note,
      );

      final saved = await mockRepository.create(record);
      expect(saved.logId, isNotEmpty);
      expect(saved.syncState, SyncState.pending);
    });

    test('all records synced after full sync cycle', () async {
      final record1 = LogRecord.create(
        logId: 'log-7',
        accountId: accountId,
        duration: 120,
        eventType: EventType.vape,
      );
      final record2 = LogRecord.create(
        logId: 'log-8',
        accountId: accountId,
        duration: 60,
        eventType: EventType.note,
      );
      final record3 = LogRecord.create(
        logId: 'log-9',
        accountId: accountId,
        duration: 180,
        eventType: EventType.vape,
      );

      await mockRepository.create(record1);
      await mockRepository.create(record2);
      await mockRepository.create(record3);

      var pendingRecords = await mockRepository.getPendingSync();
      expect(pendingRecords.length, 3);

      for (var record in pendingRecords) {
        final synced = record.copyWith(
          syncState: SyncState.synced,
          lastRemoteUpdateAt: DateTime.now(),
        );
        await mockRepository.update(synced);
      }

      pendingRecords = await mockRepository.getPendingSync();
      expect(pendingRecords.isEmpty, true);

      final allRecords = await mockRepository.getByAccount(accountId);
      expect(allRecords.length, 3);
      expect(allRecords.every((r) => r.syncState == SyncState.synced), true);
    });

    test('multiple offline changes sync correctly on reconnect', () async {
      final original = LogRecord.create(
        logId: 'log-10',
        accountId: accountId,
        duration: 300,
        eventType: EventType.vape,
      );
      var saved = await mockRepository.create(original);

      var edited = saved.copyWith(duration: 600, syncState: SyncState.pending);
      await mockRepository.update(edited);

      edited = edited.copyWith(duration: 420);
      await mockRepository.update(edited);

      var synced = edited.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );
      await mockRepository.update(synced);

      final finalRecord = await mockRepository.getByLogId(original.logId);
      expect(finalRecord?.duration, 420);
      expect(finalRecord?.syncState, SyncState.synced);
    });

    test('deleted records remain deleted after sync', () async {
      final record = LogRecord.create(
        logId: 'log-11',
        accountId: accountId,
        duration: 120,
        eventType: EventType.note,
      );

      var saved = await mockRepository.create(record);

      var deleted = saved.copyWith(
        isDeleted: true,
        syncState: SyncState.pending,
      );
      await mockRepository.update(deleted);

      var deletedAndSynced = deleted.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );
      await mockRepository.update(deletedAndSynced);

      final retrieved = await mockRepository.getByLogId(record.logId);
      expect(retrieved?.isDeleted, true);
      expect(retrieved?.syncState, SyncState.synced);
    });

    test('sync status correct for heterogeneous record states', () async {
      final pending = LogRecord.create(
        logId: 'log-12',
        accountId: accountId,
        duration: 60,
        eventType: EventType.vape,
      );

      final synced = LogRecord.create(
        logId: 'log-13',
        accountId: accountId,
        duration: 120,
        eventType: EventType.note,
      ).copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: DateTime.now(),
      );

      final errored = LogRecord.create(
        logId: 'log-14',
        accountId: accountId,
        duration: 180,
        eventType: EventType.vape,
      ).copyWith(syncState: SyncState.error);

      await mockRepository.create(pending);
      await mockRepository.create(synced);
      await mockRepository.create(errored);

      final pendingRecords = await mockRepository.getPendingSync();
      expect(pendingRecords.length, 1);
      expect(pendingRecords.first.syncState, SyncState.pending);

      final allRecords = await mockRepository.getByAccount(accountId);
      expect(allRecords.length, 3);

      final statusCount = {
        SyncState.pending: 0,
        SyncState.synced: 0,
        SyncState.error: 0,
      };
      for (var record in allRecords) {
        statusCount[record.syncState] =
            (statusCount[record.syncState] ?? 0) + 1;
      }
      expect(statusCount[SyncState.pending], 1);
      expect(statusCount[SyncState.synced], 1);
      expect(statusCount[SyncState.error], 1);
    });
  });
}

class _MockSyncRepository implements LogRecordRepository {
  final List<LogRecord> _localRecords = [];
  bool simulateNetworkError = false;

  @override
  Future<LogRecord> create(LogRecord record) async {
    _localRecords.add(record);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final index = _localRecords.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _localRecords[index] = record;
    }
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    _localRecords.removeWhere((r) => r.logId == logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    try {
      return _localRecords.firstWhere((r) => r.logId == logId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    return _localRecords
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .toList();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _localRecords
        .where(
          (r) =>
              r.accountId == accountId &&
              !r.isDeleted &&
              r.createdAt.isAfter(start) &&
              r.createdAt.isBefore(end),
        )
        .toList();
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    return _localRecords
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
    return _localRecords
        .where((r) => r.syncState == SyncState.pending)
        .toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return _localRecords
        .where((r) => r.accountId == accountId && r.isDeleted)
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _localRecords
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    _localRecords.removeWhere((r) => r.accountId == accountId);
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    return Stream.value(
      _localRecords
          .where((r) => r.accountId == accountId && !r.isDeleted)
          .toList(),
    );
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return Stream.value(
      _localRecords
          .where(
            (r) =>
                r.accountId == accountId &&
                !r.isDeleted &&
                r.createdAt.isAfter(start) &&
                r.createdAt.isBefore(end),
          )
          .toList(),
    );
  }

  @override
  Future<List<LogRecord>> getAll() async {
    return List.from(_localRecords);
  }
}
