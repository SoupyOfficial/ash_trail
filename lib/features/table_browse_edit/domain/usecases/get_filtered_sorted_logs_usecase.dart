// Use case for getting filtered and sorted smoke logs
// Handles business logic for table view operations

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../entities/log_filter.dart';
import '../entities/log_sort.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for fetching filtered and sorted smoke logs for table view
/// Implements business logic and validation for table browsing
class GetFilteredSortedLogsUseCase {
  final LogsTableRepository _repository;

  const GetFilteredSortedLogsUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Get paginated, filtered, and sorted smoke logs
  ///
  /// Parameters:
  /// - [accountId]: Account ID (required, non-empty)
  /// - [filter]: Filter criteria (optional)
  /// - [sort]: Sort configuration (optional, defaults to newest first)
  /// - [limit]: Page size (optional, defaults to 50, max 500)
  /// - [offset]: Pagination offset (optional, defaults to 0)
  ///
  /// Returns:
  /// - List of matching smoke logs
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, List<SmokeLog>>> call({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    // Validation: Check pagination parameters
    final actualLimit = limit ?? 50;
    final actualOffset = offset ?? 0;

    if (actualLimit <= 0 || actualLimit > 500) {
      return const Left(AppFailure.validation(
        message: 'Limit must be between 1 and 500',
        field: 'limit',
      ));
    }

    if (actualOffset < 0) {
      return const Left(AppFailure.validation(
        message: 'Offset must be non-negative',
        field: 'offset',
      ));
    }

    // Validation: Check filter parameters
    if (filter != null) {
      final filterValidation = _validateFilter(filter);
      if (filterValidation != null) {
        return Left(filterValidation);
      }
    }

    // Use default sort if not provided
    final actualSort = sort ?? LogSort.defaultSort;

    // Delegate to repository
    return await _repository.getFilteredSortedLogs(
      accountId: accountId,
      filter: filter,
      sort: actualSort,
      limit: actualLimit,
      offset: actualOffset,
    );
  }

  /// Validate filter criteria
  AppFailure? _validateFilter(LogFilter filter) {
    // Date range validation
    if (filter.startDate != null && filter.endDate != null) {
      if (filter.startDate!.isAfter(filter.endDate!)) {
        return const AppFailure.validation(
          message: 'Start date must be before end date',
          field: 'dateRange',
        );
      }
    }

    // Mood score validation
    if (filter.minMoodScore != null && 
        (filter.minMoodScore! < 1 || filter.minMoodScore! > 10)) {
      return const AppFailure.validation(
        message: 'Minimum mood score must be between 1 and 10',
        field: 'minMoodScore',
      );
    }

    if (filter.maxMoodScore != null && 
        (filter.maxMoodScore! < 1 || filter.maxMoodScore! > 10)) {
      return const AppFailure.validation(
        message: 'Maximum mood score must be between 1 and 10',
        field: 'maxMoodScore',
      );
    }

    if (filter.minMoodScore != null && filter.maxMoodScore != null &&
        filter.minMoodScore! > filter.maxMoodScore!) {
      return const AppFailure.validation(
        message: 'Minimum mood score must not exceed maximum',
        field: 'moodScoreRange',
      );
    }

    // Physical score validation
    if (filter.minPhysicalScore != null && 
        (filter.minPhysicalScore! < 1 || filter.minPhysicalScore! > 10)) {
      return const AppFailure.validation(
        message: 'Minimum physical score must be between 1 and 10',
        field: 'minPhysicalScore',
      );
    }

    if (filter.maxPhysicalScore != null && 
        (filter.maxPhysicalScore! < 1 || filter.maxPhysicalScore! > 10)) {
      return const AppFailure.validation(
        message: 'Maximum physical score must be between 1 and 10',
        field: 'maxPhysicalScore',
      );
    }

    if (filter.minPhysicalScore != null && filter.maxPhysicalScore != null &&
        filter.minPhysicalScore! > filter.maxPhysicalScore!) {
      return const AppFailure.validation(
        message: 'Minimum physical score must not exceed maximum',
        field: 'physicalScoreRange',
      );
    }

    // Duration validation
    if (filter.minDurationMs != null && filter.minDurationMs! < 0) {
      return const AppFailure.validation(
        message: 'Minimum duration must be non-negative',
        field: 'minDurationMs',
      );
    }

    if (filter.maxDurationMs != null && filter.maxDurationMs! < 0) {
      return const AppFailure.validation(
        message: 'Maximum duration must be non-negative',
        field: 'maxDurationMs',
      );
    }

    if (filter.minDurationMs != null && filter.maxDurationMs != null &&
        filter.minDurationMs! > filter.maxDurationMs!) {
      return const AppFailure.validation(
        message: 'Minimum duration must not exceed maximum',
        field: 'durationRange',
      );
    }

    return null;
  }
}