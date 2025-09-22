// Empty State Widget
// Shows when user has no goals set up

import 'package:flutter/material.dart';

/// Widget displayed when the user has no goals
/// Encourages the user to create their first goal
class EmptyGoalState extends StatelessWidget {
  const EmptyGoalState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'No Goals Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Set up your first goal to start tracking\nyour progress and stay motivated.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Create Goal button
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to goal creation screen
                _showGoalCreationSnackBar(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary action
            TextButton(
              onPressed: () {
                // TODO: Show goal examples or tips
                _showGoalTipsDialog(context);
              },
              child: const Text('Learn About Goals'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalCreationSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goal creation feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showGoalTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Goals'),
        content: const Text(
          'Goals help you track your progress and stay motivated. '
          'You can set goals for:\n\n'
          '• Smoke-free days\n'
          '• Reducing session count\n'
          '• Limiting session duration\n\n'
          'Each goal shows your progress with visual indicators '
          'and moves to the completed section when achieved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
