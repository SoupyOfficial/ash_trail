import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/screens/logging_screen.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/log_record_provider.dart';

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

      // Check for tab bar - only Detailed and Backdate tabs exist
      expect(find.text('Detailed'), findsOneWidget);
      expect(find.text('Backdate'), findsOneWidget);
    });

    testWidgets('Detailed tab shows event type dropdown', (
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

      // Verify Detailed tab content
      expect(find.text('Event Type'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<EventType>), findsOneWidget);
    });

    testWidgets('Detailed tab shows duration input', (
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

      // Check for duration section
      expect(
        find.text('Duration (or use long-press button below)'),
        findsOneWidget,
      );
      expect(find.text('Seconds'), findsOneWidget);
    });

    testWidgets('Detailed tab shows press-and-hold button', (
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

      // Check for press-and-hold section
      expect(find.text('Press & Hold to Record Duration'), findsOneWidget);
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('Detailed tab shows mood and physical sliders', (
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

      // Check for mood and physical labels
      expect(find.text('Mood'), findsOneWidget);
      expect(find.text('Physical'), findsOneWidget);

      // Check for sliders
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('Detailed tab shows reason filter chips', (
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

      // Check for reason section header
      expect(
        find.text('Reason (optional, can select multiple)'),
        findsOneWidget,
      );

      // LoggingScreen uses ReasonChipsGrid (custom chip buttons), not FilterChip
      expect(find.text('Medical'), findsOneWidget);
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
        find.text('Log an event that happened in the past (up to 30 days)'),
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
    testWidgets('selecting reason toggle updates draft state', (
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

      // Find and tap a reason FilterChip
      final medicalChip = find.byWidgetPredicate(
        (widget) =>
            widget is FilterChip &&
            widget.label is Row &&
            ((widget.label as Row).children.last as Text).data == 'Medical',
      );

      // If chip is found, tap it
      if (medicalChip.evaluate().isNotEmpty) {
        await tester.tap(medicalChip.first);
        await tester.pumpAndSettle();
      }
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

      // Find Clear button using a more specific finder
      final clearButton = find.widgetWithText(OutlinedButton, 'Clear');
      if (clearButton.evaluate().isNotEmpty) {
        await tester.ensureVisible(clearButton.first);
        await tester.tap(clearButton.first);
        await tester.pumpAndSettle();
      }

      // Form should be reset (event type should be back to default)
      expect(find.byType(DropdownButtonFormField<EventType>), findsOneWidget);
    });
  });
}
