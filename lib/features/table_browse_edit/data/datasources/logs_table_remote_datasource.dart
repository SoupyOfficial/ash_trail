// Remote data source interface for logs table operations
// Defines contract for Firestore operations with table-specific functionality

import '../../../../features/capture_hit/data/models/smoke_log_dto.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';

/// Abstract interface for remote logs table data operations
/// Handles Firestore queries for table browse/edit functionality
abstract class LogsTableRemoteDataSource {
  /// Get filtered and sorted smoke logs from Firestore
  /// Used for background sync and when local data is unavailable
  Future<List<SmokeLogDto>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  });

  /// Get total count of smoke logs matching filter criteria from Firestore
  /// Used for server-side pagination and verification
  Future<int> getLogsCount({
    required String accountId,
    LogFilter? filter,
  });

  /// Update a smoke log in Firestore
  /// Implements server-side validation and conflict resolution
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog);

  /// Delete a smoke log from Firestore with account verification
  /// Performs server-side authorization check
  Future<void> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  });

  /// Batch delete multiple smoke logs from Firestore
  /// Implements server-side batch operations for efficiency
  Future<int> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  });

  /// Get a single smoke log by ID from Firestore
  /// Used for conflict resolution and remote verification
  Future<SmokeLogDto?> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  });

  /// Get distinct method IDs used in smoke logs from Firestore
  /// Used for cross-device filter synchronization
  Future<List<String>> getUsedMethodIds({
    required String accountId,
  });

  /// Get distinct tag IDs used in smoke logs from Firestore
  /// Queries both SmokeLog and SmokeLogTag collections
  Future<List<String>> getUsedTagIds({
    required String accountId,
  });

  /// Batch sync multiple log updates to Firestore
  /// Used by background sync service for efficient synchronization
  Future<List<SmokeLogDto>> batchSyncLogs({
    required String accountId,
    required List<SmokeLogDto> logs,
  });

  /// Batch attach tags to multiple smoke logs in Firestore
  /// Returns number of created edges
  Future<int> addTagsToLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  });

  /// Batch remove tags from multiple smoke logs in Firestore
  /// Returns number of deleted edges
  Future<int> removeTagsFromLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  });
}
