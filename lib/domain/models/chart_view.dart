// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_view.freezed.dart';
part 'chart_view.g.dart';

@freezed
class ChartView with _$ChartView {
  const factory ChartView({
    required String id,
    required String accountId, // TODO: FK to Account
    required String title,
    required String range, // TODO: constrain to enum values
    DateTime? customStart,
    DateTime? customEnd,
    required String groupBy, // TODO: constrain to enum values
    required String metric, // TODO: constrain to enum values
    required String smoothing, // TODO: constrain to enum values
    int? smoothingWindow,
    List<String>? visibleTags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChartView;

  factory ChartView.fromJson(Map<String, dynamic> json) =>
      _$ChartViewFromJson(json);
}
