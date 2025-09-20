// Use case for getting logs count with filtering
// Handles business logic for pagination calculation

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/log_filter.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for getting the count of filtered smoke logs
/// Used for pagination and displaying total counts
class GetLogsCountUseCase {
  final LogsTableRepository _repository;

  const GetLogsCountUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Get total count of smoke logs matching filter criteria
  ///
  /// Parameters:
  /// - [accountId]: Account ID (required, non-empty)
  /// - [filter]: Filter criteria (optional)
  ///
  /// Returns:
  /// - Total count of matching logs
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, int>> call({
    required String accountId,
    LogFilter? filter,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    // Delegate to repository
    return await _repository.getLogsCount(
      accountId: accountId,
      filter: filter,
    );
  }
}