// Data Transfer Objects for logs table filtering and sorting
// Maps domain entities to storage and network representations

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';

part 'logs_table_dto.freezed.dart';
part 'logs_table_dto.g.dart';

/// DTO for LogFilter serialization and storage operations
/// Used for filter preset persistence and remote sync
@freezed
class LogFilterDto with _$LogFilterDto {
  const factory LogFilterDto({
    DateTime? startDate,
    DateTime? endDate,
    List<String>? methodIds,
    List<String>? includeTagIds,
    List<String>? excludeTagIds,
    int? minMoodScore,
    int? maxMoodScore,
    int? minPhysicalScore,
    int? maxPhysicalScore,
    int? minDurationMs,
    int? maxDurationMs,
    String? searchText,
  }) = _LogFilterDto;

  factory LogFilterDto.fromJson(Map<String, dynamic> json) =>
      _$LogFilterDtoFromJson(json);
}

/// DTO for LogSort serialization and storage operations
/// Used for sort preference persistence
@freezed
class LogSortDto with _$LogSortDto {
  const factory LogSortDto({
    required String field, // Serialized enum value
    required String order, // Serialized enum value
  }) = _LogSortDto;

  factory LogSortDto.fromJson(Map<String, dynamic> json) =>
      _$LogSortDtoFromJson(json);
}

/// Extension methods for converting between DTOs and domain entities
extension LogFilterDtoMapper on LogFilterDto {
  /// Convert DTO to domain entity
  LogFilter toEntity() {
    return LogFilter(
      startDate: startDate,
      endDate: endDate,
      methodIds: methodIds,
      includeTagIds: includeTagIds,
      excludeTagIds: excludeTagIds,
      minMoodScore: minMoodScore,
      maxMoodScore: maxMoodScore,
      minPhysicalScore: minPhysicalScore,
      maxPhysicalScore: maxPhysicalScore,
      minDurationMs: minDurationMs,
      maxDurationMs: maxDurationMs,
      searchText: searchText,
    );
  }
}

extension LogFilterEntityMapper on LogFilter {
  /// Convert domain entity to DTO
  LogFilterDto toDto() {
    return LogFilterDto(
      startDate: startDate,
      endDate: endDate,
      methodIds: methodIds,
      includeTagIds: includeTagIds,
      excludeTagIds: excludeTagIds,
      minMoodScore: minMoodScore,
      maxMoodScore: maxMoodScore,
      minPhysicalScore: minPhysicalScore,
      maxPhysicalScore: maxPhysicalScore,
      minDurationMs: minDurationMs,
      maxDurationMs: maxDurationMs,
      searchText: searchText,
    );
  }
}

extension LogSortDtoMapper on LogSortDto {
  /// Convert DTO to domain entity
  LogSort toEntity() {
    final fieldEnum = LogSortField.values.firstWhere(
      (e) => e.name == field,
      orElse: () => LogSortField.timestamp,
    );
    
    final orderEnum = LogSortOrder.values.firstWhere(
      (e) => e.name == order,
      orElse: () => LogSortOrder.descending,
    );

    return LogSort(
      field: fieldEnum,
      order: orderEnum,
    );
  }
}

extension LogSortEntityMapper on LogSort {
  /// Convert domain entity to DTO
  LogSortDto toDto() {
    return LogSortDto(
      field: field.name,
      order: order.name,
    );
  }
}