// Data Transfer Object for ChartDataPoint serialization
// Used for caching chart data points and network transfers

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/chart_data_point.dart';

part 'chart_data_point_dto.freezed.dart';
part 'chart_data_point_dto.g.dart';

/// DTO for ChartDataPoint serialization and caching
/// Optimized for storage and network transfer
@freezed
class ChartDataPointDto with _$ChartDataPointDto {
  const factory ChartDataPointDto({
    required DateTime timestamp,
    required double value,
    required int count,
    required int totalDurationMs,
    double? averageMoodScore,
    double? averagePhysicalScore,
  }) = _ChartDataPointDto;

  factory ChartDataPointDto.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointDtoFromJson(json);
}

/// Extension methods for converting between DTO and domain entity
extension ChartDataPointDtoMapper on ChartDataPointDto {
  /// Convert DTO to domain entity
  ChartDataPoint toEntity() {
    return ChartDataPoint(
      timestamp: timestamp,
      value: value,
      count: count,
      totalDurationMs: totalDurationMs,
      averageMoodScore: averageMoodScore,
      averagePhysicalScore: averagePhysicalScore,
    );
  }
}

extension ChartDataPointEntityMapper on ChartDataPoint {
  /// Convert domain entity to DTO
  /// Used for caching and serialization
  ChartDataPointDto toDto() {
    return ChartDataPointDto(
      timestamp: timestamp,
      value: value,
      count: count,
      totalDurationMs: totalDurationMs,
      averageMoodScore: averageMoodScore,
      averagePhysicalScore: averagePhysicalScore,
    );
  }
}
