// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class Session with _$Session {
  const factory Session({
    required String id,
    required String accountId, // TODO: FK to Account
    String? deviceId, // TODO: FK to Device
    required String status, // TODO: constrain to enum values
    String? tokenHash,
    DateTime? expiresAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
