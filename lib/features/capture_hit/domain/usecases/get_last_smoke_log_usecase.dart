// Use case for retrieving the most recent smoke log entry
// Handles business logic for fetching the latest log for undo operations

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../repositories/smoke_log_repository.dart';

/// Use case for retrieving the most recent smoke log entry
/// Used primarily for undo functionality but could be used for other features
class GetLastSmokeLogUseCase {
  final SmokeLogRepository _repository;

  const GetLastSmokeLogUseCase({
    required SmokeLogRepository repository,
  }) : _repository = repository;

  /// Retrieves the most recent smoke log for the given account
  ///
  /// Parameters:
  /// - [accountId]: ID of the account to query
  ///
  /// Returns:
  /// - [SmokeLog?] the most recent log or null if none exists
  /// - [AppFailure] if the operation failed or validation error
  Future<Either<AppFailure, SmokeLog?>> call({
    required String accountId,
  }) async {
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    return _repository.getLastSmokeLog(accountId);
  }
}
