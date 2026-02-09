import 'package:flutter/material.dart';

/// All available home widget types organized by category
enum HomeWidgetType {
  // ===== TIME-BASED WIDGETS =====
  /// Live elapsed time clock showing time since last entry
  timeSinceLastHit,

  /// Average time gap between hits (today and 7-day)
  avgTimeBetween,

  /// Maximum time between hits today
  longestGapToday,

  /// Time of first entry today
  firstHitToday,

  /// When the last hit occurred (actual time + relative)
  lastHitTime,

  /// Most active hour of day
  peakHour,

  /// Hours with at least one hit today
  activeHoursToday,

  // ===== DURATION-BASED WIDGETS =====
  /// Sum of all durations today
  totalDurationToday,

  /// Average duration per entry
  avgDurationPerHit,

  /// Maximum single duration today
  longestHitToday,

  /// Minimum single duration today
  shortestHitToday,

  /// Cumulative duration for 7 days
  totalDurationWeek,

  /// Duration trend with sparkline
  durationTrend,

  // ===== COUNT-BASED WIDGETS =====
  /// Total count of entries today
  hitsToday,

  /// Total count for last 7 days
  hitsThisWeek,

  /// Average hits per day (7-day)
  dailyAvgHits,

  /// Hits divided by active hours
  hitsPerActiveHour,

  // ===== COMPARISON WIDGETS =====
  /// Side-by-side comparison of today vs yesterday
  todayVsYesterday,

  /// Compare today to 7-day baseline
  todayVsWeekAvg,

  /// Pattern comparison weekday vs weekend
  weekdayVsWeekend,

  // ===== PATTERN WIDGETS =====
  /// Day-of-week distribution mini chart
  weeklyPattern,

  /// Activity by hour – weekday heatmap
  weekdayHeatmap,

  /// Activity by hour – weekend heatmap
  weekendHeatmap,

  // ===== SECONDARY DATA WIDGETS =====
  /// Average mood and physical ratings
  moodPhysicalAvg,

  /// Most common reasons
  topReasons,

  // ===== COMPOSITE/ACTION WIDGETS =====
  /// Press-and-hold logging widget
  quickLog,

  /// List of recent entries
  recentEntries,
}

/// Size category for widgets
enum WidgetSize {
  /// Fits 2-3 per row (small stat cards)
  compact,

  /// Full width, short height
  standard,

  /// Full width, taller (heatmaps, charts)
  large,
}

/// Category for organizing widgets in picker
enum WidgetCategory {
  time('Time', Icons.schedule),
  duration('Duration', Icons.timer),
  count('Count', Icons.numbers),
  comparison('Comparison', Icons.compare_arrows),
  pattern('Pattern', Icons.insights),
  secondary('Ratings & Reasons', Icons.star_outline),
  action('Actions', Icons.touch_app);

  const WidgetCategory(this.displayName, this.icon);
  final String displayName;
  final IconData icon;
}

/// Metadata for each widget type
class WidgetCatalogEntry {
  final HomeWidgetType type;
  final String displayName;
  final String description;
  final IconData icon;
  final WidgetCategory category;
  final bool allowMultiple;
  final WidgetSize size;

  const WidgetCatalogEntry({
    required this.type,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.category,
    this.allowMultiple = false,
    this.size = WidgetSize.standard,
  });
}

/// Complete catalog of all available widgets with metadata
class WidgetCatalog {
  static const Map<HomeWidgetType, WidgetCatalogEntry> entries = {
    // ===== TIME-BASED =====
    HomeWidgetType.timeSinceLastHit: WidgetCatalogEntry(
      type: HomeWidgetType.timeSinceLastHit,
      displayName: 'Time Since Last',
      description: 'Live clock showing elapsed time since last entry',
      icon: Icons.timer_outlined,
      category: WidgetCategory.time,
      size: WidgetSize.standard,
    ),
    HomeWidgetType.avgTimeBetween: WidgetCatalogEntry(
      type: HomeWidgetType.avgTimeBetween,
      displayName: 'Average Gap',
      description: 'Average time between hits (today and 7-day)',
      icon: Icons.hourglass_empty,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.longestGapToday: WidgetCatalogEntry(
      type: HomeWidgetType.longestGapToday,
      displayName: 'Longest Gap Today',
      description: 'Maximum time between hits today',
      icon: Icons.hourglass_full,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.firstHitToday: WidgetCatalogEntry(
      type: HomeWidgetType.firstHitToday,
      displayName: 'First Hit Today',
      description: 'Time of first entry today',
      icon: Icons.wb_sunny_outlined,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.lastHitTime: WidgetCatalogEntry(
      type: HomeWidgetType.lastHitTime,
      displayName: 'Last Hit Time',
      description: 'When the last hit occurred',
      icon: Icons.access_time,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.peakHour: WidgetCatalogEntry(
      type: HomeWidgetType.peakHour,
      displayName: 'Peak Hour',
      description: 'Most active hour of day',
      icon: Icons.schedule,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.activeHoursToday: WidgetCatalogEntry(
      type: HomeWidgetType.activeHoursToday,
      displayName: 'Active Hours',
      description: 'Hours with at least one hit today',
      icon: Icons.view_timeline,
      category: WidgetCategory.time,
      size: WidgetSize.compact,
    ),

    // ===== DURATION-BASED =====
    HomeWidgetType.totalDurationToday: WidgetCatalogEntry(
      type: HomeWidgetType.totalDurationToday,
      displayName: 'Total Today',
      description: 'Sum of all durations today',
      icon: Icons.today,
      category: WidgetCategory.duration,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.avgDurationPerHit: WidgetCatalogEntry(
      type: HomeWidgetType.avgDurationPerHit,
      displayName: 'Avg Per Hit',
      description: 'Average duration per entry',
      icon: Icons.av_timer,
      category: WidgetCategory.duration,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.longestHitToday: WidgetCatalogEntry(
      type: HomeWidgetType.longestHitToday,
      displayName: 'Longest Hit',
      description: 'Maximum single duration today',
      icon: Icons.arrow_upward,
      category: WidgetCategory.duration,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.shortestHitToday: WidgetCatalogEntry(
      type: HomeWidgetType.shortestHitToday,
      displayName: 'Shortest Hit',
      description: 'Minimum single duration today',
      icon: Icons.arrow_downward,
      category: WidgetCategory.duration,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.totalDurationWeek: WidgetCatalogEntry(
      type: HomeWidgetType.totalDurationWeek,
      displayName: 'Total This Week',
      description: 'Cumulative duration for 7 days',
      icon: Icons.date_range,
      category: WidgetCategory.duration,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.durationTrend: WidgetCatalogEntry(
      type: HomeWidgetType.durationTrend,
      displayName: 'Duration Trend',
      description: 'Is average duration increasing or decreasing',
      icon: Icons.trending_up,
      category: WidgetCategory.duration,
      size: WidgetSize.standard,
    ),

    // ===== COUNT-BASED =====
    HomeWidgetType.hitsToday: WidgetCatalogEntry(
      type: HomeWidgetType.hitsToday,
      displayName: 'Hits Today',
      description: 'Total count of entries today',
      icon: Icons.touch_app,
      category: WidgetCategory.count,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.hitsThisWeek: WidgetCatalogEntry(
      type: HomeWidgetType.hitsThisWeek,
      displayName: 'Hits This Week',
      description: 'Total count for last 7 days',
      icon: Icons.view_week,
      category: WidgetCategory.count,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.dailyAvgHits: WidgetCatalogEntry(
      type: HomeWidgetType.dailyAvgHits,
      displayName: 'Daily Average',
      description: 'Average hits per day (7-day)',
      icon: Icons.equalizer,
      category: WidgetCategory.count,
      size: WidgetSize.compact,
    ),
    HomeWidgetType.hitsPerActiveHour: WidgetCatalogEntry(
      type: HomeWidgetType.hitsPerActiveHour,
      displayName: 'Hits/Active Hour',
      description: 'Hits divided by active hours',
      icon: Icons.speed,
      category: WidgetCategory.count,
      size: WidgetSize.compact,
    ),

    // ===== COMPARISON =====
    HomeWidgetType.todayVsYesterday: WidgetCatalogEntry(
      type: HomeWidgetType.todayVsYesterday,
      displayName: 'Today vs Yesterday',
      description: 'Side-by-side comparison',
      icon: Icons.compare_arrows,
      category: WidgetCategory.comparison,
      size: WidgetSize.standard,
    ),
    HomeWidgetType.todayVsWeekAvg: WidgetCatalogEntry(
      type: HomeWidgetType.todayVsWeekAvg,
      displayName: 'Today vs Week Avg',
      description: 'Compare today to baseline',
      icon: Icons.analytics,
      category: WidgetCategory.comparison,
      size: WidgetSize.standard,
    ),
    HomeWidgetType.weekdayVsWeekend: WidgetCatalogEntry(
      type: HomeWidgetType.weekdayVsWeekend,
      displayName: 'Weekday vs Weekend',
      description: 'Pattern comparison',
      icon: Icons.calendar_today,
      category: WidgetCategory.comparison,
      size: WidgetSize.standard,
    ),

    // ===== PATTERN =====
    HomeWidgetType.weeklyPattern: WidgetCatalogEntry(
      type: HomeWidgetType.weeklyPattern,
      displayName: 'Weekly Pattern',
      description: 'Day-of-week distribution',
      icon: Icons.bar_chart,
      category: WidgetCategory.pattern,
      size: WidgetSize.standard,
    ),
    HomeWidgetType.weekdayHeatmap: WidgetCatalogEntry(
      type: HomeWidgetType.weekdayHeatmap,
      displayName: 'Weekday Heatmap',
      description: 'Activity by hour (Mon–Fri)',
      icon: Icons.grid_on,
      category: WidgetCategory.pattern,
      size: WidgetSize.large,
    ),
    HomeWidgetType.weekendHeatmap: WidgetCatalogEntry(
      type: HomeWidgetType.weekendHeatmap,
      displayName: 'Weekend Heatmap',
      description: 'Activity by hour (Sat–Sun)',
      icon: Icons.grid_on,
      category: WidgetCategory.pattern,
      size: WidgetSize.large,
    ),

    // ===== SECONDARY =====
    HomeWidgetType.moodPhysicalAvg: WidgetCatalogEntry(
      type: HomeWidgetType.moodPhysicalAvg,
      displayName: 'Mood/Physical Avg',
      description: 'Average ratings today and 7-day',
      icon: Icons.mood,
      category: WidgetCategory.secondary,
      size: WidgetSize.standard,
    ),
    HomeWidgetType.topReasons: WidgetCatalogEntry(
      type: HomeWidgetType.topReasons,
      displayName: 'Top Reasons',
      description: 'Most common reasons this week',
      icon: Icons.label_outline,
      category: WidgetCategory.secondary,
      size: WidgetSize.standard,
    ),

    // ===== ACTION =====
    HomeWidgetType.quickLog: WidgetCatalogEntry(
      type: HomeWidgetType.quickLog,
      displayName: 'Quick Log',
      description: 'Press-and-hold to log',
      icon: Icons.add_circle_outline,
      category: WidgetCategory.action,
      size: WidgetSize.large,
    ),
    HomeWidgetType.recentEntries: WidgetCatalogEntry(
      type: HomeWidgetType.recentEntries,
      displayName: 'Recent Entries',
      description: 'Last entries list',
      icon: Icons.history,
      category: WidgetCategory.action,
      size: WidgetSize.large,
    ),
  };

  /// Get entry for a widget type
  static WidgetCatalogEntry getEntry(HomeWidgetType type) {
    return entries[type]!;
  }

  /// Get all entries for a category
  static List<WidgetCatalogEntry> getByCategory(WidgetCategory category) {
    return entries.values.where((entry) => entry.category == category).toList();
  }

  /// Get all entries grouped by category
  static Map<WidgetCategory, List<WidgetCatalogEntry>> getAllGrouped() {
    final grouped = <WidgetCategory, List<WidgetCatalogEntry>>{};
    for (final category in WidgetCategory.values) {
      grouped[category] = getByCategory(category);
    }
    return grouped;
  }

  /// Default widgets for new users
  static List<HomeWidgetType> get defaultWidgets => [
    HomeWidgetType.timeSinceLastHit,
    HomeWidgetType.quickLog,
    HomeWidgetType.hitsToday,
    HomeWidgetType.totalDurationToday,
    HomeWidgetType.moodPhysicalAvg,
    HomeWidgetType.recentEntries,
  ];
}
