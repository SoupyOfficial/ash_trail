// Repository interface for smoke logs table browse and edit operations
// Extends the base smoke log operations with specialized table functionality

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../entities/log_filter.dart';
import '../entities/log_sort.dart';

/// Repository interface for table browse and edit operations on smoke logs
/// Provides filtering, sorting, pagination, and editing capabilities
abstract class LogsTableRepository {
  /// Get paginated smoke logs with filtering and sorting
  ///
  /// Parameters:
  /// - [accountId]: Account to fetch logs for (required)
  /// - [filter]: Filter criteria to apply (optional)
  /// - [sort]: Sort configuration (optional, defaults to newest first)
  /// - [limit]: Maximum number of results (optional, defaults to 50)
  /// - [offset]: Number of results to skip for pagination (optional)
  ///
  /// Returns:
  /// - List of matching smoke logs
  /// - AppFailure if error occurs
  Future<Either<AppFailure, List<SmokeLog>>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  });

  /// Get total count of smoke logs matching filter criteria
  /// Used for pagination calculation
  ///
  /// Parameters:
  /// - [accountId]: Account to count logs for (required)
  /// - [filter]: Filter criteria to apply (optional)
  ///
  /// Returns:
  /// - Total count of matching logs
  /// - AppFailure if error occurs
  Future<Either<AppFailure, int>> getLogsCount({
    required String accountId,
    LogFilter? filter,
  });

  /// Update an existing smoke log
  /// Used for inline editing functionality
  ///
  /// Parameters:
  /// - [smokeLog]: Updated smoke log data
  ///
  /// Returns:
  /// - Updated smoke log
  /// - AppFailure if error occurs (validation, not found, etc.)
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog);

  /// Delete a smoke log by ID
  /// Used for swipe-to-delete functionality
  ///
  /// Parameters:
  /// - [smokeLogId]: ID of log to delete
  /// - [accountId]: Account ID for verification
  ///
  /// Returns:
  /// - void on success
  /// - AppFailure if error occurs (not found, permission denied, etc.)
  Future<Either<AppFailure, void>> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  });

  /// Batch delete multiple smoke logs
  /// Used for multi-select delete functionality
  ///
  /// Parameters:
  /// - [smokeLogIds]: IDs of logs to delete
  /// - [accountId]: Account ID for verification
  ///
  /// Returns:
  /// - Count of successfully deleted logs
  /// - AppFailure if error occurs
  Future<Either<AppFailure, int>> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  });

  /// Get a single smoke log by ID
  /// Used for detailed edit modal
  ///
  /// Parameters:
  /// - [smokeLogId]: ID of log to fetch
  /// - [accountId]: Account ID for verification
  ///
  /// Returns:
  /// - Smoke log if found
  /// - AppFailure if not found or error occurs
  Future<Either<AppFailure, SmokeLog>> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  });

  /// Get distinct method IDs used in smoke logs for filter options
  /// Used to populate method filter dropdown
  ///
  /// Parameters:
  /// - [accountId]: Account to get methods for
  ///
  /// Returns:
  /// - List of method IDs that have been used in logs
  /// - AppFailure if error occurs
  Future<Either<AppFailure, List<String>>> getUsedMethodIds({
    required String accountId,
  });

  /// Get distinct tag IDs used in smoke logs for filter options
  /// Used to populate tag filter chips
  ///
  /// Parameters:
  /// - [accountId]: Account to get tags for
  ///
  /// Returns:
  /// - List of tag IDs that have been used in logs
  /// - AppFailure if error occurs
  Future<Either<AppFailure, List<String>>> getUsedTagIds({
    required String accountId,
  });
}