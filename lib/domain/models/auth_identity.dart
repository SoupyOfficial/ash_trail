// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_identity.freezed.dart';
part 'auth_identity.g.dart';

@freezed
class AuthIdentity with _$AuthIdentity {
  @JsonSerializable(explicitToJson: true)
  const factory AuthIdentity({
    required String id,
    required String accountId, // TODO: FK to Account
    required String provider, // TODO: constrain to enum values
    required String providerUid,
    String? email,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AuthIdentity;

  factory AuthIdentity.fromJson(Map<String, dynamic> json) =>
      _$AuthIdentityFromJson(json);
}
