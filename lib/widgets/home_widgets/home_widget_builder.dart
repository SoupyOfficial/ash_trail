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

    switch (config.type) {
      // ===== TIME-BASED =====
      case HomeWidgetType.timeSinceLastHit:
        return _TimeSinceLastHitWidget(records: records, metrics: metrics);

      case HomeWidgetType.avgTimeBetween:
        return _buildAvgTimeBetween(context, metrics);

      case HomeWidgetType.longestGapToday:
        return _buildLongestGapToday(context, metrics);

      case HomeWidgetType.firstHitToday:
        return _buildFirstHitToday(context, metrics);

      case HomeWidgetType.lastHitTime:
        return _buildLastHitTime(context, metrics);

      case HomeWidgetType.peakHour:
        return _buildPeakHour(context, metrics);

      case HomeWidgetType.activeHoursToday:
        return _buildActiveHoursToday(context, metrics);

      // ===== DURATION-BASED =====
      case HomeWidgetType.totalDurationToday:
        return _buildTotalDurationToday(context, metrics);

      case HomeWidgetType.avgDurationPerHit:
        return _buildAvgDurationPerHit(context, metrics);

      case HomeWidgetType.longestHitToday:
        return _buildLongestHitToday(context, metrics);

      case HomeWidgetType.shortestHitToday:
        return _buildShortestHitToday(context, metrics);

      case HomeWidgetType.totalDurationWeek:
        return _buildTotalDurationWeek(context, metrics);

      case HomeWidgetType.durationTrend:
        return _buildDurationTrend(context, metrics);

      // ===== COUNT-BASED =====
      case HomeWidgetType.hitsToday:
        return _buildHitsToday(context, metrics);

      case HomeWidgetType.hitsThisWeek:
        return _buildHitsThisWeek(context, metrics);

      case HomeWidgetType.dailyAvgHits:
        return _buildDailyAvgHits(context, metrics);

      case HomeWidgetType.hitsPerActiveHour:
        return _buildHitsPerActiveHour(context, metrics);

      // ===== COMPARISON =====
      case HomeWidgetType.todayVsYesterday:
        return _buildTodayVsYesterday(context, metrics);

      case HomeWidgetType.todayVsWeekAvg:
        return _buildTodayVsWeekAvg(context, metrics);

      case HomeWidgetType.weekdayVsWeekend:
        return _buildWeekdayVsWeekend(context, metrics);

      // ===== PATTERN =====
      case HomeWidgetType.weeklyPattern:
        return _buildWeeklyPattern(context, metrics);

      case HomeWidgetType.hourlyHeatmap:
        return _buildHourlyHeatmap(context, metrics);

      // ===== SECONDARY =====
      case HomeWidgetType.moodPhysicalAvg:
        return _buildMoodPhysicalAvg(context, metrics);

      case HomeWidgetType.topReasons:
        return _buildTopReasons(context, metrics);

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
    }
  }

  // ===== TIME-BASED BUILDERS =====

  Widget _buildAvgTimeBetween(BuildContext context, HomeMetricsService metrics) {
    // Calculate average gap from first hit of the day
    final todayGap = metrics.getAverageGapToday(records);
    final weekGap = metrics.getAverageGap(records, days: 7);

    return StatCardWidget(
      title: 'Avg Gap (Today)',
      value: todayGap != null
          ? HomeMetricsService.formatDurationObject(todayGap)
          : '--',
      subtitle: weekGap != null
          ? '7d avg: ${HomeMetricsService.formatDurationObject(weekGap)}'
          : null,
      icon: Icons.hourglass_empty,
    );
  }

  Widget _buildLongestGapToday(BuildContext context, HomeMetricsService metrics) {
    final gap = metrics.getLongestGap(records, days: 1);

    return StatCardWidget(
      title: 'Longest Gap',
      value: gap != null
          ? HomeMetricsService.formatDurationObject(gap.gap)
          : '--',
      subtitle: 'today',
      icon: Icons.hourglass_full,
    );
  }

  Widget _buildFirstHitToday(BuildContext context, HomeMetricsService metrics) {
    final firstHit = metrics.getFirstHitToday(records);

    String value = '--';
    if (firstHit != null) {
      final hour = firstHit.hour;
      final minute = firstHit.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      value = '$hour12:${minute.toString().padLeft(2, '0')} $period';
    }

    return StatCardWidget(
      title: 'First Hit',
      value: value,
      subtitle: 'today',
      icon: Icons.wb_sunny_outlined,
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

  Widget _buildPeakHour(BuildContext context, HomeMetricsService metrics) {
    final peak = metrics.getPeakHour(records, days: 7);

    return StatCardWidget(
      title: 'Peak Hour',
      value: peak != null ? HomeMetricsService.formatHour(peak.hour) : '--',
      subtitle: peak != null ? '${peak.percentage.toStringAsFixed(0)}% of hits' : null,
      icon: Icons.schedule,
    );
  }

  Widget _buildActiveHoursToday(BuildContext context, HomeMetricsService metrics) {
    final activeHours = metrics.getActiveHoursToday(records);

    return StatCardWidget(
      title: 'Active Hours',
      value: '$activeHours',
      subtitle: 'today',
      icon: Icons.view_timeline,
    );
  }

  // ===== DURATION-BASED BUILDERS =====

  Widget _buildTotalDurationToday(BuildContext context, HomeMetricsService metrics) {
    final total = metrics.getTotalDurationToday(records);
    final comparison = metrics.getTodayVsYesterday(records);

    return StatCardWidget(
      title: 'Total Today',
      value: HomeMetricsService.formatDuration(total),
      subtitle: 'duration',
      icon: Icons.today,
      trendWidget: comparison.yesterdayDuration > 0
          ? TrendIndicator(percentChange: comparison.durationChange)
          : null,
    );
  }

  Widget _buildAvgDurationPerHit(BuildContext context, HomeMetricsService metrics) {
    final todayAvg = metrics.getAverageDurationToday(records);
    final yesterdayAvg = metrics.getAverageDuration(
      records.where((r) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        return r.eventAt.isAfter(yesterdayStart) && r.eventAt.isBefore(todayStart);
      }).toList(),
    );

    double? percentChange;
    if (todayAvg != null && yesterdayAvg != null && yesterdayAvg > 0) {
      percentChange = ((todayAvg - yesterdayAvg) / yesterdayAvg) * 100;
    }

    return StatCardWidget(
      title: 'Avg Per Hit',
      value: todayAvg != null ? '${todayAvg.toStringAsFixed(1)}s' : '--',
      subtitle: 'today',
      icon: Icons.av_timer,
      trendWidget: percentChange != null
          ? TrendIndicator(percentChange: percentChange)
          : null,
    );
  }

  Widget _buildLongestHitToday(BuildContext context, HomeMetricsService metrics) {
    final longest = metrics.getLongestHit(records, days: 1);

    return StatCardWidget(
      title: 'Longest Hit',
      value: longest != null
          ? HomeMetricsService.formatDuration(longest.duration)
          : '--',
      subtitle: 'today',
      icon: Icons.arrow_upward,
    );
  }

  Widget _buildShortestHitToday(BuildContext context, HomeMetricsService metrics) {
    final shortest = metrics.getShortestHit(records, days: 1);

    return StatCardWidget(
      title: 'Shortest Hit',
      value: shortest != null
          ? HomeMetricsService.formatDuration(shortest.duration)
          : '--',
      subtitle: 'today',
      icon: Icons.arrow_downward,
    );
  }

  Widget _buildTotalDurationWeek(BuildContext context, HomeMetricsService metrics) {
    final total = metrics.getTotalDuration(records, days: 7);
    final dailyAvg = total / 7;

    return StatCardWidget(
      title: 'Total This Week',
      value: HomeMetricsService.formatDuration(total),
      subtitle: 'avg ${HomeMetricsService.formatDuration(dailyAvg)}/day',
      icon: Icons.date_range,
    );
  }

  Widget _buildDurationTrend(BuildContext context, HomeMetricsService metrics) {
    final comparison = metrics.comparePeriods(
      records: records,
      metric: 'avgDuration',
      currentDays: 3,
      previousDays: 3,
    );

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Duration Trend',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
                      'Current avg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${comparison.current.toStringAsFixed(1)}s',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TrendIndicator(percentChange: comparison.percentChange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== COUNT-BASED BUILDERS =====

  Widget _buildHitsToday(BuildContext context, HomeMetricsService metrics) {
    final count = metrics.getHitCountToday(records);
    final comparison = metrics.getTodayVsYesterday(records);

    return StatCardWidget(
      title: 'Hits Today',
      value: '$count',
      subtitle: 'count',
      icon: Icons.touch_app,
      trendWidget: comparison.yesterdayCount > 0
          ? TrendIndicator(percentChange: comparison.countChange)
          : null,
    );
  }

  Widget _buildHitsThisWeek(BuildContext context, HomeMetricsService metrics) {
    final count = metrics.getHitCount(records, days: 7);
    final dailyAvg = count / 7;

    return StatCardWidget(
      title: 'Hits This Week',
      value: '$count',
      subtitle: 'avg ${dailyAvg.toStringAsFixed(1)}/day',
      icon: Icons.view_week,
    );
  }

  Widget _buildDailyAvgHits(BuildContext context, HomeMetricsService metrics) {
    final avg = metrics.getDailyAverageHits(records, days: 7);

    return StatCardWidget(
      title: 'Daily Average',
      value: avg.toStringAsFixed(1),
      subtitle: 'hits/day (7d)',
      icon: Icons.equalizer,
    );
  }

  Widget _buildHitsPerActiveHour(BuildContext context, HomeMetricsService metrics) {
    final ratio = metrics.getHitsPerActiveHour(records, days: 1);

    return StatCardWidget(
      title: 'Hits/Active Hour',
      value: ratio != null ? ratio.toStringAsFixed(1) : '--',
      subtitle: 'today',
      icon: Icons.speed,
    );
  }

  // ===== COMPARISON BUILDERS =====

  Widget _buildTodayVsYesterday(BuildContext context, HomeMetricsService metrics) {
    final comparison = metrics.getTodayVsYesterday(records);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Today vs Yesterday',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ComparisonColumn(
                    label: 'Today',
                    count: comparison.todayCount,
                    duration: comparison.todayDuration,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ComparisonColumn(
                    label: 'Yesterday',
                    count: comparison.yesterdayCount,
                    duration: comparison.yesterdayDuration,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayVsWeekAvg(BuildContext context, HomeMetricsService metrics) {
    final todayCount = metrics.getHitCountToday(records);
    final todayDuration = metrics.getTotalDurationToday(records);
    final weekAvgCount = metrics.getDailyAverageHits(records, days: 7);
    final weekAvgDuration = metrics.getTotalDuration(records, days: 7) / 7;

    final countDiff = weekAvgCount > 0
        ? ((todayCount - weekAvgCount) / weekAvgCount) * 100
        : 0.0;
    final durationDiff = weekAvgDuration > 0
        ? ((todayDuration - weekAvgDuration) / weekAvgDuration) * 100
        : 0.0;

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Today vs Week Avg',
                  style: Theme.of(context).textTheme.titleSmall,
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
                    TrendIndicator(percentChange: countDiff),
                  ],
                ),
                Column(
                  children: [
                    Text('Duration', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    TrendIndicator(percentChange: durationDiff),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayVsWeekend(BuildContext context, HomeMetricsService metrics) {
    final comparison = metrics.getWeekdayVsWeekend(records, days: 7);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
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
                      Text('Weekday', style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        '${comparison.weekdayAvgCount.toStringAsFixed(1)}/day',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('Weekend', style: Theme.of(context).textTheme.bodySmall),
                      Text(
                        '${comparison.weekendAvgCount.toStringAsFixed(1)}/day',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildWeeklyPattern(BuildContext context, HomeMetricsService metrics) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayCounts = List.filled(7, 0);

    for (final record in records.where((r) => !r.isDeleted)) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 6));
      if (record.eventAt.isAfter(weekStart)) {
        final dayIndex = record.eventAt.weekday - 1;
        dayCounts[dayIndex]++;
      }
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
                Icon(Icons.bar_chart, size: 20, color: Theme.of(context).colorScheme.primary),
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
                  final height = maxCount > 0 ? (dayCounts[index] / maxCount) * 40 : 0.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 24,
                        height: height + 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[index],
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

  Widget _buildHourlyHeatmap(BuildContext context, HomeMetricsService metrics) {
    final hourCounts = List.filled(24, 0);

    for (final record in records.where((r) => !r.isDeleted)) {
      hourCounts[record.eventAt.hour]++;
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
                Icon(Icons.grid_on, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Hourly Heatmap',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
                  message: '${HomeMetricsService.formatHour(index)}: $count hits',
                  child: Container(
                    decoration: BoxDecoration(
                      color: count > 0
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2 + intensity * 0.7)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: 9,
                          color: intensity > 0.5 ? Colors.white : Theme.of(context).colorScheme.onSurface,
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

  Widget _buildMoodPhysicalAvg(BuildContext context, HomeMetricsService metrics) {
    final todayMood = metrics.getAverageMood(records, days: 1);
    final todayPhysical = metrics.getAveragePhysical(records, days: 1);
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
                Icon(Icons.mood, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Mood & Physical',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _RatingColumn(
                    label: 'Mood',
                    todayValue: todayMood,
                    weekValue: weekMood,
                    icon: Icons.sentiment_satisfied,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RatingColumn(
                    label: 'Physical',
                    todayValue: todayPhysical,
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

  Widget _buildTopReasons(BuildContext context, HomeMetricsService metrics) {
    final topReasons = metrics.getTopReasons(records, days: 7, limit: 3);

    return Card(
      child: Padding(
        padding: Paddings.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Top Reasons',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
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
              ...topReasons.map((r) => Padding(
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
                  )),
          ],
        ),
      ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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

  const _TimeSinceLastHitWidget({
    required this.records,
    required this.metrics,
  });

  @override
  State<_TimeSinceLastHitWidget> createState() => _TimeSinceLastHitWidgetState();
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
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
    final sorted = records
        .where((r) => !r.isDeleted)
        .toList()
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
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
                Icon(Icons.history, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          ...recent.map((record) => _RecentEntryTile(
                record: record,
                onTap: onRecordTap,
                onDelete: onRecordDelete,
              )),
        ],
      ),
    );
  }
}

class _RecentEntryTile extends StatelessWidget {
  final LogRecord record;
  final VoidCallback? onTap;
  final Future<void> Function(LogRecord)? onDelete;

  const _RecentEntryTile({
    required this.record,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.logId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Are you sure you want to delete this entry?'),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: record.note?.isNotEmpty == true
            ? Text(
                record.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: record.duration > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
