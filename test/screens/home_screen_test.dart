import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/account.dart';
import 'package:flutter_test/flutter_test.dart';

/// Casual Tracker User Persona Tests
/// Tests focused on minimal friction logging and quick entry validation

Account _buildAccount({
  String userId = 'casual-user-1',
  String displayName = 'Casual Tracker',
}) {
  return Account.create(
    userId: userId,
    displayName: displayName,
    email: 'casual@example.com',
  );
}

void main() {
  group('Casual Tracker User - Minimal Friction Logging', () {
    test('creates minimal log entry with just event type and duration', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final minimalRecord = LogRecord.create(
        logId: 'minimal-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      expect(minimalRecord.logId, 'minimal-1');
      expect(minimalRecord.eventType, EventType.vape);
      expect(minimalRecord.duration, 5);
      expect(minimalRecord.note, isNull);
      expect(minimalRecord.moodRating, isNull);
      expect(minimalRecord.physicalRating, isNull);
    });

    test('supports quick entry without notes or tags', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final quickRecord = LogRecord.create(
        logId: 'quick-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 10,
        unit: Unit.seconds,
        note: '', // explicitly empty
      );

      expect(quickRecord.note, '');
      expect(quickRecord.reasons, isNull);
    });

    test('marks new entries as pending sync initially', () {
      final account = _buildAccount();

      final record = LogRecord.create(
        logId: 'pending-1',
        accountId: account.userId,
        eventAt: DateTime.now(),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
      );

      // Default sync state should be pending
      expect(record.syncState, SyncState.pending);
    });

    test('handles sync state transitions correctly', () {
      final account = _buildAccount();
      final record = LogRecord.create(
        logId: 'sync-test-1',
        accountId: account.userId,
        eventAt: DateTime.now(),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.pending,
      );

      // Should be able to mark as synced
      expect(record.syncState, SyncState.pending);

      // Copy with updated sync state
      final syncedRecord = record.copyWith(syncState: SyncState.synced);
      expect(syncedRecord.syncState, SyncState.synced);
    });

    test('supports multiple quick consecutive logs', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final logs = List.generate(
        5,
        (i) => LogRecord.create(
          logId: 'consecutive-$i',
          accountId: account.userId,
          eventAt: now.subtract(Duration(minutes: i)),
          eventType: EventType.vape,
          duration: (5 + i).toDouble(),
          unit: Unit.seconds,
        ),
      );

      expect(logs, hasLength(5));
      expect(logs.map((l) => l.logId).toList(), [
        'consecutive-0',
        'consecutive-1',
        'consecutive-2',
        'consecutive-3',
        'consecutive-4',
      ]);
      expect(logs.map((l) => l.duration).toList(), [5.0, 6.0, 7.0, 8.0, 9.0]);
    });

    test('displays sync status for recent entries', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final syncedRecord = LogRecord.create(
        logId: 'synced-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.synced,
      );

      final pendingRecord = LogRecord.create(
        logId: 'pending-1',
        accountId: account.userId,
        eventAt: now.subtract(const Duration(hours: 1)),
        eventType: EventType.vape,
        duration: 5,
        unit: Unit.seconds,
        syncState: SyncState.pending,
      );

      expect(syncedRecord.syncState, SyncState.synced);
      expect(pendingRecord.syncState, SyncState.pending);
    });

    test('preserves entry data through creation and copies', () {
      final account = _buildAccount();
      final now = DateTime.now();

      final original = LogRecord.create(
        logId: 'preserve-1',
        accountId: account.userId,
        eventAt: now,
        eventType: EventType.vape,
        duration: 15,
        unit: Unit.seconds,
      );

      final copy = original.copyWith();

      expect(copy.logId, original.logId);
      expect(copy.accountId, original.accountId);
      expect(copy.eventAt, original.eventAt);
      expect(copy.eventType, original.eventType);
      expect(copy.duration, original.duration);
      expect(copy.unit, original.unit);
    });
  });
}
