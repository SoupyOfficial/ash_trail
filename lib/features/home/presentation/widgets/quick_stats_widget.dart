// Widget displaying quick statistics for recent smoking activity.
// Shows summary counts and trends for user engagement.

import 'package:flutter/material.dart';

class QuickStatsWidget extends StatelessWidget {
  const QuickStatsWidget({
    super.key,
    required this.recentLogsCount,
    required this.todayLogsCount,
  });

  final int recentLogsCount;
  final int todayLogsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Today',
            value: todayLogsCount.toString(),
            subtitle: todayLogsCount == 1 ? 'session' : 'sessions',
            icon: Icons.today,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'This Week',
            value: recentLogsCount.toString(),
            subtitle: recentLogsCount == 1 ? 'session' : 'sessions',
            icon: Icons.calendar_view_week,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
