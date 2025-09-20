// Use case for undoing the last created smoke log.
// Encapsulates business logic for undo functionality with timeout validation.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../capture_hit/domain/repositories/smoke_log_repository.dart';

/// Use case for undoing the last smoke log entry
///
/// Business rules:
/// - Only allows undo within timeout period (6 seconds based on feature spec)
/// - Undo is idempotent - can be called multiple times safely
/// - Works offline-first - deletion queued for sync
class UndoLastLogUseCase {
  static const Duration _undoTimeoutDuration = Duration(seconds: 6);

  final SmokeLogRepository _smokeLogRepository;

  const UndoLastLogUseCase({
    required SmokeLogRepository smokeLogRepository,
  }) : _smokeLogRepository = smokeLogRepository;

  /// Undo the last smoke log for the given account
  ///
  /// Returns success if:
  /// - Last log exists and is within timeout period
  /// - Log was successfully deleted
  /// - Already deleted (idempotent operation)
  ///
  /// Returns failure if:
  /// - No logs exist for account
  /// - Last log is beyond timeout period
  /// - Database/storage error occurs
  Future<Either<AppFailure, void>> call(String accountId) async {
    try {
      // Get the most recent smoke log
      final lastLogResult =
          await _smokeLogRepository.getLastSmokeLog(accountId);

      return lastLogResult.fold(
        (failure) => Left(failure),
        (lastLog) async {
          if (lastLog == null) {
            return const Left(AppFailure.notFound(
              message: 'No smoke logs found to undo',
            ));
          }

          // Check if the log is within the undo timeout period
          final now = DateTime.now();
          final timeSinceCreated = now.difference(lastLog.createdAt);

          if (timeSinceCreated > _undoTimeoutDuration) {
            return const Left(AppFailure.validation(
              message:
                  'Undo timeout expired. Can only undo within 6 seconds of creation.',
            ));
          }

          // Delete the log (idempotent operation)
          final deleteResult =
              await _smokeLogRepository.deleteSmokeLog(lastLog.id);

          return deleteResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(AppFailure.unexpected(
        message: 'Unexpected error during undo operation: ${e.toString()}',
        cause: e,
      ));
    }
  }

  /// Check if undo is currently available for the given account
  ///
  /// This is useful for UI state management to show/hide undo options
  Future<Either<AppFailure, bool>> canUndo(String accountId) async {
    try {
      final lastLogResult =
          await _smokeLogRepository.getLastSmokeLog(accountId);

      return lastLogResult.fold(
        (failure) => Left(failure),
        (lastLog) {
          if (lastLog == null) {
            return const Right(false);
          }

          final now = DateTime.now();
          final timeSinceCreated = now.difference(lastLog.createdAt);

          return Right(timeSinceCreated <= _undoTimeoutDuration);
        },
      );
    } catch (e) {
      return Left(AppFailure.unexpected(
        message: 'Unexpected error checking undo availability: ${e.toString()}',
        cause: e,
      ));
    }
  }

  /// Get the remaining time for undo operation
  ///
  /// Returns the remaining seconds within the timeout window
  /// Returns 0 if no undo is available or timeout has expired
  Future<Either<AppFailure, int>> getUndoTimeRemaining(String accountId) async {
    try {
      final lastLogResult =
          await _smokeLogRepository.getLastSmokeLog(accountId);

      return lastLogResult.fold(
        (failure) => Left(failure),
        (lastLog) {
          if (lastLog == null) {
            return const Right(0);
          }

          final now = DateTime.now();
          final timeSinceCreated = now.difference(lastLog.createdAt);
          final timeRemaining = _undoTimeoutDuration - timeSinceCreated;

          if (timeRemaining.isNegative) {
            return const Right(0);
          }

          return Right(timeRemaining.inSeconds);
        },
      );
    } catch (e) {
      return Left(AppFailure.unexpected(
        message:
            'Unexpected error getting undo time remaining: ${e.toString()}',
        cause: e,
      ));
    }
  }
}
