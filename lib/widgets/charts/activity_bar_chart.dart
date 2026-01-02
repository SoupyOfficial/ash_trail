import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/daily_rollup.dart';

/// Interactive bar chart showing daily activity
/// Uses fl_chart for smooth animations and touch interactions
class ActivityBarChart extends StatefulWidget {
  final List<DailyRollup> rollups;
  final String title;
  final Color barColor;
  final bool showDuration;

  const ActivityBarChart({
    super.key,
    required this.rollups,
    this.title = 'Daily Activity',
    this.barColor = Colors.blue,
    this.showDuration = false,
  });

  @override
  State<ActivityBarChart> createState() => _ActivityBarChartState();
}

class _ActivityBarChartState extends State<ActivityBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.rollups.isEmpty) {
      return _buildEmptyState(context);
    }

    final maxY = _getMaxValue();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_touchedIndex >= 0 && _touchedIndex < widget.rollups.length)
                  _buildTooltipBadge(context, widget.rollups[_touchedIndex]),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.1,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor:
                          (group) =>
                              Theme.of(context).colorScheme.inverseSurface,
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final rollup = widget.rollups[groupIndex];
                        final value =
                            widget.showDuration
                                ? '${rollup.totalValue.toStringAsFixed(0)}s'
                                : '${rollup.eventCount} entries';
                        return BarTooltipItem(
                          '${rollup.date}\n$value',
                          TextStyle(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.spot == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex = response.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: _buildTitlesData(context, maxY),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: Theme.of(
                            context,
                          ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        ),
                  ),
                  barGroups: _buildBarGroups(),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (widget.rollups.isEmpty) return 5;

    final values = widget.rollups.map(
      (r) => widget.showDuration ? r.totalValue : r.eventCount.toDouble(),
    );
    final max = values.fold(0.0, (a, b) => a > b ? a : b);
    return max > 0 ? max : 5;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.rollups.asMap().entries.map((entry) {
      final index = entry.key;
      final rollup = entry.value;
      final value =
          widget.showDuration
              ? rollup.totalValue
              : rollup.eventCount.toDouble();
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color:
                isTouched
                    ? widget.barColor
                    : widget.barColor.withValues(alpha: 0.7),
            width: _calculateBarWidth(),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxValue() * 1.1,
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  double _calculateBarWidth() {
    final count = widget.rollups.length;
    if (count <= 7) return 20;
    if (count <= 14) return 12;
    if (count <= 30) return 8;
    return 4;
  }

  FlTitlesData _buildTitlesData(BuildContext context, double maxY) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= widget.rollups.length) {
              return const SizedBox.shrink();
            }

            // Show fewer labels when there are many bars
            final interval = _calculateLabelInterval();
            if (index % interval != 0 && index != widget.rollups.length - 1) {
              return const SizedBox.shrink();
            }

            final rollup = widget.rollups[index];
            final parts = rollup.date.split('-');
            if (parts.length == 3) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${parts[1]}/${parts[2]}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  int _calculateLabelInterval() {
    final count = widget.rollups.length;
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return 7;
  }

  Widget _buildTooltipBadge(BuildContext context, DailyRollup rollup) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.barColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.barColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.showDuration
            ? '${rollup.totalValue.toStringAsFixed(0)}s on ${rollup.date}'
            : '${rollup.eventCount} on ${rollup.date}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: widget.barColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
