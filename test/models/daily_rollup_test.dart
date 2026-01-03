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
      test('creates copy with updated accountId', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
          totalValue: 10,
        );

        final copy = original.copyWith(accountId: 'account-456');

        expect(copy.accountId, 'account-456');
        expect(copy.date, original.date);
        expect(copy.totalValue, original.totalValue);
        expect(copy.id, original.id);
      });

      test('creates copy with updated date', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
        );

        final copy = original.copyWith(date: '2025-01-02');

        expect(copy.date, '2025-01-02');
        expect(copy.accountId, original.accountId);
      });

      test('creates copy with updated totalValue', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
          totalValue: 10,
        );

        final copy = original.copyWith(totalValue: 25.5);

        expect(copy.totalValue, 25.5);
      });

      test('creates copy with updated eventCount', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
          eventCount: 5,
        );

        final copy = original.copyWith(eventCount: 15);

        expect(copy.eventCount, 15);
      });

      test('creates copy with updated timestamps', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
          firstEventAt: DateTime(2025, 1, 1, 8, 0),
          lastEventAt: DateTime(2025, 1, 1, 20, 0),
        );

        final newFirst = DateTime(2025, 1, 1, 7, 30);
        final newLast = DateTime(2025, 1, 1, 22, 0);
        final copy = original.copyWith(
          firstEventAt: newFirst,
          lastEventAt: newLast,
        );

        expect(copy.firstEventAt, newFirst);
        expect(copy.lastEventAt, newLast);
      });

      test('creates copy with updated profileId', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
        );

        final copy = original.copyWith(profileId: 'profile-789');

        expect(copy.profileId, 'profile-789');
      });

      test('creates copy with updated sourceRangeHash', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
          sourceRangeHash: 'old-hash',
        );

        final copy = original.copyWith(sourceRangeHash: 'new-hash');

        expect(copy.sourceRangeHash, 'new-hash');
      });

      test('creates copy with updated eventTypeBreakdownJson', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
        );

        final copy = original.copyWith(eventTypeBreakdownJson: '{"vape": 10}');

        expect(copy.eventTypeBreakdownJson, '{"vape": 10}');
      });

      test('preserves id when copying', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          date: '2025-01-01',
        );
        original.id = 42;

        final copy = original.copyWith(totalValue: 99);

        expect(copy.id, 42);
      });

      test('preserves unchanged fields', () {
        final original = DailyRollup.create(
          accountId: 'account-123',
          profileId: 'profile-456',
          date: '2025-01-01',
          totalValue: 50,
          eventCount: 10,
        );

        final copy = original.copyWith(totalValue: 75);

        expect(copy.accountId, original.accountId);
        expect(copy.profileId, original.profileId);
        expect(copy.date, original.date);
        expect(copy.eventCount, original.eventCount);
        expect(copy.totalValue, 75);
      });
    });
  });
}
