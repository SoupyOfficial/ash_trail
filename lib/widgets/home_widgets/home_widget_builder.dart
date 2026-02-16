import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_widget_config.dart';
import '../../models/log_record.dart';
import '../../models/enums.dart';
import '../../services/home_metrics_service.dart';
import '../../utils/design_constants.dart';
import '../home_quick_log_widget.dart';
import 'widget_catalog.dart';
import 'widget_settings_keys.dart';
import 'stat_card_widget.dart';

/// Builds the appropriate widget for a given HomeWidgetConfig
class HomeWidgetBuilder extends ConsumerWidget {
  final HomeWidgetConfig config;
  final List<LogRecord> records;
  final VoidCallback? onLogCreated;
  final VoidCallback? onRecordTap;
  final Future<void> Function(LogRecord)? onRecordDelete;

  const HomeWidgetBuilder({
    super.key,
    required this.config,
    required this.records,
    this.onLogCreated,
    this.onRecordTap,
    this.onRecordDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = HomeMetricsService();

    // ── Extract shared settings ──────────────────────────────────────────
    final defaults = WidgetSettingsDefaults.defaultsFor(config.type);
    final days =
        config.getSetting<int>(kTimeWindowDays) ??
        defaults[kTimeWindowDays] as int?;
    final eventTypeFilterRaw =
        config.getSetting<List<dynamic>>(kEventTypeFilter) ??
        defaults[kEventTypeFilter] as List<dynamic>?;
    final eventTypes = _parseEventTypes(eventTypeFilterRaw);
    final filteredRecords = metrics.filterRecords(
      records,
      days: days,
      eventTypes: eventTypes,
    );
    final timeLabel =
        days != null ? WidgetSettingsDefaults.timeWindowLabel(days) : null;
    final hasEventFilter = eventTypes != null && eventTypes.isNotEmpty;

    // ── Trend comparison period (per-widget) ─────────────────────────
    final trendPeriodName =
        config.getSetting<String>(kTrendComparisonPeriod) ??
        defaults[kTrendComparisonPeriod] as String? ??
        'previousDay';
    final trendPeriod = TrendComparisonPeriod.values.firstWhere(
      (e) => e.name == trendPeriodName,
      orElse: () => TrendComparisonPeriod.previousDay,
    );

    switch (config.type) {
      // ===== TIME-BASED =====
      case HomeWidgetType.timeSinceLastHit:
        return _TimeSinceLastHitWidget(records: records, metrics: metrics);

      case HomeWidgetType.avgTimeBetween:
        return _buildAvgTimeBetween(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.longestGapToday:
        return _buildLongestGap(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.firstHitToday:
        return _buildFirstHitToday(context, metrics, trendPeriod);

      case HomeWidgetType.lastHitTime:
        return _buildLastHitTime(context, metrics);

      case HomeWidgetType.peakHour:
        return _buildPeakHour(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.activeHoursToday:
        return _buildActiveHours(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      // ===== DURATION-BASED =====
      case HomeWidgetType.totalDurationToday:
        return _buildTotalDuration(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
          trendPeriod,
        );

      case HomeWidgetType.avgDurationPerHit:
        return _buildAvgDurationPerHit(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.longestHitToday:
        return _buildLongestHit(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.shortestHitToday:
        return _buildShortestHit(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.totalDurationWeek:
        return _buildTotalDurationWeek(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.durationTrend:
        return _buildDurationTrend(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
          trendPeriod,
        );

      // ===== COUNT-BASED =====
      case HomeWidgetType.hitsToday:
        return _buildHits(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.hitsThisWeek:
        return _buildHitsWeek(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.dailyAvgHits:
        return _buildDailyAvgHits(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.hitsPerActiveHour:
        return _buildHitsPerActiveHour(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      // ===== COMPARISON =====
      case HomeWidgetType.todayVsYesterday:
        return _buildTodayVsYesterday(
          context,
          metrics,
          filteredRecords,
          config.getSetting<String>(kComparisonTarget) ??
              defaults[kComparisonTarget] as String? ??
              'yesterday',
          trendPeriod,
        );

      case HomeWidgetType.todayVsWeekAvg:
        return _buildTodayVsWeekAvg(
          context,
          metrics,
          filteredRecords,
          trendPeriod,
        );

      case HomeWidgetType.weekdayVsWeekend:
        return _buildWeekdayVsWeekend(context, metrics, filteredRecords, days);

      // ===== PATTERN =====
      case HomeWidgetType.weeklyPattern:
        return _buildWeeklyPattern(context, metrics, filteredRecords, days);

      case HomeWidgetType.weekdayHeatmap:
        return _buildHeatmap(
          context,
          metrics,
          filteredRecords,
          _resolveHeatmapDayFilter(config, defaults),
        );

      case HomeWidgetType.weekendHeatmap:
        return _buildHeatmap(
          context,
          metrics,
          filteredRecords,
          _resolveHeatmapDayFilter(config, defaults),
        );

      // ===== SECONDARY =====
      case HomeWidgetType.moodPhysicalAvg:
        return _buildMoodPhysicalAvg(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      case HomeWidgetType.topReasons:
        return _buildTopReasons(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );

      // ===== ACTION =====
      case HomeWidgetType.quickLog:
        return HomeQuickLogWidget(onLogCreated: onLogCreated);

      case HomeWidgetType.recentEntries:
        return _RecentEntriesWidget(
          records: records,
          count: config.getSetting<int>('count') ?? 5,
          onRecordTap: onRecordTap,
          onRecordDelete: onRecordDelete,
        );

      case HomeWidgetType.customStat:
        return _buildCustomStat(
          context,
          metrics,
          filteredRecords,
          days,
          timeLabel,
          hasEventFilter,
        );
    }
  }

  /// Parse event type filter from settings (stored as List<String>).
  static List<EventType>? _parseEventTypes(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return null;
    final types = <EventType>[];
    for (final name in raw) {
      try {
        types.add(EventType.values.firstWhere((e) => e.name == name));
      } catch (_) {
        // skip unknown values
      }
    }
    return types.isEmpty ? null : types;
  }

  /// Resolve heatmap day filter from config or defaults.
  static HeatmapDayFilter _resolveHeatmapDayFilter(
    HomeWidgetConfig config,
    Map<String, dynamic> defaults,
  ) {
    final name =
        config.getSetting<String>(kHeatmapDayFilter) ??
        defaults[kHeatmapDayFilter] as String? ??
        'all';
    return HeatmapDayFilter.values.firstWhere(
      (e) => e.name == name,
      orElse: () => HeatmapDayFilter.all,
    );
  }

  /// Build a subtitle with an optional filter indicator.
  static String _subtitle(String base, bool hasEventFilter) {
    return hasEventFilter ? '$base (filtered)' : base;
  }

  // ===== TIME-BASED BUILDERS =====

  Widget _buildAvgTimeBetween(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final gap = metrics.getAverageGap(filteredRecords);
    final weekGap = metrics.getAverageGap(records, days: 7);

    return StatCardWidget(
      title: 'Avg Gap',
      value: gap != null ? HomeMetricsService.formatDurationObject(gap) : '--',
      subtitle: _subtitle(
        weekGap != null
            ? '7d avg: ${HomeMetricsService.formatDurationObject(weekGap)}'
            : (timeLabel ?? 'today'),
        hasEventFilter,
      ),
      icon: Icons.hourglass_empty,
    );
  }

  Widget _buildLongestGap(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final gap = metrics.getLongestGap(filteredRecords);

    return StatCardWidget(
      title: 'Longest Gap',
      value:
          gap != null ? HomeMetricsService.formatDurationObject(gap.gap) : '--',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.hourglass_full,
    );
  }

  Widget _buildFirstHitToday(
    BuildContext context,
    HomeMetricsService metrics,
    TrendComparisonPeriod trendPeriod,
  ) {
    final firstHit = metrics.getFirstHitToday(records);

    // Get comparison first hit based on period
    final comparisonRecords = metrics.getComparisonRecords(
      records,
      trendPeriod,
    );
    final comparisonSorted =
        comparisonRecords.where((r) => !r.isDeleted).toList()
          ..sort((a, b) => a.eventAt.compareTo(b.eventAt));
    final comparisonFirstHit =
        comparisonSorted.isNotEmpty ? comparisonSorted.first.eventAt : null;

    String value = '--';
    if (firstHit != null) {
      final hour = firstHit.hour;
      final minute = firstHit.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      value = '$hour12:${minute.toString().padLeft(2, '0')} $period';
    }

    String? subtitle;
    int? deltaMinutes;
    if (firstHit != null && comparisonFirstHit != null) {
      // Compare time-of-day only (hours + minutes)
      final todayMinutes = firstHit.hour * 60 + firstHit.minute;
      final compMinutes =
          comparisonFirstHit.hour * 60 + comparisonFirstHit.minute;
      deltaMinutes = todayMinutes - compMinutes;
      subtitle = trendPeriod.shortLabel;
    } else {
      subtitle = 'today';
    }

    return StatCardWidget(
      title: 'First Hit',
      value: value,
      subtitle: subtitle,
      icon: Icons.wb_sunny_outlined,
      // Later first hit = good (delayed use), so invert colors
      trendWidget:
          deltaMinutes != null && deltaMinutes != 0
              ? TrendIndicator(
                percentChange: deltaMinutes.toDouble(),
                invertColors: true,
                suffix: 'min',
                comparisonLabel: trendPeriod.shortLabel,
              )
              : null,
    );
  }

  Widget _buildLastHitTime(BuildContext context, HomeMetricsService metrics) {
    final lastRecord = metrics.getLastRecord(records);

    String value = '--';
    String? subtitle;
    if (lastRecord != null) {
      final hour = lastRecord.eventAt.hour;
      final minute = lastRecord.eventAt.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      value = '$hour12:${minute.toString().padLeft(2, '0')} $period';
      subtitle = HomeMetricsService.formatRelativeTime(lastRecord.eventAt);
    }

    return StatCardWidget(
      title: 'Last Hit',
      value: value,
      subtitle: subtitle,
      icon: Icons.access_time,
    );
  }

  Widget _buildPeakHour(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final peak = metrics.getPeakHour(filteredRecords);

    return StatCardWidget(
      title: 'Peak Hour',
      value: peak != null ? HomeMetricsService.formatHour(peak.hour) : '--',
      subtitle: _subtitle(
        peak != null
            ? '${peak.percentage.toStringAsFixed(0)}% of hits'
            : (timeLabel ?? '7 days'),
        hasEventFilter,
      ),
      icon: Icons.schedule,
    );
  }

  Widget _buildActiveHours(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final activeHours = metrics.getActiveHoursCount(filteredRecords);

    return StatCardWidget(
      title: 'Active Hours',
      value: '$activeHours',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.view_timeline,
    );
  }

  // ===== DURATION-BASED BUILDERS =====

  Widget _buildTotalDuration(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
    TrendComparisonPeriod trendPeriod,
  ) {
    // For the "today" case, keep the live-updating card
    if (days == 1 && !hasEventFilter) {
      return _TotalDurationTodayCard(
        records: records,
        trendPeriod: trendPeriod,
      );
    }
    final total = metrics.getTotalDuration(filteredRecords);
    return StatCardWidget(
      title: 'Total Duration',
      value: HomeMetricsService.formatDuration(total),
      subtitle: _subtitle(timeLabel ?? 'duration', hasEventFilter),
      icon: Icons.today,
    );
  }

  Widget _buildAvgDurationPerHit(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final avg = metrics.getAverageDuration(filteredRecords);

    return StatCardWidget(
      title: 'Avg Per Hit',
      value: avg != null ? '${avg.toStringAsFixed(1)}s' : '--',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.av_timer,
    );
  }

  Widget _buildLongestHit(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final longest = metrics.getLongestHit(filteredRecords);

    return StatCardWidget(
      title: 'Longest Hit',
      value:
          longest != null
              ? HomeMetricsService.formatDuration(longest.duration)
              : '--',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.arrow_upward,
    );
  }

  Widget _buildShortestHit(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final shortest = metrics.getShortestHit(filteredRecords);

    return StatCardWidget(
      title: 'Shortest Hit',
      value:
          shortest != null
              ? HomeMetricsService.formatDuration(shortest.duration)
              : '--',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.arrow_downward,
    );
  }

  Widget _buildTotalDurationWeek(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final effectiveDays = days ?? 7;
    final total = metrics.getTotalDuration(filteredRecords);
    final dailyAvg = total / effectiveDays;

    return StatCardWidget(
      title: 'Total Duration',
      value: HomeMetricsService.formatDuration(total),
      subtitle: _subtitle(
        'avg ${HomeMetricsService.formatDuration(dailyAvg)}/day',
        hasEventFilter,
      ),
      icon: Icons.date_range,
    );
  }

  Widget _buildDurationTrend(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
    TrendComparisonPeriod trendPeriod,
  ) {
    final effectiveDays = days ?? 3;
    final comparison = metrics.comparePeriods(
      records: filteredRecords,
      metric: 'avgDuration',
      currentDays: effectiveDays,
      previousDays: effectiveDays,
    );

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Duration Trend',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (hasEventFilter) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.filter_list,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current avg (${effectiveDays}d)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${comparison.current.toStringAsFixed(1)}s',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TrendIndicator(
                  percentChange: comparison.percentChange,
                  comparisonLabel: trendPeriod.shortLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== COUNT-BASED BUILDERS =====

  Widget _buildHits(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final count = metrics.getHitCount(filteredRecords);

    return StatCardWidget(
      title: 'Hits',
      value: '$count',
      subtitle: _subtitle(timeLabel ?? 'count', hasEventFilter),
      icon: Icons.touch_app,
    );
  }

  Widget _buildHitsWeek(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final effectiveDays = days ?? 7;
    final count = metrics.getHitCount(filteredRecords);
    final dailyAvg = count / effectiveDays;

    return StatCardWidget(
      title: 'Hits',
      value: '$count',
      subtitle: _subtitle(
        'avg ${dailyAvg.toStringAsFixed(1)}/day',
        hasEventFilter,
      ),
      icon: Icons.view_week,
    );
  }

  Widget _buildDailyAvgHits(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final effectiveDays = days ?? 7;
    final avg = metrics.getDailyAverageHits(
      filteredRecords,
      days: effectiveDays,
    );

    return StatCardWidget(
      title: 'Daily Average',
      value: avg.toStringAsFixed(1),
      subtitle: _subtitle('hits/day (${effectiveDays}d)', hasEventFilter),
      icon: Icons.equalizer,
    );
  }

  Widget _buildHitsPerActiveHour(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final ratio = metrics.getHitsPerActiveHour(filteredRecords);

    return StatCardWidget(
      title: 'Hits/Active Hour',
      value: ratio != null ? ratio.toStringAsFixed(1) : '--',
      subtitle: _subtitle(timeLabel ?? 'today', hasEventFilter),
      icon: Icons.speed,
    );
  }

  // ===== COMPARISON BUILDERS =====

  Widget _buildTodayVsYesterday(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    String comparisonTargetName,
    TrendComparisonPeriod trendPeriod,
  ) {
    // Get today's data
    final todayCount = metrics.getHitCountToday(filteredRecords);
    final todayDuration = metrics.getTotalDurationToday(filteredRecords);

    // Get comparison data based on period
    final compRecords = metrics.getComparisonRecords(
      filteredRecords,
      trendPeriod,
    );
    final compDays = HomeMetricsService.comparisonWindowDays(trendPeriod);
    final compCount = compRecords.where((r) => !r.isDeleted).length ~/ compDays;
    final compDuration = metrics.getTotalDuration(compRecords) / compDays;

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.compare_arrows,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Today ${trendPeriod.shortLabel}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ComparisonColumn(
                    label: 'Today',
                    count: todayCount,
                    duration: todayDuration,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ComparisonColumn(
                    label: trendPeriod.displayName,
                    count: compCount,
                    duration: compDuration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayVsWeekAvg(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    TrendComparisonPeriod trendPeriod,
  ) {
    final todayCount = metrics.getHitCountToday(filteredRecords);
    final todayDuration = metrics.getTotalDurationToday(filteredRecords);

    // Get comparison data based on period
    final compRecords = metrics.getComparisonRecords(
      filteredRecords,
      trendPeriod,
    );
    final compDays = HomeMetricsService.comparisonWindowDays(trendPeriod);
    final compCount = compRecords.where((r) => !r.isDeleted).length / compDays;
    final compDuration = metrics.getTotalDuration(compRecords) / compDays;

    final countDiff =
        compCount > 0 ? ((todayCount - compCount) / compCount) * 100 : 0.0;
    final durationDiff =
        compDuration > 0
            ? ((todayDuration - compDuration) / compDuration) * 100
            : 0.0;

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Today ${trendPeriod.shortLabel}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Hits', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    TrendIndicator(
                      percentChange: countDiff,
                      comparisonLabel: trendPeriod.shortLabel,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Duration',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    TrendIndicator(
                      percentChange: durationDiff,
                      comparisonLabel: trendPeriod.shortLabel,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayVsWeekend(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
  ) {
    final effectiveDays = days ?? 7;
    final comparison = metrics.getWeekdayVsWeekend(
      filteredRecords,
      days: effectiveDays,
    );

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekday vs Weekend',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Weekday',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${comparison.weekdayAvgCount.toStringAsFixed(1)}/day',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Weekend',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${comparison.weekendAvgCount.toStringAsFixed(1)}/day',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== PATTERN BUILDERS =====

  Widget _buildWeeklyPattern(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
  ) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayCounts = List.filled(7, 0);

    for (final record in filteredRecords.where((r) => !r.isDeleted)) {
      final dayIndex = record.eventAt.weekday - 1;
      dayCounts[dayIndex]++;
    }

    final maxCount = dayCounts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Weekly Pattern',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final height =
                      maxCount > 0 ? (dayCounts[index] / maxCount) * 40 : 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 24,
                        height: height + 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabels[index],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    HeatmapDayFilter dayFilter,
  ) {
    final title = switch (dayFilter) {
      HeatmapDayFilter.weekday => 'Weekday Heatmap',
      HeatmapDayFilter.weekend => 'Weekend Heatmap',
      HeatmapDayFilter.all => 'Hourly Heatmap',
    };

    bool Function(DateTime) filterFn = switch (dayFilter) {
      HeatmapDayFilter.weekday =>
        (dt) => dt.weekday >= DateTime.monday && dt.weekday <= DateTime.friday,
      HeatmapDayFilter.weekend =>
        (dt) =>
            dt.weekday == DateTime.saturday || dt.weekday == DateTime.sunday,
      HeatmapDayFilter.all => (_) => true,
    };

    final hourCounts = List.filled(24, 0);

    for (final record in filteredRecords.where((r) => !r.isDeleted)) {
      if (filterFn(record.eventAt)) {
        hourCounts[record.eventAt.hour]++;
      }
    }

    final maxCount = hourCounts.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grid_on,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                childAspectRatio: 1.2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final count = hourCounts[index];
                final intensity = maxCount > 0 ? count / maxCount : 0.0;

                return Tooltip(
                  message:
                      '${HomeMetricsService.formatHour(index)}: $count hits',
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          count > 0
                              ? Theme.of(context).colorScheme.primary
                                  .withOpacity(0.2 + intensity * 0.7)
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              intensity > 0.5
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== SECONDARY BUILDERS =====

  Widget _buildMoodPhysicalAvg(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final mood = metrics.getAverageMood(filteredRecords);
    final physical = metrics.getAveragePhysical(filteredRecords);
    final weekMood = metrics.getAverageMood(records, days: 7);
    final weekPhysical = metrics.getAveragePhysical(records, days: 7);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mood,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mood & Physical',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (hasEventFilter) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.filter_list,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RatingColumn(
                    label: 'Mood',
                    todayValue: mood,
                    weekValue: weekMood,
                    icon: Icons.sentiment_satisfied,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RatingColumn(
                    label: 'Physical',
                    todayValue: physical,
                    weekValue: weekPhysical,
                    icon: Icons.fitness_center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopReasons(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final topReasons = metrics.getTopReasons(filteredRecords, limit: 3);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Top Reasons',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (hasEventFilter) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.filter_list,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
            if (timeLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (topReasons.isEmpty)
              Text(
                'No reasons logged',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...topReasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(r.reason.icon, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.reason.displayName)),
                      Text(
                        '${r.count}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== CUSTOM STAT BUILDER =====

  Widget _buildCustomStat(
    BuildContext context,
    HomeMetricsService metrics,
    List<LogRecord> filteredRecords,
    int? days,
    String? timeLabel,
    bool hasEventFilter,
  ) {
    final metricName = config.getSetting<String>(kMetricType) ?? 'count';
    final metricType = MetricType.values.firstWhere(
      (m) => m.name == metricName,
      orElse: () => MetricType.count,
    );

    String value;
    switch (metricType) {
      case MetricType.count:
        value = '${metrics.getHitCount(filteredRecords)}';
      case MetricType.totalDuration:
        value = HomeMetricsService.formatDuration(
          metrics.getTotalDuration(filteredRecords),
        );
      case MetricType.avgDuration:
        final avg = metrics.getAverageDuration(filteredRecords);
        value = avg != null ? '${avg.toStringAsFixed(1)}s' : '--';
      case MetricType.mood:
        final mood = metrics.getAverageMood(filteredRecords);
        value = mood != null ? mood.toStringAsFixed(1) : '--';
      case MetricType.physical:
        final phys = metrics.getAveragePhysical(filteredRecords);
        value = phys != null ? phys.toStringAsFixed(1) : '--';
    }

    return StatCardWidget(
      title: metricType.displayName,
      value: value,
      subtitle: _subtitle(timeLabel ?? 'custom', hasEventFilter),
      icon: Icons.tune,
    );
  }
}

// ===== HELPER WIDGETS =====

class _ComparisonColumn extends StatelessWidget {
  final String label;
  final int count;
  final double duration;

  const _ComparisonColumn({
    required this.label,
    required this.count,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          '$count hits',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          HomeMetricsService.formatDuration(duration),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _RatingColumn extends StatelessWidget {
  final String label;
  final double? todayValue;
  final double? weekValue;
  final IconData icon;

  const _RatingColumn({
    required this.label,
    required this.todayValue,
    required this.weekValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          todayValue != null ? todayValue!.toStringAsFixed(1) : '--',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '7d: ${weekValue != null ? weekValue!.toStringAsFixed(1) : '--'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Live time since last hit widget with timer
class _TimeSinceLastHitWidget extends StatefulWidget {
  final List<LogRecord> records;
  final HomeMetricsService metrics;

  const _TimeSinceLastHitWidget({required this.records, required this.metrics});

  @override
  State<_TimeSinceLastHitWidget> createState() =>
      _TimeSinceLastHitWidgetState();
}

class _TimeSinceLastHitWidgetState extends State<_TimeSinceLastHitWidget> {
  Timer? _timer;
  Duration? _timeSinceLastHit;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_TimeSinceLastHitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      _updateTime();
    }
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTime();
      }
    });
  }

  void _updateTime() {
    final duration = widget.metrics.getTimeSinceLastHit(widget.records);
    setState(() {
      _timeSinceLastHit = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSinceLastHit == null) {
      return Card(
        child: Padding(
          padding: Paddings.xl,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 12),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: Paddings.lg,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time Since Last Hit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatRelativeDuration(_timeSinceLastHit!),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ago';
    } else {
      return '${duration.inDays}d ${duration.inHours % 24}h ago';
    }
  }
}

/// Recent entries widget showing last N entries
class _RecentEntriesWidget extends StatelessWidget {
  final List<LogRecord> records;
  final int count;
  final VoidCallback? onRecordTap;
  final Future<void> Function(LogRecord)? onRecordDelete;

  const _RecentEntriesWidget({
    required this.records,
    required this.count,
    this.onRecordTap,
    this.onRecordDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sorted =
        records.where((r) => !r.isDeleted).toList()
          ..sort((a, b) => b.eventAt.compareTo(a.eventAt));
    final recent = sorted.take(count).toList();

    if (recent.isEmpty) {
      return Card(
        child: Padding(
          padding: Paddings.xl,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Hold the duration button to log',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          ...recent.map(
            (record) => _RecentEntryTile(
              record: record,
              onTap: onRecordTap,
              onDelete: onRecordDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  final LogRecord record;
  final VoidCallback? onTap;
  final Future<void> Function(LogRecord)? onDelete;

  const _RecentEntryTile({required this.record, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.logId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Entry'),
                content: const Text(
                  'Are you sure you want to delete this entry?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (_) => onDelete?.call(record),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getEventIcon(record.eventType),
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          HomeMetricsService.formatRelativeTime(record.eventAt),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle:
            record.note?.isNotEmpty == true
                ? Text(
                  record.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                : null,
        trailing:
            record.duration > 0
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    HomeMetricsService.formatDuration(record.duration),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                : null,
        onTap: onTap,
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.vape:
        return Icons.cloud;
      case EventType.inhale:
        return Icons.air;
      case EventType.sessionStart:
        return Icons.play_arrow;
      case EventType.sessionEnd:
        return Icons.stop;
      case EventType.note:
        return Icons.note;
      case EventType.purchase:
        return Icons.shopping_cart;
      case EventType.tolerance:
        return Icons.trending_up;
      case EventType.symptomRelief:
        return Icons.healing;
      case EventType.custom:
        return Icons.circle;
    }
  }
}

/// Card showing today's total duration up to current (or selected) time,
/// with hour-block trend. Rebuilds every minute to update the time label.
/// Updates every minute to show current time.
class _TotalDurationTodayCard extends StatefulWidget {
  final List<LogRecord> records;
  final TrendComparisonPeriod trendPeriod;

  const _TotalDurationTodayCard({
    required this.records,
    required this.trendPeriod,
  });

  @override
  State<_TotalDurationTodayCard> createState() =>
      _TotalDurationTodayCardState();
}

class _TotalDurationTodayCardState extends State<_TotalDurationTodayCard> {
  late DateTime _asOf;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _asOf = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _asOf = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asOf = _asOf;
    final metrics = HomeMetricsService();

    // Today's duration up to now
    final data = metrics.getTodayDurationUpTo(widget.records, asOf: asOf);

    // Compute trend using the user-selected comparison period
    final compRecords = metrics.getComparisonRecords(
      widget.records,
      widget.trendPeriod,
      now: asOf,
    );
    final compTotal = metrics.getTotalDuration(compRecords);
    final trend = metrics.computeHourBlockTrend(
      actualSoFar: data.duration,
      fullDayReference: compTotal,
      period: widget.trendPeriod,
      asOf: asOf,
    );

    return StatCardWidget(
      title: 'Total up to ${data.timeLabel}',
      value: HomeMetricsService.formatDuration(data.duration),
      subtitle: 'duration',
      icon: Icons.today,
      trendWidget:
          trend != 0
              ? TrendIndicator(
                percentChange: trend,
                comparisonLabel: widget.trendPeriod.shortLabel,
              )
              : null,
    );
  }
}
