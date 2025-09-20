// Test for GetSiriShortcutsUseCase
// Verifies the use case correctly retrieves shortcuts from the repository.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/repositories/siri_shortcuts_repository.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/get_siri_shortcuts_use_case.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockSiriShortcutsRepository extends Mock
    implements SiriShortcutsRepository {}

void main() {
  late GetSiriShortcutsUseCase useCase;
  late MockSiriShortcutsRepository mockRepository;

  setUp(() {
    mockRepository = MockSiriShortcutsRepository();
    useCase = GetSiriShortcutsUseCase(mockRepository);
  });

  group('GetSiriShortcutsUseCase', () {
    final testShortcuts = [
      SiriShortcutsEntity(
        id: 'test_1',
        type: const SiriShortcutType.addLog(),
        createdAt: DateTime(2023, 1, 1),
        isDonated: true,
        invocationCount: 5,
      ),
      SiriShortcutsEntity(
        id: 'test_2',
        type: const SiriShortcutType.startTimedLog(),
        createdAt: DateTime(2023, 1, 2),
        isDonated: false,
        invocationCount: 0,
      ),
    ];

    test('should return shortcuts from repository when successful', () async {
      // arrange
      when(() => mockRepository.getShortcuts())
          .thenAnswer((_) async => Right(testShortcuts));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(Right(testShortcuts)));
      verify(() => mockRepository.getShortcuts()).called(1);
    });

    test('should return failure when repository fails', () async {
      // arrange
      const failure = AppFailure.cache(message: 'Cache error');
      when(() => mockRepository.getShortcuts())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.getShortcuts()).called(1);
    });

    test('should return empty list when no shortcuts exist', () async {
      // arrange
      when(() => mockRepository.getShortcuts())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase.call();

      // assert
      expect(result, const Right<AppFailure, List<SiriShortcutsEntity>>([]));
      verify(() => mockRepository.getShortcuts()).called(1);
    });
  });
}
