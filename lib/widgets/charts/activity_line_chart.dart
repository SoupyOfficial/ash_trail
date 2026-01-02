import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/daily_rollup.dart';

/// Interactive line chart showing daily activity trends
/// Uses fl_chart for smooth animations and touch interactions
class ActivityLineChart extends StatefulWidget {
  final List<DailyRollup> rollups;
  final String title;
  final Color lineColor;
  final bool showDuration;

  const ActivityLineChart({
    super.key,
    required this.rollups,
    this.title = 'Daily Activity',
    this.lineColor = Colors.blue,
    this.showDuration = false,
  });

  @override
  State<ActivityLineChart> createState() => _ActivityLineChartState();
}

class _ActivityLineChartState extends State<ActivityLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.rollups.isEmpty) {
      return _buildEmptyState(context);
    }

    final spots = _buildSpots();
    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);

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
                if (_touchedIndex != null &&
                    _touchedIndex! < widget.rollups.length)
                  _buildTooltipBadge(context, widget.rollups[_touchedIndex!]),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
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
                  minX: 0,
                  maxX: (widget.rollups.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY > 0 ? maxY * 1.1 : 5,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor:
                          (spot) =>
                              Theme.of(context).colorScheme.inverseSurface,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final rollup = widget.rollups[spot.x.toInt()];
                          final value =
                              widget.showDuration
                                  ? '${rollup.totalValue.toStringAsFixed(0)}s'
                                  : '${rollup.eventCount} entries';
                          return LineTooltipItem(
                            '${rollup.date}\n$value',
                            TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (event, response) {
                      if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                        setState(() {
                          _touchedIndex =
                              response?.lineBarSpots?.firstOrNull?.x.toInt();
                        });
                      }
                    },
                    handleBuiltInTouches: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: widget.lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final isHighlighted = _touchedIndex == index;
                          return FlDotCirclePainter(
                            radius: isHighlighted ? 6 : 3,
                            color: widget.lineColor,
                            strokeWidth: isHighlighted ? 2 : 0,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            widget.lineColor.withValues(alpha: 0.3),
                            widget.lineColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return widget.rollups.asMap().entries.map((entry) {
      final value =
          widget.showDuration
              ? entry.value.totalValue
              : entry.value.eventCount.toDouble();
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  FlTitlesData _buildTitlesData(BuildContext context, double maxY) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: _calculateXInterval(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= widget.rollups.length) {
              return const SizedBox.shrink();
            }

            final rollup = widget.rollups[index];
            // Parse date string to format as short label
            final parts = rollup.date.split('-');
            if (parts.length == 3) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${parts[1]}/${parts[2]}',
                  style: Theme.of(context).textTheme.bodySmall,
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

  double _calculateXInterval() {
    final length = widget.rollups.length;
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    if (length <= 30) return 5;
    return (length / 6).ceilToDouble();
  }

  Widget _buildTooltipBadge(BuildContext context, DailyRollup rollup) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.lineColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.lineColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        widget.showDuration
            ? '${rollup.totalValue.toStringAsFixed(0)}s on ${rollup.date}'
            : '${rollup.eventCount} on ${rollup.date}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: widget.lineColor,
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
                Icons.show_chart,
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
