// Dashboard Header Widget
// Shows overall goal statistics and completion rate

import 'package:flutter/material.dart';

/// Header widget showing overall goal progress statistics
/// Displays completion rate, total goals, and breakdown of active/completed
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.completionRate,
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
  });

  final double completionRate;
  final int totalGoals;
  final int activeGoals;
  final int completedGoals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Completion rate circle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CompletionCircle(
                percentage: completionRate,
                theme: theme,
              ),
              const SizedBox(width: 24),
              _StatsColumn(
                totalGoals: totalGoals,
                activeGoals: activeGoals,
                completedGoals: completedGoals,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Circular progress indicator showing completion rate
class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({
    required this.percentage,
    required this.theme,
  });

  final double percentage;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          // Percentage text
          Text(
            '${percentage.round()}%',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics column showing goal counts
class _StatsColumn extends StatelessWidget {
  const _StatsColumn({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.theme,
  });

  final int totalGoals;
  final int activeGoals;
  final int completedGoals;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatItem(
          label: 'Total Goals',
          value: totalGoals.toString(),
          theme: theme,
        ),
        const SizedBox(height: 8),
        _StatItem(
          label: 'Active',
          value: activeGoals.toString(),
          theme: theme,
        ),
        const SizedBox(height: 8),
        _StatItem(
          label: 'Completed',
          value: completedGoals.toString(),
          theme: theme,
        ),
      ],
    );
  }
}

/// Individual statistic item
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}