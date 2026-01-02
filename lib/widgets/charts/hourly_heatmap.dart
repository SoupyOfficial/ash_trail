import 'package:flutter/material.dart';
import '../../models/log_record.dart';

/// Heatmap visualization showing activity by hour of day
/// Helps users identify patterns in their logging behavior
class HourlyHeatmap extends StatelessWidget {
  final List<LogRecord> records;
  final String title;
  final Color baseColor;

  const HourlyHeatmap({
    super.key,
    required this.records,
    this.title = 'Activity by Hour',
    this.baseColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    final hourCounts = _computeHourlyCounts();
    final maxCount = hourCounts.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap a cell to see details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(context, hourCounts, maxCount),
            const SizedBox(height: 16),
            _buildLegend(context, maxCount),
          ],
        ),
      ),
    );
  }

  Map<int, int> _computeHourlyCounts() {
    final counts = <int, int>{};
    for (var hour = 0; hour < 24; hour++) {
      counts[hour] = 0;
    }

    for (final record in records) {
      if (!record.isDeleted) {
        final hour = record.eventAt.hour;
        counts[hour] = (counts[hour] ?? 0) + 1;
      }
    }

    return counts;
  }

  Widget _buildHeatmapGrid(
    BuildContext context,
    Map<int, int> counts,
    int maxCount,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.5,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 24,
      itemBuilder: (context, index) {
        final count = counts[index] ?? 0;
        final intensity = maxCount > 0 ? count.toDouble() / maxCount : 0.0;

        return _HeatmapCell(
          hour: index,
          count: count,
          intensity: intensity,
          baseColor: baseColor,
        );
      },
    );
  }

  Widget _buildLegend(BuildContext context, int maxCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Less', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final intensity = index / 4;
          return Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1 + intensity * 0.8),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text('More', style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        Text(
          'Max: $maxCount entries/hour',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
                Icons.grid_on,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No activity data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual cell in the heatmap
class _HeatmapCell extends StatelessWidget {
  final int hour;
  final int count;
  final double intensity;
  final Color baseColor;

  const _HeatmapCell({
    required this.hour,
    required this.count,
    required this.intensity,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final hourLabel = _formatHour(hour);

    return Tooltip(
      message: '$hourLabel: $count entries',
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$hourLabel: $count entries'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          decoration: BoxDecoration(
            color:
                count > 0
                    ? baseColor.withValues(alpha: 0.1 + intensity * 0.8)
                    : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              hourLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal,
                color:
                    count > 0 && intensity > 0.5
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12AM';
    if (hour == 12) return '12PM';
    if (hour < 12) return '${hour}AM';
    return '${hour - 12}PM';
  }
}

/// Weekly heatmap showing activity by day of week and hour
class WeeklyHeatmap extends StatelessWidget {
  final List<LogRecord> records;
  final String title;
  final Color baseColor;

  const WeeklyHeatmap({
    super.key,
    required this.records,
    this.title = 'Weekly Pattern',
    this.baseColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState(context);
    }

    final dayHourCounts = _computeDayHourCounts();
    final maxCount = dayHourCounts.values
        .expand((hourMap) => hourMap.values)
        .fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildWeeklyGrid(context, dayHourCounts, maxCount),
            const SizedBox(height: 16),
            _buildLegend(context, maxCount),
          ],
        ),
      ),
    );
  }

  // Returns Map<dayOfWeek (1-7), Map<hour (0-23), count>>
  Map<int, Map<int, int>> _computeDayHourCounts() {
    final counts = <int, Map<int, int>>{};

    // Initialize all days and hours
    for (var day = 1; day <= 7; day++) {
      counts[day] = {};
      for (var hour = 0; hour < 24; hour++) {
        counts[day]![hour] = 0;
      }
    }

    for (final record in records) {
      if (!record.isDeleted) {
        final day = record.eventAt.weekday;
        final hour = record.eventAt.hour;
        counts[day]![hour] = (counts[day]![hour] ?? 0) + 1;
      }
    }

    return counts;
  }

  Widget _buildWeeklyGrid(
    BuildContext context,
    Map<int, Map<int, int>> counts,
    int maxCount,
  ) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Hour labels header
        Row(
          children: [
            const SizedBox(width: 32), // Space for day labels
            ...List.generate(24, (hour) {
              if (hour % 4 == 0) {
                return Expanded(
                  flex: 4,
                  child: Text(
                    _formatHour(hour),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 4),
        // Grid rows for each day
        ...List.generate(7, (dayIndex) {
          final day = dayIndex + 1;
          return Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  days[dayIndex],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              ...List.generate(24, (hour) {
                final count = counts[day]?[hour] ?? 0;
                final intensity = maxCount > 0 ? count / maxCount : 0;

                return Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Tooltip(
                      message: '${days[dayIndex]} ${_formatHour(hour)}: $count',
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color:
                              count > 0
                                  ? baseColor.withValues(
                                    alpha: 0.1 + intensity * 0.8,
                                  )
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, int maxCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
        ...List.generate(5, (index) {
          final intensity = index / 4;
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.1 + intensity * 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text('More', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12A';
    if (hour == 12) return '12P';
    if (hour < 12) return '${hour}A';
    return '${hour - 12}P';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_view_week,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'No weekly data',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
