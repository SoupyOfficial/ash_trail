import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('LogRecord Model', () {
    test('creates log record with all fields', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        profileId: 'profile-456',
        eventAt: DateTime(2025, 1, 1, 10, 0),
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 10, 0),
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        tagsString: 'morning,sativa',
        source: Source.manual,
        deviceId: 'device-789',
        appVersion: '1.0.0',
      );

      expect(record.logId, 'test-log-123');
      expect(record.accountId, 'account-123');
      expect(record.profileId, 'profile-456');
      expect(record.eventType, EventType.inhale);
      expect(record.value, 1.0);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test note');
      expect(record.source, Source.manual);
      expect(record.syncState, SyncState.pending);
      expect(record.isDeleted, false);
    });

    test('handles tags correctly', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      // Set tags using list
      record.tags = ['morning', 'sativa', 'relaxation'];

      expect(record.tagsString, 'morning,sativa,relaxation');
      expect(record.tags, ['morning', 'sativa', 'relaxation']);

      // Get tags as list
      final tags = record.tags;
      expect(tags.length, 3);
      expect(tags[0], 'morning');
    });

    test('handles empty tags', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      expect(record.tags, isEmpty);

      record.tags = [];
      expect(record.tags, isEmpty);
    });

    test('markDirty updates sync state and revision', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      expect(record.revision, 0);
      expect(record.syncState, SyncState.pending);

      record.markDirty(['note', 'value']);

      expect(record.revision, 1);
      expect(record.syncState, SyncState.pending);
      expect(record.dirtyFields, isNotNull);
      expect(record.dirtyFields!.contains('note'), true);
      expect(record.dirtyFields!.contains('value'), true);
    });

    test('markSynced clears sync fields', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        syncState: SyncState.pending,
        dirtyFields: 'note,value',
        syncError: 'Previous error',
      );

      final remoteTime = DateTime(2025, 1, 1, 12, 0);
      record.markSynced(remoteTime);

      expect(record.syncState, SyncState.synced);
      expect(record.syncedAt, isNotNull);
      expect(record.lastRemoteUpdateAt, remoteTime);
      expect(record.syncError, null);
      expect(record.dirtyFields, null);
    });

    test('markSyncError sets error state', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      record.markSyncError('Network timeout');

      expect(record.syncState, SyncState.error);
      expect(record.syncError, 'Network timeout');
    });

    test('softDelete marks record as deleted', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      expect(record.isDeleted, false);
      expect(record.deletedAt, null);

      record.softDelete();

      expect(record.isDeleted, true);
      expect(record.deletedAt, isNotNull);
      expect(record.syncState, SyncState.pending);
      expect(record.revision, 1);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        value: 1.0,
        note: 'Original note',
      );

      final copy = original.copyWith(value: 2.0, note: 'Updated note');

      expect(copy.logId, original.logId);
      expect(copy.accountId, original.accountId);
      expect(copy.value, 2.0);
      expect(copy.note, 'Updated note');
      expect(original.value, 1.0); // Original unchanged
      expect(original.note, 'Original note');
    });

    test('toFirestore converts to map correctly', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        profileId: 'profile-456',
        eventAt: DateTime(2025, 1, 1, 10, 0),
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 10, 0),
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        tagsString: 'morning,sativa',
        source: Source.manual,
        deviceId: 'device-789',
        appVersion: '1.0.0',
      );

      final map = record.toFirestore();

      expect(map['logId'], 'test-log-123');
      expect(map['accountId'], 'account-123');
      expect(map['profileId'], 'profile-456');
      expect(map['eventType'], 'inhale');
      expect(map['value'], 1.0);
      expect(map['unit'], 'hits');
      expect(map['note'], 'Test note');
      expect(map['tags'], ['morning', 'sativa']);
      expect(map['source'], 'manual');
      expect(map['deviceId'], 'device-789');
      expect(map['appVersion'], '1.0.0');
    });

    test('fromFirestore creates record from map', () {
      final map = {
        'logId': 'test-log-123',
        'accountId': 'account-123',
        'profileId': 'profile-456',
        'eventAt': '2025-01-01T10:00:00.000',
        'createdAt': '2025-01-01T10:00:00.000',
        'updatedAt': '2025-01-01T10:00:00.000',
        'eventType': 'inhale',
        'value': 1.0,
        'unit': 'hits',
        'note': 'Test note',
        'tags': ['morning', 'sativa'],
        'source': 'manual',
        'deviceId': 'device-789',
        'appVersion': '1.0.0',
        'isDeleted': false,
        'revision': 0,
      };

      final record = LogRecord.fromFirestore(map);

      expect(record.logId, 'test-log-123');
      expect(record.accountId, 'account-123');
      expect(record.profileId, 'profile-456');
      expect(record.eventType, EventType.inhale);
      expect(record.value, 1.0);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test note');
      expect(record.tags, ['morning', 'sativa']);
      expect(record.source, Source.manual);
      expect(record.syncState, SyncState.synced);
    });

    test('roundtrip toFirestore and fromFirestore', () {
      final original = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        tagsString: 'tag1,tag2',
      );

      final map = original.toFirestore();
      final restored = LogRecord.fromFirestore(map);

      expect(restored.logId, original.logId);
      expect(restored.accountId, original.accountId);
      expect(restored.eventType, original.eventType);
      expect(restored.value, original.value);
      expect(restored.unit, original.unit);
      expect(restored.note, original.note);
      expect(restored.tags, original.tags);
    });
  });
}
