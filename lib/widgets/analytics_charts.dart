import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/log_record.dart';
import '../services/analytics_service.dart';
import 'charts/charts.dart';

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
  ChartTimeRange _selectedRange = ChartTimeRange.last7Days;
  DateTimeRange? _customRange;
  RollingWindowStats? _stats;
  bool _isLoading = true;
  ChartViewType _chartType = ChartViewType.bar;
  List<LogRecord>?
  _currentFilteredRecords; // Cache filtered records for heatmaps
  int? _pendingLoadId; // Track async load requests to prevent race conditions

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant AnalyticsChartsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload stats if records change OR account changes
    if (oldWidget.records != widget.records ||
        oldWidget.accountId != widget.accountId) {
      // Clear custom date range when switching accounts to prevent confusion
      if (oldWidget.accountId != widget.accountId) {
        _selectedRange = ChartTimeRange.last7Days;
        _customRange = null;
        _currentFilteredRecords = null;
      }
      _loadStats();
    }
  }

  int get _currentDays {
    switch (_selectedRange) {
      case ChartTimeRange.last7Days:
        return 7;
      case ChartTimeRange.last14Days:
        return 14;
      case ChartTimeRange.last30Days:
        return 30;
      case ChartTimeRange.custom:
        if (_customRange != null) {
          return _customRange!.end.difference(_customRange!.start).inDays + 1;
        }
        return 7;
    }
  }

  Future<void> _loadStats() async {
    // Assign unique ID to this load request to prevent race conditions
    final loadId = DateTime.now().millisecondsSinceEpoch;
    _pendingLoadId = loadId;

    setState(() => _isLoading = true);

    final analyticsService = ref.read(analyticsServiceProvider);

    late RollingWindowStats stats;
    late List<LogRecord> recordsToUse;

    if (_selectedRange == ChartTimeRange.custom && _customRange != null) {
      // Validate date range: ensure end date >= start date
      if (_customRange!.end.isBefore(_customRange!.start)) {
        if (mounted) {
          setState(() {
            _stats = null;
            _isLoading = false;
            _currentFilteredRecords = [];
          });
        }
        return;
      }

      // For custom range, filter records by date range
      // Use inclusive boundaries: [start 00:00, end 23:59:59]
      final startOfDay = DateTime(
        _customRange!.start.year,
        _customRange!.start.month,
        _customRange!.start.day,
      );
      final endOfDay = DateTime(
        _customRange!.end.year,
        _customRange!.end.month,
        _customRange!.end.day,
        23,
        59,
        59,
      );

      recordsToUse =
          widget.records.where((record) {
            // Inclusive bounds: record time must be within [startOfDay, endOfDay]
            return !record.eventAt.isBefore(startOfDay) &&
                !record.eventAt.isAfter(endOfDay);
          }).toList();
    } else {
      // For preset ranges, use the full record set
      recordsToUse = widget.records;
    }

    // Cache filtered records for use in heatmaps
    _currentFilteredRecords = recordsToUse;

    stats = await analyticsService.computeRollingWindow(
      accountId: widget.accountId,
      records: recordsToUse,
      days: _currentDays,
    );

    // Only update state if this is still the latest load request
    if (mounted && _pendingLoadId == loadId) {
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
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_stats == null)
          Expanded(child: _buildNoDataState(context))
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Summary cards row
                  _buildSummaryCards(context, _stats!),
                  const SizedBox(height: 24),

                  // Chart type selector
                  _buildChartTypeSelector(context),
                  const SizedBox(height: 16),

                  // Activity chart - show different chart based on selection
                  _buildActivityChart(context, _stats!),
                  const SizedBox(height: 24),

                  // Hourly activity heatmap
                  // Use filtered records to match the selected date range
                  HourlyHeatmap(
                    records: _currentFilteredRecords ?? widget.records,
                    title: 'Activity by Hour',
                    baseColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Weekly pattern heatmap
                  // Use filtered records to match the selected date range
                  WeeklyHeatmap(
                    records: _currentFilteredRecords ?? widget.records,
                    title: 'Weekly Pattern',
                    baseColor: Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Trend indicators
                  _buildTrendIndicators(context, _stats!),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTimeChip(ChartTimeRange.last7Days, '7 Days'),
                    const SizedBox(width: 8),
                    _buildTimeChip(ChartTimeRange.last14Days, '14 Days'),
                    const SizedBox(width: 8),
                    _buildTimeChip(ChartTimeRange.last30Days, '30 Days'),
                    const SizedBox(width: 8),
                    _buildTimeChip(ChartTimeRange.custom, 'Custom'),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.date_range),
              tooltip: 'Custom Date Range',
              onPressed: _showCustomRangePicker,
            ),
          ],
        ),
        if (_selectedRange == ChartTimeRange.custom && _customRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Range: ${DateFormat('MMM d, yyyy').format(_customRange!.start)} - ${DateFormat('MMM d, yyyy').format(_customRange!.end)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeChip(ChartTimeRange range, String label) {
    final isSelected = _selectedRange == range;
    String displayLabel = label;

    if (range == ChartTimeRange.custom && _customRange != null) {
      // Only show formatted range if it's valid
      if (!_customRange!.end.isBefore(_customRange!.start)) {
        displayLabel =
            '${DateFormat.MMMd().format(_customRange!.start)} - ${DateFormat.MMMd().format(_customRange!.end)}';
      }
    }

    return FilterChip(
      label: Text(displayLabel),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          if (range == ChartTimeRange.custom) {
            _showCustomRangePicker();
          } else {
            setState(() {
              _selectedRange = range;
              _customRange = null;
              _currentFilteredRecords = null; // Clear filtered records cache
            });
            _loadStats();
          }
        }
      },
    );
  }

  Future<void> _showCustomRangePicker() async {
    final now = DateTime.now();
    final initialStart =
        _customRange?.start ?? now.subtract(const Duration(days: 7));
    final initialEnd = _customRange?.end ?? now;

    final result = await showTimeRangePicker(
      context: context,
      initialStart: initialStart,
      initialEnd: initialEnd,
    );

    if (result != null && mounted) {
      // Validate: reject if end date is before start date
      if (result.end.isBefore(result.start)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be on or after the start date'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Reject if start date is in the future
      if (result.start.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start date cannot be in the future'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      setState(() {
        _selectedRange = ChartTimeRange.custom;
        _customRange = result;
      });
      _loadStats();
    }
  }

  Widget _buildChartTypeSelector(BuildContext context) {
    return SegmentedButton<ChartViewType>(
      segments: const [
        ButtonSegment(
          value: ChartViewType.bar,
          icon: Icon(Icons.bar_chart),
          label: Text('Bar'),
        ),
        ButtonSegment(
          value: ChartViewType.line,
          icon: Icon(Icons.show_chart),
          label: Text('Line'),
        ),
      ],
      selected: {_chartType},
      onSelectionChanged: (Set<ChartViewType> selected) {
        setState(() => _chartType = selected.first);
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
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            title: 'Total Time',
            value: stats.formattedDuration,
            icon: Icons.timer,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
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
    if (_chartType == ChartViewType.line) {
      return ActivityLineChart(
        rollups: stats.dailyRollups,
        title: 'Daily Activity Trend',
        lineColor: Theme.of(context).colorScheme.primary,
      );
    }
    return ActivityBarChart(
      rollups: stats.dailyRollups,
      title: 'Daily Activity',
      barColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildTrendIndicators(BuildContext context, RollingWindowStats stats) {
    final analyticsService = ref.read(analyticsServiceProvider);

    final entriesTrend = analyticsService.computeTrend(
      rollups: stats.dailyRollups,
      metric: 'entries',
    );

    final durationTrend = analyticsService.computeTrend(
      rollups: stats.dailyRollups,
      metric: 'duration',
    );

    String rangeLabel = _getDateRangeLabel();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trends', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  rangeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TrendIndicator(label: 'Activity', trend: entriesTrend),
            const SizedBox(height: 12),
            _TrendIndicator(label: 'Duration', trend: durationTrend),
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

  String _getDateRangeLabel() {
    if (_selectedRange == ChartTimeRange.custom && _customRange != null) {
      // Validate range to prevent showing negative day counts
      if (_customRange!.end.isBefore(_customRange!.start)) {
        return 'Invalid range';
      }
      final daysDiff =
          _customRange!.end.difference(_customRange!.start).inDays + 1;
      return '$daysDiff days';
    }
    return 'Last $_currentDays days';
  }
}

/// Time range options for charts
enum ChartTimeRange { last7Days, last14Days, last30Days, custom }

/// Chart view type options
enum ChartViewType { bar, line }

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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            trendLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
