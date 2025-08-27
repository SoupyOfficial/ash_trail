// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_daily.freezed.dart';
part 'stats_daily.g.dart';

@freezed
class StatsDaily with _$StatsDaily {
  @JsonSerializable(explicitToJson: true)
  const factory StatsDaily({
    required String id,
    required String accountId, // TODO: FK to Account
    required DateTime date,
    required int hitCount,
    required int totalDurationMs,
    required int avgDurationMs,
  }) = _StatsDaily;

  factory StatsDaily.fromJson(Map<String, dynamic> json) =>
      _$StatsDailyFromJson(json);
}
