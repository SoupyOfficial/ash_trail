// Local data source interface for SmokeLog storage operations
// Defines contract for local persistence using Isar database

import '../models/smoke_log_dto.dart';

/// Abstract interface for local SmokeLog data operations
/// Implementation should use Isar database for offline-first storage
abstract class SmokeLogLocalDataSource {
  /// Create a new smoke log entry in local storage
  /// Sets isPendingSync flag for remote synchronization
  Future<SmokeLogDto> createSmokeLog(SmokeLogDto smokeLog);

  /// Get the most recent smoke log for an account
  /// Used for undo functionality - returns null if no logs exist
  Future<SmokeLogDto?> getLastSmokeLog(String accountId);

  /// Delete a smoke log by ID from local storage
  /// Marks as deleted rather than hard delete for sync purposes
  Future<void> deleteSmokeLog(String smokeLogId);

  /// Get smoke logs for an account within a date range
  /// Results are ordered by timestamp descending (newest first)
  Future<List<SmokeLogDto>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    bool includeDeleted = false,
  });

  /// Update an existing smoke log in local storage
  /// Sets isPendingSync flag for remote synchronization
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog);

  /// Get all smoke logs that need to be synced to remote storage
  /// Returns logs where isPendingSync = true
  Future<List<SmokeLogDto>> getPendingSyncLogs(String accountId);

  /// Mark smoke log as synchronized (clear isPendingSync flag)
  /// Called after successful remote sync
  Future<void> markAsSynced(String smokeLogId);

  /// Clear all smoke logs for an account (useful for account logout)
  /// Hard deletes all local data for the account
  Future<void> clearAccountLogs(String accountId);

  /// Get total count of smoke logs for an account
  /// Used for statistics and pagination
  Future<int> getLogsCount(String accountId);
}
