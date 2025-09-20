// Data Transfer Object for theme preference persistence.
// Maps between domain entities and storage representation.

import '../../domain/entities/theme_mode.dart';

class ThemePreferenceDto {
  const ThemePreferenceDto({
    required this.mode,
  });

  final String mode;

  factory ThemePreferenceDto.fromJson(Map<String, dynamic> json) {
    return ThemePreferenceDto(
      mode: json['mode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
    };
  }
}

extension ThemePreferenceDtoMapper on ThemePreferenceDto {
  /// Convert DTO to domain entity
  AppThemeMode toEntity() => AppThemeMode.fromString(mode);
}

extension AppThemeModeMapper on AppThemeMode {
  /// Convert domain entity to DTO
  ThemePreferenceDto toDto() => ThemePreferenceDto(mode: toString());
}
