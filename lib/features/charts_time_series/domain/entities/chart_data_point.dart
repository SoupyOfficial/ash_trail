import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_data_point.freezed.dart';
part 'chart_data_point.g.dart';

/// Represents a single data point in a time series chart
/// Contains temporal and metric data for visualization
@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    /// Timestamp for this data point
    required DateTime timestamp,
    /// Primary metric value (e.g., count, duration, average)
    required double value,
    /// Raw count of items in this time bucket
    required int count,
    /// Sum of durations in milliseconds
    required int totalDurationMs,
    /// Average mood score for this time period (0-10 scale)
    double? averageMoodScore,
    /// Average physical score for this time period (0-10 scale) 
    double? averagePhysicalScore,
  }) = _ChartDataPoint;

  const ChartDataPoint._();

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) => 
      _$ChartDataPointFromJson(json);

  /// Whether this data point has valid data
  bool get hasData => count > 0;

  /// Whether mood/physical data is available
  bool get hasScoreData => 
      averageMoodScore != null && averagePhysicalScore != null;

  /// Average duration in milliseconds, 0 if no data
  double get averageDurationMs => count > 0 ? totalDurationMs / count : 0;

  /// Format timestamp for display based on aggregation level
  String formatTimestamp(ChartAggregation aggregation) {
    switch (aggregation) {
      case ChartAggregation.daily:
        return '${timestamp.month}/${timestamp.day}';
      case ChartAggregation.weekly:
        return 'Week of ${timestamp.month}/${timestamp.day}';
      case ChartAggregation.monthly:
        return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}';
    }
  }
}

/// Chart aggregation levels supported by the time series
enum ChartAggregation {
  daily,
  weekly, 
  monthly,
}

/// Chart metric types that can be displayed
enum ChartMetric {
  count,          // Number of logs
  duration,       // Total duration
  averageDuration, // Average duration
  moodScore,      // Average mood score
  physicalScore,  // Average physical score
}

/// Chart smoothing options for data presentation
enum ChartSmoothing {
  none,           // Raw data points
  movingAverage,  // Moving average smoothing
  cumulative,     // Cumulative values
}