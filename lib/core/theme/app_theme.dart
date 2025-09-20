// Centralized theme definitions for AshTrail application.
// Provides Material 3 color schemes and semantic color tokens.

import 'package:flutter/material.dart';

class AppTheme {
  static const Color primarySeedColor =
      Color(0xFF6750A4); // Material 3 primary purple

  // Light theme color scheme
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  );

  // Dark theme color scheme
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.dark,
  );

  // High contrast light theme (placeholder for accessibility)
  static final ColorScheme highContrastLightColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  ).copyWith(
    // Increase contrast ratios for accessibility
    onSurface: const Color(0xFF000000),
    onPrimary: const Color(0xFFFFFFFF),
  );

  // High contrast dark theme (placeholder for accessibility)
  static final ColorScheme highContrastDarkColorScheme = ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.dark,
  ).copyWith(
    // Increase contrast ratios for accessibility
    onSurface: const Color(0xFFFFFFFF),
    onPrimary: const Color(0xFF000000),
  );

  // Typography supporting Dynamic Type up to 200% scaling
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // Light theme data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: lightColorScheme.surface,
          foregroundColor: lightColorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: lightColorScheme.surface,
          indicatorColor: lightColorScheme.secondaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelMedium?.copyWith(
                color: lightColorScheme.onSecondaryContainer,
              );
            }
            return textTheme.labelMedium?.copyWith(
              color: lightColorScheme.onSurfaceVariant,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: lightColorScheme.surface,
          indicatorColor: lightColorScheme.secondaryContainer,
          selectedIconTheme: IconThemeData(
            color: lightColorScheme.onSecondaryContainer,
          ),
          unselectedIconTheme: IconThemeData(
            color: lightColorScheme.onSurfaceVariant,
          ),
          selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
            color: lightColorScheme.onSecondaryContainer,
          ),
          unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
            color: lightColorScheme.onSurfaceVariant,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: lightColorScheme.primaryContainer,
          foregroundColor: lightColorScheme.onPrimaryContainer,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
          ),
        ),
      );

  // Dark theme data
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.surface,
          foregroundColor: darkColorScheme.onSurface,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkColorScheme.surface,
          indicatorColor: darkColorScheme.secondaryContainer,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelMedium?.copyWith(
                color: darkColorScheme.onSecondaryContainer,
              );
            }
            return textTheme.labelMedium?.copyWith(
              color: darkColorScheme.onSurfaceVariant,
            );
          }),
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: darkColorScheme.surface,
          indicatorColor: darkColorScheme.secondaryContainer,
          selectedIconTheme: IconThemeData(
            color: darkColorScheme.onSecondaryContainer,
          ),
          unselectedIconTheme: IconThemeData(
            color: darkColorScheme.onSurfaceVariant,
          ),
          selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
            color: darkColorScheme.onSecondaryContainer,
          ),
          unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
            color: darkColorScheme.onSurfaceVariant,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: darkColorScheme.primaryContainer,
          foregroundColor: darkColorScheme.onPrimaryContainer,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColorScheme.primary,
            foregroundColor: darkColorScheme.onPrimary,
          ),
        ),
      );

  // High contrast light theme (placeholder)
  static ThemeData get highContrastLightTheme => lightTheme.copyWith(
        colorScheme: highContrastLightColorScheme,
      );

  // High contrast dark theme (placeholder)
  static ThemeData get highContrastDarkTheme => darkTheme.copyWith(
        colorScheme: highContrastDarkColorScheme,
      );
}
