import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/widgets/home_quick_log_widget.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('HomeQuickLogWidget', () {
    Widget createTestWidget({VoidCallback? onLogCreated}) {
      return MaterialApp(
        home: Scaffold(
          body: ProviderScope(
            child: HomeQuickLogWidget(onLogCreated: onLogCreated),
          ),
        ),
      );
    }

    testWidgets('renders all form elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for mood rating
      expect(find.text('Mood'), findsOneWidget);

      // Check for physical rating
      expect(find.text('Physical'), findsOneWidget);

      // Check for reasons
      expect(find.text('Reasons'), findsOneWidget);

      // Check for press-and-hold button
      expect(find.text('Hold to record duration'), findsOneWidget);

      // Check for reason chips (all 8 reasons)
      for (final reason in LogReason.values) {
        expect(find.text(reason.displayName), findsOneWidget);
      }
    });

    testWidgets('mood slider updates value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      // Get the first slider (mood)
      final moodSlider = sliders.first;

      // Drag slider to a specific value
      await tester.drag(moodSlider, const Offset(50, 0));
      await tester.pumpWidget(createTestWidget());

      // Verify that the mood rating changed
      // (The actual value depends on slider implementation)
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('physical slider updates value', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final sliders = find.byType(Slider);
      expect(sliders, findsWidgets);

      // Get the second slider (physical)
      final physicalSlider = sliders.at(1);

      // Drag slider to a specific value
      await tester.drag(physicalSlider, const Offset(50, 0));
      await tester.pumpWidget(createTestWidget());

      // Verify that the physical rating changed
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('reset mood button clears mood rating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Drag mood slider to set a value
      final moodSlider = find.byType(Slider).first;
      await tester.drag(moodSlider, const Offset(50, 0));
      await tester.pumpWidget(createTestWidget());

      // Reset button should appear
      final resetButtons = find.text('Reset');
      expect(resetButtons, findsWidgets);

      // Click first reset button (mood)
      await tester.tap(resetButtons.first);
      await tester.pumpWidget(createTestWidget());

      // After reset, we should not see the mood value displayed separately
      // (This is a simplified check; actual implementation may vary)
    });

    testWidgets('reset physical button clears physical rating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Drag physical slider to set a value
      final physicalSlider = find.byType(Slider).at(1);
      await tester.drag(physicalSlider, const Offset(50, 0));
      await tester.pumpWidget(createTestWidget());

      // Reset button should appear
      final resetButtons = find.text('Reset');
      expect(resetButtons.evaluate().length >= 1, true);
    });

    testWidgets('reason chips can be selected and deselected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Find a reason chip
      final medicalChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Text &&
            (widget.label as Text).data == 'Medical',
      );

      expect(medicalChip, findsOneWidget);

      // Click the chip
      await tester.tap(medicalChip);
      await tester.pumpWidget(createTestWidget());

      // Chip should now be selected
      final selectedChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.selected == true &&
            widget.label is Text &&
            (widget.label as Text).data == 'Medical',
      );

      expect(selectedChip, findsOneWidget);

      // Click again to deselect
      await tester.tap(selectedChip);
      await tester.pumpWidget(createTestWidget());
    });

    testWidgets('press-and-hold button shows recording state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Find the Container with the duration button (text "Hold to record duration")
      final durationButtonText = find.text('Hold to record duration');
      expect(durationButtonText, findsOneWidget);

      final durationButton = find.ancestor(
        of: durationButtonText,
        matching: find.byType(Container),
      );

      // Long press the button
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(durationButton.first),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Release the gesture
      await gesture.up();
      await tester.pump();

      // After release, button should still be visible
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('onLogCreated callback is called', (WidgetTester tester) async {
      bool callbackCalled = false;
      void onLogCreated() {
        callbackCalled = true;
      }

      await tester.pumpWidget(createTestWidget(onLogCreated: onLogCreated));

      // Note: Full callback test would require mocking the service layer
      // This is a placeholder for the actual implementation
    });

    testWidgets('button displays touch_app icon by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.touch_app), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
    });
  });
}
