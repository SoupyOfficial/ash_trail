// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'db_meta.freezed.dart';
part 'db_meta.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class DbMeta with _$DbMeta {
  const factory DbMeta({
    required String id,
    required int schemaVersion,
    required DateTime migratedAt,
  }) = _DbMeta;

  factory DbMeta.fromJson(Map<String, dynamic> json) => _$DbMetaFromJson(json);
}
