// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'prefs.freezed.dart';
part 'prefs.g.dart';

@freezed
class Prefs with _$Prefs {
  const factory Prefs({
    required String accountId, // TODO: FK to Account
    required String defaultRange, // TODO: constrain to enum values
    required String unit, // TODO: constrain to enum values
    required bool analyticsOptIn,
    List<DateTime>? reminderTimes,
    required String preferredTheme, // TODO: constrain to enum values
    String? accentColor,
  }) = _Prefs;

  factory Prefs.fromJson(Map<String, dynamic> json) => _$PrefsFromJson(json);
}
