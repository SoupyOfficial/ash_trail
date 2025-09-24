// Local data source interface for chart data aggregation
// Aggregates SmokeLog data into chart data points and handles caching

import '../../domain/entities/time_series_chart.dart';
import '../../domain/repositories/charts_time_series_repository.dart';
import '../models/chart_data_point_dto.dart';
import '../models/time_series_chart_dto.dart';

/// Abstract interface for local chart data operations
/// Handles aggregation of SmokeLog data and chart caching
abstract class ChartsTimeSeriesLocalDataSource {
  /// Aggregate smoke log data into chart data points
  /// Performs real-time aggregation based on configuration
  Future<List<ChartDataPointDto>> aggregateChartData(ChartConfig config);

  /// Get cached chart if available and up-to-date
  /// Returns null if cache miss or stale data
  Future<TimeSeriesChartDto?> getCachedChart(String chartId);

  /// Cache a generated chart for future use
  /// TTL should be configurable based on data volatility
  Future<void> cacheChart(TimeSeriesChartDto chart);

  /// Get chart summary statistics for a time range
  /// Optimized query for summary data without full aggregation
  Future<ChartSummary> getChartSummary({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  });

  /// Check if any data exists in the given time range
  /// Fast existence check for empty state logic
  Future<bool> hasDataInRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  });

  /// Get the available date range for an account
  /// Returns first and last log timestamps
  Future<DateRange?> getAvailableDateRange(String accountId);

  /// Clear stale cached charts
  /// Should be called periodically to manage storage
  Future<void> clearStaleCache();
}
