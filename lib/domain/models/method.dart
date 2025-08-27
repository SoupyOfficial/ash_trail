// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'method.freezed.dart';
part 'method.g.dart';

@freezed
class Method with _$Method {
  const factory Method({
    required String id,
    String? accountId, // TODO: FK to Account
    required String name,
    required String category, // TODO: constrain to enum values
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Method;

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);
}
