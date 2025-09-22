// Goal Progress Dashboard Screen
// Displays active and completed goals with progress bars and achievement status

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_progress_providers.dart';
import '../../domain/usecases/get_goal_progress_usecase.dart';
import '../widgets/goal_card_list.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/section_tabs.dart';
import '../widgets/empty_state.dart';

/// Main screen for displaying goal progress dashboard
/// Shows active goals with progress bars and completed goals with achievement dates
class GoalProgressScreen extends ConsumerWidget {
  const GoalProgressScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(goalProgressDashboardProvider(accountId));
    final selectedSection = ref.watch(selectedDashboardSectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Progress'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: dashboardAsync.when(
        loading: () => const _LoadingState(),
        error: (error, stackTrace) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(goalProgressDashboardProvider(accountId)),
        ),
        data: (dashboard) {
          if (!dashboard.hasGoals) {
            return const EmptyGoalState();
          }

          return Column(
            children: [
              // Dashboard header with completion rate
              DashboardHeader(
                completionRate: dashboard.completionRate,
                totalGoals: dashboard.totalGoals,
                activeGoals: dashboard.activeGoals.length,
                completedGoals: dashboard.completedGoals.length,
              ),

              // Section tabs (Active / Completed)
              SectionTabs(
                selectedSection: selectedSection,
                activeCount: dashboard.activeGoals.length,
                completedCount: dashboard.completedGoals.length,
                onSectionChanged: (section) {
                  ref.read(selectedDashboardSectionProvider.notifier).state = section;
                },
              ),

              // Goal list based on selected section
              Expanded(
                child: _buildGoalList(dashboard, selectedSection),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoalList(GoalProgressDashboard dashboard, DashboardSection section) {
    return switch (section) {
      DashboardSection.active => GoalCardList(
          goals: dashboard.activeGoals,
          isCompletedSection: false,
        ),
      DashboardSection.completed => GoalCardList(
          goals: dashboard.completedGoals,
          isCompletedSection: true,
        ),
    };
  }
}

/// Loading state widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your goals...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              'Unable to load goal progress',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}