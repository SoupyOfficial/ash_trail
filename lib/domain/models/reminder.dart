// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String accountId, // TODO: FK to Account
    required DateTime time,
    required List<String> days, // TODO: constrain to enum values
    required bool enabled,
    DateTime? lastTriggeredAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
