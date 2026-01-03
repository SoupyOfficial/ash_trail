import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/enums.dart';

/// Interactive pie chart showing event type breakdown
/// Uses fl_chart for smooth animations and touch interactions
class EventTypePieChart extends StatefulWidget {
  final Map<EventType, int> eventTypeCounts;
  final String title;

  const EventTypePieChart({
    super.key,
    required this.eventTypeCounts,
    this.title = 'Event Types',
  });

  @override
  State<EventTypePieChart> createState() => _EventTypePieChartState();
}

class _EventTypePieChartState extends State<EventTypePieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.eventTypeCounts.isEmpty) {
      return _buildEmptyState(context);
    }

    final total = widget.eventTypeCounts.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 3,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            if (!mounted) return;
                            final newIndex =
                                (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null)
                                    ? -1
                                    : response
                                        .touchedSection!
                                        .touchedSectionIndex;
                            if (newIndex != _touchedIndex) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _touchedIndex = newIndex;
                                  });
                                }
                              });
                            }
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _buildSections(total),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(flex: 2, child: _buildLegend(context, total)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(int total) {
    final entries = widget.eventTypeCounts.entries.toList();

    return entries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final isTouched = index == _touchedIndex;
      final percentage = total > 0 ? (entry.value / total * 100) : 0;
      final color = _getEventTypeColor(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
        ),
        badgeWidget: isTouched ? _buildBadge(entry.key, color) : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildBadge(EventType type, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(_getEventTypeIcon(type), color: Colors.white, size: 16),
    );
  }

  Widget _buildLegend(BuildContext context, int total) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          widget.eventTypeCounts.entries.map((entry) {
            final color = _getEventTypeColor(entry.key);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatEventTypeName(entry.key),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.vape:
        return Colors.indigo;
      case EventType.inhale:
        return Colors.blue;
      case EventType.sessionStart:
        return Colors.green;
      case EventType.sessionEnd:
        return Colors.red;
      case EventType.note:
        return Colors.orange;
      case EventType.tolerance:
        return Colors.purple;
      case EventType.symptomRelief:
        return Colors.teal;
      case EventType.purchase:
        return Colors.amber;
      case EventType.custom:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.vape:
        return Icons.cloud;
      case EventType.inhale:
        return Icons.air;
      case EventType.sessionStart:
        return Icons.play_circle;
      case EventType.sessionEnd:
        return Icons.stop_circle;
      case EventType.note:
        return Icons.note;
      case EventType.tolerance:
        return Icons.trending_up;
      case EventType.symptomRelief:
        return Icons.healing;
      case EventType.purchase:
        return Icons.shopping_cart;
      case EventType.custom:
        return Icons.star;
    }
  }

  String _formatEventTypeName(EventType type) {
    // Convert camelCase to Title Case with spaces
    final name = type.name;
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No event data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
