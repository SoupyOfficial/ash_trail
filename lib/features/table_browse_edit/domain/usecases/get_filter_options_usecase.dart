// Use case for getting filter options
// Handles business logic for populating filter dropdowns and chips

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for getting distinct method IDs used in smoke logs
/// Used to populate method filter dropdown
class GetUsedMethodIdsUseCase {
  final LogsTableRepository _repository;

  const GetUsedMethodIdsUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Get distinct method IDs that have been used in smoke logs
  ///
  /// Parameters:
  /// - [accountId]: Account ID (required, non-empty)
  ///
  /// Returns:
  /// - List of method IDs that have been used
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, List<String>>> call({
    required String accountId,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    // Delegate to repository
    return await _repository.getUsedMethodIds(accountId: accountId);
  }
}

/// Use case for getting distinct tag IDs used in smoke logs
/// Used to populate tag filter chips
class GetUsedTagIdsUseCase {
  final LogsTableRepository _repository;

  const GetUsedTagIdsUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Get distinct tag IDs that have been used in smoke logs
  ///
  /// Parameters:
  /// - [accountId]: Account ID (required, non-empty)
  ///
  /// Returns:
  /// - List of tag IDs that have been used
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, List<String>>> call({
    required String accountId,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    // Delegate to repository
    return await _repository.getUsedTagIds(accountId: accountId);
  }
}