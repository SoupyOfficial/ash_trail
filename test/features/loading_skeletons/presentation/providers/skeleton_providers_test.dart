import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/providers/skeleton_providers.dart';

void main() {
  group('Skeleton Providers', () {
    test('reduceMotionProvider should default to false', () {
      final container = ProviderContainer();
      final reduceMotion = container.read(reduceMotionProvider);

      expect(reduceMotion, false);

      container.dispose();
    });

    test(
        'skeletonAnimationDurationProvider should return different durations based on reduce motion',
        () {
      final container = ProviderContainer();

      // Default case (reduce motion false)
      final normalDuration = container.read(skeletonAnimationDurationProvider);
      expect(normalDuration, const Duration(milliseconds: 1200));

      container.dispose();
    });

    test(
        'skeletonAnimationDurationProvider should handle reduce motion enabled',
        () {
      final container = ProviderContainer(
        overrides: [
          reduceMotionProvider.overrideWithValue(true),
        ],
      );

      final reducedDuration = container.read(skeletonAnimationDurationProvider);
      expect(reducedDuration, const Duration(milliseconds: 800));

      container.dispose();
    });

    test('minimumLoadingDurationProvider should return 300ms', () {
      final container = ProviderContainer();
      final minDuration = container.read(minimumLoadingDurationProvider);

      expect(minDuration, const Duration(milliseconds: 300));

      container.dispose();
    });

    test('providers should be independent', () {
      final container = ProviderContainer();

      final reduceMotion = container.read(reduceMotionProvider);
      final animationDuration =
          container.read(skeletonAnimationDurationProvider);
      final minDuration = container.read(minimumLoadingDurationProvider);

      expect(reduceMotion, isA<bool>());
      expect(animationDuration, isA<Duration>());
      expect(minDuration, isA<Duration>());

      container.dispose();
    });
  });
}
