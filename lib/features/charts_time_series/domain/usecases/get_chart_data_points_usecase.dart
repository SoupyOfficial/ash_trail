// Use case for getting chart data points
// Handles fetching raw data points for chart rendering

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chart_data_point.dart';
import '../entities/time_series_chart.dart';
import '../repositories/charts_time_series_repository.dart';

/// Use case for getting chart data points for rendering
/// Provides validated data points ready for chart visualization
class GetChartDataPointsUseCase
    implements UseCase<List<ChartDataPoint>, ChartConfig> {
  final ChartsTimeSeriesRepository _repository;

  const GetChartDataPointsUseCase({
    required ChartsTimeSeriesRepository repository,
  }) : _repository = repository;

  /// Get chart data points with configuration validation
  ///
  /// Parameters: [ChartConfig] containing chart parameters
  ///
  /// Returns:
  /// - [List<ChartDataPoint>] if successfully retrieved
  /// - [AppFailure] if validation fails or retrieval error occurs
  @override
  Future<Either<AppFailure, List<ChartDataPoint>>> call(
    ChartConfig config,
  ) async {
    // Basic validation
    if (config.accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (!config.isValidTimeRange) {
      return const Left(AppFailure.validation(
        message: 'Invalid date range',
        field: 'dateRange',
      ));
    }

    // Get data points via repository
    return await _repository.getChartDataPoints(config);
  }
}
