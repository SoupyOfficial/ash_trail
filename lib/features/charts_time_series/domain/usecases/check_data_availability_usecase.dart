// Use case for checking data availability in time ranges
// Handles validation of whether chart data exists for given parameters

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/charts_time_series_repository.dart';

/// Use case for checking if chart data is available in a time range
/// Used to determine when to show empty states vs loading states
class CheckDataAvailabilityUseCase
    implements UseCase<bool, CheckDataAvailabilityParams> {
  final ChartsTimeSeriesRepository _repository;

  const CheckDataAvailabilityUseCase({
    required ChartsTimeSeriesRepository repository,
  }) : _repository = repository;

  /// Check if data is available for the specified range and filters
  ///
  /// Parameters: [CheckDataAvailabilityParams] containing query parameters
  ///
  /// Returns:
  /// - [bool] indicating if data exists
  /// - [AppFailure] if validation fails or query error occurs
  @override
  Future<Either<AppFailure, bool>> call(
    CheckDataAvailabilityParams params,
  ) async {
    // Basic validation
    if (params.accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (params.endDate.isBefore(params.startDate)) {
      return const Left(AppFailure.validation(
        message: 'End date must be after start date',
        field: 'dateRange',
      ));
    }

    // Check data availability via repository
    return await _repository.hasDataInRange(
      accountId: params.accountId,
      startDate: params.startDate,
      endDate: params.endDate,
      visibleTags: params.visibleTags,
    );
  }
}

/// Parameters for checking data availability
class CheckDataAvailabilityParams {
  const CheckDataAvailabilityParams({
    required this.accountId,
    required this.startDate,
    required this.endDate,
    this.visibleTags,
  });

  final String accountId;
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? visibleTags;
}
