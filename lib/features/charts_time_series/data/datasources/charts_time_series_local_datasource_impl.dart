// Concrete implementation of chart data local data source
// Aggregates SmokeLog data and handles chart caching using Isar (when available)

import 'dart:math';

import '../../domain/entities/chart_data_point.dart';
import '../../domain/entities/time_series_chart.dart';
import '../../domain/repositories/charts_time_series_repository.dart';
import '../../../capture_hit/data/datasources/smoke_log_local_datasource.dart';
import '../models/chart_data_point_dto.dart';
import '../models/time_series_chart_dto.dart';
import 'charts_time_series_local_datasource.dart';

/// Implementation of chart data aggregation using local SmokeLog data
/// Provides real-time aggregation and basic in-memory caching
class ChartsTimeSeriesLocalDataSourceImpl
    implements ChartsTimeSeriesLocalDataSource {
  final SmokeLogLocalDataSource _smokeLogDataSource;
  final Map<String, TimeSeriesChartDto> _chartCache = {};

  ChartsTimeSeriesLocalDataSourceImpl({
    required SmokeLogLocalDataSource smokeLogDataSource,
  }) : _smokeLogDataSource = smokeLogDataSource;

  @override
  Future<List<ChartDataPointDto>> aggregateChartData(ChartConfig config) async {
    // Get smoke logs for the time range
    final smokeLogs = await _smokeLogDataSource.getSmokeLogsByDateRange(
      accountId: config.accountId,
      startDate: config.startDate,
      endDate: config.endDate,
    );

    // Filter by visible tags if specified
    final filteredLogs = config.visibleTags != null
        ? smokeLogs.where((log) {
            // Note: This is a simplified tag filter - in real implementation,
            // we would need to check SmokeLogTag relationships
            return true; // Placeholder for tag filtering logic
          }).toList()
        : smokeLogs;

    // Group logs by time buckets based on aggregation
    final Map<DateTime, List<dynamic>> buckets = {};

    for (final log in filteredLogs) {
      final bucketKey = _getBucketKey(log.ts, config.aggregation);
      buckets.putIfAbsent(bucketKey, () => []).add(log);
    }

    // Convert to data points
    final dataPoints = <ChartDataPointDto>[];

    for (final entry in buckets.entries) {
      final bucketLogs = entry.value;
      final timestamp = entry.key;

      // Calculate aggregated values
      final count = bucketLogs.length;
      final totalDurationMs = bucketLogs.fold<int>(
        0,
        (sum, log) => sum + (log.durationMs as int),
      );

      final totalMood = bucketLogs.fold<int>(
        0,
        (sum, log) => sum + (log.moodScore as int),
      );

      final totalPhysical = bucketLogs.fold<int>(
        0,
        (sum, log) => sum + (log.physicalScore as int),
      );

      // Calculate primary value based on metric
      double value;
      switch (config.metric) {
        case ChartMetric.count:
          value = count.toDouble();
          break;
        case ChartMetric.duration:
          value = totalDurationMs.toDouble();
          break;
        case ChartMetric.averageDuration:
          value = count > 0 ? totalDurationMs / count : 0;
          break;
        case ChartMetric.moodScore:
          value = count > 0 ? totalMood / count : 0;
          break;
        case ChartMetric.physicalScore:
          value = count > 0 ? totalPhysical / count : 0;
          break;
      }

      dataPoints.add(ChartDataPointDto(
        timestamp: timestamp,
        value: value,
        count: count,
        totalDurationMs: totalDurationMs,
        averageMoodScore: count > 0 ? totalMood / count : null,
        averagePhysicalScore: count > 0 ? totalPhysical / count : null,
      ));
    }

    // Sort by timestamp
    dataPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Apply smoothing if requested
    return _applySmoothing(
        dataPoints, config.smoothing, config.smoothingWindow);
  }

  @override
  Future<TimeSeriesChartDto?> getCachedChart(String chartId) async {
    return _chartCache[chartId];
  }

  @override
  Future<void> cacheChart(TimeSeriesChartDto chart) async {
    _chartCache[chart.id] = chart;
    // TODO: Implement persistent caching with TTL when Isar is available
  }

  @override
  Future<ChartSummary> getChartSummary({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  }) async {
    // Get smoke logs for the time range
    final smokeLogs = await _smokeLogDataSource.getSmokeLogsByDateRange(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
    );

    if (smokeLogs.isEmpty) {
      return ChartSummary(
        totalCount: 0,
        totalDurationMs: 0,
        averageDurationMs: 0,
        averageMoodScore: null,
        averagePhysicalScore: null,
        dayCount: endDate.difference(startDate).inDays + 1,
      );
    }

    final totalCount = smokeLogs.length;
    final totalDurationMs = smokeLogs.fold<int>(
      0,
      (sum, log) => sum + log.durationMs,
    );
    final totalMood = smokeLogs.fold<int>(
      0,
      (sum, log) => sum + log.moodScore,
    );
    final totalPhysical = smokeLogs.fold<int>(
      0,
      (sum, log) => sum + log.physicalScore,
    );

    return ChartSummary(
      totalCount: totalCount,
      totalDurationMs: totalDurationMs,
      averageDurationMs: totalCount > 0 ? totalDurationMs / totalCount : 0,
      averageMoodScore: totalCount > 0 ? totalMood / totalCount : null,
      averagePhysicalScore: totalCount > 0 ? totalPhysical / totalCount : null,
      dayCount: endDate.difference(startDate).inDays + 1,
    );
  }

  @override
  Future<bool> hasDataInRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  }) async {
    // Get limited results to check existence
    final smokeLogs = await _smokeLogDataSource.getSmokeLogsByDateRange(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      limit: 1, // We only need to know if any exist
    );

    return smokeLogs.isNotEmpty;
  }

  @override
  Future<DateRange?> getAvailableDateRange(String accountId) async {
    // This would require additional queries to get min/max dates
    // For now, return null to indicate we need to implement this
    // TODO: Implement with proper date range queries when Isar is available
    return null;
  }

  @override
  Future<void> clearStaleCache() async {
    // Simple cache clearing - in production, implement TTL logic
    _chartCache.clear();
  }

  /// Get the time bucket key for aggregation
  DateTime _getBucketKey(DateTime timestamp, ChartAggregation aggregation) {
    switch (aggregation) {
      case ChartAggregation.daily:
        return DateTime(timestamp.year, timestamp.month, timestamp.day);
      case ChartAggregation.weekly:
        // Start of week (Monday)
        final daysFromMonday = timestamp.weekday - 1;
        return DateTime(timestamp.year, timestamp.month, timestamp.day)
            .subtract(Duration(days: daysFromMonday));
      case ChartAggregation.monthly:
        return DateTime(timestamp.year, timestamp.month, 1);
    }
  }

  /// Apply smoothing to data points
  List<ChartDataPointDto> _applySmoothing(
    List<ChartDataPointDto> dataPoints,
    ChartSmoothing smoothing,
    int window,
  ) {
    switch (smoothing) {
      case ChartSmoothing.none:
        return dataPoints;
      case ChartSmoothing.movingAverage:
        return _applyMovingAverage(dataPoints, window);
      case ChartSmoothing.cumulative:
        return _applyCumulative(dataPoints);
    }
  }

  /// Apply moving average smoothing
  List<ChartDataPointDto> _applyMovingAverage(
    List<ChartDataPointDto> dataPoints,
    int window,
  ) {
    if (dataPoints.length < window) return dataPoints;

    final smoothed = <ChartDataPointDto>[];

    for (int i = 0; i < dataPoints.length; i++) {
      final start = max(0, i - window + 1);
      final end = i + 1;

      final windowPoints = dataPoints.sublist(start, end);
      final avgValue = windowPoints.fold<double>(
            0,
            (sum, point) => sum + point.value,
          ) /
          windowPoints.length;

      smoothed.add(dataPoints[i].copyWith(value: avgValue));
    }

    return smoothed;
  }

  /// Apply cumulative smoothing
  List<ChartDataPointDto> _applyCumulative(List<ChartDataPointDto> dataPoints) {
    final cumulative = <ChartDataPointDto>[];
    double runningTotal = 0;

    for (final point in dataPoints) {
      runningTotal += point.value;
      cumulative.add(point.copyWith(value: runningTotal));
    }

    return cumulative;
  }
}
