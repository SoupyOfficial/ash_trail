import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/log_record.dart';

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

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(const Duration(days: 7));

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

    setState(() {
      _weekStats = _DailyStats(
        count: weekRecords.length,
        totalDuration: weekTotalDuration,
        avgDuration: weekAvgPerDay,
      );
      _weekCount = weekRecords.length;
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

  /// Calculate trend comparing today's avg to yesterday or week avg
  /// Returns: positive = increasing, negative = decreasing, 0 = no change
  double _calculateTrend(double currentAvg, double comparisonAvg) {
    if (comparisonAvg == 0) return 0;
    return ((currentAvg - comparisonAvg) / comparisonAvg) * 100;
  }

  Widget _buildTrendIndicator(double trendPercent) {
    if (trendPercent == 0) {
      return const SizedBox.shrink();
    }

    final isUp = trendPercent > 0;
    final color = isUp ? Colors.orange : Colors.green;
    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '${trendPercent.abs().toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    Widget? trendWidget,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trendWidget != null) ...[
                    const SizedBox(width: 4),
                    trendWidget,
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSinceLastHit == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'No entries yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Time since last hit will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculate trends
    final todayVsYesterdayTrend = _calculateTrend(
      _todayStats.avgDuration,
      _yesterdayStats.avgDuration,
    );
    final todayVsWeekTrend = _calculateTrend(
      _todayStats.avgDuration,
      _weekStats.avgDuration,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Time since last hit header
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
              _formatDuration(_timeSinceLastHit!),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),

            // Count stats row
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Today',
                  value: '${_todayStats.count}',
                  subtitle: 'hits',
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  context,
                  title: 'This Week',
                  value: '$_weekCount',
                  subtitle: 'hits',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Average duration stats row
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Avg Today',
                  value: _todayStats.avgDuration.toStringAsFixed(1),
                  subtitle: 'sec/hit',
                  trendWidget: _buildTrendIndicator(todayVsYesterdayTrend),
                ),
                const SizedBox(width: 8),
                _buildStatCard(
                  context,
                  title: 'Avg Yesterday',
                  value: _yesterdayStats.avgDuration.toStringAsFixed(1),
                  subtitle: 'sec/hit',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Week average with trend comparison
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Avg/Day (7d)',
                  value: _weekStats.avgDuration.toStringAsFixed(1),
                  subtitle: 'sec/day',
                  trendWidget: _buildTrendIndicator(todayVsWeekTrend),
                ),
                const SizedBox(width: 8),
                // Trend summary card
                Expanded(
                  child: Card(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trend',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildTrendSummary(context, todayVsWeekTrend),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSummary(BuildContext context, double trendPercent) {
    if (trendPercent == 0 || _todayStats.count == 0) {
      return Text(
        'No data',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final isUp = trendPercent > 0;
    final color = isUp ? Colors.orange : Colors.green;
    final text = isUp ? 'Higher than avg' : 'Lower than avg';
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
