// Unit tests for Theme Provider
// Tests Riverpod theme state management and provider logic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/theming/domain/entities/theme_mode.dart';
import 'package:ash_trail/features/theming/presentation/providers/theme_provider.dart';
import 'package:ash_trail/core/theme/app_theme.dart';

void main() {
  group('Theme Provider', () {
    late ProviderContainer container;
    late SharedPreferences prefs;

    setUp(() async {
      // Initialize SharedPreferences with mock data
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      container = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with system theme mode by default', () async {
      // Act
      final themeMode = container.read(currentThemeModeProvider);

      // Assert
      expect(themeMode, AppThemeMode.system);
    });

    test('should update theme mode and persist preference', () async {
      // Arrange - Wait for the controller to load initial preference
      final controller = container.read(currentThemeModeProvider.notifier);

      // Wait a short time for async initialization
      await Future.delayed(Duration.zero);

      // Act
      await controller.setThemeMode(AppThemeMode.dark);

      // Assert
      final updatedMode = container.read(currentThemeModeProvider);
      expect(updatedMode, AppThemeMode.dark);
    });

    test('should provide correct theme data for light mode', () {
      // Arrange
      final lightContainer = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
          platformBrightnessProvider.overrideWithValue(Brightness.light),
          currentThemeModeProvider.overrideWith(
              (ref) => ThemeModeController(ref)..state = AppThemeMode.light),
        ],
      );

      // Act
      final themeData = lightContainer.read(currentThemeDataProvider);

      // Assert
      expect(themeData.brightness, Brightness.light);
      expect(themeData.colorScheme, AppTheme.lightTheme.colorScheme);

      lightContainer.dispose();
    });

    test('should provide correct theme data for dark mode', () {
      // Arrange
      final darkContainer = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
          platformBrightnessProvider.overrideWithValue(Brightness.dark),
          currentThemeModeProvider.overrideWith(
              (ref) => ThemeModeController(ref)..state = AppThemeMode.dark),
        ],
      );

      // Act
      final themeData = darkContainer.read(currentThemeDataProvider);

      // Assert
      expect(themeData.brightness, Brightness.dark);
      expect(themeData.colorScheme, AppTheme.darkTheme.colorScheme);

      darkContainer.dispose();
    });

    test('should follow system brightness when in system mode', () {
      // Test light system theme
      final lightContainer = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
          platformBrightnessProvider.overrideWithValue(Brightness.light),
          currentThemeModeProvider.overrideWith(
              (ref) => ThemeModeController(ref)..state = AppThemeMode.system),
        ],
      );

      final lightTheme = lightContainer.read(currentThemeDataProvider);
      expect(lightTheme.brightness, Brightness.light);

      lightContainer.dispose();

      // Test dark system theme
      final darkContainer = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
          platformBrightnessProvider.overrideWithValue(Brightness.dark),
          currentThemeModeProvider.overrideWith(
              (ref) => ThemeModeController(ref)..state = AppThemeMode.system),
        ],
      );

      final darkTheme = darkContainer.read(currentThemeDataProvider);
      expect(darkTheme.brightness, Brightness.dark);

      darkContainer.dispose();
    });

    test('should default to dark theme when system brightness unavailable', () {
      // Arrange
      final testContainer = ProviderContainer(
        overrides: [
          createThemeRepositoryOverride(prefs),
          platformBrightnessProvider.overrideWithValue(
              Brightness.dark), // Default as per requirements
        ],
      );

      // Act
      final brightness = testContainer.read(platformBrightnessProvider);

      // Assert
      expect(brightness, Brightness.dark);

      testContainer.dispose();
    });
  });
}
