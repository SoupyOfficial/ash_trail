// Repository interface for SmokeLog operations
// Defines the contract for managing smoke log persistence and retrieval

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';

/// Repository interface for managing SmokeLog entities
/// Follows offline-first pattern with local storage and remote sync
abstract class SmokeLogRepository {
  /// Create a new smoke log entry
  /// Saves to local storage first, then enqueues for remote sync
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog);

  /// Get the most recent smoke log for an account
  /// Used for undo functionality
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(String accountId);

  /// Delete a smoke log by ID
  /// Used for undo functionality
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId);

  /// Get smoke logs for an account within a date range
  /// Used for list display and analytics
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });

  /// Update an existing smoke log
  /// Used for editing entries
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog);
}
