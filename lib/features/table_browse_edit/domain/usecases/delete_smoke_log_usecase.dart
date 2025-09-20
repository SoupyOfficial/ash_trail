// Use case for deleting smoke logs
// Handles business logic for single and batch delete operations

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for deleting smoke log entries
/// Implements business logic and validation for log deletion
class DeleteSmokeLogUseCase {
  final LogsTableRepository _repository;

  const DeleteSmokeLogUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Delete a single smoke log
  ///
  /// Parameters:
  /// - [smokeLogId]: ID of log to delete (required, non-empty)
  /// - [accountId]: Account ID for verification (required, non-empty)
  ///
  /// Returns:
  /// - void on success
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, void>> call({
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
    return await _repository.deleteSmokeLog(
      smokeLogId: smokeLogId,
      accountId: accountId,
    );
  }
}

/// Use case for batch deleting multiple smoke logs
/// Implements business logic and validation for multi-select deletion
class DeleteSmokeLogsBatchUseCase {
  final LogsTableRepository _repository;

  const DeleteSmokeLogsBatchUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Delete multiple smoke logs in batch
  ///
  /// Parameters:
  /// - [smokeLogIds]: IDs of logs to delete (required, non-empty)
  /// - [accountId]: Account ID for verification (required, non-empty)
  ///
  /// Returns:
  /// - Count of successfully deleted logs
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, int>> call({
    required List<String> smokeLogIds,
    required String accountId,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (smokeLogIds.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'At least one smoke log ID is required',
        field: 'smokeLogIds',
      ));
    }

    // Validation: Check for empty IDs
    final emptyIds = smokeLogIds.where((id) => id.isEmpty).toList();
    if (emptyIds.isNotEmpty) {
      return const Left(AppFailure.validation(
        message: 'All smoke log IDs must be non-empty',
        field: 'smokeLogIds',
      ));
    }

    // Validation: Reasonable batch size limit
    if (smokeLogIds.length > 1000) {
      return const Left(AppFailure.validation(
        message: 'Cannot delete more than 1000 logs at once',
        field: 'smokeLogIds',
      ));
    }

    // Remove duplicates
    final uniqueIds = smokeLogIds.toSet().toList();

    // Delegate to repository
    return await _repository.deleteSmokeLogsBatch(
      smokeLogIds: uniqueIds,
      accountId: accountId,
    );
  }
}