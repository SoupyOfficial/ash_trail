// Use case for generating time series charts
// Handles business logic for chart creation and configuration validation

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/time_series_chart.dart';
import '../repositories/charts_time_series_repository.dart';

/// Use case for generating time series charts with configuration validation
/// Implements business logic for chart data aggregation and presentation
class GenerateChartUseCase
    implements UseCase<TimeSeriesChart, GenerateChartParams> {
  final ChartsTimeSeriesRepository _repository;

  const GenerateChartUseCase({
    required ChartsTimeSeriesRepository repository,
  }) : _repository = repository;

  /// Generates a time series chart with validation and business rules
  ///
  /// Parameters: [GenerateChartParams] containing chart configuration
  ///
  /// Returns:
  /// - [TimeSeriesChart] if successfully generated
  /// - [AppFailure] if validation fails or generation error occurs
  @override
  Future<Either<AppFailure, TimeSeriesChart>> call(
    GenerateChartParams params,
  ) async {
    // Validate chart configuration
    final validationResult = _validateChartConfig(params.config);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Generate chart via repository
    return await _repository.generateChart(params.config);
  }

  /// Validate chart configuration for business rules
  AppFailure? _validateChartConfig(ChartConfig config) {
    // Account ID validation
    if (config.accountId.isEmpty) {
      return const AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      );
    }

    // Date range validation
    if (!config.isValidTimeRange) {
      return const AppFailure.validation(
        message: 'End date must be after or equal to start date',
        field: 'dateRange',
      );
    }

    // Maximum time range validation (2 years)
    const maxDays = 730; // 2 years
    if (config.dayCount > maxDays) {
      return const AppFailure.validation(
        message: 'Date range cannot exceed 2 years',
        field: 'dateRange',
      );
    }

    // Future date validation - don't allow charts extending too far into future
    final maxFutureDate = DateTime.now().add(const Duration(days: 7));
    if (config.endDate.isAfter(maxFutureDate)) {
      return const AppFailure.validation(
        message: 'End date cannot be more than 7 days in the future',
        field: 'endDate',
      );
    }

    // Smoothing window validation
    if (config.requiresSmoothingWindow) {
      if (config.smoothingWindow < 2) {
        return const AppFailure.validation(
          message: 'Smoothing window must be at least 2',
          field: 'smoothingWindow',
        );
      }

      if (config.smoothingWindow > config.dayCount) {
        return const AppFailure.validation(
          message: 'Smoothing window cannot exceed date range',
          field: 'smoothingWindow',
        );
      }
    }

    return null;
  }
}

/// Parameters for generating a chart
class GenerateChartParams {
  const GenerateChartParams({
    required this.config,
    this.title,
  });

  final ChartConfig config;
  final String? title;
}
