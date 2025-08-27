// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'rule.freezed.dart';
part 'rule.g.dart';

@freezed
class Rule with _$Rule {
  @JsonSerializable(explicitToJson: true)
  const factory Rule({
    required String id,
    required String accountId, // TODO: FK to Account
    required String name,
    required Map<String, dynamic> condition,
    required String action, // TODO: constrain to enum values
    required bool enabled,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Rule;

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);
}
