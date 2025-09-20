// Application theme data containing Material 3 color schemes and typography.
// Provides semantic color tokens for light, dark, and high-contrast modes.

import 'package:flutter/material.dart';

class AppThemeData {
  const AppThemeData({
    required this.lightColorScheme,
    required this.darkColorScheme,
    required this.highContrastLightColorScheme,
    required this.highContrastDarkColorScheme,
    required this.textTheme,
  });

  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ColorScheme highContrastLightColorScheme;
  final ColorScheme highContrastDarkColorScheme;
  final TextTheme textTheme;
}
