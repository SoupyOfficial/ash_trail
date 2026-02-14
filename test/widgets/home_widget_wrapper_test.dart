import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/home_widgets/home_widget_wrapper.dart';
import 'package:ash_trail/widgets/home_widgets/widget_catalog.dart';

void main() {
  group('HomeWidgetWrapper', () {
    testWidgets('displays child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: false,
              child: const Text('Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('does not show edit controls when not in edit mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: false,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Should not find drag handle or remove button icons
      expect(find.byIcon(Icons.drag_handle), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows drag handle in edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              key: const ValueKey('test'),
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: true,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });

    testWidgets('shows remove button in edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              key: const ValueKey('test'),
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: true,
              onRemove: () {},
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onRemove when remove button tapped', (tester) async {
      bool removed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              key: const ValueKey('test'),
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: true,
              onRemove: () => removed = true,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('displays widget name in edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              key: const ValueKey('test'),
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: true,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // The catalog entry for hitsToday has displayName "Hits Today"
      final entry = WidgetCatalog.getEntry(HomeWidgetType.hitsToday);
      expect(find.text(entry.displayName), findsOneWidget);
    });

    testWidgets('uses AnimatedContainer for transitions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              widgetId: 'test-widget',
              type: HomeWidgetType.quickLog,
              isEditMode: false,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('shows border when in edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              key: const ValueKey('test'),
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: true,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Find AnimatedContainer and verify it has decoration
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animatedContainer.decoration, isNotNull);
    });

    testWidgets('no border decoration when not in edit mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeWidgetWrapper(
              widgetId: 'test-widget',
              type: HomeWidgetType.hitsToday,
              isEditMode: false,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animatedContainer.decoration, isNull);
    });

    testWidgets('works with different widget types', (tester) async {
      // Test with several different widget types
      final types = [
        HomeWidgetType.timeSinceLastHit,
        HomeWidgetType.totalDurationToday,
        HomeWidgetType.quickLog,
        HomeWidgetType.recentEntries,
      ];

      for (final type in types) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeWidgetWrapper(
                widgetId: 'test-${type.name}',
                type: type,
                isEditMode: false,
                child: Text('Widget: ${type.name}'),
              ),
            ),
          ),
        );

        expect(find.text('Widget: ${type.name}'), findsOneWidget);
      }
    });
  });

  group('HomeWidgetEditPadding', () {
    testWidgets('displays child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeWidgetEditPadding(
              isEditMode: false,
              child: Text('Padded Content'),
            ),
          ),
        ),
      );

      expect(find.text('Padded Content'), findsOneWidget);
    });

    testWidgets('uses AnimatedPadding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeWidgetEditPadding(
              isEditMode: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedPadding), findsOneWidget);
    });

    testWidgets('applies no top padding when not in edit mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeWidgetEditPadding(
              isEditMode: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final animatedPadding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect(animatedPadding.padding, equals(const EdgeInsets.only(top: 0)));
    });

    testWidgets('applies top padding when in edit mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeWidgetEditPadding(
              isEditMode: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      final animatedPadding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect(animatedPadding.padding, equals(const EdgeInsets.only(top: 36)));
    });

    testWidgets('animates padding change', (tester) async {
      bool editMode = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: GestureDetector(
                  onTap: () => setState(() => editMode = !editMode),
                  child: HomeWidgetEditPadding(
                    isEditMode: editMode,
                    child: const Text('Content'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Initial state - no padding
      var animatedPadding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect(animatedPadding.padding, equals(const EdgeInsets.only(top: 0)));

      // Tap to toggle edit mode
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // After animation starts, padding target should be 36
      animatedPadding = tester.widget<AnimatedPadding>(
        find.byType(AnimatedPadding),
      );
      expect(animatedPadding.padding, equals(const EdgeInsets.only(top: 36)));

      // Complete animation
      await tester.pumpAndSettle();
    });
  });
}
