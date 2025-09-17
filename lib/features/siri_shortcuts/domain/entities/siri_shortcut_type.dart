// Siri Shortcut Type enumeration for different shortcut actions.
// Defines the types of shortcuts available for donation and handling.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'siri_shortcut_type.freezed.dart';

@freezed
sealed class SiriShortcutType with _$SiriShortcutType {
  const SiriShortcutType._();

  /// Add a new log entry with default method (immediate save)
  const factory SiriShortcutType.addLog() = _AddLog;

  /// Start a timed log session
  const factory SiriShortcutType.startTimedLog() = _StartTimedLog;

  /// Get the display name for the shortcut type
  String get displayName => switch (this) {
        _AddLog() => 'Add Log',
        _StartTimedLog() => 'Start Timed Log',
      };

  /// Get the intent identifier for the shortcut type
  String get intentIdentifier => switch (this) {
        _AddLog() => 'AddLogIntent',
        _StartTimedLog() => 'StartTimedLogIntent',
      };

  /// Get the suggested invocation phrase for the shortcut
  String get suggestedPhrase => switch (this) {
        _AddLog() => 'Record my smoke',
        _StartTimedLog() => 'Start timing my smoke',
      };
}