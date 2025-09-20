// Local data source interface for logs table operations
// Extends the base SmokeLog data source with specialized table functionality

import '../../../../features/capture_hit/data/models/smoke_log_dto.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';

/// Abstract interface for local logs table data operations
/// Extends base smoke log operations with filtering, sorting, and pagination
abstract class LogsTableLocalDataSource {
  /// Get filtered and sorted smoke logs with pagination
  /// Implements complex queries for table view requirements
  Future<List<SmokeLogDto>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  });

  /// Get total count of smoke logs matching filter criteria
  /// Used for pagination calculation and total count display
  Future<int> getLogsCount({
    required String accountId,
    LogFilter? filter,
  });

  /// Update an existing smoke log with optimistic locking
  /// Returns updated DTO with new timestamp, marks as pending sync
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog);

  /// Delete a smoke log by ID with account verification
  /// Performs soft delete (marks as deleted) for sync purposes
  Future<void> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  });

  /// Batch delete multiple smoke logs with account verification
  /// Returns count of successfully deleted logs
  Future<int> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  });

  /// Get a single smoke log by ID with account verification
  /// Returns null if not found or not accessible to account
  Future<SmokeLogDto?> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  });

  /// Get distinct method IDs that have been used in smoke logs
  /// Used to populate method filter options
  Future<List<String>> getUsedMethodIds({
    required String accountId,
  });

  /// Get distinct tag IDs that have been used in smoke logs
  /// Queries SmokeLogTag relationships for the account
  Future<List<String>> getUsedTagIds({
    required String accountId,
  });
}