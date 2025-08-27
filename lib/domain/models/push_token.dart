// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_token.freezed.dart';
part 'push_token.g.dart';

@freezed
class PushToken with _$PushToken {
  const factory PushToken({
    required String id,
    required String deviceId, // TODO: FK to Device
    required String platform, // TODO: constrain to enum values
    required String token,
    required bool active,
    required DateTime createdAt,
    DateTime? revokedAt,
  }) = _PushToken;

  factory PushToken.fromJson(Map<String, dynamic> json) => _$PushTokenFromJson(json);
}
