// Use case for getting goal progress views
// Combines goal data with calculated progress percentages for display

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/goal_progress_view.dart';
import '../repositories/goal_progress_repository.dart';

/// Use case for getting goal progress dashboard data
/// Returns both active and completed goals with progress calculations
class GetGoalProgressUseCase implements UseCase<GoalProgressDashboard, String> {
  const GetGoalProgressUseCase(this._repository);

  final GoalProgressRepository _repository;

  @override
  Future<Either<AppFailure, GoalProgressDashboard>> call(String accountId) async {
    try {
      // Get active and completed goals
      final activeResult = await _repository.getActiveGoals(accountId);
      final completedResult = await _repository.getCompletedGoals(accountId);

      return await activeResult.fold(
        (failure) async => Left(failure),
        (activeGoals) async {
          return await completedResult.fold(
            (failure) async => Left(failure),
            (completedGoals) async {
              // Calculate progress for active goals
              final List<GoalProgressView> activeProgressViews = [];
              final List<GoalProgressView> completedProgressViews = [];

              // Process active goals
              for (final goal in activeGoals) {
                final progressResult = await _repository.calculateCurrentProgress(
                  accountId: accountId,
                  goal: goal,
                );
                
                progressResult.fold(
                  (failure) {
                    // If calculation fails, use stored progress or 0
                    final view = GoalProgressView.fromGoal(goal);
                    activeProgressViews.add(view);
                  },
                  (currentProgress) {
                    final view = GoalProgressView.fromGoal(goal, currentProgress: currentProgress);
                    activeProgressViews.add(view);
                  },
                );
              }

              // Process completed goals
              for (final goal in completedGoals) {
                final view = GoalProgressView.fromGoal(goal);
                completedProgressViews.add(view);
              }

              return Right(GoalProgressDashboard(
                activeGoals: activeProgressViews,
                completedGoals: completedProgressViews,
              ));
            },
          );
        },
      );
    } catch (error, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to load goal progress',
        cause: error,
        stackTrace: stackTrace,
      ));
    }
  }
}

/// Dashboard data structure containing active and completed goal progress
class GoalProgressDashboard {
  const GoalProgressDashboard({
    required this.activeGoals,
    required this.completedGoals,
  });

  final List<GoalProgressView> activeGoals;
  final List<GoalProgressView> completedGoals;

  /// Check if there are any goals to display
  bool get hasGoals => activeGoals.isNotEmpty || completedGoals.isNotEmpty;

  /// Get total number of goals
  int get totalGoals => activeGoals.length + completedGoals.length;

  /// Get completion rate as percentage
  double get completionRate {
    if (totalGoals == 0) return 0.0;
    return (completedGoals.length / totalGoals * 100);
  }
}