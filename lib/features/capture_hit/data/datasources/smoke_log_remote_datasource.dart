// Remote data source interface for SmokeLog Firestore operations
// Defines contract for cloud synchronization and backup

import '../models/smoke_log_dto.dart';

/// Abstract interface for remote SmokeLog data operations
/// Implementation should use Firestore for cloud storage and sync
abstract class SmokeLogRemoteDataSource {
  /// Create a new smoke log entry in Firestore
  /// Path: accounts/{accountId}/logs/{logId}
  Future<SmokeLogDto> createSmokeLog(SmokeLogDto smokeLog);

  /// Get smoke logs for an account within a date range from Firestore
  /// Results are ordered by timestamp descending (newest first)
  /// Uses composite index: (accountId, ts desc)
  Future<List<SmokeLogDto>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });

  /// Update an existing smoke log in Firestore
  /// Uses document merge to preserve server-side timestamps
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog);

  /// Delete a smoke log by ID from Firestore
  /// Performs hard delete - assumes soft delete handled at business layer
  Future<void> deleteSmokeLog({
    required String accountId,
    required String smokeLogId,
  });

  /// Get a specific smoke log by ID from Firestore
  /// Returns null if document doesn't exist
  Future<SmokeLogDto?> getSmokeLogById({
    required String accountId,
    required String smokeLogId,
  });

  /// Get the most recent smoke log for an account from Firestore
  /// Used for conflict resolution during sync
  Future<SmokeLogDto?> getLastSmokeLog(String accountId);

  /// Batch sync operation - upload multiple logs in a single transaction
  /// Used for efficient offline-to-online sync
  /// Returns successfully synced logs
  Future<List<SmokeLogDto>> batchSyncLogs({
    required String accountId,
    required List<SmokeLogDto> logs,
  });

  /// Get logs modified after a specific timestamp
  /// Used for incremental sync from server
  Future<List<SmokeLogDto>> getLogsModifiedAfter({
    required String accountId,
    required DateTime timestamp,
  });
}
