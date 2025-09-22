// Goal Card List Widget  
// Displays a list of goal progress cards with progress bars

import 'package:flutter/material.dart';
import '../../domain/entities/goal_progress_view.dart';
import 'goal_progress_card.dart';

/// Widget that displays a list of goal progress cards
/// Shows different styles based on whether it's the completed section
class GoalCardList extends StatelessWidget {
  const GoalCardList({
    super.key,
    required this.goals,
    required this.isCompletedSection,
  });

  final List<GoalProgressView> goals;
  final bool isCompletedSection;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return _EmptySection(isCompleted: isCompletedSection);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GoalProgressCard(
          goalProgressView: goals[index],
          isInCompletedSection: isCompletedSection,
        );
      },
    );
  }
}

/// Empty section widget for when there are no goals
class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.emoji_events_outlined : Icons.track_changes_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted 
                  ? 'No completed goals yet'
                  : 'No active goals',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCompleted 
                  ? 'Complete your active goals to see them here'
                  : 'Create some goals to track your progress',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}