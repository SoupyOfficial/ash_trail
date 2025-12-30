import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_record.dart';
import '../models/daily_rollup.dart';
import '../models/enums.dart';
import '../services/analytics_service.dart';

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Analytics Charts Widget per design doc 10.3.1, 9.2.3
/// Visualizes aggregated data with time range filters
class AnalyticsChartsWidget extends ConsumerStatefulWidget {
  final List<LogRecord> records;
  final String accountId;

  const AnalyticsChartsWidget({
    super.key,
    required this.records,
    required this.accountId,
  });

  @override
  ConsumerState<AnalyticsChartsWidget> createState() =>
      _AnalyticsChartsWidgetState();
}

class _AnalyticsChartsWidgetState extends ConsumerState<AnalyticsChartsWidget> {
  TimeRangeFilter _selectedRange = TimeRangeFilter.last7Days;
  RollingWindowStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant AnalyticsChartsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final analyticsService = ref.read(analyticsServiceProvider);
    final days = _selectedRange == TimeRangeFilter.last7Days ? 7 : 30;

    final stats = await analyticsService.computeRollingWindow(
      accountId: widget.accountId,
      records: widget.records,
      days: days,
    );

    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time range selector
        _buildTimeRangeSelector(context),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_stats == null)
          _buildNoDataState(context)
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Summary cards row
                  _buildSummaryCards(context, _stats!),
                  const SizedBox(height: 24),

                  // Activity chart placeholder
                  _buildActivityChart(context, _stats!),
                  const SizedBox(height: 24),

                  // Event type breakdown
                  _buildEventTypeBreakdown(context, _stats!),
                  const SizedBox(height: 24),

                  // Trend indicators
                  _buildTrendIndicators(context, _stats!),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return SegmentedButton<TimeRangeFilter>(
      segments: const [
        ButtonSegment(
          value: TimeRangeFilter.last7Days,
          label: Text('7 Days'),
          icon: Icon(Icons.calendar_view_week),
        ),
        ButtonSegment(
          value: TimeRangeFilter.last30Days,
          label: Text('30 Days'),
          icon: Icon(Icons.calendar_month),
        ),
      ],
      selected: {_selectedRange},
      onSelectionChanged: (Set<TimeRangeFilter> selected) {
        setState(() => _selectedRange = selected.first);
        _loadStats();
      },
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No data for this period',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging to see your analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, RollingWindowStats stats) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Total Entries',
            value: stats.totalEntries.toString(),
            icon: Icons.list_alt,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Total Time',
            value: stats.formattedDuration,
            icon: Icons.timer,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Daily Avg',
            value: stats.averageDailyEntries.toStringAsFixed(1),
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityChart(BuildContext context, RollingWindowStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Simple bar chart visualization
            SizedBox(
              height: 150,
              child: _buildSimpleBarChart(context, stats.dailyRollups),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context, List<DailyRollup> rollups) {
    if (rollups.isEmpty) {
      return const Center(child: Text('No data'));
    }

    // Find max value for scaling
    final maxValue = rollups
        .map((r) => r.eventCount)
        .fold(1, (a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          rollups.map((rollup) {
            final height =
                rollup.eventCount > 0
                    ? (rollup.eventCount / maxValue) * 130
                    : 4.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Tooltip(
                  message: '${rollup.date}: ${rollup.eventCount} entries',
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: rollup.eventCount > 0 ? 0.7 : 0.2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEventTypeBreakdown(
    BuildContext context,
    RollingWindowStats stats,
  ) {
    if (stats.eventTypeCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = stats.eventTypeCounts.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Types', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ...stats.eventTypeCounts.entries.map((entry) {
              final percentage = total > 0 ? (entry.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventTypeRow(
                  context,
                  entry.key,
                  entry.value,
                  percentage.toDouble(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeRow(
    BuildContext context,
    EventType type,
    int count,
    double percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _getEventTypeIcon(type),
                const SizedBox(width: 8),
                Text(type.name),
              ],
            ),
            Text('$count (${percentage.toStringAsFixed(0)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Widget _getEventTypeIcon(EventType type) {
    IconData icon;
    Color color;

    switch (type) {
      case EventType.inhale:
        icon = Icons.air;
        color = Colors.blue;
        break;
      case EventType.sessionStart:
        icon = Icons.play_circle;
        color = Colors.green;
        break;
      case EventType.sessionEnd:
        icon = Icons.stop_circle;
        color = Colors.red;
        break;
      case EventType.note:
        icon = Icons.note;
        color = Colors.orange;
        break;
      case EventType.tolerance:
        icon = Icons.trending_up;
        color = Colors.purple;
        break;
      case EventType.symptomRelief:
        icon = Icons.healing;
        color = Colors.teal;
        break;
      case EventType.purchase:
        icon = Icons.shopping_cart;
        color = Colors.amber;
        break;
      case EventType.custom:
        icon = Icons.star;
        color = Colors.grey;
        break;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildTrendIndicators(BuildContext context, RollingWindowStats stats) {
    final analyticsService = ref.read(analyticsServiceProvider);

    final entriesTrend = analyticsService.computeTrend(
      rollups: stats.dailyRollups,
      metric: 'entries',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trends', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _TrendIndicator(label: 'Activity', trend: entriesTrend),
            if (stats.averageMoodRating != null) ...[
              const SizedBox(height: 12),
              _TrendIndicator(
                label: 'Mood',
                trend: analyticsService.computeTrend(
                  rollups: stats.dailyRollups,
                  metric: 'mood',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Time range filter options
enum TimeRangeFilter { last7Days, last30Days }

/// Summary card widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend indicator widget
class _TrendIndicator extends StatelessWidget {
  final String label;
  final TrendDirection trend;

  const _TrendIndicator({required this.label, required this.trend});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String trendLabel;

    switch (trend) {
      case TrendDirection.up:
        icon = Icons.trending_up;
        color = Colors.green;
        trendLabel = 'Increasing';
        break;
      case TrendDirection.down:
        icon = Icons.trending_down;
        color = Colors.red;
        trendLabel = 'Decreasing';
        break;
      case TrendDirection.stable:
        icon = Icons.trending_flat;
        color = Colors.grey;
        trendLabel = 'Stable';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          trendLabel,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
