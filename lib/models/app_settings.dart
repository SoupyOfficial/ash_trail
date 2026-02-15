import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// THEME PRESETS
// ============================================================================

/// A named color preset for Material 3 seed-based theming.
class ThemePreset {
  final String name;
  final Color seedColor;

  const ThemePreset({required this.name, required this.seedColor});

  /// The 8 curated color presets available to the user.
  static const List<ThemePreset> presets = [
    ThemePreset(name: 'Royal Blue', seedColor: Color(0xFF4169E1)),
    ThemePreset(name: 'Teal', seedColor: Color(0xFF009688)),
    ThemePreset(name: 'Emerald', seedColor: Color(0xFF10B981)),
    ThemePreset(name: 'Amber', seedColor: Color(0xFFF59E0B)),
    ThemePreset(name: 'Rose', seedColor: Color(0xFFE11D48)),
    ThemePreset(name: 'Purple', seedColor: Color(0xFF7C3AED)),
    ThemePreset(name: 'Slate', seedColor: Color(0xFF64748B)),
    ThemePreset(name: 'Coral', seedColor: Color(0xFFFF6B6B)),
  ];
}

// ============================================================================
// DASHBOARD DENSITY
// ============================================================================

/// Controls spacing/padding density on the home dashboard grid.
enum DashboardDensity {
  compact,
  comfortable,
  spacious;

  /// Multiplier applied to grid cross/main axis spacing.
  double get spacingMultiplier => switch (this) {
    DashboardDensity.compact => 0.5,
    DashboardDensity.comfortable => 1.0,
    DashboardDensity.spacious => 1.5,
  };

  /// Multiplier applied to grid padding.
  double get paddingMultiplier => switch (this) {
    DashboardDensity.compact => 0.75,
    DashboardDensity.comfortable => 1.0,
    DashboardDensity.spacious => 1.25,
  };

  String get label => switch (this) {
    DashboardDensity.compact => 'Compact',
    DashboardDensity.comfortable => 'Comfortable',
    DashboardDensity.spacious => 'Spacious',
  };
}

// ============================================================================
// APP SETTINGS
// ============================================================================

/// Global application settings persisted in SharedPreferences.
///
/// Covers theme preset, appearance mode, dashboard density,
/// card style, and reduce-motion preference.
class AppSettings {
  /// Index into [ThemePreset.presets].
  final int presetIndex;

  /// Light / dark / system.
  final ThemeMode themeMode;

  /// Dashboard grid spacing density.
  final DashboardDensity dashboardDensity;

  /// Card corner radius in dp (range 4–24).
  final double cardCornerRadius;

  /// Card elevation level (range 0–8).
  final double cardElevation;

  /// When true, animations are suppressed (durations → zero).
  final bool reduceMotion;

  const AppSettings({
    this.presetIndex = 0,
    this.themeMode = ThemeMode.system,
    this.dashboardDensity = DashboardDensity.comfortable,
    this.cardCornerRadius = 12,
    this.cardElevation = 2,
    this.reduceMotion = false,
  });

  /// Factory returning default settings.
  factory AppSettings.defaults() => const AppSettings();

  /// The resolved seed color for the current preset index.
  Color get seedColor {
    final index = presetIndex.clamp(0, ThemePreset.presets.length - 1);
    return ThemePreset.presets[index].seedColor;
  }

  /// The resolved preset name.
  String get presetName {
    final index = presetIndex.clamp(0, ThemePreset.presets.length - 1);
    return ThemePreset.presets[index].name;
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'presetIndex': presetIndex,
    'themeMode': themeMode.name, // 'system' | 'light' | 'dark'
    'dashboardDensity': dashboardDensity.name,
    'cardCornerRadius': cardCornerRadius,
    'cardElevation': cardElevation,
    'reduceMotion': reduceMotion,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      presetIndex: json['presetIndex'] as int? ?? 0,
      themeMode: _themeModeFromString(json['themeMode'] as String?),
      dashboardDensity: _densityFromString(json['dashboardDensity'] as String?),
      cardCornerRadius: (json['cardCornerRadius'] as num?)?.toDouble() ?? 12,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? 2,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AppSettings.fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return AppSettings.defaults();
    }
  }

  // ── Copy-with ──────────────────────────────────────────────────────────────

  AppSettings copyWith({
    int? presetIndex,
    ThemeMode? themeMode,
    DashboardDensity? dashboardDensity,
    double? cardCornerRadius,
    double? cardElevation,
    bool? reduceMotion,
  }) {
    return AppSettings(
      presetIndex: presetIndex ?? this.presetIndex,
      themeMode: themeMode ?? this.themeMode,
      dashboardDensity: dashboardDensity ?? this.dashboardDensity,
      cardCornerRadius: cardCornerRadius ?? this.cardCornerRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  // ── Equality ───────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          presetIndex == other.presetIndex &&
          themeMode == other.themeMode &&
          dashboardDensity == other.dashboardDensity &&
          cardCornerRadius == other.cardCornerRadius &&
          cardElevation == other.cardElevation &&
          reduceMotion == other.reduceMotion;

  @override
  int get hashCode => Object.hash(
    presetIndex,
    themeMode,
    dashboardDensity,
    cardCornerRadius,
    cardElevation,
    reduceMotion,
  );

  @override
  String toString() =>
      'AppSettings(preset=$presetName, mode=$themeMode, density=$dashboardDensity, '
      'radius=$cardCornerRadius, elevation=$cardElevation, reduceMotion=$reduceMotion)';

  // ── Private helpers ────────────────────────────────────────────────────────

  static ThemeMode _themeModeFromString(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static DashboardDensity _densityFromString(String? value) => switch (value) {
    'compact' => DashboardDensity.compact,
    'spacious' => DashboardDensity.spacious,
    _ => DashboardDensity.comfortable,
  };
}
