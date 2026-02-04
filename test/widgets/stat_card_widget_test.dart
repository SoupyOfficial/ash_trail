import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/home_widgets/stat_card_widget.dart';

void main() {
  group('StatCardWidget', () {
    testWidgets('displays title and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Test Title',
              value: '42',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Title',
              value: '100',
              subtitle: 'Some subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Some subtitle'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'With Icon',
              value: '50',
              icon: Icons.access_time,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('does not display icon when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'No Icon',
              value: '25',
            ),
          ),
        ),
      );

      // Should not find any Icon widgets except maybe system icons
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('handles tap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Tappable',
              value: '10',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(StatCardWidget));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('handles long press callback', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Long Pressable',
              value: '20',
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(StatCardWidget));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('applies custom accent color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Custom Color',
              value: '75',
              icon: Icons.star,
              accentColor: Colors.orange,
            ),
          ),
        ),
      );

      // Widget should build without errors
      expect(find.byType(StatCardWidget), findsOneWidget);
    });

    testWidgets('displays trend widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'With Trend',
              value: '150',
              trendWidget: TrendIndicator(percentChange: 15.0),
            ),
          ),
        ),
      );

      expect(find.byType(TrendIndicator), findsOneWidget);
    });

    testWidgets('is wrapped in a Card widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'Card Test',
              value: '5',
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('is tappable with InkWell when onTap is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'With Tap',
              value: '10',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });
  });

  group('TrendIndicator', () {
    testWidgets('shows nothing for zero change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: 0),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsNothing);
      expect(find.byIcon(Icons.trending_down), findsNothing);
    });

    testWidgets('shows up arrow for positive change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: 25.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+25%'), findsOneWidget);
    });

    testWidgets('shows down arrow for negative change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: -30.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('formats percentage without decimals', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: 15.7),
          ),
        ),
      );

      // Should round to nearest integer
      expect(find.text('+16%'), findsOneWidget);
    });

    testWidgets('invertColors reverses color meaning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(
              percentChange: 10.0,
              invertColors: true,
            ),
          ),
        ),
      );

      // Widget should still display correctly
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('displays small decimal changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: 0.3),
          ),
        ),
      );

      // 0.3 rounds to 0, which should show nothing... or should show +0%
      // Based on the code, it checks percentChange == 0, so 0.3 != 0 will render
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+0%'), findsOneWidget);
    });

    testWidgets('handles large percentage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: 500.0),
          ),
        ),
      );

      expect(find.text('+500%'), findsOneWidget);
    });

    testWidgets('handles negative percentage display', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TrendIndicator(percentChange: -100.0),
          ),
        ),
      );

      // Negative shows absolute value without minus sign
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('StatCardRow', () {
    testWidgets('displays single child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardRow(
              children: [
                StatCardWidget(title: 'Single', value: '1'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StatCardWidget), findsOneWidget);
    });

    testWidgets('displays multiple children', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardRow(
              children: [
                StatCardWidget(title: 'First', value: '1'),
                StatCardWidget(title: 'Second', value: '2'),
                StatCardWidget(title: 'Third', value: '3'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(StatCardWidget), findsNWidgets(3));
    });

    testWidgets('uses expanded children for equal spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardRow(
              children: [
                StatCardWidget(title: 'A', value: '10'),
                StatCardWidget(title: 'B', value: '20'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Expanded), findsNWidgets(2));
    });

    testWidgets('wraps content in Row widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardRow(
              children: [
                StatCardWidget(title: 'Test', value: '5'),
              ],
            ),
          ),
        ),
      );

      // StatCardRow builds a Row
      expect(find.ancestor(
        of: find.byType(StatCardWidget),
        matching: find.byType(Row),
      ), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty children list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardRow(children: []),
          ),
        ),
      );

      expect(find.byType(StatCardRow), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1));
    });
  });
}
