import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/min_tap_target.dart';

void main() {
  group('MinTapTarget', () {
    testWidgets('enforces minimum size constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinTapTarget(
              minSize: 48.0,
              child: Container(
                width: 20,
                height: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Find all ConstrainedBox widgets within MinTapTarget
      final constrainedBoxes = find.descendant(
        of: find.byType(MinTapTarget),
        matching: find.byType(ConstrainedBox),
      );

      // Look for the ConstrainedBox with minimum size constraints (from MinTapTarget)
      bool foundMinTapTargetConstraints = false;
      for (int i = 0;
          i < tester.widgetList<ConstrainedBox>(constrainedBoxes).length;
          i++) {
        final constrainedBox =
            tester.widgetList<ConstrainedBox>(constrainedBoxes).elementAt(i);
        if (constrainedBox.constraints.minWidth == 48.0 &&
            constrainedBox.constraints.minHeight == 48.0) {
          foundMinTapTargetConstraints = true;
          break;
        }
      }
      expect(foundMinTapTargetConstraints, isTrue);
    });

    testWidgets('allows custom minimum size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinTapTarget(
              minSize: 60.0,
              child: Container(
                width: 20,
                height: 20,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // Find all ConstrainedBox widgets within MinTapTarget
      final constrainedBoxes = find.descendant(
        of: find.byType(MinTapTarget),
        matching: find.byType(ConstrainedBox),
      );

      // Look for the ConstrainedBox with minimum size constraints (from MinTapTarget)
      bool foundMinTapTargetConstraints = false;
      for (int i = 0;
          i < tester.widgetList<ConstrainedBox>(constrainedBoxes).length;
          i++) {
        final constrainedBox =
            tester.widgetList<ConstrainedBox>(constrainedBoxes).elementAt(i);
        if (constrainedBox.constraints.minWidth == 60.0 &&
            constrainedBox.constraints.minHeight == 60.0) {
          foundMinTapTargetConstraints = true;
          break;
        }
      }
      expect(foundMinTapTargetConstraints, isTrue);
    });

    testWidgets('preserves child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinTapTarget(
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });
  });

  group('MinTapTargetWidget extension', () {
    testWidgets('wraps widget with MinTapTarget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withMinTapTarget(minSize: 56.0),
          ),
        ),
      );

      expect(find.byType(MinTapTarget), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);

      final minTapTarget =
          tester.widget<MinTapTarget>(find.byType(MinTapTarget));
      expect(minTapTarget.minSize, equals(56.0));
    });
  });

  group('ResponsiveButton', () {
    testWidgets('enforces minimum tap target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              onPressed: () {},
              minTapTarget: 60.0,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      expect(find.byType(MinTapTarget), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      final minTapTarget =
          tester.widget<MinTapTarget>(find.byType(MinTapTarget));
      expect(minTapTarget.minSize, equals(60.0));

      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton.style?.minimumSize?.resolve({}),
          equals(const Size(60.0, 60.0)));
    });

    testWidgets('handles null onPressed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              onPressed: null,
              child: Text('Disabled Button'),
            ),
          ),
        ),
      );

      final textButton = tester.widget<TextButton>(find.byType(TextButton));
      expect(textButton.onPressed, isNull);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveButton(
              onPressed: () => pressed = true,
              child: const Text('Button'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      expect(pressed, isTrue);
    });
  });

  group('ResponsiveIconButton', () {
    testWidgets('enforces minimum tap target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveIconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              minTapTarget: 56.0,
            ),
          ),
        ),
      );

      expect(find.byType(MinTapTarget), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);

      final minTapTarget =
          tester.widget<MinTapTarget>(find.byType(MinTapTarget));
      expect(minTapTarget.minSize, equals(56.0));

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.constraints?.minWidth, equals(56.0));
      expect(iconButton.constraints?.minHeight, equals(56.0));
    });

    testWidgets('displays icon and tooltip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveIconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
              tooltip: 'Home Button',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, equals('Home Button'));
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveIconButton(
              onPressed: () => pressed = true,
              icon: const Icon(Icons.home),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });
  });

  group('MinTapTargetWidget extension', () {
    testWidgets('withMinTapTarget wraps widget with MinTapTarget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withMinTapTarget(),
          ),
        ),
      );

      expect(find.byType(MinTapTarget), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('withMinTapTarget accepts custom minSize', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withMinTapTarget(minSize: 56.0),
          ),
        ),
      );

      final minTapTarget =
          tester.widget<MinTapTarget>(find.byType(MinTapTarget));
      expect(minTapTarget.minSize, equals(56.0));
    });

    testWidgets('withMinTapTarget accepts custom debugLabel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:
                const Text('Test').withMinTapTarget(debugLabel: 'Custom Label'),
          ),
        ),
      );

      final minTapTarget =
          tester.widget<MinTapTarget>(find.byType(MinTapTarget));
      expect(minTapTarget.debugLabel, equals('Custom Label'));
    });
  });
}
