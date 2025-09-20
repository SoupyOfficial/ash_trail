// Use case for deleting smoke log entries
// Handles business logic for smoke log deletion with validation

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/smoke_log_repository.dart';

/// Use case for deleting smoke log entries
/// Provides business logic layer for smoke log deletion operations
class DeleteSmokeLogUseCase {
  final SmokeLogRepository _repository;

  const DeleteSmokeLogUseCase({
    required SmokeLogRepository repository,
  }) : _repository = repository;

  /// Deletes a smoke log by its ID
  ///
  /// Parameters:
  /// - [smokeLogId]: ID of the smoke log to delete
  ///
  /// Returns:
  /// - [void] if successfully deleted
  /// - [AppFailure] if the operation failed or validation error
  Future<Either<AppFailure, void>> call({
    required String smokeLogId,
  }) async {
    if (smokeLogId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Smoke log ID is required',
        field: 'smokeLogId',
      ));
    }

    return _repository.deleteSmokeLog(smokeLogId);
  }
}
