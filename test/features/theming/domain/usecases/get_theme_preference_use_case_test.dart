// Unit tests for GetThemePreferenceUseCase
// Tests the theme preference retrieval logic with various scenarios.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/theming/domain/entities/theme_mode.dart';
import 'package:ash_trail/features/theming/domain/repositories/theme_repository.dart';
import 'package:ash_trail/features/theming/domain/usecases/get_theme_preference_use_case.dart';

class MockThemeRepository implements ThemeRepository {
  Either<AppFailure, AppThemeMode>? mockResult;

  @override
  Future<Either<AppFailure, AppThemeMode>> getThemePreference() async {
    return mockResult ?? right(AppThemeMode.system);
  }

  @override
  Future<Either<AppFailure, void>> setThemePreference(AppThemeMode mode) async {
    throw UnimplementedError();
  }
}

void main() {
  group('GetThemePreferenceUseCase', () {
    late MockThemeRepository repository;
    late GetThemePreferenceUseCase useCase;

    setUp(() {
      repository = MockThemeRepository();
      useCase = GetThemePreferenceUseCase(repository);
    });

    test('should return theme preference from repository', () async {
      // Arrange
      const expectedMode = AppThemeMode.dark;
      repository.mockResult = right(expectedMode);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, expectedMode),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const expectedFailure = AppFailure.cache(message: 'Cache error');
      repository.mockResult = left(expectedFailure);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, expectedFailure),
        (mode) => fail('Expected failure but got success: $mode'),
      );
    });

    test('should default to system theme when no preference stored', () async {
      // Arrange
      repository.mockResult = right(AppThemeMode.system);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (mode) => expect(mode, AppThemeMode.system),
      );
    });
  });
}
