// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'smoke_log.freezed.dart';
part 'smoke_log.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class SmokeLog with _$SmokeLog {
  const factory SmokeLog({
    required String id,
    required String accountId, // TODO: FK to Account
    required DateTime ts,
    required int durationMs,
    String? methodId, // TODO: FK to Method
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
    String? deviceLocalId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SmokeLog;

  factory SmokeLog.fromJson(Map<String, dynamic> json) =>
      _$SmokeLogFromJson(json);
}
