import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/home_widgets/widget_settings_keys.dart';
import 'package:ash_trail/widgets/home_widgets/widget_catalog.dart';

void main() {
  group('WidgetSettingsDefaults', () {
    test('defaultsFor returns a map for every widget type', () {
      for (final type in HomeWidgetType.values) {
        final defaults = WidgetSettingsDefaults.defaultsFor(type);
        expect(defaults, isA<Map<String, dynamic>>());
      }
    });

    test('hitsToday defaults to 1 day', () {
      final d = WidgetSettingsDefaults.defaultsFor(HomeWidgetType.hitsToday);
      expect(d[kTimeWindowDays], 1);
    });

    test('hitsThisWeek defaults to 7 days', () {
      final d = WidgetSettingsDefaults.defaultsFor(HomeWidgetType.hitsThisWeek);
      expect(d[kTimeWindowDays], 7);
    });

    test('durationTrend defaults to 3 days', () {
      final d = WidgetSettingsDefaults.defaultsFor(
        HomeWidgetType.durationTrend,
      );
      expect(d[kTimeWindowDays], 3);
    });

    test('quickLog has no settings', () {
      final d = WidgetSettingsDefaults.defaultsFor(HomeWidgetType.quickLog);
      expect(d, isEmpty);
    });

    test('todayVsYesterday defaults include comparison target', () {
      final d = WidgetSettingsDefaults.defaultsFor(
        HomeWidgetType.todayVsYesterday,
      );
      expect(d[kComparisonTarget], 'yesterday');
    });

    test('weekdayHeatmap defaults to weekday filter', () {
      final d = WidgetSettingsDefaults.defaultsFor(
        HomeWidgetType.weekdayHeatmap,
      );
      expect(d[kHeatmapDayFilter], 'weekday');
    });
  });

  group('WidgetSettingsDefaults.timeWindowLabel', () {
    test('returns "today" for 1 day', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(1), 'today');
    });

    test('returns "3 days" for 3', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(3), '3 days');
    });

    test('returns "7 days" for 7', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(7), '7 days');
    });

    test('returns "14 days" for 14', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(14), '14 days');
    });

    test('returns "30 days" for 30', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(30), '30 days');
    });

    test('returns "all time" for 365+', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(365), 'all time');
    });

    test('returns "N days" for arbitrary values', () {
      expect(WidgetSettingsDefaults.timeWindowLabel(5), '5 days');
    });
  });

  group('WidgetSettingsDefaults.supportsTimeWindow', () {
    test('excludes timeSinceLastHit', () {
      expect(
        WidgetSettingsDefaults.supportsTimeWindow(
          HomeWidgetType.timeSinceLastHit,
        ),
        isFalse,
      );
    });

    test('excludes firstHitToday', () {
      expect(
        WidgetSettingsDefaults.supportsTimeWindow(HomeWidgetType.firstHitToday),
        isFalse,
      );
    });

    test('excludes quickLog', () {
      expect(
        WidgetSettingsDefaults.supportsTimeWindow(HomeWidgetType.quickLog),
        isFalse,
      );
    });

    test('includes hitsToday', () {
      expect(
        WidgetSettingsDefaults.supportsTimeWindow(HomeWidgetType.hitsToday),
        isTrue,
      );
    });

    test('includes peakHour', () {
      expect(
        WidgetSettingsDefaults.supportsTimeWindow(HomeWidgetType.peakHour),
        isTrue,
      );
    });
  });

  group('WidgetSettingsDefaults.supportsEventTypeFilter', () {
    test('excludes quickLog', () {
      expect(
        WidgetSettingsDefaults.supportsEventTypeFilter(HomeWidgetType.quickLog),
        isFalse,
      );
    });

    test('excludes timeSinceLastHit', () {
      expect(
        WidgetSettingsDefaults.supportsEventTypeFilter(
          HomeWidgetType.timeSinceLastHit,
        ),
        isFalse,
      );
    });

    test('includes hitsToday', () {
      expect(
        WidgetSettingsDefaults.supportsEventTypeFilter(
          HomeWidgetType.hitsToday,
        ),
        isTrue,
      );
    });
  });

  group('MetricType enum', () {
    test('has all expected values', () {
      expect(MetricType.values.length, 5);
      expect(MetricType.count.displayName, 'Count');
      expect(MetricType.totalDuration.displayName, 'Total Duration');
      expect(MetricType.avgDuration.displayName, 'Avg Duration');
      expect(MetricType.mood.displayName, 'Mood');
      expect(MetricType.physical.displayName, 'Physical');
    });
  });

  group('ComparisonTarget enum', () {
    test('has correct day values', () {
      expect(ComparisonTarget.yesterday.days, 1);
      expect(ComparisonTarget.weekAvg.days, 7);
      expect(ComparisonTarget.lastWeek.days, 7);
      expect(ComparisonTarget.lastMonth.days, 30);
    });

    test('has display names', () {
      expect(ComparisonTarget.yesterday.displayName, 'Yesterday');
    });
  });

  group('HeatmapDayFilter enum', () {
    test('has expected values', () {
      expect(HeatmapDayFilter.values.length, 3);
      expect(HeatmapDayFilter.all.displayName, 'All Days');
      expect(HeatmapDayFilter.weekday.displayName, 'Weekdays');
      expect(HeatmapDayFilter.weekend.displayName, 'Weekends');
    });
  });
}
