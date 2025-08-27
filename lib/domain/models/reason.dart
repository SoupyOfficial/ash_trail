// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'reason.freezed.dart';
part 'reason.g.dart';

@freezed
class Reason with _$Reason {
  const factory Reason({
    required String id,
    String? accountId, // TODO: FK to Account
    required String name,
    required bool enabled,
    required int orderIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reason;

  factory Reason.fromJson(Map<String, dynamic> json) => _$ReasonFromJson(json);
}
