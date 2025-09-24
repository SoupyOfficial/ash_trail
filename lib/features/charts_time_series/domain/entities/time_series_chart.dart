import 'package:freezed_annotation/freezed_annotation.dart';
import 'chart_data_point.dart';

part 'time_series_chart.freezed.dart';
part 'time_series_chart.g.dart';

/// Represents a complete time series chart with data points and metadata
@freezed
class TimeSeriesChart with _$TimeSeriesChart {
  const factory TimeSeriesChart({
    /// Unique identifier for this chart
    required String id,

    /// Account this chart belongs to
    required String accountId,

    /// Human-readable title for the chart
    required String title,

    /// Time range start (inclusive)
    required DateTime startDate,

    /// Time range end (inclusive)
    required DateTime endDate,

    /// Aggregation level for data points
    required ChartAggregation aggregation,

    /// Metric being displayed
    required ChartMetric metric,

    /// Smoothing applied to the data
    required ChartSmoothing smoothing,

    /// Data points for the chart
    required List<ChartDataPoint> dataPoints,

    /// Window size for moving average (if applicable)
    int? smoothingWindow,

    /// Tags to filter by (null means all tags)
    List<String>? visibleTags,

    /// When this chart was generated
    required DateTime createdAt,
  }) = _TimeSeriesChart;

  const TimeSeriesChart._();

  factory TimeSeriesChart.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesChartFromJson(json);

  /// Whether the chart has any data to display
  bool get hasData => dataPoints.isNotEmpty;

  /// Whether the chart has valid data points with values
  bool get hasValidData => dataPoints.any((point) => point.hasData);

  /// Total number of entries across all data points
  int get totalCount => dataPoints.fold(0, (sum, point) => sum + point.count);

  /// Total duration in milliseconds across all data points
  int get totalDurationMs =>
      dataPoints.fold(0, (sum, point) => sum + point.totalDurationMs);

  /// Average value across all data points (weighted by count)
  double get averageValue {
    if (!hasValidData) return 0.0;

    final totalValue =
        dataPoints.fold(0.0, (sum, point) => sum + (point.value * point.count));

    return totalValue / totalCount;
  }

  /// Maximum value in the dataset
  double get maxValue => hasValidData
      ? dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b)
      : 0.0;

  /// Minimum value in the dataset
  double get minValue => hasValidData
      ? dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b)
      : 0.0;

  /// Get formatted title with metric and range info
  String get formattedTitle {
    final metricLabel = _getMetricLabel();
    final rangeLabel = _getRangeLabel();
    return '$title - $metricLabel ($rangeLabel)';
  }

  /// Get data points filtered to only show valid data
  List<ChartDataPoint> get validDataPoints =>
      dataPoints.where((point) => point.hasData).toList();

  String _getMetricLabel() {
    switch (metric) {
      case ChartMetric.count:
        return 'Count';
      case ChartMetric.duration:
        return 'Total Duration';
      case ChartMetric.averageDuration:
        return 'Avg Duration';
      case ChartMetric.moodScore:
        return 'Mood Score';
      case ChartMetric.physicalScore:
        return 'Physical Score';
    }
  }

  String _getRangeLabel() {
    final days = endDate.difference(startDate).inDays + 1;
    return '$days days';
  }
}

/// Chart configuration for building time series
@freezed
class ChartConfig with _$ChartConfig {
  const factory ChartConfig({
    /// Account to fetch data for
    required String accountId,

    /// Time range start
    required DateTime startDate,

    /// Time range end
    required DateTime endDate,

    /// How to aggregate the data
    required ChartAggregation aggregation,

    /// Which metric to display
    required ChartMetric metric,

    /// How to smooth the data
    required ChartSmoothing smoothing,

    /// Moving average window size
    @Default(7) int smoothingWindow,

    /// Filter by specific tags (null = all tags)
    List<String>? visibleTags,
  }) = _ChartConfig;

  const ChartConfig._();

  factory ChartConfig.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigFromJson(json);

  /// Whether this config represents a valid time range
  bool get isValidTimeRange =>
      endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);

  /// Number of days in the time range
  int get dayCount => endDate.difference(startDate).inDays + 1;

  /// Whether smoothing requires a window parameter
  bool get requiresSmoothingWindow => smoothing == ChartSmoothing.movingAverage;
}
