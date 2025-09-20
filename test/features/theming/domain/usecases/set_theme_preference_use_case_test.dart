// Unit tests for SetThemePreferenceUseCase
// Tests the theme preference persistence logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/theming/domain/entities/theme_mode.dart';
import 'package:ash_trail/features/theming/domain/repositories/theme_repository.dart';
import 'package:ash_trail/features/theming/domain/usecases/set_theme_preference_use_case.dart';

class MockThemeRepository implements ThemeRepository {
  Either<AppFailure, void>? mockSetResult;
  AppThemeMode? lastSetMode;

  @override
  Future<Either<AppFailure, AppThemeMode>> getThemePreference() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppFailure, void>> setThemePreference(AppThemeMode mode) async {
    lastSetMode = mode;
    return mockSetResult ?? right(null);
  }
}

void main() {
  group('SetThemePreferenceUseCase', () {
    late MockThemeRepository repository;
    late SetThemePreferenceUseCase useCase;

    setUp(() {
      repository = MockThemeRepository();
      useCase = SetThemePreferenceUseCase(repository);
    });

    test('should save theme preference to repository', () async {
      // Arrange
      const modeToSet = AppThemeMode.light;
      repository.mockSetResult = right(null);

      // Act
      final result = await useCase.call(modeToSet);

      // Assert
      expect(result.isRight(), true);
      expect(repository.lastSetMode, modeToSet);
    });

    test('should return failure when repository fails to save', () async {
      // Arrange
      const expectedFailure = AppFailure.cache(message: 'Save failed');
      repository.mockSetResult = left(expectedFailure);

      // Act
      final result = await useCase.call(AppThemeMode.dark);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, expectedFailure),
        (_) => fail('Expected failure but got success'),
      );
    });

    test('should pass correct mode to repository', () async {
      // Arrange
      const modes = [
        AppThemeMode.system,
        AppThemeMode.light,
        AppThemeMode.dark,
      ];

      for (final mode in modes) {
        // Act
        await useCase.call(mode);

        // Assert
        expect(repository.lastSetMode, mode);
      }
    });
  });
}
