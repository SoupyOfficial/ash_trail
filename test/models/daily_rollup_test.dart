import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/daily_rollup.dart';

void main() {
  group('DailyRollup Model', () {
    test('creates daily rollup with all fields', () {
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        profileId: 'profile-456',
        date: '2025-01-01',
        totalValue: 15.5,
        eventCount: 10,
        firstEventAt: DateTime(2025, 1, 1, 8, 0),
        lastEventAt: DateTime(2025, 1, 1, 23, 59),
        eventTypeBreakdownJson: '{"inhale": 8, "note": 2}',
        updatedAt: DateTime(2025, 1, 1, 23, 59),
        sourceRangeHash: 'abc123def456',
      );

      expect(rollup.accountId, 'account-123');
      expect(rollup.profileId, 'profile-456');
      expect(rollup.date, '2025-01-01');
      expect(rollup.eventCount, 10);
      expect(rollup.totalValue, 15.5);
      expect(rollup.firstEventAt, DateTime(2025, 1, 1, 8, 0));
      expect(rollup.lastEventAt, DateTime(2025, 1, 1, 23, 59));
      expect(rollup.eventTypeBreakdownJson, '{"inhale": 8, "note": 2}');
      expect(rollup.sourceRangeHash, 'abc123def456');
    });

    test('isStale returns true when hash differs', () {
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        date: '2025-01-01',
        sourceRangeHash: 'old-hash',
      );

      expect(rollup.isStale('new-hash'), true);
      expect(rollup.isStale('old-hash'), false);
    });

    test('isStale returns true when hash is null', () {
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        date: '2025-01-01',
        sourceRangeHash: null,
      );

      expect(rollup.isStale('any-hash'), true);
    });

    test('handles null optional fields', () {
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        date: '2025-01-01',
        totalValue: 0,
        eventCount: 0,
        profileId: null,
        firstEventAt: null,
        lastEventAt: null,
        eventTypeBreakdownJson: null,
        sourceRangeHash: null,
      );

      expect(rollup.profileId, null);
      expect(rollup.firstEventAt, null);
      expect(rollup.lastEventAt, null);
      expect(rollup.eventTypeBreakdownJson, null);
      expect(rollup.sourceRangeHash, null);
    });
  });
}
