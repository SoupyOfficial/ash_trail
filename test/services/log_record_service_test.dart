import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/repositories/log_record_repository_hive.dart';

void main() {
  late Box box;
  late LogRecordRepositoryHive repository;
  late LogRecordService service;

  setUp(() async {
    // Initialize Hive for testing (in-memory)
    Hive.init('test_data_${DateTime.now().millisecondsSinceEpoch}');

    // Create in-memory box for testing
    box = await Hive.openBox(
      'test_log_records_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Create repository with test box
    repository = LogRecordRepositoryHive({'logRecords': box});

    // Inject repository into service for testing
    service = LogRecordService(repository: repository);
  });

  tearDown(() async {
    // Dispose repository to cancel stream subscriptions
    repository.dispose();
    // Close box
    await box.clear();
    await box.close();
  });

  group('LogRecordService - Create', () {
    test('creates log record with all fields', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        profileId: 'test-profile',
        eventType: EventType.inhale,
        eventAt: DateTime(2025, 1, 1, 10, 0),
        value: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        tags: ['test', 'morning'],
        sessionId: 'session-123',
      );

      expect(record.accountId, 'test-account');
      expect(record.profileId, 'test-profile');
      expect(record.eventType, EventType.inhale);
      expect(record.value, 1.0);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test note');
      expect(record.tags, ['test', 'morning']);
      expect(record.sessionId, 'session-123');
      expect(record.syncState, SyncState.pending);
      expect(record.isDeleted, false);
      expect(record.logId.isNotEmpty, true);
    });

    test('creates log record with minimal fields', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      expect(record.accountId, 'test-account');
      expect(record.eventType, EventType.note);
      expect(record.syncState, SyncState.pending);
      expect(record.value, null);
      expect(record.note, null);
    });

    test('generates unique logId for each record', () async {
      final record1 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final record2 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      expect(record1.logId, isNot(record2.logId));
    });

    test('sets timestamps correctly', () async {
      final before = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 10));

      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final after = DateTime.now();

      expect(record.createdAt.isAfter(before), true);
      expect(record.createdAt.isBefore(after), true);
      expect(record.updatedAt.isAfter(before), true);
      expect(record.updatedAt.isBefore(after), true);
    });
  });

  group('LogRecordService - Read', () {
    test('gets log record by logId', () async {
      final created = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final retrieved = await service.getLogRecordByLogId(created.logId);

      expect(retrieved, isNotNull);
      expect(retrieved!.logId, created.logId);
      expect(retrieved.accountId, created.accountId);
    });

    test('returns null for non-existent logId', () async {
      final retrieved = await service.getLogRecordByLogId('non-existent');
      expect(retrieved, null);
    });

    test('gets log records with filters', () async {
      // Create test records
      await service.createLogRecord(
        accountId: 'account1',
        eventType: EventType.inhale,
        eventAt: DateTime(2025, 1, 1),
      );

      await service.createLogRecord(
        accountId: 'account1',
        eventType: EventType.note,
        eventAt: DateTime(2025, 1, 2),
      );

      await service.createLogRecord(
        accountId: 'account2',
        eventType: EventType.inhale,
        eventAt: DateTime(2025, 1, 1),
      );

      // Query by account
      final account1Records = await service.getLogRecords(
        accountId: 'account1',
      );
      expect(account1Records.length, 2);

      // Query with date filter
      final dateFiltered = await service.getLogRecords(
        accountId: 'account1',
        startDate: DateTime(2025, 1, 2),
      );
      expect(dateFiltered.length, 1);
      expect(dateFiltered.first.eventType, EventType.note);

      // Query with event type filter
      final typeFiltered = await service.getLogRecords(
        accountId: 'account1',
        eventTypes: [EventType.inhale],
      );
      expect(typeFiltered.length, 1);
      expect(typeFiltered.first.eventType, EventType.inhale);
    });

    test('counts log records correctly', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      final count = await service.countLogRecords(accountId: 'test-account');
      expect(count, 2);
    });

    test('gets log records by session', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.sessionStart,
        sessionId: 'session-1',
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        sessionId: 'session-1',
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        sessionId: 'session-2',
      );

      final session1Records = await service.getLogRecordsBySession('session-1');
      expect(session1Records.length, 2);
    });
  });

  group('LogRecordService - Update', () {
    test('updates log record fields', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        note: 'Original note',
      );

      final updated = await service.updateLogRecord(
        record,
        value: 2.0,
        note: 'Updated note',
        tags: ['updated'],
      );

      expect(updated.value, 2.0);
      expect(updated.note, 'Updated note');
      expect(updated.tags, ['updated']);
      expect(updated.syncState, SyncState.pending);
      expect(updated.revision, 1);
    });

    test('tracks dirty fields on update', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final updated = await service.updateLogRecord(
        record,
        note: 'New note',
        value: 1.0,
      );

      expect(updated.dirtyFields, isNotNull);
      expect(updated.dirtyFields!.contains('note'), true);
      expect(updated.dirtyFields!.contains('value'), true);
    });

    test('increments revision on update', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      expect(record.revision, 0);

      final updated1 = await service.updateLogRecord(record, note: 'Update 1');
      expect(updated1.revision, 1);

      final updated2 = await service.updateLogRecord(
        updated1,
        note: 'Update 2',
      );
      expect(updated2.revision, 2);
    });
  });

  group('LogRecordService - Delete', () {
    test('soft deletes log record', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await service.deleteLogRecord(record);

      final retrieved = await service.getLogRecordByLogId(record.logId);
      expect(retrieved!.isDeleted, true);
      expect(retrieved.deletedAt, isNotNull);
      expect(retrieved.syncState, SyncState.pending);
    });

    test('soft deleted records not included by default', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final record2 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      await service.deleteLogRecord(record2);

      final records = await service.getLogRecords(
        accountId: 'test-account',
        includeDeleted: false,
      );

      expect(records.length, 1);
      expect(records.first.eventType, EventType.inhale);
    });

    test('soft deleted records included when requested', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final record2 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      await service.deleteLogRecord(record2);

      final records = await service.getLogRecords(
        accountId: 'test-account',
        includeDeleted: true,
      );

      expect(records.length, 2);
    });

    test('restores soft deleted record', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
        note: 'Test note',
      );

      // Delete the record
      await service.deleteLogRecord(record);

      final deleted = await service.getLogRecordByLogId(record.logId);
      expect(deleted!.isDeleted, true);
      expect(deleted.deletedAt, isNotNull);

      // Restore the record
      await service.restoreDeleted(deleted);

      final restored = await service.getLogRecordByLogId(record.logId);
      expect(restored!.isDeleted, false);
      expect(restored.deletedAt, null);
      expect(restored.value, 2.0);
      expect(restored.note, 'Test note');
    });

    test('restored records appear in default queries', () async {
      final record1 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      final record2 = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      // Delete and restore record2
      await service.deleteLogRecord(record2);
      final deleted = await service.getLogRecordByLogId(record2.logId);
      await service.restoreDeleted(deleted!);

      // Both records should be in default query
      final records = await service.getLogRecords(
        accountId: 'test-account',
        includeDeleted: false,
      );

      expect(records.length, 2);
      expect(records.any((r) => r.logId == record1.logId), true);
      expect(records.any((r) => r.logId == record2.logId), true);
    });

    test('restore marks dirty fields for sync', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await service.deleteLogRecord(record);
      final deleted = await service.getLogRecordByLogId(record.logId);

      await service.restoreDeleted(deleted!);

      final restored = await service.getLogRecordByLogId(record.logId);
      expect(restored!.dirtyFields, isNotNull);
      expect(restored.dirtyFields!.contains('isDeleted'), true);
      expect(restored.dirtyFields!.contains('deletedAt'), true);
    });
  });

  group('LogRecordService - Sync', () {
    test('gets pending sync records', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
      );

      final pendingRecords = await service.getPendingSync();
      expect(pendingRecords.length, 2);
      expect(
        pendingRecords.every((r) => r.syncState == SyncState.pending),
        true,
      );
    });

    test('marks record as synced', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      expect(record.syncState, SyncState.pending);

      final remoteUpdateTime = DateTime.now();
      await service.markSynced(record, remoteUpdateTime);

      final updated = await service.getLogRecordByLogId(record.logId);
      expect(updated!.syncState, SyncState.synced);
      expect(updated.syncedAt, isNotNull);
      expect(updated.lastRemoteUpdateAt, remoteUpdateTime);
      expect(updated.syncError, null);
    });

    test('marks record with sync error', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
      );

      await service.markSyncError(record, 'Network error');

      final updated = await service.getLogRecordByLogId(record.logId);
      expect(updated!.syncState, SyncState.error);
      expect(updated.syncError, 'Network error');
    });
  });

  group('LogRecordService - Batch Operations', () {
    test('batch creates multiple records', () async {
      final recordsData = [
        {
          'accountId': 'test-account',
          'eventType': EventType.inhale,
          'value': 1.0,
          'unit': Unit.hits,
        },
        {
          'accountId': 'test-account',
          'eventType': EventType.note,
          'note': 'Test note',
        },
        {'accountId': 'test-account', 'eventType': EventType.sessionStart},
      ];

      final records = await service.batchCreateLogRecords(recordsData);

      expect(records.length, 3);
      expect(records[0].eventType, EventType.inhale);
      expect(records[1].eventType, EventType.note);
      expect(records[2].eventType, EventType.sessionStart);
    });
  });

  group('LogRecordService - Duration Recording', () {
    test('creates duration log with correct values', () async {
      final durationMs = 5327; // 5.327 seconds
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: durationMs,
        eventType: EventType.inhale,
      );

      expect(record.accountId, 'test-account');
      expect(record.eventType, EventType.inhale);
      expect(record.unit, Unit.seconds);
      expect(record.value, closeTo(5.327, 0.001));
      expect(record.timeConfidence, TimeConfidence.high);
      expect(record.syncState, SyncState.pending);
      expect(record.isDeleted, false);
    });

    test('converts duration milliseconds to seconds correctly', () async {
      // Test various durations
      final testCases = [
        (1000, 1.0), // Exactly 1 second
        (1500, 1.5), // 1.5 seconds
        (10000, 10.0), // 10 seconds
        (3456, 3.456), // 3.456 seconds
        (60000, 60.0), // 1 minute
      ];

      for (final (durationMs, expectedSeconds) in testCases) {
        final record = await service.recordDurationLog(
          accountId: 'test-account',
          durationMs: durationMs,
        );

        expect(
          record.value,
          closeTo(expectedSeconds, 0.001),
          reason: '${durationMs}ms should convert to ${expectedSeconds}s',
        );
        expect(record.unit, Unit.seconds);
      }
    });

    test('enforces minimum duration threshold', () async {
      // Less than 1 second should throw
      expect(
        () => service.recordDurationLog(
          accountId: 'test-account',
          durationMs: 500, // 0.5 seconds
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => service.recordDurationLog(
          accountId: 'test-account',
          durationMs: 999, // 0.999 seconds
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Exactly 1 second should succeed
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 1000,
      );
      expect(record.value, 1.0);
    });

    test('sets timestamp to current time (release time)', () async {
      final before = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 10));

      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 5000,
      );

      await Future.delayed(const Duration(milliseconds: 10));
      final after = DateTime.now();

      expect(record.eventAt.isAfter(before), true);
      expect(record.eventAt.isBefore(after), true);
      expect(record.createdAt.isAfter(before), true);
      expect(record.createdAt.isBefore(after), true);
    });

    test('includes optional fields when provided', () async {
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 8000,
        profileId: 'test-profile',
        eventType: EventType.sessionStart,
        tags: ['morning', 'focus'],
        note: 'Recorded with hold gesture',
        location: 'Home',
      );

      expect(record.profileId, 'test-profile');
      expect(record.eventType, EventType.sessionStart);
      expect(record.tags, ['morning', 'focus']);
      expect(record.note, 'Recorded with hold gesture');
      expect(record.location, 'Home');
    });

    test('defaults to inhale event type when not specified', () async {
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 3000,
      );

      expect(record.eventType, EventType.inhale);
    });

    test('clamps extremely long durations', () async {
      // Test 2 hours (should be clamped by ValidationService)
      final twoHoursMs = 2 * 60 * 60 * 1000;
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: twoHoursMs,
      );

      // Expect ValidationService to clamp to max duration (likely 1 hour = 3600s)
      expect(record.value, lessThanOrEqualTo(3600.0));
      expect(record.unit, Unit.seconds);
    });

    test('multiple duration logs have unique IDs', () async {
      final record1 = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 2000,
      );

      final record2 = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 3000,
      );

      expect(record1.logId, isNot(record2.logId));
      expect(record1.id, isNot(record2.id));
    });

    test('duration logs can be retrieved like other logs', () async {
      await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 5000,
      );

      await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 10000,
      );

      final records = await service.getLogRecords(accountId: 'test-account');

      expect(records.length, 2);
      expect(records[0].unit, Unit.seconds);
      expect(records[1].unit, Unit.seconds);
    });

    test('duration logs can be soft deleted', () async {
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 7000,
      );

      await service.deleteLogRecord(record);

      final deletedRecord = await service.getLogRecordByLogId(record.logId);
      expect(deletedRecord!.isDeleted, true);
      expect(deletedRecord.deletedAt, isNotNull);
    });

    test('duration logs are marked for sync', () async {
      final record = await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 4000,
      );

      expect(record.syncState, SyncState.pending);

      final pendingRecords = await service.getPendingSync();
      expect(pendingRecords.any((r) => r.logId == record.logId), true);
    });
  });

  group('LogRecordService - Statistics', () {
    test('computes statistics correctly', () async {
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 2.0,
        eventAt: DateTime(2025, 1, 1, 11, 0),
      );

      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        eventAt: DateTime(2025, 1, 1, 12, 0),
      );

      final stats = await service.getStatistics(accountId: 'test-account');

      expect(stats['totalCount'], 3);
      expect(stats['totalValue'], 3.0);
      expect(stats['averageValue'], 1.0);
      expect((stats['eventTypeCounts'] as Map)[EventType.inhale], 2);
      expect((stats['eventTypeCounts'] as Map)[EventType.note], 1);
    });

    test('includes duration logs in statistics', () async {
      // Create regular log
      await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        eventAt: DateTime(2025, 1, 1, 10, 0),
      );

      // Create duration logs
      await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 5000, // 5 seconds
      );

      await service.recordDurationLog(
        accountId: 'test-account',
        durationMs: 10000, // 10 seconds
      );

      final stats = await service.getStatistics(accountId: 'test-account');

      expect(stats['totalCount'], 3);
      expect(stats['totalValue'], closeTo(16.0, 0.1)); // 1 + 5 + 10
      expect(stats['averageValue'], closeTo(5.33, 0.1));
    });
  });
}
