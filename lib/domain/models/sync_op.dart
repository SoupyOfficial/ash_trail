// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_op.freezed.dart';
part 'sync_op.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class SyncOp with _$SyncOp {
  const factory SyncOp({
    required String id,
    required String accountId, // TODO: FK to Account
    required String entity, // TODO: constrain to enum values
    required String op, // TODO: constrain to enum values
    required String recordId,
    required Map<String, dynamic> payload,
    required String status, // TODO: constrain to enum values
    required int attempts,
    String? lastError,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SyncOp;

  factory SyncOp.fromJson(Map<String, dynamic> json) => _$SyncOpFromJson(json);
}
