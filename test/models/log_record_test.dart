import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('LogRecord Model', () {
    test('creates log record with all fields', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventAt: DateTime(2025, 1, 1, 10, 0),
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 10, 0),
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        source: Source.manual,
        deviceId: 'device-789',
        appVersion: '1.0.0',
      );

      expect(record.logId, 'test-log-123');
      expect(record.accountId, 'account-123');
      expect(record.eventType, EventType.inhale);
      expect(record.duration, 1.0);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test note');
      expect(record.source, Source.manual);
      expect(record.syncState, SyncState.pending);
      expect(record.isDeleted, false);
    });

    test('handles location correctly', () {
      final recordWithLocation = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(recordWithLocation.hasLocation, true);
      expect(recordWithLocation.latitude, 37.7749);
      expect(recordWithLocation.longitude, -122.4194);

      final recordWithoutLocation = LogRecord.create(
        logId: 'test-log-124',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      expect(recordWithoutLocation.hasLocation, false);
    });

    test('markDirty updates sync state and revision', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
      );

      expect(record.revision, 0);
      expect(record.syncState, SyncState.pending);

      record.markDirty();

      expect(record.revision, 1);
      expect(record.syncState, SyncState.pending);
    });

    test('markSynced clears sync fields', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        syncState: SyncState.pending,
        syncError: 'Previous error',
      );

      final remoteTime = DateTime(2025, 1, 1, 12, 0);
      record.markSynced(remoteTime);

      expect(record.syncState, SyncState.synced);
      expect(record.syncedAt, isNotNull);
      expect(record.lastRemoteUpdateAt, remoteTime);
      expect(record.syncError, null);
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
        duration: 1.0,
        note: 'Original note',
      );

      final copy = original.copyWith(duration: 2.0, note: 'Updated note');

      expect(copy.logId, original.logId);
      expect(copy.accountId, original.accountId);
      expect(copy.duration, 2.0);
      expect(copy.note, 'Updated note');
      expect(original.duration, 1.0); // Original unchanged
      expect(original.note, 'Original note');
    });

    test('toFirestore converts to map correctly', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventAt: DateTime(2025, 1, 1, 10, 0),
        createdAt: DateTime(2025, 1, 1, 10, 0),
        updatedAt: DateTime(2025, 1, 1, 10, 0),
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Test note',
        source: Source.manual,
        deviceId: 'device-789',
        appVersion: '1.0.0',
      );

      final map = record.toFirestore();

      expect(map['logId'], 'test-log-123');
      expect(map['accountId'], 'account-123');
      expect(map['eventType'], 'inhale');
      expect(map['duration'], 1.0);
      expect(map['unit'], 'hits');
      expect(map['note'], 'Test note');
      expect(map['source'], 'manual');
      expect(map['deviceId'], 'device-789');
      expect(map['appVersion'], '1.0.0');
    });

    test('fromFirestore creates record from map', () {
      final map = {
        'logId': 'test-log-123',
        'accountId': 'account-123',
        'eventAt': '2025-01-01T10:00:00.000',
        'createdAt': '2025-01-01T10:00:00.000',
        'updatedAt': '2025-01-01T10:00:00.000',
        'eventType': 'inhale',
        'duration': 1.0,
        'unit': 'hits',
        'note': 'Test note',
        'source': 'manual',
        'deviceId': 'device-789',
        'appVersion': '1.0.0',
        'isDeleted': false,
        'revision': 0,
      };

      final record = LogRecord.fromFirestore(map);

      expect(record.logId, 'test-log-123');
      expect(record.accountId, 'account-123');
      expect(record.eventType, EventType.inhale);
      expect(record.duration, 1.0);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test note');
      expect(record.source, Source.manual);
      expect(record.syncState, SyncState.synced);
    });

    test('roundtrip toFirestore and fromFirestore', () {
      final original = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Test note',
      );

      final map = original.toFirestore();
      final restored = LogRecord.fromFirestore(map);

      expect(restored.logId, original.logId);
      expect(restored.accountId, original.accountId);
      expect(restored.eventType, original.eventType);
      expect(restored.duration, original.duration);
      expect(restored.unit, original.unit);
      expect(restored.note, original.note);
    });

    test('handles mood and physical ratings', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        moodRating: 7.5,
        physicalRating: 8.0,
      );

      expect(record.moodRating, 7.5);
      expect(record.physicalRating, 8.0);
    });

    test('handles reasons field', () {
      final record = LogRecord.create(
        logId: 'test-log-123',
        accountId: 'account-123',
        eventType: EventType.inhale,
        reasons: [LogReason.recreational, LogReason.social],
      );

      expect(record.reasons, [LogReason.recreational, LogReason.social]);
    });
  });

  group('LogRecord Transfer Metadata', () {
    test('creates record with transfer metadata', () {
      final transferredAt = DateTime(2025, 3, 15, 10, 0);
      final record = LogRecord.create(
        logId: 'transferred-log-1',
        accountId: 'target-account',
        eventType: EventType.vape,
        transferredFromAccountId: 'source-account',
        transferredAt: transferredAt,
        transferredFromLogId: 'original-log-id',
      );

      expect(record.transferredFromAccountId, 'source-account');
      expect(record.transferredAt, transferredAt);
      expect(record.transferredFromLogId, 'original-log-id');
    });

    test('creates record without transfer metadata by default', () {
      final record = LogRecord.create(
        logId: 'normal-log',
        accountId: 'account-123',
        eventType: EventType.vape,
      );

      expect(record.transferredFromAccountId, isNull);
      expect(record.transferredAt, isNull);
      expect(record.transferredFromLogId, isNull);
    });

    test('copyWith preserves transfer metadata', () {
      final transferredAt = DateTime(2025, 3, 15, 10, 0);
      final original = LogRecord.create(
        logId: 'transferred-log',
        accountId: 'target-account',
        eventType: EventType.vape,
        transferredFromAccountId: 'source-account',
        transferredAt: transferredAt,
        transferredFromLogId: 'original-log',
      );

      final copy = original.copyWith(note: 'Updated note');

      expect(copy.transferredFromAccountId, 'source-account');
      expect(copy.transferredAt, transferredAt);
      expect(copy.transferredFromLogId, 'original-log');
      expect(copy.note, 'Updated note');
    });

    test('copyWith can update transfer metadata', () {
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'account-1',
        eventType: EventType.vape,
      );

      final now = DateTime.now();
      final copy = record.copyWith(
        transferredFromAccountId: 'other-account',
        transferredAt: now,
        transferredFromLogId: 'old-log-id',
      );

      expect(copy.transferredFromAccountId, 'other-account');
      expect(copy.transferredAt, now);
      expect(copy.transferredFromLogId, 'old-log-id');
    });

    test('toFirestore includes transfer metadata', () {
      final transferredAt = DateTime(2025, 3, 15, 10, 0);
      final record = LogRecord.create(
        logId: 'transferred-log',
        accountId: 'target-account',
        eventType: EventType.vape,
        transferredFromAccountId: 'source-account',
        transferredAt: transferredAt,
        transferredFromLogId: 'original-log',
      );

      final map = record.toFirestore();

      expect(map['transferredFromAccountId'], 'source-account');
      expect(map['transferredAt'], transferredAt.toIso8601String());
      expect(map['transferredFromLogId'], 'original-log');
    });

    test('toFirestore has null transfer fields when not set', () {
      final record = LogRecord.create(
        logId: 'normal-log',
        accountId: 'account-123',
        eventType: EventType.vape,
      );

      final map = record.toFirestore();

      expect(map['transferredFromAccountId'], isNull);
      expect(map['transferredAt'], isNull);
      expect(map['transferredFromLogId'], isNull);
    });

    test('fromFirestore parses transfer metadata', () {
      final map = {
        'logId': 'transferred-log',
        'accountId': 'target-account',
        'eventAt': '2025-01-01T10:00:00.000',
        'createdAt': '2025-01-01T10:00:00.000',
        'updatedAt': '2025-01-01T10:00:00.000',
        'eventType': 'vape',
        'duration': 30.0,
        'isDeleted': false,
        'revision': 0,
        'transferredFromAccountId': 'source-account',
        'transferredAt': '2025-03-15T10:00:00.000',
        'transferredFromLogId': 'original-log',
      };

      final record = LogRecord.fromFirestore(map);

      expect(record.transferredFromAccountId, 'source-account');
      expect(record.transferredAt, DateTime(2025, 3, 15, 10, 0));
      expect(record.transferredFromLogId, 'original-log');
    });

    test('fromFirestore handles missing transfer metadata', () {
      final map = {
        'logId': 'normal-log',
        'accountId': 'account-123',
        'eventAt': '2025-01-01T10:00:00.000',
        'createdAt': '2025-01-01T10:00:00.000',
        'updatedAt': '2025-01-01T10:00:00.000',
        'eventType': 'vape',
        'duration': 30.0,
        'isDeleted': false,
        'revision': 0,
      };

      final record = LogRecord.fromFirestore(map);

      expect(record.transferredFromAccountId, isNull);
      expect(record.transferredAt, isNull);
      expect(record.transferredFromLogId, isNull);
    });

    test('roundtrip toFirestore/fromFirestore preserves transfer metadata', () {
      final transferredAt = DateTime(2025, 3, 15, 10, 0);
      final original = LogRecord.create(
        logId: 'roundtrip-transfer',
        accountId: 'target-account',
        eventType: EventType.vape,
        duration: 30.0,
        transferredFromAccountId: 'source-account',
        transferredAt: transferredAt,
        transferredFromLogId: 'original-log',
      );

      final map = original.toFirestore();
      final restored = LogRecord.fromFirestore(map);

      expect(
        restored.transferredFromAccountId,
        original.transferredFromAccountId,
      );
      expect(restored.transferredAt, original.transferredAt);
      expect(restored.transferredFromLogId, original.transferredFromLogId);
    });
  });
}
