// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  @JsonSerializable(explicitToJson: true)
  const factory Tag({
    required String id,
    required String accountId, // TODO: FK to Account
    required String name,
    String? color,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
