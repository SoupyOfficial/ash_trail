// Test for DonateShortcutsUseCase
// Verifies the use case correctly handles shortcut donation logic.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/repositories/siri_shortcuts_repository.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/donate_shortcuts_use_case.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockSiriShortcutsRepository extends Mock
    implements SiriShortcutsRepository {}

void main() {
  late DonateShortcutsUseCase useCase;
  late MockSiriShortcutsRepository mockRepository;

  setUp(() {
    mockRepository = MockSiriShortcutsRepository();
    useCase = DonateShortcutsUseCase(mockRepository);
  });

  group('DonateShortcutsUseCase', () {
    test('should return validation error when Siri shortcuts not supported',
        () async {
      // arrange
      when(() => mockRepository.isSiriShortcutsSupported())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase.call();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.displayMessage, contains('not supported'));
        },
        (_) => fail('Expected failure'),
      );
      verify(() => mockRepository.isSiriShortcutsSupported()).called(1);
    });

    test('should return failure when checking support fails', () async {
      // arrange
      const failure = AppFailure.network(message: 'Network error');
      when(() => mockRepository.isSiriShortcutsSupported())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.isSiriShortcutsSupported()).called(1);
    });

    test('should donate shortcuts when supported and shortcuts need donation',
        () async {
      // arrange
      final shortcutsNeedingDonation = [
        SiriShortcutsEntity(
          id: 'test_1',
          type: const SiriShortcutType.addLog(),
          createdAt: DateTime(2023, 1, 1),
          isDonated: false,
        ),
      ];

      when(() => mockRepository.isSiriShortcutsSupported())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.getShortcutsNeedingDonation())
          .thenAnswer((_) async => Right(shortcutsNeedingDonation));
      when(() => mockRepository.donateShortcuts(shortcutsNeedingDonation))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.isSiriShortcutsSupported()).called(1);
      verify(() => mockRepository.getShortcutsNeedingDonation()).called(1);
      verify(() => mockRepository.donateShortcuts(shortcutsNeedingDonation))
          .called(1);
    });

    test('should succeed when no shortcuts need donation', () async {
      // arrange
      when(() => mockRepository.isSiriShortcutsSupported())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.getShortcutsNeedingDonation())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.isSiriShortcutsSupported()).called(1);
      verify(() => mockRepository.getShortcutsNeedingDonation()).called(1);
      verifyNever(() => mockRepository.donateShortcuts(any()));
    });

    test('should return failure when donation fails', () async {
      // arrange
      final shortcutsNeedingDonation = [
        SiriShortcutsEntity(
          id: 'test_1',
          type: const SiriShortcutType.addLog(),
          createdAt: DateTime(2023, 1, 1),
          isDonated: false,
        ),
      ];
      const failure = AppFailure.network(message: 'Donation failed');

      when(() => mockRepository.isSiriShortcutsSupported())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.getShortcutsNeedingDonation())
          .thenAnswer((_) async => Right(shortcutsNeedingDonation));
      when(() => mockRepository.donateShortcuts(shortcutsNeedingDonation))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase.call();

      // assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.donateShortcuts(shortcutsNeedingDonation))
          .called(1);
    });
  });
}
