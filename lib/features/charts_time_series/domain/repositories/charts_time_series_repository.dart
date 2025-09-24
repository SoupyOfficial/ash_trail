// Repository interface for chart data operations
// Defines the contract for fetching and aggregating smoke log data for time series charts

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/chart_data_point.dart';
import '../entities/time_series_chart.dart';

/// Repository interface for managing time series chart data
/// Handles data aggregation and chart generation from SmokeLog data
abstract class ChartsTimeSeriesRepository {
  /// Generate a time series chart based on the provided configuration
  /// Aggregates SmokeLog data according to the specified parameters
  Future<Either<AppFailure, TimeSeriesChart>> generateChart(
    ChartConfig config,
  );

  /// Get raw chart data points for a specific configuration
  /// Useful for chart rendering and data processing
  Future<Either<AppFailure, List<ChartDataPoint>>> getChartDataPoints(
    ChartConfig config,
  );

  /// Get aggregated statistics for a time range
  /// Returns summary statistics like total count, average duration, etc.
  Future<Either<AppFailure, ChartSummary>> getChartSummary({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  });

  /// Check if chart data is available for the given time range
  /// Used to determine whether to show empty state
  Future<Either<AppFailure, bool>> hasDataInRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? visibleTags,
  });

  /// Get available date range for chart data for an account
  /// Used for setting default chart ranges
  Future<Either<AppFailure, DateRange?>> getAvailableDateRange(
    String accountId,
  );
}

/// Summary statistics for chart data
class ChartSummary {
  const ChartSummary({
    required this.totalCount,
    required this.totalDurationMs,
    required this.averageDurationMs,
    required this.averageMoodScore,
    required this.averagePhysicalScore,
    required this.dayCount,
  });

  final int totalCount;
  final int totalDurationMs;
  final double averageDurationMs;
  final double? averageMoodScore;
  final double? averagePhysicalScore;
  final int dayCount;

  // Calculate derived statistics
  double get averagePerDay => dayCount > 0 ? totalCount / dayCount : 0;
  double get totalDurationHours => totalDurationMs / (1000 * 60 * 60);
}

/// Date range for available data
class DateRange {
  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  int get dayCount => endDate.difference(startDate).inDays + 1;

  bool contains(DateTime date) =>
      date.isAtSameMomentAs(startDate) ||
      date.isAtSameMomentAs(endDate) ||
      (date.isAfter(startDate) && date.isBefore(endDate));
}
