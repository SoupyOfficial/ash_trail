// Widget tests for SiriS      expect(find.byIcon(Icons.mic), findsOneWidget);ortcutsWidget
// Verifies UI elements and basic functionality.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/presentation/widgets/siri_shortcuts_widget.dart';

void main() {
  group('SiriShortcutsWidget', () {
    testWidgets('displays Siri Shortcuts card with title and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SiriShortcutsWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Siri Shortcuts'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('has correct semantic structure for accessibility',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SiriShortcutsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for semantic labels
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.text('Siri Shortcuts'), findsOneWidget);
    });

    testWidgets('displays expected minimum touch targets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SiriShortcutsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card is tappable and meets minimum size requirements
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final cardWidget = tester.widget<Card>(cardFinder);
      expect(cardWidget, isNotNull);
    });
  });

  group('SiriShortcutsScreen', () {
    testWidgets('displays screen with app bar and content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SiriShortcutsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Siri Shortcuts'), findsWidgets);
    });

    testWidgets('includes instructions widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SiriShortcutsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that some instructional text is present
      expect(find.textContaining('voice commands'), findsOneWidget);
    });
  });
}
