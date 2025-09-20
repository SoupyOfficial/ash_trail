// Unit tests for ThemeRepositoryImpl
// Tests SharedPreferences-based theme persistence implementation.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/theming/domain/entities/theme_mode.dart';
import 'package:ash_trail/features/theming/data/repositories/theme_repository_impl.dart';

void main() {
  group('ThemeRepositoryImpl', () {
    late ThemeRepositoryImpl repository;

    setUp(() async {
      // Initialize SharedPreferences with in-memory implementation for testing
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepositoryImpl(prefs);
    });

    test('should return system theme when no preference stored', () async {
      // Act
      final result = await repository.getThemePreference();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, AppThemeMode.system),
      );
    });

    test('should save and retrieve theme preference', () async {
      // Arrange
      const modeToSave = AppThemeMode.dark;

      // Act - Save
      final saveResult = await repository.setThemePreference(modeToSave);

      // Assert - Save succeeded
      expect(saveResult.isRight(), true);

      // Act - Retrieve
      final getResult = await repository.getThemePreference();

      // Assert - Retrieved correctly
      expect(getResult.isRight(), true);
      getResult.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, modeToSave),
      );
    });

    test('should handle all theme modes correctly', () async {
      const modes = [
        AppThemeMode.system,
        AppThemeMode.light,
        AppThemeMode.dark,
      ];

      for (final mode in modes) {
        // Act - Save
        final saveResult = await repository.setThemePreference(mode);
        expect(saveResult.isRight(), true);

        // Act - Retrieve
        final getResult = await repository.getThemePreference();

        // Assert
        expect(getResult.isRight(), true);
        getResult.fold(
          (failure) =>
              fail('Expected success for $mode but got failure: $failure'),
          (retrievedMode) => expect(retrievedMode, mode),
        );
      }
    });

    test('should parse invalid stored values as system theme', () async {
      // Arrange - Set invalid value directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preference', 'invalid_mode');

      // Act
      final result = await repository.getThemePreference();

      // Assert - Should fallback to system
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, AppThemeMode.system),
      );
    });

    test('should persist theme preference across repository instances',
        () async {
      // Arrange
      const modeToSave = AppThemeMode.light;

      // Act - Save with first instance
      await repository.setThemePreference(modeToSave);

      // Create new repository instance
      final prefs = await SharedPreferences.getInstance();
      final newRepository = ThemeRepositoryImpl(prefs);

      // Act - Retrieve with new instance
      final result = await newRepository.getThemePreference();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, modeToSave),
      );
    });
  });
}
