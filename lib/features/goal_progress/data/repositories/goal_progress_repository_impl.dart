// Repository implementation for Goal Progress operations
// Implements offline-first pattern with local storage and remote sync

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/goal.dart';
import '../../domain/repositories/goal_progress_repository.dart';
import '../datasources/goal_progress_local_datasource.dart';
import '../datasources/goal_progress_remote_datasource.dart';

/// Concrete implementation of GoalProgressRepository
/// Follows offline-first approach: read from local, sync from remote when needed
class GoalProgressRepositoryImpl implements GoalProgressRepository {
  const GoalProgressRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final GoalProgressLocalDataSource localDataSource;
  final GoalProgressRemoteDataSource remoteDataSource;

  @override
  Future<Either<AppFailure, List<Goal>>> getActiveGoals(
      String accountId) async {
    try {
      // Try local first for offline-first approach
      final localGoals = await localDataSource.getActiveGoals(accountId);

      // TODO: Consider implementing background sync logic here
      // For now, return local data immediately for performance

      return Right(localGoals);
    } catch (error) {
      // If local fails, try remote as fallback
      try {
        final remoteGoals = await remoteDataSource.getActiveGoals(accountId);
        return Right(remoteGoals);
      } catch (remoteError) {
        return Left(AppFailure.cache(
          message: 'Failed to load active goals: $error',
        ));
      }
    }
  }

  @override
  Future<Either<AppFailure, List<Goal>>> getCompletedGoals(
      String accountId) async {
    try {
      final localGoals = await localDataSource.getCompletedGoals(accountId);
      return Right(localGoals);
    } catch (error) {
      try {
        final remoteGoals = await remoteDataSource.getCompletedGoals(accountId);
        return Right(remoteGoals);
      } catch (remoteError) {
        return Left(AppFailure.cache(
          message: 'Failed to load completed goals: $error',
        ));
      }
    }
  }

  @override
  Future<Either<AppFailure, List<Goal>>> getAllGoals(String accountId) async {
    try {
      final localGoals = await localDataSource.getAllGoals(accountId);
      return Right(localGoals);
    } catch (error) {
      try {
        final remoteGoals = await remoteDataSource.getAllGoals(accountId);
        return Right(remoteGoals);
      } catch (remoteError) {
        return Left(AppFailure.cache(
          message: 'Failed to load all goals: $error',
        ));
      }
    }
  }

  @override
  Future<Either<AppFailure, Goal>> updateGoalProgress({
    required String goalId,
    required int newProgress,
  }) async {
    try {
      // Update local first
      final updatedGoal = await localDataSource.updateGoalProgress(
        goalId: goalId,
        newProgress: newProgress,
      );

      // Try to sync to remote (best effort, don't fail if remote is down)
      try {
        await remoteDataSource.updateGoalProgress(
          goalId: goalId,
          newProgress: newProgress,
        );
        await localDataSource.markAsSynced(goalId);
      } catch (remoteError) {
        // Remote sync failed, but local update succeeded
        // Goal will be synced later via background sync
      }

      return Right(updatedGoal);
    } catch (error) {
      return Left(AppFailure.cache(
        message: 'Failed to update goal progress: $error',
      ));
    }
  }

  @override
  Future<Either<AppFailure, Goal>> markGoalAsAchieved(String goalId) async {
    try {
      // Mark as achieved locally first
      final achievedGoal = await localDataSource.markGoalAsAchieved(goalId);

      // Try to sync to remote (best effort)
      try {
        await remoteDataSource.markGoalAsAchieved(goalId);
        await localDataSource.markAsSynced(goalId);
      } catch (remoteError) {
        // Remote sync failed, but local update succeeded
      }

      return Right(achievedGoal);
    } catch (error) {
      return Left(AppFailure.cache(
        message: 'Failed to mark goal as achieved: $error',
      ));
    }
  }

  @override
  Future<Either<AppFailure, int>> calculateCurrentProgress({
    required String accountId,
    required Goal goal,
  }) async {
    try {
      // Calculate progress based on goal type
      // This is a simplified version - in a real app, you'd query actual data
      switch (goal.type.toLowerCase()) {
        case 'smoke_free_days':
          return Right(await _calculateSmokeFreeProgress(accountId, goal));
        case 'reduction_count':
          return Right(await _calculateReductionProgress(accountId, goal));
        case 'duration_limit':
          return Right(await _calculateDurationProgress(accountId, goal));
        default:
          // For unknown types, return stored progress or 0
          return Right(goal.progress ?? 0);
      }
    } catch (error) {
      // If calculation fails, return stored progress or 0
      return Right(goal.progress ?? 0);
    }
  }

  /// Calculate smoke-free days progress
  Future<int> _calculateSmokeFreeProgress(String accountId, Goal goal) async {
    // TODO: This would query SmokeLog data to calculate actual smoke-free days
    // For now, when there's stored progress, return it (simulating fallback behavior)
    // In a real implementation, we'd query actual smoke logs and calculate
    if (goal.progress != null && goal.progress! > 0) {
      return goal.progress!;
    }

    // If no stored progress, calculate based on time (simplified mock calculation)
    final daysSinceStart = DateTime.now().difference(goal.startDate).inDays;
    return daysSinceStart.clamp(0, goal.target);
  }

  /// Calculate reduction count progress
  Future<int> _calculateReductionProgress(String accountId, Goal goal) async {
    // TODO: This would query SmokeLog data to count sessions in the goal period
    // For now, return stored progress
    return goal.progress ?? 0;
  }

  /// Calculate duration limit progress
  Future<int> _calculateDurationProgress(String accountId, Goal goal) async {
    // TODO: This would query SmokeLog data to calculate average duration
    // For now, return stored progress
    return goal.progress ?? 0;
  }
}
