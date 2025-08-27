// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'smoke_log_tag.freezed.dart';
part 'smoke_log_tag.g.dart';

@freezed
class SmokeLogTag with _$SmokeLogTag {
  const factory SmokeLogTag({
    required String id,
    required String smokeLogId, // TODO: FK to SmokeLog
    required String tagId, // TODO: FK to Tag
    required String accountId, // TODO: FK to Account
    required DateTime ts,
    required DateTime createdAt,
  }) = _SmokeLogTag;

  factory SmokeLogTag.fromJson(Map<String, dynamic> json) =>
      _$SmokeLogTagFromJson(json);
}
