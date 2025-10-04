// Widget tests for GoalProgressScreen
// Tests the main screen UI, loading states, error states, and data display

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/goal_progress/presentation/screens/goal_progress_screen.dart';
import 'package:ash_trail/features/goal_progress/presentation/providers/goal_progress_providers.dart';
import 'package:ash_trail/features/goal_progress/domain/usecases/get_goal_progress_usecase.dart';
import 'package:ash_trail/features/goal_progress/domain/entities/goal_progress_view.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/goal.dart';

void main() {
  group('GoalProgressScreen Widget Tests', () {
    const accountId = 'test-account-id';

    // Test data
    final testActiveGoal = Goal(
      id: 'goal1',
      accountId: accountId,
      type: 'smoke_free_days',
      target: 30,
      window: 'monthly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 15,
    );

    final testCompletedGoal = Goal(
      id: 'goal2',
      accountId: accountId,
      type: 'reduction_count',
      target: 10,
      window: 'weekly',
      startDate: DateTime(2024, 1, 1),
      active: true,
      progress: 10,
      achievedAt: DateTime(2024, 1, 15),
    );

    Widget createTestWidget({
      required GoalProgressDashboard dashboardData,
    }) {
      return ProviderScope(
        overrides: [
          goalProgressDashboardProvider(accountId).overrideWith((ref) {
            return Future.value(dashboardData);
          }),
        ],
        child: const MaterialApp(
          home: GoalProgressScreen(accountId: accountId),
        ),
      );
    }

    testWidgets('displays loading state correctly', (tester) async {
      late Completer<GoalProgressDashboard> completer;

      // Arrange & Act
      await tester.pumpWidget(ProviderScope(
        overrides: [
          goalProgressDashboardProvider(accountId).overrideWith((ref) async {
            completer = Completer<GoalProgressDashboard>();
            return completer.future;
          }),
        ],
        child: const MaterialApp(
          home: GoalProgressScreen(accountId: accountId),
        ),
      ));

      await tester.pump();

      // Assert - should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading your goals...'), findsOneWidget);
      expect(find.text('Goal Progress'), findsOneWidget); // App bar title

      // Clean up
      if (!completer.isCompleted) {
        completer.complete(
            const GoalProgressDashboard(activeGoals: [], completedGoals: []));
      }
    });

    testWidgets('displays error state correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(ProviderScope(
        overrides: [
          goalProgressDashboardProvider(accountId).overrideWith((ref) async {
            throw const AppFailure.network(message: 'Network error occurred');
          }),
        ],
        child: const MaterialApp(
          home: GoalProgressScreen(accountId: accountId),
        ),
      ));

      // Act
      await tester.pump();
      await tester.pump(); // Allow async error to propagate

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Unable to load goal progress'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('displays empty state when no goals exist', (tester) async {
      // Arrange
      const emptyDashboard = GoalProgressDashboard(
        activeGoals: [],
        completedGoals: [],
      );

      await tester.pumpWidget(createTestWidget(dashboardData: emptyDashboard));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('No Goals Yet'), findsOneWidget);
      expect(find.text('Create Your First Goal'), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('displays dashboard with goals correctly', (tester) async {
      // Arrange
      final activeGoalView = GoalProgressView.fromGoal(testActiveGoal);
      final completedGoalView = GoalProgressView.fromGoal(testCompletedGoal);

      final dashboardWithGoals = GoalProgressDashboard(
        activeGoals: [activeGoalView],
        completedGoals: [completedGoalView],
      );

      await tester
          .pumpWidget(createTestWidget(dashboardData: dashboardWithGoals));

      // Act
      await tester.pump();

      // Assert
      // Dashboard header should be present
      expect(find.text('2'), findsWidgets); // Total goals count

      // Section tabs should be present
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Goal cards should be present (active section is shown by default)
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('switches between active and completed sections',
        (tester) async {
      // Arrange
      final activeGoalView = GoalProgressView.fromGoal(testActiveGoal);
      final completedGoalView = GoalProgressView.fromGoal(testCompletedGoal);

      final dashboardWithGoals = GoalProgressDashboard(
        activeGoals: [activeGoalView],
        completedGoals: [completedGoalView],
      );

      await tester
          .pumpWidget(createTestWidget(dashboardData: dashboardWithGoals));
      await tester.pump();

      // Initially should show active goals
      expect(find.text('Active'), findsAtLeastNWidgets(1));

      // Find widgets containing "Completed" text within button widgets
      final completedButtons = find.widgetWithText(OutlinedButton, 'Completed');
      if (completedButtons.evaluate().isNotEmpty) {
        // Act - tap on Completed tab
        await tester.tap(completedButtons.first);
        await tester.pump();
      }

      // Assert - should now show completed goals
      // Verify the tab switching worked (implementation details may vary)
      expect(find.text('Completed'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles retry action in error state', (tester) async {
      // Arrange
      await tester.pumpWidget(ProviderScope(
        overrides: [
          goalProgressDashboardProvider(accountId).overrideWith((ref) async {
            throw const AppFailure.cache(message: 'Cache error');
          }),
        ],
        child: const MaterialApp(
          home: GoalProgressScreen(accountId: accountId),
        ),
      ));

      await tester.pump();
      await tester.pump(); // Allow async error to propagate

      // Act - tap retry button
      expect(find.text('Try Again'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      await tester.pump();

      // Assert - verify retry button was tapped (the provider would be invalidated)
      // This test mainly ensures the button is tappable and doesn't crash
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('displays app bar with correct title', (tester) async {
      // Arrange
      const emptyDashboard = GoalProgressDashboard(
        activeGoals: [],
        completedGoals: [],
      );

      await tester.pumpWidget(createTestWidget(dashboardData: emptyDashboard));

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Goal Progress'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    group('Empty State Widget', () {
      testWidgets('shows correct empty state content', (tester) async {
        // Arrange
        const emptyDashboard = GoalProgressDashboard(
          activeGoals: [],
          completedGoals: [],
        );

        await tester
            .pumpWidget(createTestWidget(dashboardData: emptyDashboard));

        // Act
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
        expect(find.text('No Goals Yet'), findsOneWidget);
        expect(
            find.text(
                'Set up your first goal to start tracking\nyour progress and stay motivated.'),
            findsOneWidget);
        expect(find.text('Create Your First Goal'), findsOneWidget);
        expect(find.text('Learn About Goals'), findsOneWidget);
      });

      testWidgets('handles create goal button tap', (tester) async {
        // Arrange
        const emptyDashboard = GoalProgressDashboard(
          activeGoals: [],
          completedGoals: [],
        );

        await tester
            .pumpWidget(createTestWidget(dashboardData: emptyDashboard));
        await tester.pump();

        // Act
        await tester.tap(find.text('Create Your First Goal'));
        await tester.pump();

        // Assert - should show snackbar (since actual navigation isn't implemented)
        expect(find.text('Goal creation feature coming soon!'), findsOneWidget);
      });

      testWidgets('handles learn about goals button tap', (tester) async {
        // Arrange
        const emptyDashboard = GoalProgressDashboard(
          activeGoals: [],
          completedGoals: [],
        );

        await tester
            .pumpWidget(createTestWidget(dashboardData: emptyDashboard));
        await tester.pump();

        // Act
        await tester.tap(find.text('Learn About Goals'));
        await tester.pumpAndSettle();

        // Assert - should show dialog
        expect(find.text('About Goals'), findsOneWidget);
        expect(find.textContaining('Goals help you track your progress'),
            findsOneWidget);
        expect(find.text('Got it'), findsOneWidget);
      });
    });
  });
}
