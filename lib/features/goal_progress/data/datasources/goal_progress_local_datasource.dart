// Local data source interface for Goal data operations
// Defines contract for local persistence using Isar database

import '../../../../domain/models/goal.dart';

/// Abstract interface for local Goal data operations
/// Implementation should use Isar database for offline-first storage
abstract class GoalProgressLocalDataSource {
  /// Get active goals for an account
  /// Returns goals where active = true and endDate is null or in the future
  Future<List<Goal>> getActiveGoals(String accountId);

  /// Get completed goals for an account
  /// Returns goals where achievedAt is not null
  Future<List<Goal>> getCompletedGoals(String accountId);

  /// Get all goals for an account (active and completed)
  /// Used for comprehensive goal overview
  Future<List<Goal>> getAllGoals(String accountId);

  /// Get a specific goal by ID
  /// Returns null if goal doesn't exist
  Future<Goal?> getGoalById(String goalId);

  /// Update goal progress
  /// Used when progress needs to be updated based on calculations
  Future<Goal> updateGoalProgress({
    required String goalId,
    required int newProgress,
  });

  /// Mark goal as achieved
  /// Sets achievedAt timestamp to current time
  Future<Goal> markGoalAsAchieved(String goalId);

  /// Get goals that need to be synced to remote storage
  /// Returns goals where isPendingSync = true (if applicable)
  Future<List<Goal>> getPendingSyncGoals(String accountId);

  /// Mark goal as synchronized (clear isPendingSync flag)
  /// Called after successful remote sync
  Future<void> markAsSynced(String goalId);

  /// Get total count of goals for an account
  /// Used for statistics and overview
  Future<int> getGoalsCount(String accountId);

  /// Clear all goals for an account (useful for account logout)
  /// Hard deletes all local data for the account
  Future<void> clearAccountGoals(String accountId);
}