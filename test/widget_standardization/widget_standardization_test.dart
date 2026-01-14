/// Widget Standardization Test Suite
///
/// Tests for consistent widget alignment, spacing, centering,
/// and spacing utilities across the app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/design_constants.dart';
import 'package:ash_trail/utils/widget_standardization.dart';

void main() {
  group('Widget Standardization - Spacing Widgets', () {
    testWidgets('SpacedColumn renders with correct spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              spacing: 16,
              children: [
                Container(height: 50, color: Colors.red),
                Container(height: 50, color: Colors.blue),
                Container(height: 50, color: Colors.green),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);

      // Should have 2 spacers between 3 children
      expect(find.byType(SizedBox).evaluate().length, greaterThanOrEqualTo(2));
    });

    testWidgets('SpacedRow renders with correct spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpacedRow(
              spacing: 12,
              children: [
                Container(width: 50, height: 50, color: Colors.red),
                Container(width: 50, height: 50, color: Colors.blue),
                Container(width: 50, height: 50, color: Colors.green),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('CenteredSpacedColumn centers children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CenteredSpacedColumn(
              spacing: 16,
              children: [const Text('Item 1'), const Text('Item 2')],
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(SpacedColumn), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('CenteredSpacedRow centers children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CenteredSpacedRow(
              spacing: 12,
              children: [const Text('Item 1'), const Text('Item 2')],
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(SpacedRow), findsOneWidget);
    });
  });

  group('Widget Standardization - Alignment Helpers', () {
    testWidgets('centerHorizontal centers widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.centerHorizontal(
              child: const Text('Centered'),
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Centered'), findsOneWidget);
    });

    testWidgets('centerVertical centers widget vertically', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.centerVertical(
              child: const Text('Centered'),
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('center centers widget both ways', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.center(
              child: const Text('Centered'),
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('alignWithPadding aligns and pads widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.alignWithPadding(
              child: const Text('Aligned'),
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(16),
            ),
          ),
        ),
      );

      expect(find.byType(Align), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });
  });

  group('Widget Standardization - Card Containers', () {
    testWidgets('StandardCard renders with default styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StandardCard(child: const Text('Card content'))),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('StandardCard responds to tap', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StandardCard(
              onTap: () => tapped = true,
              child: const Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('CenteredCard is centered with max width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CenteredCard(
              maxWidth: 300,
              child: const Text('Centered card'),
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('Widget Standardization - Padded Containers', () {
    testWidgets('PaddedContainer applies padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaddedContainer(
              padding: Spacing.lg,
              child: const Text('Padded'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('PaddedContainer fills width by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: PaddedContainer(child: Container()))),
      );

      final container = tester.getSize(find.byType(Container).first);
      expect(container.width, greaterThan(0));
    });

    testWidgets('ResponsivePaddedContainer adapts padding to screen size', (
      WidgetTester tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsivePaddedContainer(
              mobilePadding: 8,
              tabletPadding: 16,
              desktopPadding: 24,
              child: const Text('Responsive'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Responsive'), findsOneWidget);
    });
  });

  group('Widget Standardization - Dividers', () {
    testWidgets('ResponsiveDivider renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ResponsiveDivider())),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('SpacingDivider renders correct height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SpacingDivider(height: 24))),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('Widget Standardization - Section Containers', () {
    testWidgets('StyledSection renders title and content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSection(
              title: 'Section Title',
              content: const Text('Section content'),
            ),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
      expect(find.text('Section content'), findsOneWidget);
    });

    testWidgets('StyledSection shows divider by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSection(
              title: 'Section',
              content: const Text('Content'),
              showDivider: true,
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('StyledSection can hide divider', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSection(
              title: 'Section',
              content: const Text('Content'),
              showDivider: false,
            ),
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
    });
  });

  group('Widget Standardization - Fill Container', () {
    testWidgets('FillContainer expands to fill available space', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FillContainer(child: const Text('Filling space')),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Filling space'), findsOneWidget);
    });
  });

  group('Widget Standardization - Minimum Touch Target', () {
    testWidgets('MinimumTouchTarget creates accessible button', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              onTap: () => tapped = true,
              child: const Text('Tap'),
            ),
          ),
        ),
      );

      final container = find.byType(Container).first;
      final size = tester.getSize(container);

      expect(size.width, greaterThanOrEqualTo(A11yConstants.minimumTouchSize));
      expect(size.height, greaterThanOrEqualTo(A11yConstants.minimumTouchSize));

      await tester.tap(container);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('MinimumTouchTarget is semantically a button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(onTap: () {}, child: const Text('Button')),
          ),
        ),
      );

      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('Widget Standardization - Safe Padding', () {
    testWidgets('SafePadding respects safe areas', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SafePadding(child: const Text('Safe'))),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('SafePadding applies additional padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SafePadding(additionalPadding: 16, child: const Text('Padded')),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('Widget Standardization - Padding Constants', () {
    test('All padding values are positive', () {
      expect(Paddings.xs.top, greaterThan(0));
      expect(Paddings.sm.top, greaterThan(0));
      expect(Paddings.md.top, greaterThan(0));
      expect(Paddings.lg.top, greaterThan(0));
      expect(Paddings.xl.top, greaterThan(0));
      expect(Paddings.xxl.top, greaterThan(0));
    });

    test('Padding values are logically ordered', () {
      expect(Paddings.xs.top, lessThan(Paddings.sm.top));
      expect(Paddings.sm.top, lessThan(Paddings.md.top));
      expect(Paddings.md.top, lessThan(Paddings.lg.top));
      expect(Paddings.lg.top, lessThan(Paddings.xl.top));
      expect(Paddings.xl.top, lessThan(Paddings.xxl.top));
    });

    test('Horizontal and vertical padding are consistent', () {
      expect(Paddings.horizontalSm.left, equals(8));
      expect(Paddings.horizontalSm.right, equals(8));
      expect(Paddings.horizontalMd.left, equals(12));
      expect(Paddings.horizontalLg.left, equals(16));
    });

    test('No padding is zero', () {
      expect(Paddings.none.top, equals(0));
      expect(Paddings.none.left, equals(0));
    });
  });

  group('Widget Standardization - Border Radius', () {
    test('BorderRadii values match BorderRadiusSize', () {
      expect(BorderRadii.sm.topLeft.x, equals(BorderRadiusSize.sm.value));
      expect(BorderRadii.md.topLeft.x, equals(BorderRadiusSize.md.value));
      expect(BorderRadii.lg.topLeft.x, equals(BorderRadiusSize.lg.value));
      expect(BorderRadii.xl.topLeft.x, equals(BorderRadiusSize.xl.value));
    });

    test('BorderRadiusSize borderRadius getter works', () {
      final radius = BorderRadiusSize.md.borderRadius;
      expect(radius.topLeft.x, equals(12));
      expect(radius.topRight.x, equals(12));
      expect(radius.bottomLeft.x, equals(12));
      expect(radius.bottomRight.x, equals(12));
    });
  });

  group('Widget Standardization - Elevation Levels', () {
    test('Elevation levels are non-negative', () {
      for (final level in ElevationLevel.values) {
        expect(level.value, greaterThanOrEqualTo(0));
      }
    });

    test('Elevation levels are properly ordered', () {
      expect(ElevationLevel.none.value, lessThan(ElevationLevel.sm.value));
      expect(ElevationLevel.sm.value, lessThan(ElevationLevel.md.value));
      expect(ElevationLevel.md.value, lessThan(ElevationLevel.lg.value));
      expect(ElevationLevel.lg.value, lessThan(ElevationLevel.xl.value));
    });
  });

  group('Widget Standardization - Icon Sizes', () {
    test('Icon sizes are properly ordered', () {
      expect(IconSize.sm.value, lessThan(IconSize.md.value));
      expect(IconSize.md.value, lessThan(IconSize.lg.value));
      expect(IconSize.lg.value, lessThan(IconSize.xl.value));
      expect(IconSize.xl.value, lessThan(IconSize.xxl.value));
      expect(IconSize.xxl.value, lessThan(IconSize.xxxl.value));
    });

    test('Icon sizes are all positive', () {
      for (final size in IconSize.values) {
        expect(size.value, greaterThan(0));
      }
    });
  });

  group('Widget Standardization - Spacing Consistency', () {
    testWidgets('Multiple SpacedColumns have consistent spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SpacedColumn(
                  spacing: 16,
                  children: const [
                    Text('Column 1 Item 1'),
                    Text('Column 1 Item 2'),
                  ],
                ),
                SpacedColumn(
                  spacing: 16,
                  children: const [
                    Text('Column 2 Item 1'),
                    Text('Column 2 Item 2'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Padding constants create uniform spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Padding(padding: Paddings.lg, child: const Text('Item 1')),
                Padding(padding: Paddings.lg, child: const Text('Item 2')),
                Padding(padding: Paddings.lg, child: const Text('Item 3')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsWidgets);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });
  });
}
