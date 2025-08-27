// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class Account with _$Account {
  const factory Account({
    required String id,
    required String displayName,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    required String provider, // TODO: constrain to enum values
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
}
