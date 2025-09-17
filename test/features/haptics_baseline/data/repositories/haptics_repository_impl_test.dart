// Unit tests for HapticsRepositoryImpl

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/haptics_baseline/data/repositories/haptics_repository_impl.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('HapticsRepositoryImpl', () {
    late HapticsRepositoryImpl repository;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      repository = HapticsRepositoryImpl(mockPrefs);
    });

    group('getHapticsEnabled', () {
      test('should return true when preference is not set (default)', () async {
        // arrange
        when(() => mockPrefs.getBool('haptics_enabled')).thenReturn(null);

        // act
        final result = await repository.getHapticsEnabled();

        // assert
        expect(result, equals(const Right<AppFailure, bool>(true)));
        verify(() => mockPrefs.getBool('haptics_enabled')).called(1);
      });

      test('should return stored preference value', () async {
        // arrange
        when(() => mockPrefs.getBool('haptics_enabled')).thenReturn(false);

        // act
        final result = await repository.getHapticsEnabled();

        // assert
        expect(result, equals(const Right<AppFailure, bool>(false)));
      });

      test('should return cache failure when SharedPreferences throws',
          () async {
        // arrange
        when(() => mockPrefs.getBool(any()))
            .thenThrow(Exception('Storage error'));

        // act
        final result = await repository.getHapticsEnabled();

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to get haptics enabled preference'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('setHapticsEnabled', () {
      test('should successfully save preference', () async {
        // arrange
        when(() => mockPrefs.setBool('haptics_enabled', any()))
            .thenAnswer((_) async => true);

        // act
        final result = await repository.setHapticsEnabled(false);

        // assert
        expect(result, equals(const Right<AppFailure, void>(null)));
        verify(() => mockPrefs.setBool('haptics_enabled', false)).called(1);
      });

      test('should return cache failure when save fails', () async {
        // arrange
        when(() => mockPrefs.setBool(any(), any()))
            .thenThrow(Exception('Save error'));

        // act
        final result = await repository.setHapticsEnabled(true);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to save haptics enabled preference'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('isHapticsSupported', () {
      test('should return result from Vibration.hasVibrator', () async {
        // Note: This test is limited because we can't mock static methods easily
        // In a real implementation, we'd inject a VibrationService abstraction

        // act
        final result = await repository.isHapticsSupported();

        // assert
        expect(result.isRight(), isTrue);
        // The actual value depends on the test environment, so we just check it doesn't crash
      });
    });

    group('isReduceMotionEnabled', () {
      test('should return result from accessibility features', () async {
        // Note: This test is limited because we can't easily mock PlatformDispatcher
        // In a real implementation, we'd inject an AccessibilityService abstraction

        // act
        final result = await repository.isReduceMotionEnabled();

        // assert
        expect(result.isRight(), isTrue);
        // The actual value depends on the test environment, so we just check it doesn't crash
      });
    });
  });
}
