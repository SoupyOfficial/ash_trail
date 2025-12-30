import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/logging_screen.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/providers/account_provider.dart';

void main() {
  group('LoggingScreen Widget Tests', () {
    testWidgets('shows no account message when no active account', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeAccountIdProvider.overrideWith((ref) => null)],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Log Event'), findsOneWidget);
      expect(find.text('Please select an account first'), findsOneWidget);
    });

    testWidgets('shows tabs when account is active', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Check for tab bar
      expect(find.text('Quick'), findsOneWidget);
      expect(find.text('Detailed'), findsOneWidget);
      expect(find.text('Backdate'), findsOneWidget);
    });

    testWidgets('Quick tab shows quick log content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Quick tab content - use findsAtLeastNWidgets for texts that may appear multiple times
      expect(find.text('Quick Log'), findsAtLeastNWidgets(1));
      expect(
        find.text('Tap for instant log • Long press for duration'),
        findsOneWidget,
      );
      expect(find.text('Templates'), findsOneWidget);
      expect(find.text('Quick Events'), findsOneWidget);
    });

    testWidgets('Quick tab shows event type chips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify quick event chips
      expect(find.text('Inhale'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Tolerance'), findsOneWidget);
      expect(find.text('Relief'), findsOneWidget);
    });

    testWidgets('can navigate to Detailed tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Verify Detailed tab content
      expect(find.text('Event Type'), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
      expect(find.text('Reason (optional)'), findsOneWidget);
      expect(find.text('How are you feeling?'), findsOneWidget);
      expect(find.text('Additional Details'), findsOneWidget);
    });

    testWidgets('Detailed tab shows mood and craving sliders', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Check for mood and craving labels
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Craving'), findsOneWidget);

      // Check for sliders
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('Detailed tab shows reason choice chips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Check for reason chips
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Medical'), findsOneWidget);
      expect(find.text('Recreational'), findsOneWidget);
      expect(find.text('Social'), findsOneWidget);
      expect(find.text('Stress Relief'), findsOneWidget);
    });

    testWidgets('Detailed tab has clear and submit buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Use findsAtLeastNWidgets since "Log Event" appears in both title and button
      expect(find.text('Clear'), findsOneWidget);
      expect(find.text('Log Event'), findsAtLeastNWidgets(1));
    });

    testWidgets('can navigate to Backdate tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Backdate tab
      await tester.tap(find.text('Backdate'));
      await tester.pumpAndSettle();

      // Verify Backdate tab content
      expect(find.text('Backdate Entry'), findsOneWidget);
      expect(
        find.text('Log an event that happened in the past'),
        findsOneWidget,
      );
      expect(find.text('Create Backdated Entry'), findsOneWidget);
    });

    testWidgets('Backdate tab shows info card', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Backdate tab
      await tester.tap(find.text('Backdate'));
      await tester.pumpAndSettle();

      // Check for info text
      expect(
        find.textContaining('Backdated entries are marked'),
        findsOneWidget,
      );
    });
  });

  group('LogDraft integration with UI', () {
    testWidgets('selecting reason updates draft state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Tap on Medical reason chip
      await tester.tap(find.text('Medical'));
      await tester.pumpAndSettle();

      // The Medical chip should now be selected (ChoiceChip behavior)
      final medicalChip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Medical'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(medicalChip.selected, true);
    });

    testWidgets('event type dropdown changes draft state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Find and tap the event type dropdown
      final dropdown = find.byType(DropdownButtonFormField<EventType>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select 'Note' from dropdown
      await tester.tap(find.text('Note').last);
      await tester.pumpAndSettle();
    });

    testWidgets('clear button resets form', (WidgetTester tester) async {
      // Use a larger screen size for this test
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountIdProvider.overrideWith((ref) => 'test-account-id'),
          ],
          child: const MaterialApp(home: LoggingScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Detailed tab
      await tester.tap(find.text('Detailed'));
      await tester.pumpAndSettle();

      // Select a reason chip to modify the draft state
      await tester.tap(find.text('Medical'));
      await tester.pumpAndSettle();

      // Verify Medical is selected
      final medicalChipBefore = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Medical'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(medicalChipBefore.selected, true);

      // Tap clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // None should now be selected
      final noneChip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('None'), matching: find.byType(ChoiceChip)),
      );
      expect(noneChip.selected, true);
    });
  });
}
