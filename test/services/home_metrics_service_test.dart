import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/home_metrics_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/utils/day_boundary.dart';
import 'package:ash_trail/widgets/home_widgets/widget_settings_keys.dart'
    show TrendComparisonPeriod, WidgetSettingsDefaults;
import 'package:ash_trail/widgets/home_widgets/widget_catalog.dart'
    show HomeWidgetType;

/// Test helper to create a LogRecord with specific properties
LogRecord createLogRecord({
  String? logId,
  String accountId = 'test-account',
  EventType eventType = EventType.vape,
  required DateTime eventAt,
  double duration = 0,
  bool isDeleted = false,
}) {
  final record = LogRecord.create(
    logId: logId ?? 'log-${eventAt.millisecondsSinceEpoch}',
    accountId: accountId,
    eventType: eventType,
    eventAt: eventAt,
    duration: duration,
    isDeleted: isDeleted,
  );
  return record;
}

void main() {
  late HomeMetricsService service;

  setUp(() {
    service = HomeMetricsService();
  });

  group('HomeMetricsService - Time Since Last Hit', () {
    test('returns null for empty records', () {
      expect(service.getTimeSinceLastHit([]), isNull);
    });

    test('returns null when all records are deleted', () {
      final records = [
        createLogRecord(
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          isDeleted: true,
        ),
      ];
      expect(service.getTimeSinceLastHit(records), isNull);
    });

    test('returns duration since most recent record', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
      final records = [
        createLogRecord(eventAt: oneHourAgo),
        createLogRecord(
          eventAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      final duration = service.getTimeSinceLastHit(records);
      expect(duration, isNotNull);
      expect(duration!.inMinutes, closeTo(60, 1));
    });
  });

  group('HomeMetricsService - Get Last Record', () {
    test('returns null for empty records', () {
      expect(service.getLastRecord([]), isNull);
    });

    test('returns most recent non-deleted record', () {
      final newestTime = DateTime.now().subtract(const Duration(hours: 1));
      final records = [
        createLogRecord(logId: 'newest', eventAt: newestTime),
        createLogRecord(
          logId: 'deleted',
          eventAt: DateTime.now(),
          isDeleted: true,
        ),
        createLogRecord(
          logId: 'older',
          eventAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      final last = service.getLastRecord(records);
      expect(last?.logId, 'newest');
    });
  });

  group('HomeMetricsService - Average Gap', () {
    test('returns null with less than 2 records', () {
      final records = [createLogRecord(eventAt: DateTime.now())];
      expect(service.getAverageGap(records), isNull);
    });

    test('returns null with empty records', () {
      expect(service.getAverageGap([]), isNull);
    });

    test('calculates average gap between multiple records', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 2))),
      ];

      final avg = service.getAverageGap(records);
      expect(avg, isNotNull);
      expect(avg!.inMinutes, 60);
    });

    test('filters by days when specified', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 10))),
      ];

      final avg = service.getAverageGap(records, days: 1);
      expect(avg, isNotNull);
      // Should only consider first 2 records (within last day)
      expect(avg!.inMinutes, 60);
    });
  });

  group('HomeMetricsService - Average Gap Today', () {
    test('returns null with less than 2 records today', () {
      final records = [createLogRecord(eventAt: DateTime.now())];
      expect(service.getAverageGapToday(records), isNull);
    });

    test('calculates average for today records only', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 2))),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 1)),
        ), // Yesterday
      ];

      final avg = service.getAverageGapToday(records);
      expect(avg, isNotNull);
      // First hit (2h ago) to last hit (now) = 2h span, 2 gaps = 1h average
      expect(avg!.inMinutes, 60);
    });
  });

  group('HomeMetricsService - Longest Gap', () {
    test('returns null with less than 2 records', () {
      expect(service.getLongestGap([]), isNull);
      expect(
        service.getLongestGap([createLogRecord(eventAt: DateTime.now())]),
        isNull,
      );
    });

    test('finds the longest gap', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 3)),
        ), // 3h gap
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 4)),
        ), // 1h gap
      ];

      final result = service.getLongestGap(records);
      expect(result, isNotNull);
      expect(result!.gap.inHours, 3);
    });

    test('returns start and end times of longest gap', () {
      final now = DateTime.now();
      final gapEnd = now.subtract(const Duration(hours: 1));
      final gapStart = now.subtract(const Duration(hours: 5));

      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: gapEnd),
        createLogRecord(eventAt: gapStart), // 4h gap before this
      ];

      final result = service.getLongestGap(records);
      expect(result, isNotNull);
      expect(result!.gap.inHours, 4);
    });
  });

  group('HomeMetricsService - First/Last Hit Today', () {
    test('getFirstHitToday returns null for empty records', () {
      expect(service.getFirstHitToday([]), isNull);
    });

    test('getLastHitToday returns null for empty records', () {
      expect(service.getLastHitToday([]), isNull);
    });

    test('getFirstHitToday returns earliest hit today', () {
      final now = DateTime.now();
      // Use DayBoundary-aware "earliest" so it's always within the logical day
      // (which starts at 6am). Pick a time 1 hour after today's day-start.
      final todayStart = DayBoundary.getTodayStart();
      final earliest = todayStart.add(const Duration(hours: 1));
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: earliest),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 1)),
        ), // Yesterday
      ];

      final first = service.getFirstHitToday(records);
      expect(first, isNotNull);
      expect(first!.hour, earliest.hour);
    });

    test('getLastHitToday returns most recent hit today', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 2))),
      ];

      final last = service.getLastHitToday(records);
      expect(last, isNotNull);
      expect(last!.hour, now.hour);
    });
  });

  group('HomeMetricsService - Peak Hour', () {
    test('returns null for empty records', () {
      expect(service.getPeakHour([]), isNull);
    });

    test('finds the hour with most hits', () {
      final baseTime = DateTime(2024, 1, 15, 14, 0); // 2 PM
      final records = [
        createLogRecord(eventAt: baseTime),
        createLogRecord(eventAt: baseTime.add(const Duration(minutes: 30))),
        createLogRecord(
          eventAt: baseTime.add(const Duration(hours: 1)),
        ), // 3 PM
        createLogRecord(eventAt: DateTime(2024, 1, 15, 10, 0)), // 10 AM
      ];

      final peak = service.getPeakHour(records);
      expect(peak, isNotNull);
      expect(peak!.hour, 14); // 2 PM has 2 hits
      expect(peak.count, 2);
    });

    test('calculates percentage correctly', () {
      final baseTime = DateTime(2024, 1, 15, 14, 0);
      final records = [
        createLogRecord(eventAt: baseTime),
        createLogRecord(eventAt: baseTime.add(const Duration(minutes: 30))),
      ];

      final peak = service.getPeakHour(records);
      expect(peak!.percentage, 100.0); // All 2 hits in same hour
    });
  });

  group('HomeMetricsService - Active Hours Count', () {
    test('returns 0 for empty records', () {
      expect(service.getActiveHoursCount([]), 0);
    });

    test('counts unique hours with activity', () {
      final records = [
        createLogRecord(eventAt: DateTime(2024, 1, 15, 10, 0)),
        createLogRecord(eventAt: DateTime(2024, 1, 15, 10, 30)), // Same hour
        createLogRecord(eventAt: DateTime(2024, 1, 15, 14, 0)),
        createLogRecord(eventAt: DateTime(2024, 1, 15, 18, 0)),
      ];

      expect(service.getActiveHoursCount(records), 3);
    });

    test('excludes deleted records', () {
      final records = [
        createLogRecord(eventAt: DateTime(2024, 1, 15, 10, 0)),
        createLogRecord(eventAt: DateTime(2024, 1, 15, 14, 0), isDeleted: true),
      ];

      expect(service.getActiveHoursCount(records), 1);
    });
  });

  group('HomeMetricsService - Total Duration', () {
    test('returns 0 for empty records', () {
      expect(service.getTotalDuration([]), 0);
    });

    test('sums durations correctly', () {
      final records = [
        createLogRecord(eventAt: DateTime.now(), duration: 30),
        createLogRecord(
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 45,
        ),
      ];

      expect(service.getTotalDuration(records), 75);
    });

    test('excludes deleted records', () {
      final records = [
        createLogRecord(eventAt: DateTime.now(), duration: 30),
        createLogRecord(
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 45,
          isDeleted: true,
        ),
      ];

      expect(service.getTotalDuration(records), 30);
    });

    test('filters by days when specified', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 10)),
          duration: 100,
        ),
      ];

      expect(service.getTotalDuration(records, days: 1), 30);
    });
  });

  group('HomeMetricsService - Total Duration Today', () {
    test('only counts today records', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 2)),
          duration: 20,
        ),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 1)),
          duration: 100,
        ),
      ];

      expect(service.getTotalDurationToday(records), 50);
    });
  });

  group('HomeMetricsService - Count Methods', () {
    test('getHitCountToday counts today records only', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 1))),
      ];

      expect(service.getHitCountToday(records), 2);
    });

    test('getHitCountToday excludes deleted records', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          isDeleted: true,
        ),
      ];

      expect(service.getHitCountToday(records), 1);
    });

    test('getHitCount with days filter', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(days: 3))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 10))),
      ];

      expect(service.getHitCount(records, days: 7), 2);
    });

    test('getDailyAverageHits calculates correctly', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 1))),
      ];

      final avg = service.getDailyAverageHits(records, days: 7);
      expect(avg, greaterThan(0));
    });
  });

  group('HomeMetricsService - Rate Calculations', () {
    test('getHitsPerActiveHour calculates correctly', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(minutes: 30))),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 2))),
      ];

      // 2 hits in 1 hour, 1 hit in another hour
      final rate = service.getHitsPerActiveHour(records, days: 1);
      expect(rate, isNotNull);
      expect(rate!, greaterThan(0));
    });

    test('getHitsPerActiveHour returns null for empty records', () {
      expect(service.getHitsPerActiveHour([]), isNull);
    });
  });

  group('HomeMetricsService - Today vs Yesterday Comparison', () {
    test('getTodayVsYesterday returns comparison data', () {
      final now = DateTime.now();
      final records = [
        // Today: 2 hits
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 1))),
        // Yesterday: 1 hit
        createLogRecord(eventAt: now.subtract(const Duration(days: 1))),
      ];

      final comparison = service.getTodayVsYesterday(records);
      expect(comparison.todayCount, 2);
      expect(comparison.yesterdayCount, 1);
      expect(
        comparison.countChange,
        greaterThan(0),
      ); // Today more than yesterday
    });

    test('getTodayVsYesterday handles empty yesterday', () {
      final now = DateTime.now();
      final records = [createLogRecord(eventAt: now)];

      final comparison = service.getTodayVsYesterday(records);
      expect(comparison.todayCount, 1);
      expect(comparison.yesterdayCount, 0);
      expect(comparison.countChange, 100.0); // 100% increase from 0
    });
  });

  group('HomeMetricsService - Period Comparison', () {
    test('comparePeriods compares count correctly', () {
      final now = DateTime.now();
      final records = [
        // Current 7 days: 2 hits
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(days: 3))),
        // Previous 7 days: 1 hit
        createLogRecord(eventAt: now.subtract(const Duration(days: 10))),
      ];

      final comparison = service.comparePeriods(
        records: records,
        metric: 'count',
        currentDays: 7,
        previousDays: 7,
      );
      expect(comparison.current, 2);
      expect(comparison.previous, 1);
      expect(comparison.percentChange, greaterThan(0));
    });
  });

  group('HomeMetricsService - Weekday vs Weekend', () {
    test('getWeekdayVsWeekend compares patterns', () {
      // Create records with specific weekday/weekend patterns
      final monday = DateTime(2024, 1, 15, 10, 0); // Monday
      final saturday = DateTime(2024, 1, 13, 10, 0); // Saturday

      final records = [
        createLogRecord(eventAt: monday),
        createLogRecord(eventAt: monday.add(const Duration(hours: 1))),
        createLogRecord(eventAt: saturday),
      ];

      final comparison = service.getWeekdayVsWeekend(records, days: 7);
      expect(comparison.weekdayAvgCount, isNotNull);
      expect(comparison.weekendAvgCount, isNotNull);
    });
  });

  group('HomeMetricsService - Mood & Physical Ratings', () {
    test('getAverageMood calculates correctly', () {
      final now = DateTime.now();
      final recordWithMood1 = LogRecord.create(
        logId: 'log-1',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now,
        moodRating: 4.0,
      );

      final recordWithMood2 = LogRecord.create(
        logId: 'log-2',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now.subtract(const Duration(hours: 1)),
        moodRating: 2.0,
      );

      final records = [recordWithMood1, recordWithMood2];
      final avg = service.getAverageMood(records);
      expect(avg, 3.0);
    });

    test('getAverageMood returns null for no mood data', () {
      final records = [createLogRecord(eventAt: DateTime.now())];
      expect(service.getAverageMood(records), isNull);
    });

    test('getAveragePhysical returns null for no physical data', () {
      final records = [createLogRecord(eventAt: DateTime.now())];
      expect(service.getAveragePhysical(records), isNull);
    });

    test('getAveragePhysical calculates correctly', () {
      final now = DateTime.now();
      final record1 = LogRecord.create(
        logId: 'log-1',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now,
        physicalRating: 3.0,
      );
      final record2 = LogRecord.create(
        logId: 'log-2',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now.subtract(const Duration(hours: 1)),
        physicalRating: 5.0,
      );

      final avg = service.getAveragePhysical([record1, record2]);
      expect(avg, 4.0);
    });
  });

  group('HomeMetricsService - Top Reasons', () {
    test('getTopReasons returns empty list for no reasons', () {
      final records = [createLogRecord(eventAt: DateTime.now())];
      expect(service.getTopReasons(records), isEmpty);
    });

    test('getTopReasons limits results', () {
      final now = DateTime.now();
      final record = LogRecord.create(
        logId: 'log-1',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now,
        reasons: [
          LogReason.medical,
          LogReason.social,
          LogReason.stress,
          LogReason.habit,
        ],
      );

      final results = service.getTopReasons([record], limit: 2);
      expect(results.length, lessThanOrEqualTo(2));
    });

    test('getTopReasons counts reasons across records', () {
      final now = DateTime.now();
      final record1 = LogRecord.create(
        logId: 'log-1',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now,
        reasons: [LogReason.stress, LogReason.habit],
      );
      final record2 = LogRecord.create(
        logId: 'log-2',
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: now.subtract(const Duration(hours: 1)),
        reasons: [LogReason.stress],
      );

      final results = service.getTopReasons([record1, record2]);
      // stress appears twice, habit once
      expect(results.first.reason, LogReason.stress);
      expect(results.first.count, 2);
    });
  });

  group('HomeMetricsService - Duration Up To', () {
    test('getTodayDurationUpTo returns correct structure', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 20,
        ),
      ];

      final result = service.getTodayDurationUpTo(records);
      expect(result.duration, greaterThanOrEqualTo(0));
      expect(result.timeLabel, isNotEmpty);
      expect(result.count, greaterThanOrEqualTo(0));
    });

    test('getTodayDurationUpTo respects cutoff time', () {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 2));
      final records = [
        createLogRecord(eventAt: now, duration: 100), // After cutoff
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 3)),
          duration: 30,
        ), // Before cutoff
      ];

      final result = service.getTodayDurationUpTo(records, asOf: cutoff);
      // Only the earlier record should count
      expect(result.count, lessThanOrEqualTo(2));
    });
  });

  group('HomeMetricsService - Hits Up To', () {
    test('getTodayHitsUpTo returns correct structure', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 20,
        ),
      ];

      final result = service.getTodayHitsUpTo(records);
      expect(result.count, greaterThanOrEqualTo(0));
      expect(result.timeLabel, isNotEmpty);
    });

    test('getTodayHitsUpTo respects cutoff time', () {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 2));
      final records = [
        createLogRecord(eventAt: now, duration: 100), // After cutoff
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 3)),
          duration: 30,
        ), // Before cutoff
      ];

      final result = service.getTodayHitsUpTo(records, asOf: cutoff);
      // Only the earlier record should count
      expect(result.count, 1);
    });

    test('getTodayHitsUpTo excludes deleted records', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 20,
          isDeleted: true,
        ), // Deleted, should not count
      ];

      final result = service.getTodayHitsUpTo(records);
      expect(result.count, 1); // Only non-deleted record
    });

    test('getTodayHitsUpTo returns 0 for cutoff before today', () {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 2));
      final records = [
        createLogRecord(eventAt: now, duration: 30),
      ];

      final result = service.getTodayHitsUpTo(records, asOf: cutoff);
      expect(result.count, 0);
      expect(result.timeLabel, isNotEmpty);
    });
  });

  group('HomeMetricsService - Average Duration', () {
    test('getAverageDuration returns null for empty records', () {
      expect(service.getAverageDuration([]), isNull);
    });

    test('getAverageDuration calculates correctly', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 60,
        ),
      ];

      final avg = service.getAverageDuration(records);
      expect(avg, 45); // (30 + 60) / 2
    });

    test('getAverageDurationToday filters to today', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, duration: 30),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 1)),
          duration: 100,
        ),
      ];

      final avg = service.getAverageDurationToday(records);
      expect(avg, 30);
    });
  });

  group('HomeMetricsService - Longest/Shortest Hit', () {
    test('getLongestHit finds record with max duration', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(logId: 'short', eventAt: now, duration: 10),
        createLogRecord(
          logId: 'long',
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 60,
        ),
        createLogRecord(
          logId: 'medium',
          eventAt: now.subtract(const Duration(hours: 2)),
          duration: 30,
        ),
      ];

      final longest = service.getLongestHit(records);
      expect(longest?.logId, 'long');
    });

    test('getShortestHit finds record with min duration', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(logId: 'short', eventAt: now, duration: 10),
        createLogRecord(
          logId: 'long',
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 60,
        ),
      ];

      final shortest = service.getShortestHit(records);
      expect(shortest?.logId, 'short');
    });

    test('getLongestHit returns null for empty records', () {
      expect(service.getLongestHit([]), isNull);
    });

    test('getShortestHit returns null for empty records', () {
      expect(service.getShortestHit([]), isNull);
    });
  });

  group('HomeMetricsService - Active Hours Today', () {
    test('getActiveHoursToday counts today hours only', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(hours: 2))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 1))),
      ];

      final count = service.getActiveHoursToday(records);
      expect(count, greaterThanOrEqualTo(1));
    });
  });

  // ===================================================================
  // filterRecords() — shared filtering helper
  // ===================================================================
  group('HomeMetricsService - filterRecords', () {
    test('returns all records when no filters applied', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(days: 5))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 20))),
      ];

      final result = service.filterRecords(records);
      expect(result.length, 3);
    });

    test('filters by days only', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now),
        createLogRecord(eventAt: now.subtract(const Duration(days: 2))),
        createLogRecord(eventAt: now.subtract(const Duration(days: 10))),
      ];

      final result = service.filterRecords(records, days: 3);
      expect(result.length, 2);
    });

    test('filters by event type only', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
        createLogRecord(eventAt: now, eventType: EventType.inhale),
        createLogRecord(eventAt: now, eventType: EventType.note),
      ];

      final result = service.filterRecords(
        records,
        eventTypes: [EventType.vape],
      );
      expect(result.length, 1);
      expect(result.first.eventType, EventType.vape);
    });

    test('filters by both days and event type', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
        createLogRecord(eventAt: now, eventType: EventType.inhale),
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 10)),
          eventType: EventType.vape,
        ),
      ];

      final result = service.filterRecords(
        records,
        days: 3,
        eventTypes: [EventType.vape],
      );
      expect(result.length, 1);
      expect(result.first.eventType, EventType.vape);
    });

    test('returns empty when no records match event type', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
      ];

      final result = service.filterRecords(
        records,
        eventTypes: [EventType.note],
      );
      expect(result, isEmpty);
    });

    test('returns empty when no records match day window', () {
      final records = [
        createLogRecord(
          eventAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

      final result = service.filterRecords(records, days: 1);
      expect(result, isEmpty);
    });

    test('null event types list means no filter', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
        createLogRecord(eventAt: now, eventType: EventType.inhale),
      ];

      final result = service.filterRecords(records, eventTypes: null);
      expect(result.length, 2);
    });

    test('empty event types list means no filter', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
        createLogRecord(eventAt: now, eventType: EventType.inhale),
      ];

      final result = service.filterRecords(records, eventTypes: []);
      expect(result.length, 2);
    });

    test('multiple event types', () {
      final now = DateTime.now();
      final records = [
        createLogRecord(eventAt: now, eventType: EventType.vape),
        createLogRecord(eventAt: now, eventType: EventType.inhale),
        createLogRecord(eventAt: now, eventType: EventType.note),
      ];

      final result = service.filterRecords(
        records,
        eventTypes: [EventType.vape, EventType.inhale],
      );
      expect(result.length, 2);
    });
  });

  // ===== TREND COMPARISON PERIOD TESTS =====

  group('HomeMetricsService - Trend Comparison', () {
    test('getComparisonRecords previousDay returns yesterday records', () {
      final now = DateTime.now();
      final yesterdayStart = DayBoundary.getYesterdayStart();
      final records = [
        createLogRecord(
          eventAt: yesterdayStart.add(const Duration(hours: 2)),
          duration: 10,
        ),
        createLogRecord(
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 20,
        ),
      ];

      final result = service.getComparisonRecords(
        records,
        TrendComparisonPeriod.previousDay,
        now: now,
      );
      expect(result.length, 1);
      expect(result.first.duration, 10);
    });

    test(
      'getComparisonRecords sameDayLastWeek returns records from 7 days ago',
      () {
        final now = DateTime.now();
        final target = now.subtract(const Duration(days: 7));
        final dayStart = DayBoundary.getDayStart(target);
        final records = [
          createLogRecord(
            eventAt: dayStart.add(const Duration(hours: 3)),
            duration: 15,
          ),
          createLogRecord(
            eventAt: now.subtract(const Duration(hours: 1)),
            duration: 20,
          ),
        ];

        final result = service.getComparisonRecords(
          records,
          TrendComparisonPeriod.sameDayLastWeek,
          now: now,
        );
        expect(result.length, 1);
        expect(result.first.duration, 15);
      },
    );

    test('getComparisonRecords weekAverage returns 7 day window', () {
      final now = DateTime.now();
      final records = <LogRecord>[];
      // Add records for each of the last 7 days
      for (int i = 0; i < 7; i++) {
        records.add(
          createLogRecord(
            eventAt: now.subtract(Duration(days: i, hours: 2)),
            duration: 10.0 + i,
          ),
        );
      }
      // Add a record outside window
      records.add(
        createLogRecord(
          eventAt: now.subtract(const Duration(days: 10)),
          duration: 99,
        ),
      );

      final result = service.getComparisonRecords(
        records,
        TrendComparisonPeriod.weekAverage,
        now: now,
      );
      // Should include all 7 recent records but not the 10-day-old one
      expect(result.length, 7);
    });

    test('comparisonWindowDays returns correct values', () {
      expect(
        HomeMetricsService.comparisonWindowDays(
          TrendComparisonPeriod.previousDay,
        ),
        1,
      );
      expect(
        HomeMetricsService.comparisonWindowDays(
          TrendComparisonPeriod.sameDayLastWeek,
        ),
        1,
      );
      expect(
        HomeMetricsService.comparisonWindowDays(
          TrendComparisonPeriod.sameDayLastMonth,
        ),
        1,
      );
      expect(
        HomeMetricsService.comparisonWindowDays(
          TrendComparisonPeriod.weekAverage,
        ),
        7,
      );
      expect(
        HomeMetricsService.comparisonWindowDays(
          TrendComparisonPeriod.monthAverage,
        ),
        30,
      );
    });

    test('computeTrendForPeriod single day comparison', () {
      final trend = service.computeTrendForPeriod(
        currentValue: 120,
        referenceTotal: 100,
        period: TrendComparisonPeriod.previousDay,
      );
      expect(trend, closeTo(20.0, 0.01));
    });

    test('computeTrendForPeriod multi-day divides by window', () {
      // weekAverage: referenceTotal is divided by 7
      final trend = service.computeTrendForPeriod(
        currentValue: 10,
        referenceTotal: 70,
        period: TrendComparisonPeriod.weekAverage,
      );
      // 70 / 7 = 10 daily avg → (10 - 10) / 10 * 100 = 0%
      expect(trend, closeTo(0, 0.01));
    });

    test('computeTrendForPeriod returns 0 when reference is 0', () {
      final trend = service.computeTrendForPeriod(
        currentValue: 50,
        referenceTotal: 0,
        period: TrendComparisonPeriod.previousDay,
      );
      expect(trend, 0);
    });

    test('computeHourBlockTrend adjusts for time of day', () {
      // At exactly midday (fraction ≈ 0.5), if reference day was 200
      // and actual so far is 80, expected = 200 * 0.5 = 100
      // trend = (80 - 100) / 100 * 100 = -20%
      final todayStart = DayBoundary.getTodayStart();
      final midday = todayStart.add(const Duration(hours: 12));

      final trend = service.computeHourBlockTrend(
        actualSoFar: 80,
        fullDayReference: 200,
        period: TrendComparisonPeriod.previousDay,
        asOf: midday,
      );
      expect(trend, closeTo(-20.0, 1.0));
    });

    test('computeHourBlockTrend multi-day averages reference', () {
      final todayStart = DayBoundary.getTodayStart();
      final midday = todayStart.add(const Duration(hours: 12));

      // weekAverage with 700 total → daily avg = 100
      // At midday expected = 100 * 0.5 = 50
      // actual = 60 → (60 - 50) / 50 * 100 = +20%
      final trend = service.computeHourBlockTrend(
        actualSoFar: 60,
        fullDayReference: 700,
        period: TrendComparisonPeriod.weekAverage,
        asOf: midday,
      );
      expect(trend, closeTo(20.0, 1.0));
    });
  });

  group('TrendComparisonPeriod - Enum Properties', () {
    test('all periods have non-empty labels', () {
      for (final period in TrendComparisonPeriod.values) {
        expect(period.shortLabel, isNotEmpty);
        expect(period.displayName, isNotEmpty);
      }
    });

    test('shortLabel starts with "vs"', () {
      for (final period in TrendComparisonPeriod.values) {
        expect(period.shortLabel, startsWith('vs'));
      }
    });
  });

  group('WidgetSettingsDefaults - Trend Comparison', () {
    test('supportsTrendComparison returns true for applicable widgets', () {
      expect(
        WidgetSettingsDefaults.supportsTrendComparison(
          HomeWidgetType.totalDurationToday,
        ),
        isTrue,
      );
      expect(
        WidgetSettingsDefaults.supportsTrendComparison(
          HomeWidgetType.hitsToday,
        ),
        isTrue,
      );
      expect(
        WidgetSettingsDefaults.supportsTrendComparison(
          HomeWidgetType.durationTrend,
        ),
        isTrue,
      );
    });

    test(
      'supportsTrendComparison returns false for non-applicable widgets',
      () {
        expect(
          WidgetSettingsDefaults.supportsTrendComparison(
            HomeWidgetType.quickLog,
          ),
          isFalse,
        );
        expect(
          WidgetSettingsDefaults.supportsTrendComparison(
            HomeWidgetType.recentEntries,
          ),
          isFalse,
        );
        expect(
          WidgetSettingsDefaults.supportsTrendComparison(
            HomeWidgetType.weeklyPattern,
          ),
          isFalse,
        );
      },
    );
  });
}
