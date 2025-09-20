// Use case for getting a single smoke log by ID
// Handles business logic for detailed edit modal

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for fetching a single smoke log by ID
/// Used for detailed edit modal and verification operations
class GetSmokeLogByIdUseCase {
  final LogsTableRepository _repository;

  const GetSmokeLogByIdUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Get a single smoke log by ID
  ///
  /// Parameters:
  /// - [smokeLogId]: ID of log to fetch (required, non-empty)
  /// - [accountId]: Account ID for verification (required, non-empty)
  ///
  /// Returns:
  /// - SmokeLog if found and accessible
  /// - AppFailure if validation fails, not found, or operation error occurs
  Future<Either<AppFailure, SmokeLog>> call({
    required String smokeLogId,
    required String accountId,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (smokeLogId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Smoke log ID is required',
        field: 'smokeLogId',
      ));
    }

    // Delegate to repository
    return await _repository.getSmokeLogById(
      smokeLogId: smokeLogId,
      accountId: accountId,
    );
  }
}