// Repository interface for Goal Progress operations
// Defines the contract for managing goal progress data and calculations

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/goal.dart';

/// Repository interface for managing Goal Progress data
/// Follows offline-first pattern with local storage and remote sync
abstract class GoalProgressRepository {
  /// Get active goals for an account
  /// Returns goals where active = true and endDate is null or in the future
  Future<Either<AppFailure, List<Goal>>> getActiveGoals(String accountId);

  /// Get completed goals for an account
  /// Returns goals where achievedAt is not null or target has been reached
  Future<Either<AppFailure, List<Goal>>> getCompletedGoals(String accountId);

  /// Get all goals for an account (active and completed)
  /// Used for comprehensive goal overview
  Future<Either<AppFailure, List<Goal>>> getAllGoals(String accountId);

  /// Update goal progress
  /// Used when progress needs to be recalculated based on new data
  Future<Either<AppFailure, Goal>> updateGoalProgress({
    required String goalId,
    required int newProgress,
  });

  /// Mark goal as achieved
  /// Sets achievedAt timestamp and updates completion status
  Future<Either<AppFailure, Goal>> markGoalAsAchieved(String goalId);

  /// Get current progress count for a goal
  /// Calculates progress based on actual data (smoke logs, etc.)
  Future<Either<AppFailure, int>> calculateCurrentProgress({
    required String accountId,
    required Goal goal,
  });
}