// Domain entity for smoke log filtering criteria
// Defines filter options for the logs table view

import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_filter.freezed.dart';

@freezed
class LogFilter with _$LogFilter {
  const factory LogFilter({
    // Date range filtering
    DateTime? startDate,
    DateTime? endDate,
    
    // Method filtering
    List<String>? methodIds,
    
    // Tag filtering (using SmokeLogTag relationships)
    List<String>? includeTagIds,
    List<String>? excludeTagIds,
    
    // Mood score filtering (1-10)
    int? minMoodScore,
    int? maxMoodScore,
    
    // Physical score filtering (1-10)
    int? minPhysicalScore,
    int? maxPhysicalScore,
    
    // Duration filtering (in milliseconds)
    int? minDurationMs,
    int? maxDurationMs,
    
    // Text search in notes
    String? searchText,
  }) = _LogFilter;

  const LogFilter._();

  /// Returns true if any filter criteria are set
  bool get hasFilters =>
      startDate != null ||
      endDate != null ||
      (methodIds?.isNotEmpty ?? false) ||
      (includeTagIds?.isNotEmpty ?? false) ||
      (excludeTagIds?.isNotEmpty ?? false) ||
      minMoodScore != null ||
      maxMoodScore != null ||
      minPhysicalScore != null ||
      maxPhysicalScore != null ||
      minDurationMs != null ||
      maxDurationMs != null ||
      (searchText?.isNotEmpty ?? false);

  /// Returns a copy with all filters cleared
  LogFilter get cleared => const LogFilter();
}