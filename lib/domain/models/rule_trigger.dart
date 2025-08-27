// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule_trigger.freezed.dart';
part 'rule_trigger.g.dart';

@freezed
class RuleTrigger with _$RuleTrigger {
  @JsonSerializable(explicitToJson: true)
  const factory RuleTrigger({
    required String id,
    required String ruleId, // TODO: FK to Rule
    required DateTime triggeredAt,
    required Map<String, dynamic> context,
  }) = _RuleTrigger;

  factory RuleTrigger.fromJson(Map<String, dynamic> json) =>
      _$RuleTriggerFromJson(json);
}
