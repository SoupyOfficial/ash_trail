// Theme mode enumeration for AshTrail theming system.
// Supports system-based, light, and dark theme preferences.

enum AppThemeMode {
  /// Follow system theme preference
  system,

  /// Always use light theme
  light,

  /// Always use dark theme
  dark;

  /// Convert from string representation for persistence
  static AppThemeMode fromString(String value) {
    return switch (value.toLowerCase()) {
      'system' => AppThemeMode.system,
      'light' => AppThemeMode.light,
      'dark' => AppThemeMode.dark,
      _ => AppThemeMode.system, // Default fallback
    };
  }

  /// Convert to string for persistence
  @override
  String toString() => name;
}
