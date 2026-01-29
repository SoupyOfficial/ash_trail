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

    test('sets default updatedAt when not provided', () {
      final before = DateTime.now();
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        date: '2025-01-01',
      );
      final after = DateTime.now();

      expect(
        rollup.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        rollup.updatedAt.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });

    test('uses provided updatedAt when specified', () {
      final specificTime = DateTime(2025, 1, 1, 12, 0);
      final rollup = DailyRollup.create(
        accountId: 'account-123',
        date: '2025-01-01',
        updatedAt: specificTime,
      );

      expect(rollup.updatedAt, specificTime);
    });

    test('default constructor creates empty rollup', () {
      final rollup = DailyRollup();
      expect(rollup.id, 0);
    });

    group('copyWith', () {
      test('updates multiple fields while preserving unchanged ones', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          profileId: 'profile-456',
          date: '2025-01-01',
          totalValue: 50,
          eventCount: 10,
          firstEventAt: DateTime(2025, 1, 1, 8, 0),
          lastEventAt: DateTime(2025, 1, 1, 20, 0),
          sourceRangeHash: 'old-hash',
        );
        original.id = 42;

        final newFirst = DateTime(2025, 1, 1, 7, 30);
        final newLast = DateTime(2025, 1, 1, 22, 0);
        final copy = original.copyWith(
          date: '2025-01-02',
          totalValue: 75,
          eventCount: 15,
          firstEventAt: newFirst,
          lastEventAt: newLast,
          sourceRangeHash: 'new-hash',
          eventTypeBreakdownJson: '{"vape": 10}',
        );

        // Updated fields
        expect(copy.date, '2025-01-02');
        expect(copy.totalValue, 75);
        expect(copy.eventCount, 15);
        expect(copy.firstEventAt, newFirst);
        expect(copy.lastEventAt, newLast);
        expect(copy.sourceRangeHash, 'new-hash');
        expect(copy.eventTypeBreakdownJson, '{"vape": 10}');

        // Preserved fields
        expect(copy.id, 42);
        expect(copy.accountId, 'account-123');
        expect(copy.profileId, 'profile-456');
      });
    });
  });
}
