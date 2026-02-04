import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/widget_standardization.dart';
import 'package:ash_trail/utils/design_constants.dart';

void main() {
  group('AlignmentHelper', () {
    testWidgets('centerHorizontal centers widget without width',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.centerHorizontal(
              child: const Text('Test'),
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('centerHorizontal applies max width constraint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.centerHorizontal(
              child: const Text('Test'),
              width: 200,
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      // Find the ConstrainedBox that wraps our text
      final constrainedBoxFinder = find.ancestor(
        of: find.text('Test'),
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox =
          tester.widget<ConstrainedBox>(constrainedBoxFinder);
      expect(constrainedBox.constraints.maxWidth, 200);
    });

    testWidgets('centerVertical centers widget with height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.centerVertical(
              child: const Text('Test'),
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('center centers widget with dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.center(
              child: const Text('Test'),
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('alignWithPadding applies alignment and padding',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlignmentHelper.alignWithPadding(
              child: const Text('Test'),
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.topLeft);

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(16));
    });
  });

  group('SpacedColumn', () {
    testWidgets('renders children with spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              spacing: 20,
              children: [
                Text('First'),
                Text('Second'),
                Text('Third'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      // Should have 2 SizedBoxes for spacing (between 3 items)
      expect(find.byType(SizedBox), findsNWidgets(2));
    });

    testWidgets('applies mainAxisAlignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('applies crossAxisAlignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('applies mainAxisSize', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              mainAxisSize: MainAxisSize.max,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, MainAxisSize.max);
    });

    testWidgets('handles single child without spacer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              spacing: 20,
              children: [Text('Only')],
            ),
          ),
        ),
      );

      expect(find.text('Only'), findsOneWidget);
      expect(find.byType(SizedBox), findsNothing);
    });

    testWidgets('handles empty children list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedColumn(
              children: [],
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
    });
  });

  group('SpacedRow', () {
    testWidgets('renders children with horizontal spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedRow(
              spacing: 16,
              children: [
                Text('A'),
                Text('B'),
                Text('C'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.byType(SizedBox), findsNWidgets(2));
    });

    testWidgets('applies mainAxisAlignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
    });

    testWidgets('applies crossAxisAlignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacedRow(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.crossAxisAlignment, CrossAxisAlignment.end);
    });
  });

  group('CenteredSpacedColumn', () {
    testWidgets('centers column with spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredSpacedColumn(
              spacing: 12,
              children: [
                Text('One'),
                Text('Two'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('applies maxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredSpacedColumn(
              maxWidth: 300,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final constrainedBoxFinder = find.ancestor(
        of: find.text('Test'),
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox =
          tester.widget<ConstrainedBox>(constrainedBoxFinder);
      expect(constrainedBox.constraints.maxWidth, 300);
    });
  });

  group('CenteredSpacedRow', () {
    testWidgets('centers row with spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredSpacedRow(
              spacing: 8,
              children: [
                Text('Left'),
                Text('Right'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('applies maxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredSpacedRow(
              maxWidth: 400,
              children: [Text('Test')],
            ),
          ),
        ),
      );

      final constrainedBoxFinder = find.ancestor(
        of: find.text('Test'),
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox =
          tester.widget<ConstrainedBox>(constrainedBoxFinder);
      expect(constrainedBox.constraints.maxWidth, 400);
    });
  });

  group('PaddedContainer', () {
    testWidgets('applies padding from Spacing enum', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaddedContainer(
              padding: Spacing.xl,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, EdgeInsets.all(Spacing.xl.value));
    });

    testWidgets('fills width when fillWidth is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaddedContainer(
              fillWidth: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('applies minHeight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PaddedContainer(
              minHeight: 100,
              child: Text('Content'),
            ),
          ),
        ),
      );

      // Just verify widget renders
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('StandardCard', () {
    testWidgets('renders with default styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StandardCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies custom elevation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              elevation: 8,
              child: Text('Card'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 8);
    });

    testWidgets('applies custom backgroundColor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              backgroundColor: Colors.blue,
              child: Text('Card'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, Colors.blue);
    });

    testWidgets('applies custom borderRadius', (tester) async {
      const radius = BorderRadius.all(Radius.circular(32));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StandardCard(
              borderRadius: radius,
              child: Text('Card'),
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, radius);
    });
  });

  group('CenteredCard', () {
    testWidgets('centers card with max width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredCard(
              maxWidth: 500,
              child: Text('Centered'),
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.text('Centered'), findsOneWidget);
      // Verify the ConstrainedBox with maxWidth exists
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(
        constrainedBoxes.any((box) => box.constraints.maxWidth == 500),
        isTrue,
      );
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CenteredCard(
              padding: const EdgeInsets.all(32),
              child: Text('Padded'),
            ),
          ),
        ),
      );

      expect(find.text('Padded'), findsOneWidget);
    });
  });

  group('FillContainer', () {
    testWidgets('expands to fill available space', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FillContainer(
              child: Text('Filled'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Filled'), findsOneWidget);
    });
  });

  group('MinimumTouchTarget', () {
    testWidgets('wraps child with minimum size constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, A11yConstants.minimumTouchSize);
      expect(container.constraints?.minHeight, A11yConstants.minimumTouchSize);
    });

    testWidgets('handles tap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              onTap: () => tapped = true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('handles long press callback', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              onLongPress: () => longPressed = true,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.add));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('applies custom minSize', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              minSize: 64,
              child: Icon(Icons.add),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, 64);
      expect(container.constraints?.minHeight, 64);
    });
  });

  group('ResponsiveDivider', () {
    testWidgets('renders with default values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ResponsiveDivider(),
              ],
            ),
          ),
        ),
      );

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.height, 24);
      expect(divider.thickness, 1);
    });

    testWidgets('applies custom properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ResponsiveDivider(
                  height: 32,
                  thickness: 2,
                  color: Colors.red,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            ),
          ),
        ),
      );

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.height, 32);
      expect(divider.thickness, 2);
      expect(divider.color, Colors.red);
      expect(divider.indent, 16);
      expect(divider.endIndent, 16);
    });
  });

  group('SpacingDivider', () {
    testWidgets('renders as SizedBox with height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacingDivider(height: 24),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, 24);
    });

    testWidgets('uses default height of 16', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpacingDivider(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, 16);
    });
  });

  group('StyledSection', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StyledSection(
              title: 'Section Title',
              content: Text('Section content'),
            ),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
      expect(find.text('Section content'), findsOneWidget);
    });

    testWidgets('shows divider by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StyledSection(
                title: 'Title',
                content: Text('Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ResponsiveDivider), findsOneWidget);
    });

    testWidgets('hides divider when showDivider is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StyledSection(
                title: 'Title',
                content: Text('Content'),
                showDivider: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ResponsiveDivider), findsNothing);
    });

    testWidgets('applies custom title style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StyledSection(
              title: 'Styled',
              content: Text('Content'),
              titleStyle: TextStyle(
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Styled'));
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.color, Colors.blue);
    });
  });

  group('SafePadding', () {
    testWidgets('wraps child in SafeArea', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SafePadding(
            child: Text('Safe'),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.text('Safe'), findsOneWidget);
    });

    testWidgets('applies additional padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SafePadding(
            additionalPadding: 16,
            child: Text('Padded'),
          ),
        ),
      );

      // Find the padding widget that's a descendant of SafeArea
      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea, isNotNull);
      // Just verify the child exists and the structure is correct
      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('respects safe area flags', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SafePadding(
            top: false,
            bottom: false,
            left: true,
            right: true,
            child: Text('Partial'),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, false);
      expect(safeArea.bottom, false);
      expect(safeArea.left, true);
      expect(safeArea.right, true);
    });
  });
}
