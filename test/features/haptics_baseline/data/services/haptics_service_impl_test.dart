// Unit tests for HapticsServiceImpl

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/haptics_baseline/domain/entities/haptic_event.dart';
import 'package:ash_trail/features/haptics_baseline/domain/usecases/get_haptics_enabled_usecase.dart';
import 'package:ash_trail/features/haptics_baseline/data/services/haptics_service_impl.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockGetHapticsEnabledUseCase extends Mock
    implements GetHapticsEnabledUseCase {}

void main() {
  group('HapticsServiceImpl', () {
    late HapticsServiceImpl service;
    late MockGetHapticsEnabledUseCase mockUseCase;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Mock the haptic feedback platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          return null;
        }
        return null;
      });
    });

    setUp(() {
      mockUseCase = MockGetHapticsEnabledUseCase();
      service = HapticsServiceImpl(mockUseCase);
    });

    test('should return false when haptics is disabled', () async {
      // arrange
      when(() => mockUseCase()).thenAnswer((_) async => const Right(false));

      // act
      final result = await service.triggerHaptic(HapticEvent.tap);

      // assert
      expect(result, isFalse);
      verify(() => mockUseCase()).called(1);
    });

    test('should return true when haptics is enabled', () async {
      // arrange
      when(() => mockUseCase()).thenAnswer((_) async => const Right(true));

      // act
      final result = await service.triggerHaptic(HapticEvent.tap);

      // assert
      expect(result, isTrue);
      verify(() => mockUseCase()).called(1);
    });

    test('should return false when use case fails', () async {
      // arrange
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(AppFailure.unexpected()));

      // act
      final result = await service.triggerHaptic(HapticEvent.success);

      // assert
      expect(result, isFalse);
      verify(() => mockUseCase()).called(1);
    });

    test('should handle all haptic event types when enabled', () async {
      // arrange
      when(() => mockUseCase()).thenAnswer((_) async => const Right(true));

      const allEvents = [
        HapticEvent.tap,
        HapticEvent.success,
        HapticEvent.warning,
        HapticEvent.error,
        HapticEvent.impactLight,
      ];

      // act & assert
      for (final event in allEvents) {
        final result = await service.triggerHaptic(event);
        expect(result, isTrue, reason: 'Failed for event: $event');
      }

      verify(() => mockUseCase()).called(5);
    });

    test('should return correct enabled state from isHapticsEnabled', () async {
      // arrange
      when(() => mockUseCase()).thenAnswer((_) async => const Right(true));

      // act
      final result = await service.isHapticsEnabled();

      // assert
      expect(result, isTrue);
    });

    test('should return false from isHapticsEnabled when use case fails',
        () async {
      // arrange
      when(() => mockUseCase())
          .thenAnswer((_) async => const Left(AppFailure.cache()));

      // act
      final result = await service.isHapticsEnabled();

      // assert
      expect(result, isFalse);
    });

    test('should throw UnimplementedError for setHapticsEnabled', () async {
      expect(
        () => service.setHapticsEnabled(true),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('should return false on exception without crashing', () async {
      // arrange - mock use case to throw exception
      when(() => mockUseCase()).thenThrow(Exception('Unexpected error'));

      // act
      final result = await service.triggerHaptic(HapticEvent.error);

      // assert - should handle exception gracefully
      expect(result, isFalse);
    });
  });
}
