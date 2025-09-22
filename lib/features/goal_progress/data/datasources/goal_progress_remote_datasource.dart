// Remote data source interface for Goal data operations
// Defines contract for remote persistence using Firestore

import '../../../../domain/models/goal.dart';

/// Abstract interface for remote Goal data operations
/// Implementation should use Firestore for cloud storage and sync
abstract class GoalProgressRemoteDataSource {
  /// Get active goals for an account from remote storage
  /// Returns goals where active = true and endDate is null or in the future
  Future<List<Goal>> getActiveGoals(String accountId);

  /// Get completed goals for an account from remote storage
  /// Returns goals where achievedAt is not null
  Future<List<Goal>> getCompletedGoals(String accountId);

  /// Get all goals for an account from remote storage
  /// Used for initial sync or full refresh
  Future<List<Goal>> getAllGoals(String accountId);

  /// Get a specific goal by ID from remote storage
  /// Returns null if goal doesn't exist
  Future<Goal?> getGoalById(String goalId);

  /// Update goal progress in remote storage
  /// Used when local progress updates need to be synced
  Future<Goal> updateGoalProgress({
    required String goalId,
    required int newProgress,
  });

  /// Mark goal as achieved in remote storage
  /// Sets achievedAt timestamp to current server time
  Future<Goal> markGoalAsAchieved(String goalId);

  /// Sync local goals to remote storage
  /// Uploads pending changes and resolves conflicts
  Future<void> syncGoals(List<Goal> localGoals);

  /// Check for remote changes since last sync
  /// Returns goals modified after the given timestamp
  Future<List<Goal>> getGoalsModifiedSince({
    required String accountId,
    required DateTime since,
  });

  /// Get server timestamp for conflict resolution
  /// Used to ensure consistent timestamps across devices
  Future<DateTime> getServerTimestamp();

  /// Delete goals from remote storage
  /// Used for account deletion or goal removal
  Future<void> deleteGoals(List<String> goalIds);
}