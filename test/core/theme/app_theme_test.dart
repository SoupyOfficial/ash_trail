import 'package:ash_trail/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    group('color schemes', () {
      test('should have consistent primary seed color', () {
        expect(AppTheme.primarySeedColor, equals(const Color(0xFF6750A4)));
      });

      test('should create light color scheme', () {
        final colorScheme = AppTheme.lightColorScheme;
        expect(colorScheme.brightness, equals(Brightness.light));
      });

      test('should create dark color scheme', () {
        final colorScheme = AppTheme.darkColorScheme;
        expect(colorScheme.brightness, equals(Brightness.dark));
      });

      test('should create high contrast light color scheme', () {
        final colorScheme = AppTheme.highContrastLightColorScheme;
        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.onSurface, equals(const Color(0xFF000000)));
        expect(colorScheme.onPrimary, equals(const Color(0xFFFFFFFF)));
      });

      test('should create high contrast dark color scheme', () {
        final colorScheme = AppTheme.highContrastDarkColorScheme;
        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.onSurface, equals(const Color(0xFFFFFFFF)));
        expect(colorScheme.onPrimary, equals(const Color(0xFF000000)));
      });
    });

    group('text theme', () {
      test('should have consistent text styles', () {
        const textTheme = AppTheme.textTheme;

        expect(textTheme.displayLarge?.fontSize, equals(57));
        expect(textTheme.displayMedium?.fontSize, equals(45));
        expect(textTheme.displaySmall?.fontSize, equals(36));
        expect(textTheme.headlineLarge?.fontSize, equals(32));
        expect(textTheme.bodyLarge?.fontSize, equals(16));
        expect(textTheme.bodyMedium?.fontSize, equals(14));
        expect(textTheme.bodySmall?.fontSize, equals(12));
      });
    });

    group('theme data', () {
      test('should create light theme with Material 3', () {
        final theme = AppTheme.lightTheme;
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, equals(Brightness.light));
        // Check specific text theme properties instead of full equality
        expect(theme.textTheme.displayLarge?.fontSize, equals(57));
        expect(theme.textTheme.bodyLarge?.fontSize, equals(16));
      });

      test('should create dark theme with Material 3', () {
        final theme = AppTheme.darkTheme;
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, equals(Brightness.dark));
        // Check specific text theme properties instead of full equality
        expect(theme.textTheme.displayLarge?.fontSize, equals(57));
        expect(theme.textTheme.bodyLarge?.fontSize, equals(16));
      });

      test('should create high contrast light theme', () {
        final theme = AppTheme.highContrastLightTheme;
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, equals(Brightness.light));
        expect(theme.colorScheme.onSurface, equals(const Color(0xFF000000)));
      });

      test('should create high contrast dark theme', () {
        final theme = AppTheme.highContrastDarkTheme;
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, equals(Brightness.dark));
        expect(theme.colorScheme.onSurface, equals(const Color(0xFFFFFFFF)));
      });
    });

    group('component themes', () {
      test('light theme should have proper component styling', () {
        final theme = AppTheme.lightTheme;

        expect(theme.appBarTheme.elevation, equals(0));
        expect(theme.appBarTheme.scrolledUnderElevation, equals(1));
        expect(theme.navigationBarTheme.backgroundColor,
            equals(AppTheme.lightColorScheme.surface));
        expect(theme.navigationRailTheme.backgroundColor,
            equals(AppTheme.lightColorScheme.surface));
      });

      test('dark theme should have proper component styling', () {
        final theme = AppTheme.darkTheme;

        expect(theme.appBarTheme.elevation, equals(0));
        expect(theme.appBarTheme.scrolledUnderElevation, equals(1));
        expect(theme.navigationBarTheme.backgroundColor,
            equals(AppTheme.darkColorScheme.surface));
        expect(theme.navigationRailTheme.backgroundColor,
            equals(AppTheme.darkColorScheme.surface));
      });
    });
  });
}
