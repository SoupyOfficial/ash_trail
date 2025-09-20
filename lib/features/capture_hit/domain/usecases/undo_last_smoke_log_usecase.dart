// Use case for undoing the last smoke log entry
// Handles business logic for the undo functionality with time-based constraints

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../repositories/smoke_log_repository.dart';

/// Use case for undoing the most recent smoke log entry
/// Implements time-based undo with business logic validation
class UndoLastSmokeLogUseCase {
  final SmokeLogRepository _repository;

  const UndoLastSmokeLogUseCase({
    required SmokeLogRepository repository,
  }) : _repository = repository;

  /// Undoes the last smoke log entry if within the allowed time window
  ///
  /// Parameters:
  /// - [accountId]: ID of the account
  /// - [undoWindowSeconds]: Maximum seconds since creation to allow undo (default: 6)
  ///
  /// Returns:
  /// - [SmokeLog] if successfully undone
  /// - [AppFailure] if no recent log found, window expired, or operation failed
  Future<Either<AppFailure, SmokeLog>> call({
    required String accountId,
    int undoWindowSeconds = 6,
  }) async {
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    // Get the most recent smoke log
    final result = await _repository.getLastSmokeLog(accountId);

    if (result.isLeft()) {
      return result.fold(
        (failure) => Left(failure),
        (_) => throw StateError('Unexpected right value in left check'),
      );
    }

    final lastLog = result.fold(
      (_) => throw StateError('Unexpected left value in right extraction'),
      (smokeLog) => smokeLog,
    );

    if (lastLog == null) {
      return const Left(AppFailure.notFound(
        message: 'No recent smoke log found to undo',
      ));
    }

    // Check if the log is within the undo window
    final now = DateTime.now();
    final timeSinceCreation = now.difference(lastLog.createdAt);

    if (timeSinceCreation.inSeconds > undoWindowSeconds) {
      return Left(AppFailure.validation(
        message:
            'Undo window has expired. You can only undo within $undoWindowSeconds seconds.',
        field: 'undoWindow',
      ));
    }

    // Delete the smoke log (this will return the deleted log or failure)
    return await _deleteAndReturn(lastLog);
  }

  /// Helper method to delete a smoke log and return it if successful
  Future<Either<AppFailure, SmokeLog>> _deleteAndReturn(
      SmokeLog smokeLog) async {
    final deleteResult = await _repository.deleteSmokeLog(smokeLog.id);

    return deleteResult.fold(
      (failure) => Left(failure),
      (_) => Right(smokeLog),
    );
  }
}
