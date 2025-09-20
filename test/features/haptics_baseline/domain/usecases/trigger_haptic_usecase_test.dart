// Unit tests for TriggerHapticUseCase

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/haptics_baseline/domain/entities/haptic_event.dart';
import 'package:ash_trail/features/haptics_baseline/domain/services/haptics_service.dart';
import 'package:ash_trail/features/haptics_baseline/domain/usecases/trigger_haptic_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockHapticsService extends Mock implements HapticsService {}

void main() {
  setUpAll(() {
    registerFallbackValue(HapticEvent.tap);
  });

  group('TriggerHapticUseCase', () {
    late TriggerHapticUseCase useCase;
    late MockHapticsService mockHapticsService;

    setUp(() {
      mockHapticsService = MockHapticsService();
      useCase = TriggerHapticUseCase(mockHapticsService);
    });

    test('should return true when haptic is successfully triggered', () async {
      // arrange
      when(() => mockHapticsService.triggerHaptic(any()))
          .thenAnswer((_) async => true);

      // act
      final result = await useCase(HapticEvent.tap);

      // assert
      expect(result, equals(const Right<AppFailure, bool>(true)));
      verify(() => mockHapticsService.triggerHaptic(HapticEvent.tap)).called(1);
    });

    test('should return false when haptic is not triggered (disabled)',
        () async {
      // arrange
      when(() => mockHapticsService.triggerHaptic(any()))
          .thenAnswer((_) async => false);

      // act
      final result = await useCase(HapticEvent.success);

      // assert
      expect(result, equals(const Right<AppFailure, bool>(false)));
      verify(() => mockHapticsService.triggerHaptic(HapticEvent.success))
          .called(1);
    });

    test('should return AppFailure when service throws exception', () async {
      // arrange
      final exception = Exception('Haptic service error');
      when(() => mockHapticsService.triggerHaptic(any())).thenThrow(exception);

      // act
      final result = await useCase(HapticEvent.error);

      // assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.displayMessage,
              contains('Failed to trigger haptic feedback'));
        },
        (_) => fail('Expected failure'),
      );
    });

    test('should work with all haptic event types', () async {
      // arrange
      when(() => mockHapticsService.triggerHaptic(any()))
          .thenAnswer((_) async => true);

      const allEvents = [
        HapticEvent.tap,
        HapticEvent.success,
        HapticEvent.warning,
        HapticEvent.error,
        HapticEvent.impactLight,
      ];

      // act & assert
      for (final event in allEvents) {
        final result = await useCase(event);
        expect(result.isRight(), isTrue);
        verify(() => mockHapticsService.triggerHaptic(event)).called(1);
      }
    });
  });
}
