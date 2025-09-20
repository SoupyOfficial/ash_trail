// Data model for Siri shortcuts with JSON serialization.
// Maps between domain entities and data transfer objects.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/siri_shortcuts_entity.dart';
import '../../domain/entities/siri_shortcut_type.dart';

part 'siri_shortcuts_model.freezed.dart';
part 'siri_shortcuts_model.g.dart';

@freezed
class SiriShortcutsModel with _$SiriShortcutsModel {
  const SiriShortcutsModel._();

  const factory SiriShortcutsModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_donated_at') DateTime? lastDonatedAt,
    @JsonKey(name: 'invocation_count') @Default(0) int invocationCount,
    @JsonKey(name: 'is_donated') @Default(false) bool isDonated,
    @JsonKey(name: 'custom_phrase') String? customPhrase,
    @JsonKey(name: 'last_invoked_at') DateTime? lastInvokedAt,
  }) = _SiriShortcutsModel;

  factory SiriShortcutsModel.fromJson(Map<String, dynamic> json) =>
      _$SiriShortcutsModelFromJson(json);

  /// Convert from domain entity to data model
  factory SiriShortcutsModel.fromEntity(SiriShortcutsEntity entity) {
    return SiriShortcutsModel(
      id: entity.id,
      type: _typeToString(entity.type),
      createdAt: entity.createdAt,
      lastDonatedAt: entity.lastDonatedAt,
      invocationCount: entity.invocationCount,
      isDonated: entity.isDonated,
      customPhrase: entity.customPhrase,
      lastInvokedAt: entity.lastInvokedAt,
    );
  }

  /// Convert to domain entity
  SiriShortcutsEntity toEntity() {
    return SiriShortcutsEntity(
      id: id,
      type: _stringToType(type),
      createdAt: createdAt,
      lastDonatedAt: lastDonatedAt,
      invocationCount: invocationCount,
      isDonated: isDonated,
      customPhrase: customPhrase,
      lastInvokedAt: lastInvokedAt,
    );
  }

  /// Convert SiriShortcutType to string for serialization
  static String _typeToString(SiriShortcutType type) {
    if (type == const SiriShortcutType.addLog()) {
      return 'add_log';
    } else if (type == const SiriShortcutType.startTimedLog()) {
      return 'start_timed_log';
    } else {
      throw ArgumentError('Unknown shortcut type: $type');
    }
  }

  /// Convert string to SiriShortcutType for deserialization
  static SiriShortcutType stringToType(String type) {
    return switch (type) {
      'add_log' => const SiriShortcutType.addLog(),
      'start_timed_log' => const SiriShortcutType.startTimedLog(),
      _ => throw ArgumentError('Unknown shortcut type: $type'),
    };
  }

  /// Convert string to SiriShortcutType for deserialization (private)
  static SiriShortcutType _stringToType(String type) => stringToType(type);
}