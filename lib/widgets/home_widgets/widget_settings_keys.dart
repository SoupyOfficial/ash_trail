/// Standardized settings keys and defaults for configurable home widgets.
///
/// All widget-specific configuration is stored in `HomeWidgetConfig.settings`
/// using these keys. Defaults ensure backward compatibility — widgets without
/// explicit settings fall back to the hardcoded values below.
import 'widget_catalog.dart';

// ===== SETTINGS KEY CONSTANTS =====

/// Time window in days. Used by most stat widgets.
const String kTimeWindowDays = 'timeWindowDays';

/// Event type filter. Stored as `List<String>` of [EventType] enum names.
/// Null or empty = no filter (show all event types).
const String kEventTypeFilter = 'eventTypeFilter';

/// The metric to display. Stored as [MetricType] enum name.
const String kMetricType = 'metricType';

/// Comparison target for comparison widgets. Stored as [ComparisonTarget] name.
const String kComparisonTarget = 'comparisonTarget';

/// Day filter for heatmaps. Stored as [HeatmapDayFilter] enum name.
const String kHeatmapDayFilter = 'heatmapDayFilter';

// ===== ENUMS =====

/// Metric type for widgets that can display different metrics.
enum MetricType {
  count('Count'),
  totalDuration('Total Duration'),
  avgDuration('Avg Duration'),
  mood('Mood'),
  physical('Physical');

  const MetricType(this.displayName);
  final String displayName;
}

/// Comparison target for comparison widgets.
enum ComparisonTarget {
  yesterday('Yesterday'),
  weekAvg('Week Average'),
  lastWeek('Last Week'),
  lastMonth('Last Month');

  const ComparisonTarget(this.displayName);
  final String displayName;

  /// Number of days for the comparison period.
  int get days => switch (this) {
    ComparisonTarget.yesterday => 1,
    ComparisonTarget.weekAvg => 7,
    ComparisonTarget.lastWeek => 7,
    ComparisonTarget.lastMonth => 30,
  };
}

/// Day filter for heatmap widgets.
enum HeatmapDayFilter {
  all('All Days'),
  weekday('Weekdays'),
  weekend('Weekends');

  const HeatmapDayFilter(this.displayName);
  final String displayName;
}

// ===== DEFAULTS =====

/// Provides default settings for each widget type, matching the original
/// hardcoded behavior before the configurable settings system was added.
class WidgetSettingsDefaults {
  const WidgetSettingsDefaults._();

  /// Return the default settings map for a widget type.
  ///
  /// These values reproduce the pre-configurability behavior exactly so that
  /// existing widgets (with no stored settings) continue to look the same.
  static Map<String, dynamic> defaultsFor(HomeWidgetType type) {
    return switch (type) {
      // Time-based
      HomeWidgetType.timeSinceLastHit => const {},
      HomeWidgetType.avgTimeBetween => const {kTimeWindowDays: 1},
      HomeWidgetType.longestGapToday => const {kTimeWindowDays: 1},
      HomeWidgetType.firstHitToday => const {}, // special today-only semantics
      HomeWidgetType.lastHitTime => const {},
      HomeWidgetType.peakHour => const {kTimeWindowDays: 7},
      HomeWidgetType.activeHoursToday => const {kTimeWindowDays: 1},

      // Duration-based
      HomeWidgetType.totalDurationToday => const {kTimeWindowDays: 1},
      HomeWidgetType.avgDurationPerHit => const {kTimeWindowDays: 1},
      HomeWidgetType.longestHitToday => const {kTimeWindowDays: 1},
      HomeWidgetType.shortestHitToday => const {kTimeWindowDays: 1},
      HomeWidgetType.totalDurationWeek => const {kTimeWindowDays: 7},
      HomeWidgetType.durationTrend => const {kTimeWindowDays: 3},

      // Count-based
      HomeWidgetType.hitsToday => const {kTimeWindowDays: 1},
      HomeWidgetType.hitsThisWeek => const {kTimeWindowDays: 7},
      HomeWidgetType.dailyAvgHits => const {kTimeWindowDays: 7},
      HomeWidgetType.hitsPerActiveHour => const {kTimeWindowDays: 1},

      // Comparison
      HomeWidgetType.todayVsYesterday => const {
        kTimeWindowDays: 1,
        kComparisonTarget: 'yesterday',
      },
      HomeWidgetType.todayVsWeekAvg => const {
        kTimeWindowDays: 1,
        kComparisonTarget: 'weekAvg',
      },
      HomeWidgetType.weekdayVsWeekend => const {kTimeWindowDays: 7},

      // Pattern
      HomeWidgetType.weeklyPattern => const {kTimeWindowDays: 7},
      HomeWidgetType.weekdayHeatmap => const {kHeatmapDayFilter: 'weekday'},
      HomeWidgetType.weekendHeatmap => const {kHeatmapDayFilter: 'weekend'},

      // Secondary
      HomeWidgetType.moodPhysicalAvg => const {kTimeWindowDays: 1},
      HomeWidgetType.topReasons => const {kTimeWindowDays: 7},

      // Action (no time-based settings)
      HomeWidgetType.quickLog => const {},
      HomeWidgetType.recentEntries => const {},

      // Custom
      HomeWidgetType.customStat => const {
        kTimeWindowDays: 1,
        kMetricType: 'count',
      },
    };
  }

  /// Human-readable label for a time window.
  static String timeWindowLabel(int days) {
    return switch (days) {
      1 => 'today',
      3 => '3 days',
      7 => '7 days',
      14 => '14 days',
      30 => '30 days',
      _ when days >= 365 => 'all time',
      _ => '$days days',
    };
  }

  /// Set of widget types that should NOT show a time window selector
  /// because they have special "live" or "now" semantics.
  static const Set<HomeWidgetType> excludeFromTimeWindow = {
    HomeWidgetType.timeSinceLastHit,
    HomeWidgetType.firstHitToday,
    HomeWidgetType.lastHitTime,
    HomeWidgetType.quickLog,
    HomeWidgetType.recentEntries,
  };

  /// Standard time window options available in the selector.
  static const List<int> timeWindowOptions = [1, 3, 7, 14, 30];

  /// Whether a widget type supports the time window setting.
  static bool supportsTimeWindow(HomeWidgetType type) {
    return !excludeFromTimeWindow.contains(type);
  }

  /// Whether a widget type supports the event type filter.
  static bool supportsEventTypeFilter(HomeWidgetType type) {
    return !const {
      HomeWidgetType.quickLog,
      HomeWidgetType.recentEntries,
      HomeWidgetType.timeSinceLastHit,
    }.contains(type);
  }
}
