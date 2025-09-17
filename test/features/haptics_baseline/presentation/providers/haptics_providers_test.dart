// Unit tests for haptics providers

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/haptics_baseline/domain/entities/haptic_event.dart';
import 'package:ash_trail/features/haptics_baseline/presentation/providers/haptics_providers.dart';
import '../../../../test_util/test_harness.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('Haptics Providers', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      // Set up default mock behavior
      when(() => mockPrefs.getBool('haptics_enabled')).thenReturn(true);
    });

    group('hapticsEnabledProvider', () {
      test('should return haptics enabled state', () async {
        // arrange
        final harness = TestHarness.overrides([
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ]);

        // act
        final result =
            await harness.container.read(hapticsEnabledProvider.future);

        // assert - depends on system settings but should not crash
        expect(result, isA<bool>());
        harness.container.dispose();
      });

      test('should handle repository failure gracefully', () async {
        // arrange
        when(() => mockPrefs.getBool(any()))
            .thenThrow(Exception('Storage error'));

        final harness = TestHarness.overrides([
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ]);

        // act
        final result =
            await harness.container.read(hapticsEnabledProvider.future);

        // assert - should return false on failure
        expect(result, isFalse);
        harness.container.dispose();
      });
    });

    group('hapticTriggerProvider', () {
      test('should trigger haptic events successfully when enabled', () async {
        // arrange
        final harness = TestHarness.overrides([
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ]);

        final notifier = harness.container.read(hapticTriggerProvider.notifier);

        // act & assert - should not throw
        final tapResult = await notifier.tap();
        final successResult = await notifier.success();
        final warningResult = await notifier.warning();
        final errorResult = await notifier.error();
        final impactResult = await notifier.impactLight();

        expect(tapResult, isA<bool>());
        expect(successResult, isA<bool>());
        expect(warningResult, isA<bool>());
        expect(errorResult, isA<bool>());
        expect(impactResult, isA<bool>());

        harness.container.dispose();
      });

      test('should handle trigger with specific haptic event', () async {
        // arrange
        final harness = TestHarness.overrides([
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ]);

        final notifier = harness.container.read(hapticTriggerProvider.notifier);

        // act & assert
        final result = await notifier.trigger(HapticEvent.tap);
        expect(result, isA<bool>());

        harness.container.dispose();
      });
    });

    group('provider dependencies', () {
      test('all providers should be properly initialized', () {
        // arrange
        final harness = TestHarness.overrides([
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ]);

        // act & assert - should not throw
        expect(() => harness.container.read(hapticsRepositoryProvider),
            returnsNormally);
        expect(() => harness.container.read(getHapticsEnabledUseCaseProvider),
            returnsNormally);
        expect(() => harness.container.read(hapticsServiceProvider),
            returnsNormally);
        expect(() => harness.container.read(triggerHapticUseCaseProvider),
            returnsNormally);

        harness.container.dispose();
      });

      test('should throw when sharedPreferencesProvider is not overridden', () {
        // arrange
        final container = ProviderContainer();

        // act & assert
        expect(
          () => container.read(hapticsRepositoryProvider),
          throwsA(isA<UnimplementedError>()),
        );

        container.dispose();
      });
    });
  });
}
