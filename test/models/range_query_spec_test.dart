import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/range_query_spec.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('RangeQuerySpec Factory Methods', () {
    test('today creates correct range', () {
      final spec = RangeQuerySpec.today();

      expect(spec.rangeType, RangeType.today);
      expect(spec.startAt.day, DateTime.now().day);
      expect(spec.endAt.day, DateTime.now().day);
      expect(spec.groupBy, GroupBy.hour);
    });

    test('week creates 7-day range', () {
      final spec = RangeQuerySpec.week();

      expect(spec.rangeType, RangeType.week);
      // Week calculation goes back to Monday, so duration varies by current day
      expect(spec.durationInDays >= 0, true);
      expect(spec.durationInDays <= 7, true);
      expect(spec.groupBy, GroupBy.day);
    });

    test('month creates range from start of month', () {
      final spec = RangeQuerySpec.month();

      expect(spec.rangeType, RangeType.month);
      expect(spec.startAt.day, 1); // Starts on 1st of month
      expect(spec.groupBy, GroupBy.day);
    });

    test('year creates range from start of year', () {
      final spec = RangeQuerySpec.year();

      expect(spec.rangeType, RangeType.year);
      expect(spec.startAt.month, 1);
      expect(spec.startAt.day, 1);
      expect(spec.groupBy, GroupBy.month);
    });

    test('ytd creates year-to-date range', () {
      final now = DateTime.now();
      final spec = RangeQuerySpec.ytd();

      expect(spec.rangeType, RangeType.ytd);
      expect(spec.startAt.year, now.year);
      expect(spec.startAt.month, 1);
      expect(spec.startAt.day, 1);
      expect(spec.endAt.day, now.day);
      expect(spec.groupBy, GroupBy.month);
    });

    test('custom creates range with specified dates', () {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);
      final spec = RangeQuerySpec.custom(
        startAt: start,
        endAt: end,
        groupBy: GroupBy.day,
      );

      expect(spec.rangeType, RangeType.custom);
      expect(spec.startAt, start);
      expect(spec.endAt, end);
      expect(spec.groupBy, GroupBy.day);
    });
  });

  group('RangeQuerySpec Methods', () {
    test('containsDate returns true for dates within range', () {
      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 31),
        groupBy: GroupBy.day,
      );

      expect(spec.containsDate(DateTime(2025, 1, 15)), true);
      expect(spec.containsDate(DateTime(2025, 1, 1)), true);
      expect(spec.containsDate(DateTime(2025, 1, 31)), true);
    });

    test('containsDate returns false for dates outside range', () {
      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 31),
        groupBy: GroupBy.day,
      );

      expect(spec.containsDate(DateTime(2024, 12, 31)), false);
      expect(spec.containsDate(DateTime(2025, 2, 1)), false);
    });

    test('durationInDays calculates correct duration', () {
      final spec1 = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 31),
        groupBy: GroupBy.day,
      );
      expect(spec1.durationInDays, 30);

      final spec2 = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 1, 1),
        groupBy: GroupBy.hour,
      );
      expect(spec2.durationInDays, 0);

      final spec3 = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 1),
        endAt: DateTime(2025, 12, 31),
        groupBy: GroupBy.month,
      );
      expect(spec3.durationInDays, 364);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = RangeQuerySpec.week();

      final updated = original.copyWith(
        groupBy: GroupBy.hour,
        eventTypes: [EventType.inhale],
      );

      expect(updated.rangeType, original.rangeType);
      expect(updated.startAt, original.startAt);
      expect(updated.endAt, original.endAt);
      expect(updated.groupBy, GroupBy.hour);
      expect(updated.eventTypes, [EventType.inhale]);
      expect(original.groupBy, GroupBy.day); // Original unchanged
    });

    test('handles optional filters', () {
      final spec = RangeQuerySpec.week();

      expect(spec.profileId, null);
      expect(spec.eventTypes, null);
      expect(spec.tags, null);

      final filtered = spec.copyWith(
        profileId: 'profile-1',
        eventTypes: [EventType.inhale, EventType.sessionStart],
        tags: ['morning', 'sativa'],
      );

      expect(filtered.profileId, 'profile-1');
      expect(filtered.eventTypes, [EventType.inhale, EventType.sessionStart]);
      expect(filtered.tags, ['morning', 'sativa']);
    });
  });

  group('RangeQuerySpec Edge Cases', () {
    test('handles same start and end date', () {
      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2025, 1, 15),
        endAt: DateTime(2025, 1, 15),
        groupBy: GroupBy.hour,
      );

      expect(spec.durationInDays, 0);
      expect(spec.containsDate(DateTime(2025, 1, 15)), true);
      expect(spec.containsDate(DateTime(2025, 1, 14)), false);
      expect(spec.containsDate(DateTime(2025, 1, 16)), false);
    });

    test('handles leap year correctly', () {
      final spec = RangeQuerySpec.custom(
        startAt: DateTime(2024, 1, 1), // 2024 is a leap year
        endAt: DateTime(2024, 12, 31),
        groupBy: GroupBy.month,
      );

      expect(spec.durationInDays, 365); // Dec 31 - Jan 1
    });

    test('preserves time components in dates', () {
      final start = DateTime(2025, 1, 1, 10, 30);
      final end = DateTime(2025, 1, 1, 18, 45);
      final spec = RangeQuerySpec.custom(
        startAt: start,
        endAt: end,
        groupBy: GroupBy.hour,
      );

      expect(spec.startAt.hour, 10);
      expect(spec.startAt.minute, 30);
      expect(spec.endAt.hour, 18);
      expect(spec.endAt.minute, 45);
    });
  });
}
