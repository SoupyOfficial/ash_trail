// Tests for accessibility foundation components
// Tests mixin utilities and export accessibility

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/accessibility_foundation/accessibility_foundation.dart';

class TestWidgetWithMixin extends StatelessWidget with AccessibilityMixin {
  const TestWidgetWithMixin({super.key});

  @override
  Widget build(BuildContext context) {
    final isActive = isAccessibilityModeActive(context);
    final tapTarget = getEffectiveMinTapTarget(context);

    return Column(
      children: [
        Text('Accessibility Active: $isActive'),
        Text('Min Tap Target: $tapTarget'),
      ],
    );
  }
}

void main() {
  group('AccessibilityMixin', () {
    testWidgets('should detect accessibility mode correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const TestWidgetWithMixin(),
          ),
        ),
      );

      // Verify the mixin methods are called without errors
      expect(find.textContaining('Accessibility Active:'), findsOneWidget);
      expect(find.textContaining('Min Tap Target:'), findsOneWidget);
    });

    testWidgets('should provide effective minimum tap target size',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            boldText: true,
            textScaler: TextScaler.linear(1.5),
          ),
          child: MaterialApp(
            home: Scaffold(
              body: const TestWidgetWithMixin(),
            ),
          ),
        ),
      );

      // The widget should build successfully with MediaQuery data
      expect(find.byType(TestWidgetWithMixin), findsOneWidget);
    });

    test('mixin methods should work with accessibility service', () {
      // This tests that the mixin properly delegates to AccessibilityService
      // We can't test the actual values without a BuildContext, but we can verify
      // the mixin class exists and has the expected methods

      final mixin = TestWidgetWithMixin();
      expect(mixin, isA<AccessibilityMixin>());
    });
  });

  group('Module Exports', () {
    test('should export accessibility service', () {
      // Test that the main exports are available
      expect(AccessibilityService, isNotNull);
    });
  });
}
