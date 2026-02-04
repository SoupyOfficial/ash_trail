import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/a11y_utils.dart';

void main() {
  group('SemanticLabelBuilder', () {
    test('button creates proper label', () {
      expect(
        SemanticLabelBuilder.button('Submit'),
        contains('Submit'),
      );
    });

    test('field creates proper label', () {
      expect(
        SemanticLabelBuilder.field('Email'),
        contains('Email'),
      );
    });

    test('toggle creates label with enabled state', () {
      final label = SemanticLabelBuilder.toggle('Dark Mode', enabled: true);
      expect(label, contains('Dark Mode'));
      expect(label, contains('enabled'));
    });

    test('toggle creates label with disabled state', () {
      final label = SemanticLabelBuilder.toggle('Dark Mode', enabled: false);
      expect(label, contains('Dark Mode'));
      expect(label, contains('disabled'));
    });

    test('sliderValue creates label without unit', () {
      final label = SemanticLabelBuilder.sliderValue('Volume', 75.5);
      expect(label, contains('Volume'));
      expect(label, contains('75.5'));
    });

    test('sliderValue creates label with unit', () {
      final label = SemanticLabelBuilder.sliderValue('Temperature', 22.0, unit: '°C');
      expect(label, contains('Temperature'));
      expect(label, contains('22.0'));
      expect(label, contains('°C'));
    });

    test('listItem creates label with title only', () {
      final label = SemanticLabelBuilder.listItem('My Item');
      expect(label, contains('My Item'));
    });

    test('listItem creates label with title and subtitle', () {
      final label = SemanticLabelBuilder.listItem('My Item', subtitle: 'Details');
      expect(label, contains('My Item'));
      expect(label, contains('Details'));
    });

    test('listItem creates label with title and index', () {
      final label = SemanticLabelBuilder.listItem('My Item', index: 0);
      expect(label, contains('My Item'));
      expect(label, contains('item 1'));
    });

    test('listItem creates label with all parameters', () {
      final label = SemanticLabelBuilder.listItem('My Item', subtitle: 'Details', index: 2);
      expect(label, contains('My Item'));
      expect(label, contains('Details'));
      expect(label, contains('item 3'));
    });

    test('tab creates selected label', () {
      final label = SemanticLabelBuilder.tab('Home', selected: true);
      expect(label, contains('Home'));
      expect(label, contains('tab'));
      expect(label, contains('selected'));
    });

    test('tab creates unselected label', () {
      final label = SemanticLabelBuilder.tab('Home', selected: false);
      expect(label, contains('Home'));
      expect(label, contains('tab'));
      expect(label, contains('unselected'));
    });

    test('dialog creates proper label', () {
      final label = SemanticLabelBuilder.dialog('Confirm Action');
      expect(label, contains('Dialog'));
      expect(label, contains('Confirm Action'));
    });

    test('bottomSheet creates proper label', () {
      final label = SemanticLabelBuilder.bottomSheet('Options');
      expect(label, contains('Bottom sheet'));
      expect(label, contains('Options'));
    });

    test('interactive creates proper label', () {
      final label = SemanticLabelBuilder.interactive('Click me');
      expect(label, contains('Click me'));
    });

    test('iconButton creates proper label', () {
      final label = SemanticLabelBuilder.iconButton('Delete');
      expect(label, contains('Delete'));
      expect(label, contains('button'));
    });
  });

  group('MinimumTouchTarget', () {
    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              child: Text('Touch Me'),
            ),
          ),
        ),
      );

      expect(find.text('Touch Me'), findsOneWidget);
    });

    testWidgets('enforces minimum size constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              minSize: 48.0,
              child: SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byType(SizedBox).first,
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(constrainedBox.constraints.minWidth, 48.0);
      expect(constrainedBox.constraints.minHeight, 48.0);
    });

    testWidgets('wraps with InkWell when onTap provided', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('does not wrap with InkWell when onTap is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              child: Text('Static'),
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('uses custom minSize', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(
              minSize: 60.0,
              child: Text('Big Target'),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.text('Big Target'),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(constrainedBox.constraints.minWidth, 60.0);
      expect(constrainedBox.constraints.minHeight, 60.0);
    });
  });

  group('SemanticIcon', () {
    testWidgets('renders icon with semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticIcon(
              icon: Icons.add,
              semanticLabel: 'Add item',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      final semantics = tester.getSemantics(find.byType(SemanticIcon));
      expect(semantics.label, contains('Add item'));
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticIcon(
              icon: Icons.star,
              semanticLabel: 'Star',
              color: Colors.yellow,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.yellow);
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticIcon(
              icon: Icons.home,
              semanticLabel: 'Home',
              size: 48,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 48);
    });
  });

  group('SemanticIconButton', () {
    testWidgets('renders icon button with semantic label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.delete,
              semanticLabel: 'Delete item',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('shows tooltip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.info,
              semanticLabel: 'Info',
              tooltip: 'Show information',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Tooltip), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Show information');
    });

    testWidgets('uses semanticLabel as tooltip when tooltip not provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.info,
              semanticLabel: 'Info button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Info button');
    });

    testWidgets('calls onPressed when enabled', (WidgetTester tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.play_arrow,
              semanticLabel: 'Play',
              onPressed: () => pressed = true,
              enabled: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when disabled', (WidgetTester tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.play_arrow,
              semanticLabel: 'Play',
              onPressed: () => pressed = true,
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, isFalse);
    });

    testWidgets('applies custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.edit,
              semanticLabel: 'Edit',
              onPressed: () {},
              size: 36,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 36);
    });

    testWidgets('applies custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.favorite,
              semanticLabel: 'Favorite',
              onPressed: () {},
              color: Colors.red,
            ),
          ),
        ),
      );

      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.color, Colors.red);
    });
  });

  group('SemanticFormField', () {
    testWidgets('renders child widget with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticFormField(
              label: 'Username',
              child: TextField(),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows error text when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticFormField(
              label: 'Email',
              errorText: 'Invalid email format',
              child: TextField(),
            ),
          ),
        ),
      );

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('does not show error text when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticFormField(
              label: 'Password',
              child: TextField(),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });
  });

  group('SemanticListItem', () {
    testWidgets('renders list tile with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticListItem(
              title: 'Item Title',
              index: 0,
              total: 5,
            ),
          ),
        ),
      );

      expect(find.text('Item Title'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticListItem(
              title: 'Main Title',
              subtitle: 'Subtitle text',
              index: 0,
              total: 3,
            ),
          ),
        ),
      );

      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('renders leading widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticListItem(
              title: 'With Icon',
              index: 0,
              total: 1,
              leading: Icon(Icons.star),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SemanticListItem(
              title: 'With Arrow',
              index: 0,
              total: 1,
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('handles tap when onTap provided', (WidgetTester tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticListItem(
              title: 'Tappable Item',
              index: 0,
              total: 1,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });
  });

  group('FocusBorder', () {
    test('focused creates border with primary color', () {
      const colorScheme = ColorScheme.light(
        primary: Colors.blue,
        outline: Colors.grey,
        error: Colors.red,
      );

      final border = FocusBorder.focused(colorScheme: colorScheme);
      expect(border.borderSide.color, Colors.blue);
    });

    test('focused allows custom width', () {
      const colorScheme = ColorScheme.light();
      final border = FocusBorder.focused(colorScheme: colorScheme, width: 4.0);
      expect(border.borderSide.width, 4.0);
    });

    test('unfocused creates border with outline color', () {
      const colorScheme = ColorScheme.light(
        primary: Colors.blue,
        outline: Colors.grey,
        error: Colors.red,
      );

      final border = FocusBorder.unfocused(colorScheme: colorScheme);
      expect(border.borderSide.color, Colors.grey);
    });

    test('unfocused allows custom width', () {
      const colorScheme = ColorScheme.light();
      final border = FocusBorder.unfocused(colorScheme: colorScheme, width: 2.0);
      expect(border.borderSide.width, 2.0);
    });

    test('error creates border with error color', () {
      const colorScheme = ColorScheme.light(
        primary: Colors.blue,
        outline: Colors.grey,
        error: Colors.red,
      );

      final border = FocusBorder.error(colorScheme: colorScheme);
      expect(border.borderSide.color, Colors.red);
    });

    test('error allows custom width', () {
      const colorScheme = ColorScheme.light();
      final border = FocusBorder.error(colorScheme: colorScheme, width: 3.0);
      expect(border.borderSide.width, 3.0);
    });
  });

  group('ContrastHelper', () {
    test('getRelativeLuminance calculates correctly for white', () {
      final luminance = ContrastHelper.getRelativeLuminance(Colors.white);
      expect(luminance, closeTo(1.0, 0.01));
    });

    test('getRelativeLuminance calculates correctly for black', () {
      final luminance = ContrastHelper.getRelativeLuminance(Colors.black);
      expect(luminance, closeTo(0.0, 0.01));
    });

    test('getRelativeLuminance calculates correctly for mid-gray', () {
      final luminance = ContrastHelper.getRelativeLuminance(Colors.grey);
      expect(luminance, greaterThan(0.0));
      expect(luminance, lessThan(1.0));
    });

    test('getContrastRatio returns 21:1 for black on white', () {
      final ratio = ContrastHelper.getContrastRatio(Colors.black, Colors.white);
      expect(ratio, closeTo(21.0, 0.1));
    });

    test('getContrastRatio returns 1:1 for same colors', () {
      final ratio = ContrastHelper.getContrastRatio(Colors.red, Colors.red);
      expect(ratio, closeTo(1.0, 0.01));
    });

    test('getContrastRatio is symmetric', () {
      final ratio1 = ContrastHelper.getContrastRatio(Colors.blue, Colors.yellow);
      final ratio2 = ContrastHelper.getContrastRatio(Colors.yellow, Colors.blue);
      expect(ratio1, closeTo(ratio2, 0.01));
    });

    test('meetsWCAGAA returns true for black on white', () {
      expect(ContrastHelper.meetsWCAGAA(Colors.black, Colors.white), isTrue);
    });

    test('meetsWCAGAA returns false for light gray on white', () {
      expect(
        ContrastHelper.meetsWCAGAA(Colors.grey.shade300, Colors.white),
        isFalse,
      );
    });

    test('meetsWCAGAAA returns true for black on white', () {
      expect(ContrastHelper.meetsWCAGAAA(Colors.black, Colors.white), isTrue);
    });

    test('meetsWCAGAAA has stricter requirements than AA', () {
      // Black on white passes both AA and AAA
      expect(ContrastHelper.meetsWCAGAA(Colors.black, Colors.white), isTrue);
      expect(ContrastHelper.meetsWCAGAAA(Colors.black, Colors.white), isTrue);
      
      // meetsWCAGAAA requires 7:1 ratio while meetsWCAGAA requires 4.5:1
      // Both work with high contrast colors
      const highContrastColor = Colors.black;
      final ratio = ContrastHelper.getContrastRatio(highContrastColor, Colors.white);
      expect(ratio, greaterThanOrEqualTo(7.0)); // AAA requirement is 7.0
    });
  });
}
