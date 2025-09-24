// Repository implementation for charts time series functionality
// Orchestrates data sources and implements business logic for chart generation

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/chart_data_point.dart';
import '../../domain/entities/time_series_chart.dart';
import '../../domain/repositories/charts_time_series_repository.dart';
import '../datasources/charts_time_series_local_datasource.dart';
import '../models/chart_data_point_dto.dart';
import '../models/time_series_chart_dto.dart';

/// Implementation of ChartsTimeSeriesRepository using local data aggregation
/// Provides offline-first chart generation with optional caching
class ChartsTimeSeriesRepositoryImpl implements ChartsTimeSeriesRepository {
  final ChartsTimeSeriesLocalDataSource _localDataSource;

  const ChartsTimeSeriesRepositoryImpl({
    required ChartsTimeSeriesLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Either<AppFailure, TimeSeriesChart>> generateChart(
    ChartConfig config,
  ) async {
    try {
      // Generate unique ID for this chart configuration
      final chartId = _generateChartId(config);

      // Check for cached chart first
      final cachedChart = await _localDataSource.getCachedChart(chartId);
      if (cachedChart != null) {
        return Right(cachedChart.toEntity());
      }

      // Generate chart data
      final dataPoints = await _localDataSource.aggregateChartData(config);

      // Create chart entity
      final chart = TimeSeriesChart(
        id: chartId,
        accountId: config.accountId,
        title: _generateChartTitle(config),
        startDate: config.startDate,
        endDate: config.endDate,
        aggregation: config.aggregation,
        metric: config.metric,
        smoothing: config.smoothing,
        dataPoints: dataPoints.map((dto) => dto.toEntity()).toList(),
        smoothingWindow: config.smoothingWindow,
        visibleTags: config.visibleTags,
        createdAt: DateTime.now(),
      );

      // Cache the chart for future requests
      await _localDataSource.cacheChart(chart.toDto());

      return Right(chart);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to generate chart: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, List<ChartDataPoint>>> getChartDataPoints(
    ChartConfig config,
  ) async {
    try {
      final dataPointDtos = await _localDataSource.aggregateChartData(config);
      final dataPoints = dataPointDtos.map((dto) => dto.toEntity()).toList();
      return Right(dataPoints);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to get chart data points: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, ChartSummary>> getChartSummary({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  }) async {
    try {
      final summary = await _localDataSource.getChartSummary(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        visibleTags: visibleTags,
      );
      return Right(summary);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to get chart summary: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, bool>> hasDataInRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  }) async {
    try {
      final hasData = await _localDataSource.hasDataInRange(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        visibleTags: visibleTags,
      );
      return Right(hasData);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to check data availability: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, DateRange?>> getAvailableDateRange(
    String accountId,
  ) async {
    try {
      final dateRange = await _localDataSource.getAvailableDateRange(accountId);
      return Right(dateRange);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to get available date range: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Generate a unique ID for chart configuration
  /// Used for caching and deduplication
  String _generateChartId(ChartConfig config) {
    final components = [
      config.accountId,
      config.startDate.millisecondsSinceEpoch.toString(),
      config.endDate.millisecondsSinceEpoch.toString(),
      config.aggregation.name,
      config.metric.name,
      config.smoothing.name,
      config.smoothingWindow.toString(),
      (config.visibleTags ?? []).join(','),
    ];

    return components.join('_');
  }

  /// Generate a human-readable title for the chart
  String _generateChartTitle(ChartConfig config) {
    final metricLabel = _getMetricLabel(config.metric);
    final aggregationLabel = _getAggregationLabel(config.aggregation);
    final days = config.endDate.difference(config.startDate).inDays + 1;

    return '$metricLabel by $aggregationLabel ($days days)';
  }

  String _getMetricLabel(ChartMetric metric) {
    switch (metric) {
      case ChartMetric.count:
        return 'Log Count';
      case ChartMetric.duration:
        return 'Total Duration';
      case ChartMetric.averageDuration:
        return 'Average Duration';
      case ChartMetric.moodScore:
        return 'Average Mood';
      case ChartMetric.physicalScore:
        return 'Average Physical';
    }
  }

  String _getAggregationLabel(ChartAggregation aggregation) {
    switch (aggregation) {
      case ChartAggregation.daily:
        return 'Day';
      case ChartAggregation.weekly:
        return 'Week';
      case ChartAggregation.monthly:
        return 'Month';
    }
  }
}
