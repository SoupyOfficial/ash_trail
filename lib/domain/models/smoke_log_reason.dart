// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'smoke_log_reason.freezed.dart';
part 'smoke_log_reason.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class SmokeLogReason with _$SmokeLogReason {
  const factory SmokeLogReason({
    required String id,
    required String smokeLogId, // TODO: FK to SmokeLog
    required String reasonId, // TODO: FK to Reason
    required String accountId, // TODO: FK to Account
    required DateTime ts,
    required DateTime createdAt,
  }) = _SmokeLogReason;

  factory SmokeLogReason.fromJson(Map<String, dynamic> json) => _$SmokeLogReasonFromJson(json);
}
