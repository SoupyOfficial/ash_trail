// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter_preset.freezed.dart';
part 'filter_preset.g.dart';

@freezed
class FilterPreset with _$FilterPreset {
  @JsonSerializable(explicitToJson: true)
  const factory FilterPreset({
    required String id,
    required String accountId, // TODO: FK to Account
    required String name,
    required String range, // TODO: constrain to enum values
    DateTime? customStart,
    DateTime? customEnd,
    List<String>? includeTags,
    List<String>? excludeTags,
    required String sort, // TODO: constrain to enum values
    String? query,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FilterPreset;

  factory FilterPreset.fromJson(Map<String, dynamic> json) =>
      _$FilterPresetFromJson(json);
}
