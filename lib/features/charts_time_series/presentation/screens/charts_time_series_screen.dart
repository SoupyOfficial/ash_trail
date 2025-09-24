import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/charts_time_series_providers.dart';
import '../../domain/entities/chart_data_point.dart';
import '../../domain/entities/time_series_chart.dart';

/// Charts Time Series Screen
/// Displays interactive charts with aggregation controls
class ChartsTimeSeriesScreen extends ConsumerStatefulWidget {
  const ChartsTimeSeriesScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  ConsumerState<ChartsTimeSeriesScreen> createState() => _ChartsTimeSeriesScreenState();
}

class _ChartsTimeSeriesScreenState extends ConsumerState<ChartsTimeSeriesScreen> {
  @override
  Widget build(BuildContext context) {
    final chartDataAsync = ref.watch(chartDataProvider(widget.accountId));
    final hasDataAsync = ref.watch(hasChartDataProvider(widget.accountId));
    final chartConfig = ref.watch(chartConfigNotifierProvider(widget.accountId));
    final uiState = ref.watch(chartUIStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts'),
        actions: [
          IconButton(
            icon: Icon(uiState.showLegend ? Icons.legend_toggle : Icons.legend_toggle_outlined),
            onPressed: () => ref.read(chartUIStateNotifierProvider.notifier).toggleLegend(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Aggregation controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAggregationControls(context),
          ),
          
          // Chart area
          Expanded(
            child: hasDataAsync.when(
              data: (hasData) => hasData
                  ? chartDataAsync.when(
                      data: (result) => result.fold(
                        (failure) => _buildErrorState(context, failure.toString()),
                        (chart) => _buildChartView(context, chart),
                      ),
                      loading: () => _buildLoadingState(context),
                      error: (error, stack) => _buildErrorState(context, error.toString()),
                    )
                  : _buildEmptyState(context),
              loading: () => _buildLoadingState(context),
              error: (error, stack) => _buildErrorState(context, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregationControls(BuildContext context) {
    final config = ref.watch(chartConfigNotifierProvider(widget.accountId));
    final notifier = ref.read(chartConfigNotifierProvider(widget.accountId).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aggregation level toggle
            Row(
              children: [
                const Text('Time Period:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<ChartAggregation>(
                    segments: const [
                      ButtonSegment(
                        value: ChartAggregation.daily,
                        label: Text('Daily'),
                        icon: Icon(Icons.today),
                      ),
                      ButtonSegment(
                        value: ChartAggregation.weekly,
                        label: Text('Weekly'),
                        icon: Icon(Icons.view_week),
                      ),
                      ButtonSegment(
                        value: ChartAggregation.monthly,
                        label: Text('Monthly'),
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {config.aggregation},
                    onSelectionChanged: (selection) => notifier.setAggregation(selection.first),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Metric selection
            Row(
              children: [
                const Text('Metric:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<ChartMetric>(
                    value: config.metric,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: ChartMetric.count, child: Text('Count')),
                      DropdownMenuItem(value: ChartMetric.duration, child: Text('Total Duration')),
                      DropdownMenuItem(value: ChartMetric.averageDuration, child: Text('Average Duration')),
                      DropdownMenuItem(value: ChartMetric.moodScore, child: Text('Mood Score')),
                      DropdownMenuItem(value: ChartMetric.physicalScore, child: Text('Physical Score')),
                    ],
                    onChanged: (metric) => metric != null ? notifier.setMetric(metric) : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Smoothing options
            Row(
              children: [
                const Text('Smoothing:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<ChartSmoothing>(
                    value: config.smoothing,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: ChartSmoothing.none, child: Text('None')),
                      DropdownMenuItem(value: ChartSmoothing.movingAverage, child: Text('Moving Average')),
                      DropdownMenuItem(value: ChartSmoothing.cumulative, child: Text('Cumulative')),
                    ],
                    onChanged: (smoothing) => smoothing != null ? notifier.setSmoothing(smoothing) : null,
                  ),
                ),
              ],
            ),

            // Smoothing window if applicable
            if (config.smoothing == ChartSmoothing.movingAverage) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Window Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: config.smoothingWindow.toDouble(),
                      min: 2,
                      max: 14,
                      divisions: 12,
                      label: '${config.smoothingWindow} periods',
                      onChanged: (value) => notifier.setSmoothingWindow(value.round()),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartView(BuildContext context, TimeSeriesChart chart) {
    if (!chart.hasValidData) {
      return _buildEmptyState(context, message: 'No valid data for selected parameters');
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title and info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chart.formattedTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${chart.totalCount} entries • ${_formatDuration(chart.totalDurationMs)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Chart
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chart.dataPoints.length) {
                            final point = chart.dataPoints[index];
                            return Text(
                              point.formatTimestamp(chart.aggregation),
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatYAxisValue(value, chart.metric),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chart.validDataPoints.asMap().entries
                          .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
                          .toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: chart.validDataPoints.length <= 31, // Show dots for monthly or less
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < chart.validDataPoints.length) {
                            final point = chart.validDataPoints[index];
                            return LineTooltipItem(
                              '${point.formatTimestamp(chart.aggregation)}\n${_formatTooltipValue(point.value, chart.metric)}',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Legend if enabled
            if (ref.watch(chartUIStateNotifierProvider).showLegend) ...[
              const SizedBox(height: 16),
              _buildLegend(context, chart),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, TimeSeriesChart chart) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(context, 'Total', chart.totalCount.toString(), Icons.analytics),
          _buildLegendItem(context, 'Average', _formatDuration(chart.totalDurationMs ~/ chart.totalCount.clamp(1, double.infinity).toInt()), Icons.schedule),
          _buildLegendItem(context, 'Peak', _formatYAxisValue(chart.maxValue, chart.metric), Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading chart data...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No data available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting the time range or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(chartDataProvider(widget.accountId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatYAxisValue(double value, ChartMetric metric) {
    switch (metric) {
      case ChartMetric.count:
        return value.toInt().toString();
      case ChartMetric.duration:
        return _formatDuration(value.toInt());
      case ChartMetric.averageDuration:
        return _formatDuration(value.toInt());
      case ChartMetric.moodScore:
      case ChartMetric.physicalScore:
        return value.toStringAsFixed(1);
    }
  }

  String _formatTooltipValue(double value, ChartMetric metric) {
    switch (metric) {
      case ChartMetric.count:
        return '${value.toInt()} entries';
      case ChartMetric.duration:
        return 'Total: ${_formatDuration(value.toInt())}';
      case ChartMetric.averageDuration:
        return 'Avg: ${_formatDuration(value.toInt())}';
      case ChartMetric.moodScore:
        return 'Mood: ${value.toStringAsFixed(1)}/10';
      case ChartMetric.physicalScore:
        return 'Physical: ${value.toStringAsFixed(1)}/10';
    }
  }
}