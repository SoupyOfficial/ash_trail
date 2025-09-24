// Data Transfer Object for TimeSeriesChart serialization and caching
// Used for caching generated charts and network transfers

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chart_data_point.dart';
import '../../domain/entities/time_series_chart.dart';
import 'chart_data_point_dto.dart';

part 'time_series_chart_dto.freezed.dart';
part 'time_series_chart_dto.g.dart';

/// DTO for TimeSeriesChart serialization and caching
/// Used to persist pre-generated charts to avoid recomputation
@freezed
class TimeSeriesChartDto with _$TimeSeriesChartDto {
  const factory TimeSeriesChartDto({
    required String id,
    required String accountId,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String aggregation,
    required String metric,
    required String smoothing,
    required List<ChartDataPointDto> dataPoints,
    int? smoothingWindow,
    List<String>? visibleTags,
    required DateTime createdAt,
  }) = _TimeSeriesChartDto;

  factory TimeSeriesChartDto.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesChartDtoFromJson(json);
}

/// Extension methods for converting between DTO and domain entity
extension TimeSeriesChartDtoMapper on TimeSeriesChartDto {
  /// Convert DTO to domain entity
  TimeSeriesChart toEntity() {
    return TimeSeriesChart(
      id: id,
      accountId: accountId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      aggregation: ChartAggregation.values.firstWhere(
        (e) => e.name == aggregation,
        orElse: () => ChartAggregation.daily,
      ),
      metric: ChartMetric.values.firstWhere(
        (e) => e.name == metric,
        orElse: () => ChartMetric.count,
      ),
      smoothing: ChartSmoothing.values.firstWhere(
        (e) => e.name == smoothing,
        orElse: () => ChartSmoothing.none,
      ),
      dataPoints: dataPoints.map((dto) => dto.toEntity()).toList(),
      smoothingWindow: smoothingWindow,
      visibleTags: visibleTags,
      createdAt: createdAt,
    );
  }
}

extension TimeSeriesChartEntityMapper on TimeSeriesChart {
  /// Convert domain entity to DTO
  /// Used for caching generated charts
  TimeSeriesChartDto toDto() {
    return TimeSeriesChartDto(
      id: id,
      accountId: accountId,
      title: title,
      startDate: startDate,
      endDate: endDate,
      aggregation: aggregation.name,
      metric: metric.name,
      smoothing: smoothing.name,
      dataPoints: dataPoints.map((point) => point.toDto()).toList(),
      smoothingWindow: smoothingWindow,
      visibleTags: visibleTags,
      createdAt: createdAt,
    );
  }
}
