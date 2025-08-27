// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String accountId, // TODO: FK to Account
    required String type, // TODO: constrain to enum values
    required int target,
    required String window, // TODO: constrain to enum values
    required DateTime startDate,
    DateTime? endDate,
    required bool active,
    int? progress,
    DateTime? achievedAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
