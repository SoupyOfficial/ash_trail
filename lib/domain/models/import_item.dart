// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'import_item.freezed.dart';
part 'import_item.g.dart';

@freezed
class ImportItem with _$ImportItem {
  const factory ImportItem({
    required String id,
    required String batchId, // TODO: FK to ImportBatch
    required String status, // TODO: constrain to enum values
    required Map<String, dynamic> raw,
    String? error,
  }) = _ImportItem;

  factory ImportItem.fromJson(Map<String, dynamic> json) => _$ImportItemFromJson(json);
}
