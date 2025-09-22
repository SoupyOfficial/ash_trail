// Individual Goal Progress Card Widget
// Displays a single goal with progress bar and achievement status

import 'package:flutter/material.dart';
import '../../domain/entities/goal_progress_view.dart';

/// Widget that displays a single goal's progress information
/// Shows progress bar for active goals and completion date for achieved goals
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.goalProgressView,
    required this.isInCompletedSection,
  });

  final GoalProgressView goalProgressView;
  final bool isInCompletedSection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = goalProgressView.goal;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal title and type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGoalTitle(goal.type),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGoalSubtitle(goal),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  goalProgressView: goalProgressView,
                  isCompleted: isInCompletedSection,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress section
            if (isInCompletedSection) ...[
              _CompletedGoalInfo(goalProgressView: goalProgressView),
            ] else ...[
              _ActiveGoalProgress(goalProgressView: goalProgressView),
            ],
          ],
        ),
      ),
    );
  }

  String _getGoalTitle(String goalType) {
    return switch (goalType.toLowerCase()) {
      'smoke_free_days' => 'Smoke-Free Days',
      'reduction_count' => 'Reduce Sessions',
      'duration_limit' => 'Duration Limit',
      _ => 'Goal Progress',
    };
  }

  String _getGoalSubtitle(goal) {
    final startDate = goal.startDate;
    final endDate = goal.endDate;
    
    if (endDate != null) {
      return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
    return 'Started ${_formatDate(startDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Status chip widget showing goal completion state
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.goalProgressView,
    required this.isCompleted,
  });

  final GoalProgressView goalProgressView;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final (color, label) = _getStatusInfo(theme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(ThemeData theme) {
    if (isCompleted) {
      return (theme.colorScheme.primary, 'Completed');
    }
    
    if (goalProgressView.isOverdue) {
      return (theme.colorScheme.error, 'Overdue');
    }
    
    if (goalProgressView.progressPercentage >= 0.8) {
      return (Colors.orange, 'Almost There');
    }
    
    return (theme.colorScheme.primary, 'In Progress');
  }
}

/// Widget for displaying active goal progress with progress bar
class _ActiveGoalProgress extends StatelessWidget {
  const _ActiveGoalProgress({required this.goalProgressView});

  final GoalProgressView goalProgressView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              goalProgressView.displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(goalProgressView.progressPercentage * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress bar
        LinearProgressIndicator(
          value: goalProgressView.progressPercentage,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(theme),
          ),
          minHeight: 6,
        ),
      ],
    );
  }

  Color _getProgressColor(ThemeData theme) {
    if (goalProgressView.isOverdue) {
      return theme.colorScheme.error;
    }
    
    if (goalProgressView.progressPercentage >= 0.8) {
      return Colors.orange;
    }
    
    return theme.colorScheme.primary;
  }
}

/// Widget for displaying completed goal information
class _CompletedGoalInfo extends StatelessWidget {
  const _CompletedGoalInfo({required this.goalProgressView});

  final GoalProgressView goalProgressView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          goalProgressView.displayText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}