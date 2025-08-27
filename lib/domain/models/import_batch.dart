// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_batch.freezed.dart';
part 'import_batch.g.dart';

@freezed
class ImportBatch with _$ImportBatch {
  const factory ImportBatch({
    required String id,
    required String accountId, // TODO: FK to Account
    required String source, // TODO: constrain to enum values
    String? fileName,
    required int countInserted,
    required int countFailed,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? log,
  }) = _ImportBatch;

  factory ImportBatch.fromJson(Map<String, dynamic> json) => _$ImportBatchFromJson(json);
}
