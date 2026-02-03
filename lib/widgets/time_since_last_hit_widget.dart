import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/log_record.dart';
import '../services/home_metrics_service.dart';
import '../utils/pattern_analysis.dart'
    show PatternAnalysis, PeakHourData, DayPatternData;
import '../utils/design_constants.dart';
import '../utils/day_boundary.dart';

/// Statistics data class for cleaner organization
class _DailyStats {
  final int count;
  final double totalDuration;
  final double avgDuration;

  const _DailyStats({
    required this.count,
    required this.totalDuration,
    required this.avgDuration,
  });

  static const empty = _DailyStats(count: 0, totalDuration: 0, avgDuration: 0);
}

/// Widget that displays a live clock showing time since the last log entry
/// and statistics including counts and average durations with trend indicators
class TimeSinceLastHitWidget extends ConsumerStatefulWidget {
  final List<LogRecord> records;

  const TimeSinceLastHitWidget({super.key, required this.records});

  @override
  ConsumerState<TimeSinceLastHitWidget> createState() =>
      _TimeSinceLastHitWidgetState();
}

class _TimeSinceLastHitWidgetState
    extends ConsumerState<TimeSinceLastHitWidget> {
  Timer? _timer;
  Duration? _timeSinceLastHit;

  // Statistics
  _DailyStats _todayStats = _DailyStats.empty;
  _DailyStats _yesterdayStats = _DailyStats.empty;
  _DailyStats _weekStats = _DailyStats.empty;
  int _weekCount = 0;

  // Pattern analysis
  PeakHourData? _peakHour;
  List<DayPatternData> _dayPatterns = [];
  ({double weekdayAvg, double weekendAvg, String trend})?
  _weekdayWeekendComparison;

  // Collapsible section state
  bool _statsSectionExpanded = true;
  bool _patternSectionExpanded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _calculateStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimeSinceLastHitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate if records changed
    if (oldWidget.records != widget.records) {
      _updateTimeSinceLastHit();
      _calculateStats();
    }
  }

  void _startTimer() {
    _updateTimeSinceLastHit();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTimeSinceLastHit();
      }
    });
  }

  void _updateTimeSinceLastHit() {
    if (widget.records.isEmpty) {
      setState(() => _timeSinceLastHit = null);
      return;
    }

    // Find the most recent log entry
    final sortedRecords =
        widget.records.toList()..sort((a, b) => b.eventAt.compareTo(a.eventAt));
    final mostRecentRecord = sortedRecords.first;

    setState(() {
      _timeSinceLastHit = DateTime.now().difference(mostRecentRecord.eventAt);
    });
  }

  void _calculateStats() {
    if (widget.records.isEmpty) {
      setState(() {
        _todayStats = _DailyStats.empty;
        _yesterdayStats = _DailyStats.empty;
        _weekStats = _DailyStats.empty;
        _weekCount = 0;
      });
      return;
    }

    // Use 6am day boundary for more natural grouping of late-night activity
    final todayStart = DayBoundary.getTodayStart();
    final yesterdayStart = DayBoundary.getYesterdayStart();
    final weekStart = DayBoundary.getDayStartDaysAgo(7);

    // Filter records for each period
    final todayRecords =
        widget.records
            .where(
              (r) =>
                  r.eventAt.isAfter(todayStart) ||
                  r.eventAt.isAtSameMomentAs(todayStart),
            )
            .toList();

    final yesterdayRecords =
        widget.records
            .where(
              (r) =>
                  (r.eventAt.isAfter(yesterdayStart) ||
                      r.eventAt.isAtSameMomentAs(yesterdayStart)) &&
                  r.eventAt.isBefore(todayStart),
            )
            .toList();

    final weekRecords =
        widget.records
            .where(
              (r) =>
                  r.eventAt.isAfter(weekStart) ||
                  r.eventAt.isAtSameMomentAs(weekStart),
            )
            .toList();

    // Calculate stats for each period
    _todayStats = _calculatePeriodStats(todayRecords);
    _yesterdayStats = _calculatePeriodStats(yesterdayRecords);

    // For the week, calculate average per day
    final weekTotalDuration = weekRecords.fold<double>(
      0,
      (sum, r) => sum + r.duration,
    );

    // Calculate how many days have data in the last 7 days
    final daysWithData = <int>{};
    for (final record in weekRecords) {
      final dayOffset =
          todayStart
              .difference(
                DateTime(
                  record.eventAt.year,
                  record.eventAt.month,
                  record.eventAt.day,
                ),
              )
              .inDays;
      if (dayOffset >= 0 && dayOffset < 7) {
        daysWithData.add(dayOffset);
      }
    }

    final daysCount = daysWithData.isEmpty ? 1 : daysWithData.length;
    final weekAvgPerDay =
        weekRecords.isEmpty ? 0.0 : weekTotalDuration / daysCount;

    // Calculate pattern analysis for week data
    final peakHour = PatternAnalysis.getPeakHour(weekRecords);
    final dayPatterns = PatternAnalysis.getDayPatternsDetailed(weekRecords);
    final weekdayWeekendComparison =
        PatternAnalysis.getWeekdayWeekendComparison(weekRecords);

    setState(() {
      _weekStats = _DailyStats(
        count: weekRecords.length,
        totalDuration: weekTotalDuration,
        avgDuration: weekAvgPerDay,
      );
      _weekCount = weekRecords.length;

      // Update pattern analysis
      _peakHour = peakHour;
      _dayPatterns = dayPatterns;
      _weekdayWeekendComparison = weekdayWeekendComparison;
    });
  }

  _DailyStats _calculatePeriodStats(List<LogRecord> records) {
    if (records.isEmpty) {
      return _DailyStats.empty;
    }

    final totalDuration = records.fold<double>(0, (sum, r) => sum + r.duration);
    final avgDuration = totalDuration / records.length;

    return _DailyStats(
      count: records.length,
      totalDuration: totalDuration,
      avgDuration: avgDuration,
    );
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format duration as relative time (e.g., "Just now", "5m ago", "2h ago")
  String _formatRelativeDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'Just now';
    } else if (duration.inHours < 1) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inDays < 1) {
      return '${duration.inHours}h ago';
    } else if (duration.inDays < 7) {
      return '${duration.inDays}d ago';
    } else {
      final weeks = (duration.inDays / 7).floor();
      if (weeks < 4) {
        return '${weeks}w ago';
      } else {
        // Fall back to absolute format for very long durations (> 1 month)
        return _formatDuration(duration);
      }
    }
  }

  /// Format seconds (double) to a readable duration string
  String _formatSeconds(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final secs = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Calculate trend comparing today's avg to yesterday or week avg
  /// Returns: positive = increasing, negative = decreasing, 0 = no change
  double _calculateTrend(double currentAvg, double comparisonAvg) {
    if (comparisonAvg == 0) return 0;
    return ((currentAvg - comparisonAvg) / comparisonAvg) * 100;
  }

  /// Calculate trend for today's total duration based on hour-block pace.
  /// Compares today's accumulated duration to the expected amount by this hour
  /// (fullDayReference × elapsed fraction of day). Behind pace → negative,
  /// ahead of pace → positive. Avoids "always down until end of day" when
  /// comparing raw today total to yesterday's full-day total.
  /// Returns: positive = ahead of pace, negative = behind pace, 0 = no change / no reference
  double _calculateTrendHourBlock(double actualSoFar, double fullDayReference) {
    if (fullDayReference <= 0) return 0;
    final now = DateTime.now();
    final todayStart = DayBoundary.getTodayStart();
    final elapsed = now.difference(todayStart);
    const secondsPerDay = 24 * 60 * 60;
    final elapsedSeconds = elapsed.inSeconds.clamp(0, secondsPerDay);
    final fraction = elapsedSeconds / secondsPerDay;
    final expectedByNow = fullDayReference * fraction;
    if (expectedByNow <= 0) return 0;
    return ((actualSoFar - expectedByNow) / expectedByNow) * 100;
  }

  Widget _buildTrendIndicator(double trendPercent, BuildContext context) {
    if (trendPercent == 0) {
      return const SizedBox.shrink();
    }

    final isUp = trendPercent > 0;
    final colorScheme = Theme.of(context).colorScheme;
    // Use semantic colors: error for increase (more usage), tertiary/green for decrease (less usage)
    final color = isUp 
        ? colorScheme.error 
        : colorScheme.tertiaryContainer;
    final textColor = isUp
        ? colorScheme.onError
        : colorScheme.onTertiaryContainer;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${isUp ? '+' : ''}${trendPercent.abs().toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    Widget? trendWidget,
    String? tooltipDescription,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget cardContent = Card(
      elevation: ElevationLevel.sm.value,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadii.md,
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        onLongPress: tooltipDescription != null
            ? () {
                HapticFeedback.mediumImpact();
                _showTooltip(context, title, tooltipDescription);
              }
            : null,
        borderRadius: BorderRadii.md,
        child: Padding(
          padding: Paddings.md,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title with optional icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: IconSize.sm.value,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    SizedBox(width: Spacing.xs.value),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.sm.value),
              // Value - larger and more prominent with smooth transitions
              AnimatedSwitcher(
                duration: AnimationDuration.fast.duration,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  value,
                  key: ValueKey<String>(value),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: Spacing.xs.value),
              // Subtitle with trend widget
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trendWidget != null) ...[
                    SizedBox(width: Spacing.xs.value),
                    trendWidget,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Expanded(child: cardContent);
  }

  void _showTooltip(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDetailView(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Map<String, dynamic>? additionalData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                if (additionalData != null) ...[
                  const SizedBox(height: 24),
                  ...additionalData.entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                softWrap: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry.value.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build peak hour display
  Widget _buildPeakHourSection(BuildContext context) {
    if (_peakHour == null) {
      return const SizedBox.shrink();
    }

    final percentage = _peakHour!.percentage.toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showTooltip(
            context,
            'Peak Hour',
            'The hour of day when you most frequently log hits. This is calculated from your activity over the last 7 days.',
          );
        },
        onTap: () {
          HapticFeedback.lightImpact();
          // Get hour distribution for detail view (using 6am day boundary)
          final weekRecords = widget.records.where((r) {
            final weekStart = DayBoundary.getDayStartDaysAgo(7);
            return r.eventAt.isAfter(weekStart) ||
                r.eventAt.isAtSameMomentAs(weekStart);
          }).toList();
          
          final hourDistribution = <int, int>{};
          for (final record in weekRecords) {
            final hour = record.eventAt.hour;
            hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1;
          }
          
          final topHours = hourDistribution.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          
          final topHoursText = topHours.take(3).map((entry) {
            final hour12 = entry.key % 12 == 0 ? 12 : entry.key % 12;
            final period = entry.key < 12 ? 'AM' : 'PM';
            return '$hour12 $period (${entry.value} hits)';
          }).join(', ');
          
          _showDetailView(
            context,
            'Peak Hour',
            _peakHour!.formattedHour,
            '$percentage% of hits',
            {
              'Total Hits in Peak Hour': _peakHour!.count,
              'Total Hits (7d)': weekRecords.length,
              'Top 3 Hours': topHoursText,
              'Analysis': 'Most of your activity occurs during $_peakHour!.formattedHour.toLowerCase(), which represents $percentage% of your hits in the last 7 days.',
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Peak Hour',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_peakHour!.formattedHour} ($percentage%)',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build day-of-week patterns section
  Widget _buildDayPatternSection(BuildContext context) {
    if (_dayPatterns.isEmpty || _weekdayWeekendComparison == null) {
      return const SizedBox.shrink();
    }

    final comparison = _weekdayWeekendComparison!;
    final topDay = _dayPatterns.firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onLongPress: () => _showTooltip(
          context,
          'Weekly Pattern',
          'Shows your usage patterns across days of the week. Compares weekday vs weekend averages and identifies which day has the highest activity.',
        ),
        onTap: () {
          final dayBreakdown = _dayPatterns.map((day) => 
            '${day.dayName}: ${day.average.toStringAsFixed(1)}'
          ).join(', ');
          
          final weekdayWeekendDiff = (comparison.weekdayAvg - comparison.weekendAvg).abs();
          final weekdayHigher = comparison.weekdayAvg > comparison.weekendAvg;
          
          _showDetailView(
            context,
            'Weekly Pattern',
            topDay != null ? topDay.dayName : 'N/A',
            'Highest activity day',
            {
              'Weekday Average': '${comparison.weekdayAvg.toStringAsFixed(1)} sec/day',
              'Weekend Average': '${comparison.weekendAvg.toStringAsFixed(1)} sec/day',
              'Trend': comparison.trend,
              'Difference': '${weekdayWeekendDiff.toStringAsFixed(1)} sec (${weekdayHigher ? "weekdays" : "weekends"} higher)',
              'Day Breakdown': dayBreakdown,
              'Analysis': weekdayHigher
                  ? 'You tend to use more on weekdays than weekends'
                  : 'You tend to use more on weekends than weekdays',
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Weekly Pattern',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (topDay != null)
                  Text(
                    'Highest: ${topDay.dayName}',
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Weekday: ${comparison.weekdayAvg.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      'Weekend: ${comparison.weekendAvg.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.labelSmall,
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

  @override
  Widget build(BuildContext context) {
    if (_timeSinceLastHit == null) {
      final colorScheme = Theme.of(context).colorScheme;
      return Card(
        key: const Key('time_since_last_hit'),
        elevation: ElevationLevel.md.value,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadii.md,
        ),
        child: Padding(
          padding: Paddings.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: IconSize.xxl.value,
                color: colorScheme.primary.withOpacity(0.6),
              ),
              SizedBox(height: Spacing.md.value),
              Text(
                'No entries yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Spacing.xs.value),
              Text(
                'Time since last hit will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate trends
    // Average duration per hit trends (raw comparison)
    final todayVsYesterdayTrend = _calculateTrend(
      _todayStats.avgDuration,
      _yesterdayStats.avgDuration,
    );

    // Total duration trends: hour-block pace (expected-by-now vs actual so far)
    final todayTotalVsYesterdayTotalTrend = _calculateTrendHourBlock(
      _todayStats.totalDuration,
      _yesterdayStats.totalDuration,
    );
    final todayTotalVsWeekAvgTrend = _calculateTrendHourBlock(
      _todayStats.totalDuration,
      _weekStats.avgDuration,
    );

    final timeLabel = HomeMetricsService.formatTimeLabel(DateTime.now());

    return Card(
      key: const Key('time_since_last_hit'),
      elevation: ElevationLevel.md.value,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadii.md,
      ),
      child: Padding(
        padding: Paddings.lg,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Time since last hit header
              GestureDetector(
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  _showTooltip(
                    context,
                    'Time Since Last Hit',
                    'Shows how long it has been since your most recent log entry. This timer updates every second.',
                  );
                },
                onTap: () {
                  HapticFeedback.lightImpact();
                  final sortedRecords = widget.records.toList()
                    ..sort((a, b) => b.eventAt.compareTo(a.eventAt));
                  final mostRecentRecord = sortedRecords.isNotEmpty
                      ? sortedRecords.first
                      : null;
                  
                  _showDetailView(
                    context,
                    'Time Since Last Hit',
                    _formatDuration(_timeSinceLastHit!),
                    'since last entry',
                    mostRecentRecord != null
                        ? {
                            'Last Entry Time': mostRecentRecord.eventAt.toString().split('.')[0],
                            'Last Entry Duration': '${mostRecentRecord.duration.toStringAsFixed(1)} sec',
                            'Total Entries': widget.records.length,
                          }
                        : null,
                  );
                },
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Spacing.lg.value),
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                thickness: 1,
              ),
              SizedBox(height: Spacing.md.value),

              // Statistics section (collapsible)
              _buildCollapsibleSection(
                context: context,
                title: 'Statistics',
                isExpanded: _statsSectionExpanded,
                onToggle: () {
                  setState(() {
                    _statsSectionExpanded = !_statsSectionExpanded;
                  });
                },
                content: Column(
                  children: [
                    // Row 1: Total Duration Comparison (Today vs Yesterday)
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Total up to $timeLabel',
                          value: _formatSeconds(_todayStats.totalDuration),
                          subtitle: 'duration',
                          icon: Icons.today,
                          trendWidget: _buildTrendIndicator(todayTotalVsYesterdayTotalTrend, context),
                          tooltipDescription:
                              'Total duration today up to $timeLabel. Trend vs yesterday\'s pace (expected-by-this-hour); ahead or behind.',
                          onTap: () => _showDetailView(
                            context,
                            'Total up to $timeLabel',
                            _formatSeconds(_todayStats.totalDuration),
                            'total duration',
                            {
                              'Total Hits': _todayStats.count,
                              'Average per Hit': '${_todayStats.avgDuration.toStringAsFixed(1)} sec',
                              'Comparison': todayTotalVsYesterdayTotalTrend == 0
                                  ? 'On yesterday\'s pace'
                                  : todayTotalVsYesterdayTotalTrend > 0
                                      ? '${todayTotalVsYesterdayTotalTrend.toStringAsFixed(0)}% ahead of yesterday\'s pace'
                                      : '${todayTotalVsYesterdayTotalTrend.abs().toStringAsFixed(0)}% behind yesterday\'s pace',
                              'Yesterday Total': _formatSeconds(_yesterdayStats.totalDuration),
                            },
                          ),
                        ),
                        SizedBox(width: Spacing.sm.value),
                        _buildStatCard(
                          context,
                          title: 'Total Yesterday',
                          value: _formatSeconds(_yesterdayStats.totalDuration),
                          subtitle: 'duration',
                          icon: Icons.history,
                          tooltipDescription:
                              'Total duration of all hits yesterday. Sum of all individual hit durations.',
                          onTap: () => _showDetailView(
                            context,
                            'Total Yesterday',
                            _formatSeconds(_yesterdayStats.totalDuration),
                            'total duration',
                            {
                              'Total Hits': _yesterdayStats.count,
                              'Average per Hit': '${_yesterdayStats.avgDuration.toStringAsFixed(1)} sec',
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Spacing.sm.value),

                    // Row 2: Today vs Week Average
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Total up to $timeLabel',
                          value: _formatSeconds(_todayStats.totalDuration),
                          subtitle: 'duration',
                          icon: Icons.today,
                          trendWidget: _buildTrendIndicator(todayTotalVsWeekAvgTrend, context),
                          tooltipDescription:
                              'Total duration today up to $timeLabel. Trend vs 7-day avg pace (expected-by-this-hour); ahead or behind.',
                          onTap: () => _showDetailView(
                            context,
                            'Total up to $timeLabel',
                            _formatSeconds(_todayStats.totalDuration),
                            'total duration',
                            {
                              'Total Hits': _todayStats.count,
                              'Average per Hit': '${_todayStats.avgDuration.toStringAsFixed(1)} sec',
                              'Comparison': todayTotalVsWeekAvgTrend == 0
                                  ? 'On 7-day avg pace'
                                  : todayTotalVsWeekAvgTrend > 0
                                      ? '${todayTotalVsWeekAvgTrend.toStringAsFixed(0)}% ahead of 7-day avg pace'
                                      : '${todayTotalVsWeekAvgTrend.abs().toStringAsFixed(0)}% behind 7-day avg pace',
                              '7-Day Avg/Day': _formatSeconds(_weekStats.avgDuration),
                            },
                          ),
                        ),
                        SizedBox(width: Spacing.sm.value),
                        _buildStatCard(
                          context,
                          title: 'Avg/Day (7d)',
                          value: _formatSeconds(_weekStats.avgDuration),
                          subtitle: 'avg duration/day',
                          icon: Icons.calendar_view_week,
                          tooltipDescription:
                              'Average total duration per day over the last 7 days. Calculated by dividing total duration by number of days with data.',
                          onTap: () => _showDetailView(
                            context,
                            'Avg/Day (7d)',
                            _formatSeconds(_weekStats.avgDuration),
                            'avg duration/day',
                            {
                              'Total Hits (7d)': _weekCount,
                              'Total Duration (7d)': _formatSeconds(_weekStats.totalDuration),
                              'Days with Data': _weekStats.totalDuration > 0 ? '7 days' : '0 days',
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Spacing.sm.value),

                    // Row 3: Average Duration Per Hit (Today vs Yesterday)
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Avg Today',
                          value: _todayStats.avgDuration.toStringAsFixed(1),
                          subtitle: 'sec/hit',
                          icon: Icons.av_timer,
                          trendWidget: _buildTrendIndicator(todayVsYesterdayTrend, context),
                          tooltipDescription:
                              'Average duration per hit today. Shows percentage difference compared to yesterday.',
                          onTap: () => _showDetailView(
                            context,
                            'Avg Today',
                            _todayStats.avgDuration.toStringAsFixed(1),
                            'sec/hit',
                            {
                              'Total Hits': _todayStats.count,
                              'Total Duration': _formatSeconds(_todayStats.totalDuration),
                              'Comparison': todayVsYesterdayTrend == 0
                                  ? 'No change from yesterday'
                                  : todayVsYesterdayTrend > 0
                                      ? '${todayVsYesterdayTrend.toStringAsFixed(0)}% higher than yesterday'
                                      : '${todayVsYesterdayTrend.abs().toStringAsFixed(0)}% lower than yesterday',
                              'Yesterday Avg': '${_yesterdayStats.avgDuration.toStringAsFixed(1)} sec/hit',
                            },
                          ),
                        ),
                        SizedBox(width: Spacing.sm.value),
                        _buildStatCard(
                          context,
                          title: 'Avg Yesterday',
                          value: _yesterdayStats.avgDuration.toStringAsFixed(1),
                          subtitle: 'sec/hit',
                          icon: Icons.access_time,
                          tooltipDescription:
                              'Average duration per hit yesterday. Calculated by dividing total duration by number of hits.',
                          onTap: () => _showDetailView(
                            context,
                            'Avg Yesterday',
                            _yesterdayStats.avgDuration.toStringAsFixed(1),
                            'sec/hit',
                            {
                              'Total Hits': _yesterdayStats.count,
                              'Total Duration': _formatSeconds(_yesterdayStats.totalDuration),
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Spacing.sm.value),

                    // Row 4: Hit Counts (less prominent, moved to bottom)
                    Row(
                      children: [
                        _buildStatCard(
                          context,
                          title: 'Hits Today',
                          value: '${_todayStats.count}',
                          subtitle: 'count',
                          icon: Icons.touch_app,
                          tooltipDescription:
                              'Total number of hits logged today.',
                          onTap: () => _showDetailView(
                            context,
                            'Hits Today',
                            '${_todayStats.count}',
                            'hits',
                            {
                              'Total Duration': _formatSeconds(_todayStats.totalDuration),
                              'Average Duration': '${_todayStats.avgDuration.toStringAsFixed(1)} sec/hit',
                            },
                          ),
                        ),
                        SizedBox(width: Spacing.sm.value),
                        _buildStatCard(
                          context,
                          title: 'Hits This Week',
                          value: '$_weekCount',
                          subtitle: 'count (7d)',
                          icon: Icons.view_week,
                          tooltipDescription:
                              'Total number of hits logged in the last 7 days.',
                          onTap: () => _showDetailView(
                            context,
                            'Hits This Week',
                            '$_weekCount',
                            'hits',
                            {
                              'Total Duration (7d)': _formatSeconds(_weekStats.totalDuration),
                              'Average per Day': _formatSeconds(_weekStats.avgDuration),
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Pattern analysis section (collapsible)
              if (_peakHour != null || (_dayPatterns.isNotEmpty && _weekdayWeekendComparison != null)) ...[
                SizedBox(height: Spacing.lg.value),
                _buildCollapsibleSection(
                  context: context,
                  title: 'Patterns',
                  isExpanded: _patternSectionExpanded,
                  onToggle: () {
                    setState(() {
                      _patternSectionExpanded = !_patternSectionExpanded;
                    });
                  },
                  content: Column(
                    children: [
                      _buildPeakHourSection(context),
                      _buildDayPatternSection(context),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build a collapsible section with header and content
  Widget _buildCollapsibleSection({
    required BuildContext context,
    required String title,
    required Widget content,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          borderRadius: BorderRadii.sm,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Spacing.sm.value,
              horizontal: Spacing.xs.value,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: AnimationDuration.fast.duration,
                  curve: AnimationCurves.easeInOut,
                  child: Icon(
                    Icons.expand_more,
                    size: IconSize.md.value,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: AnimationDuration.normal.duration,
          curve: AnimationCurves.easeInOut,
          child: isExpanded
              ? content
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
