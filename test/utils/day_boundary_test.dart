import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/day_boundary.dart';

void main() {
  group('DayBoundary', () {
    group('getDayStart', () {
      test('returns same day at 6am for times after 6am', () {
        final tuesday7am = DateTime(2024, 1, 16, 7, 0);
        final result = DayBoundary.getDayStart(tuesday7am);
        expect(result, DateTime(2024, 1, 16, 6, 0));
      });

      test('returns same day at 6am for exactly 6am', () {
        final tuesday6am = DateTime(2024, 1, 16, 6, 0);
        final result = DayBoundary.getDayStart(tuesday6am);
        expect(result, DateTime(2024, 1, 16, 6, 0));
      });

      test('returns previous day at 6am for times before 6am', () {
        final tuesday2am = DateTime(2024, 1, 16, 2, 0);
        final result = DayBoundary.getDayStart(tuesday2am);
        expect(result, DateTime(2024, 1, 15, 6, 0)); // Monday 6am
      });

      test('returns previous day at 6am for midnight', () {
        final tuesdayMidnight = DateTime(2024, 1, 16, 0, 0);
        final result = DayBoundary.getDayStart(tuesdayMidnight);
        expect(result, DateTime(2024, 1, 15, 6, 0)); // Monday 6am
      });

      test('handles 5:59am as previous day', () {
        final tuesday559am = DateTime(2024, 1, 16, 5, 59);
        final result = DayBoundary.getDayStart(tuesday559am);
        expect(result, DateTime(2024, 1, 15, 6, 0)); // Monday 6am
      });

      test('handles late night 11pm as same day', () {
        final tuesday11pm = DateTime(2024, 1, 16, 23, 0);
        final result = DayBoundary.getDayStart(tuesday11pm);
        expect(result, DateTime(2024, 1, 16, 6, 0)); // Tuesday 6am
      });
    });

    group('getTodayStart', () {
      test('returns a DateTime at 6am', () {
        final result = DayBoundary.getTodayStart();
        expect(result.hour, 6);
        expect(result.minute, 0);
        expect(result.second, 0);
      });
    });

    group('getYesterdayStart', () {
      test('returns one day before today start', () {
        final todayStart = DayBoundary.getTodayStart();
        final yesterdayStart = DayBoundary.getYesterdayStart();
        expect(todayStart.difference(yesterdayStart).inDays, 1);
      });

      test('returns a DateTime at 6am', () {
        final result = DayBoundary.getYesterdayStart();
        expect(result.hour, 6);
        expect(result.minute, 0);
      });
    });

    group('getDayStartDaysAgo', () {
      test('returns today start for 0 days ago', () {
        final todayStart = DayBoundary.getTodayStart();
        final result = DayBoundary.getDayStartDaysAgo(0);
        expect(result, todayStart);
      });

      test('returns yesterday start for 1 day ago', () {
        final yesterdayStart = DayBoundary.getYesterdayStart();
        final result = DayBoundary.getDayStartDaysAgo(1);
        expect(result, yesterdayStart);
      });

      test('returns 7 days ago correctly', () {
        final todayStart = DayBoundary.getTodayStart();
        final result = DayBoundary.getDayStartDaysAgo(7);
        expect(todayStart.difference(result).inDays, 7);
      });
    });

    group('getDayEnd', () {
      test('returns day end just before next day start', () {
        final tuesday7am = DateTime(2024, 1, 16, 7, 0);
        final dayEnd = DayBoundary.getDayEnd(tuesday7am);

        // Should be just before Wednesday 6am
        expect(dayEnd.day, 17);
        expect(dayEnd.hour, 5);
        expect(dayEnd.minute, 59);
        expect(dayEnd.second, 59);
      });

      test('day end is exactly one day after day start minus microsecond', () {
        final tuesday7am = DateTime(2024, 1, 16, 7, 0);
        final dayStart = DayBoundary.getDayStart(tuesday7am);
        final dayEnd = DayBoundary.getDayEnd(tuesday7am);

        final expectedEnd = dayStart
            .add(const Duration(days: 1))
            .subtract(const Duration(microseconds: 1));
        expect(dayEnd, expectedEnd);
      });
    });

    group('getTodayEnd', () {
      test('returns a DateTime one day after today start', () {
        final todayStart = DayBoundary.getTodayStart();
        final todayEnd = DayBoundary.getTodayEnd();

        // todayEnd should be just before tomorrow's start
        final tomorrowStart = todayStart.add(const Duration(days: 1));
        expect(todayEnd.isBefore(tomorrowStart), isTrue);
        expect(todayEnd.difference(todayStart).inHours, 23);
      });
    });

    group('isSameDay', () {
      test('returns true for same calendar day after 6am', () {
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        final tuesday8pm = DateTime(2024, 1, 16, 20, 0);
        expect(DayBoundary.isSameDay(tuesday10am, tuesday8pm), isTrue);
      });

      test('returns true for late night and previous morning', () {
        // 2am Tuesday and 10am Monday are NOT same day
        // But 2am Tuesday and 11pm Monday ARE same day (Monday's logical day)
        final monday11pm = DateTime(2024, 1, 15, 23, 0);
        final tuesday2am = DateTime(2024, 1, 16, 2, 0);
        expect(DayBoundary.isSameDay(monday11pm, tuesday2am), isTrue);
      });

      test('returns false for different calendar days after 6am', () {
        final monday10am = DateTime(2024, 1, 15, 10, 0);
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        expect(DayBoundary.isSameDay(monday10am, tuesday10am), isFalse);
      });

      test('returns false for times spanning 6am boundary', () {
        // 5am Tuesday is Monday's day
        // 7am Tuesday is Tuesday's day
        final tuesday5am = DateTime(2024, 1, 16, 5, 0);
        final tuesday7am = DateTime(2024, 1, 16, 7, 0);
        expect(DayBoundary.isSameDay(tuesday5am, tuesday7am), isFalse);
      });
    });

    group('isToday', () {
      test('returns true for current time', () {
        final now = DateTime.now();
        expect(DayBoundary.isToday(now), isTrue);
      });

      test('returns true for earlier today', () {
        final now = DateTime.now();
        // If it's after 8am, check that 7am today is still today
        if (now.hour >= 8) {
          final earlier = DateTime(now.year, now.month, now.day, 7, 0);
          expect(DayBoundary.isToday(earlier), isTrue);
        }
      });
    });

    group('isYesterday', () {
      test('returns true for yesterday afternoon', () {
        // Use DayBoundary-aware yesterday to avoid failure when running before 6am
        final logicalYesterday = DayBoundary.getYesterdayStart();
        // Adjust to afternoon time to ensure it's clearly yesterday
        final yesterdayAfternoon = DateTime(
          logicalYesterday.year,
          logicalYesterday.month,
          logicalYesterday.day,
          14,
          0,
        );
        expect(DayBoundary.isYesterday(yesterdayAfternoon), isTrue);
      });

      test('returns false for today', () {
        final now = DateTime.now();
        expect(DayBoundary.isYesterday(now), isFalse);
      });
    });

    group('isWithinDays', () {
      test('returns true for today with days=1', () {
        final now = DateTime.now();
        expect(DayBoundary.isWithinDays(now, 1), isTrue);
      });

      test('returns true for yesterday with days=2', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DayBoundary.isWithinDays(yesterday, 2), isTrue);
      });

      test('returns false for 8 days ago with days=7', () {
        final eightDaysAgo = DateTime.now().subtract(const Duration(days: 8));
        expect(DayBoundary.isWithinDays(eightDaysAgo, 7), isFalse);
      });

      test('returns true for exactly 7 days ago with days=7', () {
        // Get the start of 7 days ago
        final sevenDaysAgoStart = DayBoundary.getDayStartDaysAgo(6);
        expect(DayBoundary.isWithinDays(sevenDaysAgoStart, 7), isTrue);
      });
    });

    group('daysBetween', () {
      test('returns 0 for same day', () {
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        final tuesday8pm = DateTime(2024, 1, 16, 20, 0);
        expect(DayBoundary.daysBetween(tuesday10am, tuesday8pm), 0);
      });

      test('returns 1 for consecutive days', () {
        final monday10am = DateTime(2024, 1, 15, 10, 0);
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        expect(DayBoundary.daysBetween(monday10am, tuesday10am), 1);
      });

      test('returns negative for reversed order', () {
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        final monday10am = DateTime(2024, 1, 15, 10, 0);
        expect(DayBoundary.daysBetween(tuesday10am, monday10am), -1);
      });

      test('returns 7 for one week', () {
        final day1 = DateTime(2024, 1, 15, 10, 0);
        final day8 = DateTime(2024, 1, 22, 10, 0);
        expect(DayBoundary.daysBetween(day1, day8), 7);
      });

      test('handles times spanning 6am correctly', () {
        // 2am Tuesday (Monday's day) to 10am Tuesday (Tuesday's day) = 1 day
        final tuesday2am = DateTime(2024, 1, 16, 2, 0);
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        expect(DayBoundary.daysBetween(tuesday2am, tuesday10am), 1);
      });
    });

    group('getCalendarDate', () {
      test('returns midnight of logical day', () {
        final tuesday10am = DateTime(2024, 1, 16, 10, 0);
        final result = DayBoundary.getCalendarDate(tuesday10am);
        expect(result, DateTime(2024, 1, 16, 0, 0, 0));
      });

      test('returns previous day midnight for times before 6am', () {
        final tuesday2am = DateTime(2024, 1, 16, 2, 0);
        final result = DayBoundary.getCalendarDate(tuesday2am);
        expect(result, DateTime(2024, 1, 15, 0, 0, 0)); // Monday midnight
      });
    });

    group('getWeekStart', () {
      test('returns Monday 6am for a Tuesday', () {
        final tuesday10am = DateTime(2024, 1, 16, 10, 0); // Tuesday
        final result = DayBoundary.getWeekStart(tuesday10am);
        expect(result.weekday, DateTime.monday);
        expect(result.hour, 6);
        expect(result, DateTime(2024, 1, 15, 6, 0)); // Monday 6am
      });

      test('returns same day for a Monday', () {
        final monday10am = DateTime(2024, 1, 15, 10, 0); // Monday
        final result = DayBoundary.getWeekStart(monday10am);
        expect(result.weekday, DateTime.monday);
        expect(result, DateTime(2024, 1, 15, 6, 0));
      });

      test('returns previous Monday for a Sunday', () {
        final sunday10am = DateTime(2024, 1, 21, 10, 0); // Sunday
        final result = DayBoundary.getWeekStart(sunday10am);
        expect(result.weekday, DateTime.monday);
        expect(result, DateTime(2024, 1, 15, 6, 0));
      });

      test('handles early morning on Monday correctly', () {
        // 2am Monday is actually Sunday's logical day
        // So week start should be previous Monday
        final monday2am = DateTime(2024, 1, 15, 2, 0);
        final result = DayBoundary.getWeekStart(monday2am);
        expect(result.weekday, DateTime.monday);
        expect(result, DateTime(2024, 1, 8, 6, 0)); // Previous Monday
      });
    });

    group('getThisWeekStart', () {
      test('returns a Monday at 6am', () {
        final result = DayBoundary.getThisWeekStart();
        expect(result.weekday, DateTime.monday);
        expect(result.hour, 6);
        expect(result.minute, 0);
      });
    });

    group('dayStartHour constant', () {
      test('is 6', () {
        expect(DayBoundary.dayStartHour, 6);
      });
    });
  });
}
