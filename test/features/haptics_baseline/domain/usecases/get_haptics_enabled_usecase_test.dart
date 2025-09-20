// Unit tests for GetHapticsEnabledUseCase

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/haptics_baseline/domain/repositories/haptics_repository.dart';
import 'package:ash_trail/features/haptics_baseline/domain/usecases/get_haptics_enabled_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHapticsRepository extends Mock implements HapticsRepository {}

void main() {
  group('GetHapticsEnabledUseCase', () {
    late GetHapticsEnabledUseCase useCase;
    late MockHapticsRepository mockRepository;

    setUp(() {
      mockRepository = MockHapticsRepository();
      useCase = GetHapticsEnabledUseCase(mockRepository);
    });

    test('should return false when user preference is disabled', () async {
      // arrange
      when(() => mockRepository.getHapticsEnabled())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase();

      // assert
      expect(result, equals(const Right<AppFailure, bool>(false)));
      verify(() => mockRepository.getHapticsEnabled()).called(1);
      verifyNever(() => mockRepository.isHapticsSupported());
      verifyNever(() => mockRepository.isReduceMotionEnabled());
    });

    test('should return false when system haptics is not supported', () async {
      // arrange
      when(() => mockRepository.getHapticsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.isHapticsSupported())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase();

      // assert
      expect(result, equals(const Right<AppFailure, bool>(false)));
      verify(() => mockRepository.getHapticsEnabled()).called(1);
      verify(() => mockRepository.isHapticsSupported()).called(1);
      verifyNever(() => mockRepository.isReduceMotionEnabled());
    });

    test('should return false when reduce motion is enabled', () async {
      // arrange
      when(() => mockRepository.getHapticsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.isHapticsSupported())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.isReduceMotionEnabled())
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await useCase();

      // assert
      expect(result, equals(const Right<AppFailure, bool>(false)));
      verify(() => mockRepository.getHapticsEnabled()).called(1);
      verify(() => mockRepository.isHapticsSupported()).called(1);
      verify(() => mockRepository.isReduceMotionEnabled()).called(1);
    });

    test('should return true when all conditions are met', () async {
      // arrange
      when(() => mockRepository.getHapticsEnabled())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.isHapticsSupported())
          .thenAnswer((_) async => const Right(true));
      when(() => mockRepository.isReduceMotionEnabled())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await useCase();

      // assert
      expect(result, equals(const Right<AppFailure, bool>(true)));
      verify(() => mockRepository.getHapticsEnabled()).called(1);
      verify(() => mockRepository.isHapticsSupported()).called(1);
      verify(() => mockRepository.isReduceMotionEnabled()).called(1);
    });

    test('should use default values when repository methods fail', () async {
      // arrange - simulate repository failures
      when(() => mockRepository.getHapticsEnabled())
          .thenAnswer((_) async => const Left(AppFailure.cache()));
      when(() => mockRepository.isHapticsSupported())
          .thenAnswer((_) async => const Left(AppFailure.unexpected()));
      when(() => mockRepository.isReduceMotionEnabled())
          .thenAnswer((_) async => const Left(AppFailure.unexpected()));

      // act
      final result = await useCase();

      // assert - should use defaults: user pref = true, system support = false, reduce motion = false
      expect(
          result,
          equals(const Right<AppFailure, bool>(
              false))); // false because system support defaults to false
    });

    test('should return AppFailure when unexpected exception occurs', () async {
      // arrange
      when(() => mockRepository.getHapticsEnabled())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await useCase();

      // assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.displayMessage,
              contains('Failed to check haptics enabled state'));
        },
        (_) => fail('Expected failure'),
      );
    });
  });
}
