// Spec Header:
// Accessibility Service Unit Tests
// Tests accessibility detection, system integration, and utility methods.
// Assumption: MediaQuery values are mocked for consistent test results.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/accessibility_foundation/presentation/services/accessibility_service.dart';

void main() {
  group('AccessibilityService', () {
    group('fromMediaQuery', () {
      testWidgets('returns correct capabilities from MediaQuery',
          (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Act
                final capabilities =
                    AccessibilityService.fromMediaQuery(context);

                // Assert
                expect(capabilities, isA<AccessibilityCapabilities>());
                expect(capabilities.textScaleFactor, equals(1.0));
                expect(capabilities.isScreenReaderEnabled, isFalse);
                expect(capabilities.isHighContrastEnabled, isFalse);
                expect(capabilities.isBoldTextEnabled, isFalse);
                expect(capabilities.isReduceMotionEnabled, isFalse);

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('detects high text scale factor', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(2.0),
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final capabilities =
                      AccessibilityService.fromMediaQuery(context);

                  // Assert
                  expect(capabilities.textScaleFactor, equals(2.0));
                  expect(capabilities.isAccessibilityModeActive, isTrue);
                  expect(capabilities.needsLargerTapTargets, isTrue);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects screen reader enabled', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                accessibleNavigation: true,
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final capabilities =
                      AccessibilityService.fromMediaQuery(context);

                  // Assert
                  expect(capabilities.isScreenReaderEnabled, isTrue);
                  expect(capabilities.isAccessibilityModeActive, isTrue);
                  expect(capabilities.needsLargerTapTargets, isTrue);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('detects high contrast enabled', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                highContrast: true,
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final capabilities =
                      AccessibilityService.fromMediaQuery(context);

                  // Assert
                  expect(capabilities.isHighContrastEnabled, isTrue);
                  expect(capabilities.needsHighContrast, isTrue);
                  expect(capabilities.isAccessibilityModeActive, isTrue);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('getEffectiveMinTapTarget', () {
      testWidgets('returns base size for normal conditions', (tester) async {
        // Arrange
        const baseSize = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Act
                final effectiveSize =
                    AccessibilityService.getEffectiveMinTapTarget(
                  context,
                  baseSize: baseSize,
                );

                // Assert
                expect(effectiveSize, equals(baseSize));

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('increases size for screen reader users', (tester) async {
        // Arrange
        const baseSize = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                accessibleNavigation: true,
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final effectiveSize =
                      AccessibilityService.getEffectiveMinTapTarget(
                    context,
                    baseSize: baseSize,
                  );

                  // Assert
                  expect(effectiveSize, equals(baseSize * 1.2));

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('increases size for high text scale', (tester) async {
        // Arrange
        const baseSize = 48.0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.5),
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final effectiveSize =
                      AccessibilityService.getEffectiveMinTapTarget(
                    context,
                    baseSize: baseSize,
                  );

                  // Assert
                  expect(effectiveSize, equals(baseSize * 1.2));

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('isScreenReaderActive', () {
      testWidgets('returns false for normal conditions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Act
                final isActive =
                    AccessibilityService.isScreenReaderActive(context);

                // Assert
                expect(isActive, isFalse);

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('returns true when accessibleNavigation is enabled',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                accessibleNavigation: true,
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final isActive =
                      AccessibilityService.isScreenReaderActive(context);

                  // Assert
                  expect(isActive, isTrue);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('shouldReduceMotion', () {
      testWidgets('returns false for normal conditions', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Act
                final shouldReduce =
                    AccessibilityService.shouldReduceMotion(context);

                // Assert
                expect(shouldReduce, isFalse);

                return const SizedBox.shrink();
              },
            ),
          ),
        );
      });

      testWidgets('returns true when disableAnimations is enabled',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                disableAnimations: true,
              ),
              child: Builder(
                builder: (context) {
                  // Act
                  final shouldReduce =
                      AccessibilityService.shouldReduceMotion(context);

                  // Assert
                  expect(shouldReduce, isTrue);

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      });
    });

    group('shouldAnnounceImmediately', () {
      test('returns false for normal conditions', () {
        // Act
        final shouldAnnounce = AccessibilityService.shouldAnnounceImmediately();

        // Assert
        expect(shouldAnnounce, isFalse);
      });

      test('returns true for error conditions', () {
        // Act
        final shouldAnnounce =
            AccessibilityService.shouldAnnounceImmediately(isError: true);

        // Assert
        expect(shouldAnnounce, isTrue);
      });

      test('returns true for important conditions', () {
        // Act
        final shouldAnnounce =
            AccessibilityService.shouldAnnounceImmediately(isImportant: true);

        // Assert
        expect(shouldAnnounce, isTrue);
      });
    });
  });

  group('AccessibilityCapabilities', () {
    test('isAccessibilityModeActive returns false for default values', () {
      // Arrange
      const capabilities = AccessibilityCapabilities(
        textScaleFactor: 1.0,
        isScreenReaderEnabled: false,
        isHighContrastEnabled: false,
        isBoldTextEnabled: false,
        isReduceMotionEnabled: false,
        platformBrightness: Brightness.light,
        devicePixelRatio: 1.0,
      );

      // Act & Assert
      expect(capabilities.isAccessibilityModeActive, isFalse);
    });

    test('isAccessibilityModeActive returns true for high text scale', () {
      // Arrange
      const capabilities = AccessibilityCapabilities(
        textScaleFactor: 1.5,
        isScreenReaderEnabled: false,
        isHighContrastEnabled: false,
        isBoldTextEnabled: false,
        isReduceMotionEnabled: false,
        platformBrightness: Brightness.light,
        devicePixelRatio: 1.0,
      );

      // Act & Assert
      expect(capabilities.isAccessibilityModeActive, isTrue);
    });

    test('needsLargerTapTargets returns true for screen reader', () {
      // Arrange
      const capabilities = AccessibilityCapabilities(
        textScaleFactor: 1.0,
        isScreenReaderEnabled: true,
        isHighContrastEnabled: false,
        isBoldTextEnabled: false,
        isReduceMotionEnabled: false,
        platformBrightness: Brightness.light,
        devicePixelRatio: 1.0,
      );

      // Act & Assert
      expect(capabilities.needsLargerTapTargets, isTrue);
    });

    test('equality works correctly', () {
      // Arrange
      const capabilities1 = AccessibilityCapabilities(
        textScaleFactor: 1.0,
        isScreenReaderEnabled: false,
        isHighContrastEnabled: false,
        isBoldTextEnabled: false,
        isReduceMotionEnabled: false,
        platformBrightness: Brightness.light,
        devicePixelRatio: 1.0,
      );

      const capabilities2 = AccessibilityCapabilities(
        textScaleFactor: 1.0,
        isScreenReaderEnabled: false,
        isHighContrastEnabled: false,
        isBoldTextEnabled: false,
        isReduceMotionEnabled: false,
        platformBrightness: Brightness.light,
        devicePixelRatio: 1.0,
      );

      // Act & Assert
      expect(capabilities1, equals(capabilities2));
      expect(capabilities1.hashCode, equals(capabilities2.hashCode));
    });
  });
}
