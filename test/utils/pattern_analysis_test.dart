import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/pattern_analysis.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';

/// Helper to create a LogRecord at a specific time
LogRecord createRecord({
  required DateTime eventAt,
  String? logId,
}) {
  return LogRecord.create(
    logId: logId ?? 'log-${eventAt.millisecondsSinceEpoch}',
    accountId: 'test-account',
    eventType: EventType.vape,
    eventAt: eventAt,
  );
}

void main() {
  group('PeakHourData', () {
    test('creates with all parameters', () {
      const data = PeakHourData(hour: 14, count: 5, percentage: 25.0);
      expect(data.hour, 14);
      expect(data.count, 5);
      expect(data.percentage, 25.0);
    });

    group('formattedHour', () {
      test('formats midnight correctly', () {
        const data = PeakHourData(hour: 0, count: 1, percentage: 10);
        expect(data.formattedHour, '12 AM');
      });

      test('formats noon correctly', () {
        const data = PeakHourData(hour: 12, count: 1, percentage: 10);
        expect(data.formattedHour, '12 PM');
      });

      test('formats morning hours correctly', () {
        const data = PeakHourData(hour: 9, count: 1, percentage: 10);
        expect(data.formattedHour, '9 AM');
      });

      test('formats afternoon hours correctly', () {
        const data = PeakHourData(hour: 14, count: 1, percentage: 10);
        expect(data.formattedHour, '2 PM');
      });

      test('formats evening hours correctly', () {
        const data = PeakHourData(hour: 22, count: 1, percentage: 10);
        expect(data.formattedHour, '10 PM');
      });

      test('formats early morning correctly', () {
        const data = PeakHourData(hour: 3, count: 1, percentage: 10);
        expect(data.formattedHour, '3 AM');
      });
    });
  });

  group('DayPatternData', () {
    test('creates with all parameters', () {
      const data = DayPatternData(
        dayOfWeek: 1,
        dayName: 'Monday',
        count: 10,
        average: 2.5,
      );
      expect(data.dayOfWeek, 1);
      expect(data.dayName, 'Monday');
      expect(data.count, 10);
      expect(data.average, 2.5);
    });

    group('getDayName', () {
      test('returns Monday for 1', () {
        expect(DayPatternData.getDayName(1), 'Monday');
      });

      test('returns Tuesday for 2', () {
        expect(DayPatternData.getDayName(2), 'Tuesday');
      });

      test('returns Wednesday for 3', () {
        expect(DayPatternData.getDayName(3), 'Wednesday');
      });

      test('returns Thursday for 4', () {
        expect(DayPatternData.getDayName(4), 'Thursday');
      });

      test('returns Friday for 5', () {
        expect(DayPatternData.getDayName(5), 'Friday');
      });

      test('returns Saturday for 6', () {
        expect(DayPatternData.getDayName(6), 'Saturday');
      });

      test('returns Sunday for 7', () {
        expect(DayPatternData.getDayName(7), 'Sunday');
      });

      test('returns Unknown for invalid day', () {
        expect(DayPatternData.getDayName(0), 'Unknown');
        expect(DayPatternData.getDayName(8), 'Unknown');
        expect(DayPatternData.getDayName(-1), 'Unknown');
      });
    });
  });

  group('PatternAnalysis', () {
    group('getPeakHour', () {
      test('returns null for empty records', () {
        expect(PatternAnalysis.getPeakHour([]), isNull);
      });

      test('returns single hour for single record', () {
        final records = [
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 0)),
        ];

        final result = PatternAnalysis.getPeakHour(records);
        expect(result, isNotNull);
        expect(result!.hour, 14);
        expect(result.count, 1);
        expect(result.percentage, 100.0);
      });

      test('finds peak hour among multiple hours', () {
        final records = [
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 0)),
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 30)),
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 45)),
          createRecord(eventAt: DateTime(2024, 1, 15, 10, 0)),
          createRecord(eventAt: DateTime(2024, 1, 15, 18, 0)),
        ];

        final result = PatternAnalysis.getPeakHour(records);
        expect(result!.hour, 14); // 3 records at 2 PM
        expect(result.count, 3);
        expect(result.percentage, 60.0); // 3/5 = 60%
      });

      test('calculates percentage correctly', () {
        final records = [
          createRecord(eventAt: DateTime(2024, 1, 15, 10, 0)),
          createRecord(eventAt: DateTime(2024, 1, 15, 10, 15)),
          createRecord(eventAt: DateTime(2024, 1, 15, 11, 0)),
          createRecord(eventAt: DateTime(2024, 1, 15, 12, 0)),
        ];

        final result = PatternAnalysis.getPeakHour(records);
        expect(result!.hour, 10);
        expect(result.count, 2);
        expect(result.percentage, 50.0); // 2/4 = 50%
      });
    });

    group('getHourDistribution', () {
      test('returns map with all 24 hours', () {
        final records = [
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 0)),
        ];

        final result = PatternAnalysis.getHourDistribution(records);
        expect(result.length, 24);
        for (int i = 0; i < 24; i++) {
          expect(result.containsKey(i), isTrue);
        }
      });

      test('counts hits per hour correctly', () {
        final records = [
          createRecord(eventAt: DateTime(2024, 1, 15, 10, 0)),
          createRecord(eventAt: DateTime(2024, 1, 15, 10, 30)),
          createRecord(eventAt: DateTime(2024, 1, 15, 14, 0)),
        ];

        final result = PatternAnalysis.getHourDistribution(records);
        expect(result[10], 2);
        expect(result[14], 1);
        expect(result[0], 0); // No records at midnight
      });

      test('returns all zeros for empty records', () {
        final result = PatternAnalysis.getHourDistribution([]);
        expect(result.length, 24);
        for (int i = 0; i < 24; i++) {
          expect(result[i], 0);
        }
      });
    });

    group('getDayPatterns', () {
      test('returns 7 day patterns for empty records', () {
        final result = PatternAnalysis.getDayPatterns([]);
        expect(result.length, 7);
        for (final pattern in result) {
          expect(pattern.count, 0);
          expect(pattern.average, 0);
        }
      });

      test('counts records per day of week', () {
        // Monday = 1, Tuesday = 2, etc.
        final monday = DateTime(2024, 1, 15, 10, 0); // Monday
        final tuesday = DateTime(2024, 1, 16, 10, 0); // Tuesday
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: monday.add(const Duration(hours: 1))),
          createRecord(eventAt: tuesday),
        ];

        final result = PatternAnalysis.getDayPatterns(records);
        
        // Find Monday and Tuesday patterns
        final mondayPattern = result.firstWhere((p) => p.dayOfWeek == 1);
        final tuesdayPattern = result.firstWhere((p) => p.dayOfWeek == 2);
        
        expect(mondayPattern.count, 2);
        expect(tuesdayPattern.count, 1);
      });

      test('returns patterns sorted by count descending', () {
        final monday = DateTime(2024, 1, 15, 10, 0);
        final tuesday = DateTime(2024, 1, 16, 10, 0);
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: tuesday),
          createRecord(eventAt: tuesday.add(const Duration(hours: 1))),
          createRecord(eventAt: tuesday.add(const Duration(hours: 2))),
        ];

        final result = PatternAnalysis.getDayPatterns(records);
        expect(result.first.dayOfWeek, 2); // Tuesday has most
        expect(result.first.count, 3);
      });
    });

    group('getDayPatternsDetailed', () {
      test('returns 7 patterns for empty records', () {
        final result = PatternAnalysis.getDayPatternsDetailed([]);
        expect(result.length, 7);
      });

      test('calculates average over time range', () {
        // Two Mondays, one week apart
        final monday1 = DateTime(2024, 1, 15, 10, 0);
        final monday2 = DateTime(2024, 1, 22, 10, 0);
        
        final records = [
          createRecord(eventAt: monday1),
          createRecord(eventAt: monday1.add(const Duration(hours: 1))),
          createRecord(eventAt: monday2),
        ];

        final result = PatternAnalysis.getDayPatternsDetailed(records);
        final mondayPattern = result.firstWhere((p) => p.dayOfWeek == 1);
        
        expect(mondayPattern.count, 3);
        // Average should be count / weeks in range
        expect(mondayPattern.average, greaterThan(0));
      });

      test('returns sorted by average descending', () {
        final monday = DateTime(2024, 1, 15, 10, 0);
        final tuesday = DateTime(2024, 1, 16, 10, 0);
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: tuesday),
          createRecord(eventAt: tuesday.add(const Duration(hours: 1))),
        ];

        final result = PatternAnalysis.getDayPatternsDetailed(records);
        expect(result.first.dayOfWeek, 2); // Tuesday should be first
      });
    });

    group('getWeekdayWeekendComparison', () {
      test('calculates weekday vs weekend averages', () {
        final monday = DateTime(2024, 1, 15, 10, 0);
        final saturday = DateTime(2024, 1, 20, 10, 0);
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: monday.add(const Duration(hours: 1))),
          createRecord(eventAt: saturday),
        ];

        final result = PatternAnalysis.getWeekdayWeekendComparison(records);
        expect(result.weekdayAvg, greaterThan(0));
        expect(result.weekendAvg, greaterThan(0));
      });

      test('identifies weekdays higher trend', () {
        final monday = DateTime(2024, 1, 15, 10, 0);
        final tuesday = DateTime(2024, 1, 16, 10, 0);
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: monday.add(const Duration(hours: 1))),
          createRecord(eventAt: monday.add(const Duration(hours: 2))),
          createRecord(eventAt: tuesday),
          createRecord(eventAt: tuesday.add(const Duration(hours: 1))),
          // No weekend records
        ];

        final result = PatternAnalysis.getWeekdayWeekendComparison(records);
        expect(result.weekdayAvg, greaterThan(result.weekendAvg));
        expect(result.trend, 'weekdays higher');
      });

      test('identifies weekends higher trend', () {
        final monday = DateTime(2024, 1, 15, 10, 0);
        final saturday = DateTime(2024, 1, 20, 10, 0);
        final sunday = DateTime(2024, 1, 21, 10, 0);
        
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: saturday),
          createRecord(eventAt: saturday.add(const Duration(hours: 1))),
          createRecord(eventAt: saturday.add(const Duration(hours: 2))),
          createRecord(eventAt: sunday),
          createRecord(eventAt: sunday.add(const Duration(hours: 1))),
        ];

        final result = PatternAnalysis.getWeekdayWeekendComparison(records);
        expect(result.weekendAvg, greaterThan(result.weekdayAvg));
        expect(result.trend, 'weekends higher');
      });

      test('identifies neutral trend when similar', () {
        // Create balanced records where averages are within 10% of each other
        final monday = DateTime(2024, 1, 15, 10, 0);
        final tuesday = DateTime(2024, 1, 16, 10, 0);
        final saturday = DateTime(2024, 1, 20, 10, 0);
        final sunday = DateTime(2024, 1, 21, 10, 0);
        
        // 5 weekday records across 5 days = 1 per day
        // 2 weekend records across 2 days = 1 per day
        final records = [
          createRecord(eventAt: monday),
          createRecord(eventAt: tuesday),
          createRecord(eventAt: DateTime(2024, 1, 17, 10, 0)), // Wed
          createRecord(eventAt: DateTime(2024, 1, 18, 10, 0)), // Thu
          createRecord(eventAt: DateTime(2024, 1, 19, 10, 0)), // Fri
          createRecord(eventAt: saturday),
          createRecord(eventAt: sunday),
        ];

        final result = PatternAnalysis.getWeekdayWeekendComparison(records);
        // With equal distribution, should be neutral
        expect(result.trend, '→');
      });
    });
  });
}
