// Domain entity for smoke log sorting criteria
// Defines sort options for the logs table view

import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_sort.freezed.dart';

@freezed
class LogSort with _$LogSort {
  const factory LogSort({
    @Default(LogSortField.timestamp) LogSortField field,
    @Default(LogSortOrder.descending) LogSortOrder order,
  }) = _LogSort;

  const LogSort._();

  /// Create default sort (newest first)
  static const LogSort defaultSort = LogSort();

  /// Create sort by date ascending (oldest first)
  static const LogSort dateAscending = LogSort(
    field: LogSortField.timestamp,
    order: LogSortOrder.ascending,
  );

  /// Create sort by duration descending (longest first)
  static const LogSort durationDescending = LogSort(
    field: LogSortField.duration,
    order: LogSortOrder.descending,
  );

  /// Create sort by duration ascending (shortest first)
  static const LogSort durationAscending = LogSort(
    field: LogSortField.duration,
    order: LogSortOrder.ascending,
  );
}

/// Available fields for sorting smoke logs
enum LogSortField {
  timestamp,
  duration,
  moodScore,
  physicalScore,
  createdAt,
  updatedAt,
}

/// Sort order direction
enum LogSortOrder {
  ascending,
  descending,
}

/// Extensions for better string representation
extension LogSortFieldExtension on LogSortField {
  String get displayName => switch (this) {
    LogSortField.timestamp => 'Date',
    LogSortField.duration => 'Duration',
    LogSortField.moodScore => 'Mood',
    LogSortField.physicalScore => 'Physical',
    LogSortField.createdAt => 'Created',
    LogSortField.updatedAt => 'Updated',
  };
}

extension LogSortOrderExtension on LogSortOrder {
  String get displayName => switch (this) {
    LogSortOrder.ascending => 'Ascending',
    LogSortOrder.descending => 'Descending',
  };

  bool get isAscending => this == LogSortOrder.ascending;
  bool get isDescending => this == LogSortOrder.descending;
}