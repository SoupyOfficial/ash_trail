/// Unit tests for LogRecordRepository
/// Uses in-memory implementation to test repository interface behavior
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';
import 'package:uuid/uuid.dart';

/// In-memory implementation of LogRecordRepository for testing
class InMemoryLogRecordRepository implements LogRecordRepository {
  final Map<String, LogRecord> _records = {};
  final _accountStreamControllers = <String, StreamController<List<LogRecord>>>{};

  @override
  Future<LogRecord> create(LogRecord record) async {
    _records[record.logId] = record.copyWith();
    _notifyAccount(record.accountId);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    _records[record.logId] = record.copyWith();
    _notifyAccount(record.accountId);
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    final record = _records[logId];
    _records.remove(logId);
    if (record != null) {
      _notifyAccount(record.accountId);
    }
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    return _records[logId]?.copyWith();
  }

  @override
  Future<List<LogRecord>> getAll() async {
    return _records.values.map((r) => r.copyWith()).toList();
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    return _records.values
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .map((r) => r.copyWith())
        .toList();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _records.values
        .where((r) =>
            r.accountId == accountId &&
            !r.isDeleted &&
            !r.eventAt.isBefore(start) &&
            !r.eventAt.isAfter(end))
        .map((r) => r.copyWith())
        .toList();
  }

  @override
  Future<List<LogRecord>> getByEventType(String accountId, EventType eventType) async {
    return _records.values
        .where((r) => r.accountId == accountId && r.eventType == eventType && !r.isDeleted)
        .map((r) => r.copyWith())
        .toList();
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    return _records.values
        .where((r) => r.syncState == SyncState.pending)
        .map((r) => r.copyWith())
        .toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return _records.values
        .where((r) => r.accountId == accountId && r.isDeleted)
        .map((r) => r.copyWith())
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _records.values
        .where((r) => r.accountId == accountId && !r.isDeleted)
        .length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    final keysToRemove =
        _records.entries.where((e) => e.value.accountId == accountId).map((e) => e.key).toList();
    for (final key in keysToRemove) {
      _records.remove(key);
    }
    _notifyAccount(accountId);
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    _accountStreamControllers[accountId] ??=
        StreamController<List<LogRecord>>.broadcast();
    return _accountStreamControllers[accountId]!.stream;
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return watchByAccount(accountId).map((records) => records
        .where((r) => !r.eventAt.isBefore(start) && !r.eventAt.isAfter(end))
        .toList());
  }

  void _notifyAccount(String accountId) async {
    final controller = _accountStreamControllers[accountId];
    if (controller != null && !controller.isClosed) {
      controller.add(await getByAccount(accountId));
    }
  }

  void dispose() {
    for (final controller in _accountStreamControllers.values) {
      controller.close();
    }
  }
}

void main() {
  late InMemoryLogRecordRepository repository;
  const uuid = Uuid();

  LogRecord _createTestRecord({
    String? logId,
    String accountId = 'account-1',
    EventType eventType = EventType.vape,
    DateTime? eventAt,
    String? note,
    SyncState syncState = SyncState.pending,
    bool isDeleted = false,
  }) {
    return LogRecord.create(
      logId: logId ?? uuid.v4(),
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt ?? DateTime(2024, 1, 15),
      note: note,
      syncState: syncState,
      isDeleted: isDeleted,
    );
  }

  setUp(() {
    repository = InMemoryLogRecordRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('LogRecordRepository - CRUD Operations', () {
    test('create() stores new log record', () async {
      final record = _createTestRecord(logId: 'log-1');

      final created = await repository.create(record);

      expect(created.logId, equals('log-1'));
      expect(created.accountId, equals('account-1'));
    });

    test('create() with generated logId works', () async {
      final record = _createTestRecord();
      await repository.create(record);

      expect(record.logId, isNotEmpty);
    });

    test('update() modifies existing record', () async {
      final record = _createTestRecord(logId: 'log-1', note: 'Original');
      await repository.create(record);

      final updated = record.copyWith(note: 'Updated');
      await repository.update(updated);

      final retrieved = await repository.getByLogId('log-1');
      expect(retrieved?.note, equals('Updated'));
    });

    test('delete() removes record', () async {
      final record = _createTestRecord(logId: 'log-1');
      await repository.create(record);

      await repository.delete('log-1');

      final retrieved = await repository.getByLogId('log-1');
      expect(retrieved, isNull);
    });

    test('getByLogId() returns null for non-existent', () async {
      final result = await repository.getByLogId('non-existent');

      expect(result, isNull);
    });

    test('getByLogId() returns correct record', () async {
      await repository.create(_createTestRecord(logId: 'log-1', note: 'First'));
      await repository.create(_createTestRecord(logId: 'log-2', note: 'Second'));

      final result = await repository.getByLogId('log-2');

      expect(result?.note, equals('Second'));
    });

    test('getAll() returns all records', () async {
      await repository.create(_createTestRecord(logId: 'log-1'));
      await repository.create(_createTestRecord(logId: 'log-2'));
      await repository.create(_createTestRecord(logId: 'log-3'));

      final all = await repository.getAll();

      expect(all.length, equals(3));
    });
  });

  group('LogRecordRepository - Account Filtering', () {
    test('getByAccount() returns only records for specified account', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-2'));
      await repository.create(_createTestRecord(logId: 'log-3', accountId: 'account-1'));

      final account1Records = await repository.getByAccount('account-1');

      expect(account1Records.length, equals(2));
      expect(account1Records.every((r) => r.accountId == 'account-1'), isTrue);
    });

    test('getByAccount() excludes deleted records', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-1', isDeleted: true));

      final records = await repository.getByAccount('account-1');

      expect(records.length, equals(1));
    });

    test('countByAccount() returns correct count', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-3', accountId: 'account-2'));

      final count = await repository.countByAccount('account-1');

      expect(count, equals(2));
    });

    test('deleteByAccount() removes all records for account', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-3', accountId: 'account-2'));

      await repository.deleteByAccount('account-1');

      final account1Records = await repository.getByAccount('account-1');
      final account2Records = await repository.getByAccount('account-2');

      expect(account1Records, isEmpty);
      expect(account2Records.length, equals(1));
    });
  });

  group('LogRecordRepository - Date Range Filtering', () {
    test('getByDateRange() returns records within range', () async {
      await repository.create(_createTestRecord(
        logId: 'log-1',
        eventAt: DateTime(2024, 1, 10),
      ));
      await repository.create(_createTestRecord(
        logId: 'log-2',
        eventAt: DateTime(2024, 1, 15),
      ));
      await repository.create(_createTestRecord(
        logId: 'log-3',
        eventAt: DateTime(2024, 1, 20),
      ));

      final records = await repository.getByDateRange(
        'account-1',
        DateTime(2024, 1, 12),
        DateTime(2024, 1, 18),
      );

      expect(records.length, equals(1));
      expect(records.first.logId, equals('log-2'));
    });

    test('getByDateRange() includes boundary dates', () async {
      await repository.create(_createTestRecord(
        logId: 'log-1',
        eventAt: DateTime(2024, 1, 15),
      ));

      final records = await repository.getByDateRange(
        'account-1',
        DateTime(2024, 1, 15),
        DateTime(2024, 1, 15),
      );

      expect(records.length, equals(1));
    });

    test('getByDateRange() returns empty for out-of-range', () async {
      await repository.create(_createTestRecord(
        logId: 'log-1',
        eventAt: DateTime(2024, 1, 15),
      ));

      final records = await repository.getByDateRange(
        'account-1',
        DateTime(2024, 2, 1),
        DateTime(2024, 2, 28),
      );

      expect(records, isEmpty);
    });
  });

  group('LogRecordRepository - Event Type Filtering', () {
    test('getByEventType() filters by event type', () async {
      await repository.create(_createTestRecord(logId: 'log-1', eventType: EventType.vape));
      await repository.create(_createTestRecord(logId: 'log-2', eventType: EventType.inhale));
      await repository.create(_createTestRecord(logId: 'log-3', eventType: EventType.vape));

      final vapeRecords = await repository.getByEventType('account-1', EventType.vape);

      expect(vapeRecords.length, equals(2));
      expect(vapeRecords.every((r) => r.eventType == EventType.vape), isTrue);
    });

    test('getByEventType() returns empty when no matches', () async {
      await repository.create(_createTestRecord(logId: 'log-1', eventType: EventType.vape));

      final records = await repository.getByEventType('account-1', EventType.note);

      expect(records, isEmpty);
    });
  });

  group('LogRecordRepository - Sync Status', () {
    test('getPendingSync() returns only pending records', () async {
      await repository.create(_createTestRecord(logId: 'log-1', syncState: SyncState.pending));
      await repository.create(_createTestRecord(logId: 'log-2', syncState: SyncState.synced));
      await repository.create(_createTestRecord(logId: 'log-3', syncState: SyncState.pending));

      final pending = await repository.getPendingSync();

      expect(pending.length, equals(2));
      expect(pending.every((r) => r.syncState == SyncState.pending), isTrue);
    });
  });

  group('LogRecordRepository - Deleted Records', () {
    test('getDeleted() returns only deleted records for account', () async {
      await repository.create(_createTestRecord(logId: 'log-1', isDeleted: false));
      await repository.create(_createTestRecord(logId: 'log-2', isDeleted: true));
      await repository.create(_createTestRecord(logId: 'log-3', isDeleted: true));

      final deleted = await repository.getDeleted('account-1');

      expect(deleted.length, equals(2));
      expect(deleted.every((r) => r.isDeleted), isTrue);
    });
  });

  group('LogRecordRepository - Reactive Streams', () {
    test('watchByAccount() emits updates on create', () async {
      final stream = repository.watchByAccount('account-1');
      final emitted = <List<LogRecord>>[];
      final subscription = stream.listen(emitted.add);

      await Future.delayed(const Duration(milliseconds: 10));
      await repository.create(_createTestRecord(logId: 'log-1'));
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();

      expect(emitted.isNotEmpty, isTrue);
    });

    test('watchByAccount() emits updates on delete', () async {
      await repository.create(_createTestRecord(logId: 'log-1'));

      final stream = repository.watchByAccount('account-1');
      final emitted = <List<LogRecord>>[];
      final subscription = stream.listen(emitted.add);

      await Future.delayed(const Duration(milliseconds: 10));
      await repository.delete('log-1');
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();

      expect(emitted.isNotEmpty, isTrue);
    });
  });

  group('LogRecordRepository - Edge Cases', () {
    test('handles records with empty note', () async {
      final record = _createTestRecord(logId: 'log-1', note: '');
      await repository.create(record);

      final retrieved = await repository.getByLogId('log-1');
      expect(retrieved?.note, equals(''));
    });

    test('handles records with very long note', () async {
      final longNote = 'A' * 10000;
      final record = _createTestRecord(logId: 'log-1', note: longNote);
      await repository.create(record);

      final retrieved = await repository.getByLogId('log-1');
      expect(retrieved?.note?.length, equals(10000));
    });

    test('handles unicode in note', () async {
      final record = _createTestRecord(logId: 'log-1', note: '日本語のメモ 🎉 émoji');
      await repository.create(record);

      final retrieved = await repository.getByLogId('log-1');
      expect(retrieved?.note, equals('日本語のメモ 🎉 émoji'));
    });

    test('delete non-existent record does not throw', () async {
      // Should not throw
      await repository.delete('non-existent');
    });

    test('deleteByAccount on empty account does not throw', () async {
      // Should not throw
      await repository.deleteByAccount('non-existent-account');
    });
  });

  group('LogRecordRepository - Multiple Accounts', () {
    test('keeps records separate between accounts', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-2'));

      final account1 = await repository.getByAccount('account-1');
      final account2 = await repository.getByAccount('account-2');

      expect(account1.length, equals(1));
      expect(account2.length, equals(1));
      expect(account1.first.accountId, equals('account-1'));
      expect(account2.first.accountId, equals('account-2'));
    });

    test('countByAccount is account-specific', () async {
      await repository.create(_createTestRecord(logId: 'log-1', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-2', accountId: 'account-1'));
      await repository.create(_createTestRecord(logId: 'log-3', accountId: 'account-2'));

      expect(await repository.countByAccount('account-1'), equals(2));
      expect(await repository.countByAccount('account-2'), equals(1));
      expect(await repository.countByAccount('account-3'), equals(0));
    });
  });
}
