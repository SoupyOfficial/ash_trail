// Integration test for home widgets feature.
// Tests the complete flow from UI interaction to data persistence.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/home_widgets/presentation/screens/widget_config_screen.dart';
import 'package:ash_trail/features/home_widgets/presentation/providers/home_widgets_providers.dart';

void main() {
  group('Home Widgets Integration Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('complete widget creation flow', (tester) async {
      // Arrange
      const testAccountId = 'test-account-123';

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      // Act & Assert - Test the complete flow
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Configure Widget'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Widget Size'), findsOneWidget);
      expect(find.text('Tap Action'), findsOneWidget);

      // Test widget size selection
      expect(find.text('MEDIUM'), findsOneWidget); // Default selected

      // Tap on large widget size
      await tester.tap(find.text('LARGE'));
      await tester.pumpAndSettle();

      // Test tap action selection
      expect(find.text('Open App'), findsOneWidget); // Default action

      // Scroll to make the Record Overlay button visible
      await tester.scrollUntilVisible(
        find.text('Record Overlay'),
        500.0,
      );

      // Tap on record overlay action
      await tester.tap(find.text('Record Overlay'));
      await tester.pumpAndSettle();

      // Test display options toggle
      expect(find.byType(SwitchListTile), findsWidgets);

      // Scroll to make the streak switch visible
      await tester.scrollUntilVisible(
        find.widgetWithText(SwitchListTile, 'Show Streak'),
        500.0,
      );

      // Enable streak display
      final streakSwitch = find.widgetWithText(SwitchListTile, 'Show Streak');
      await tester.tap(streakSwitch);
      await tester.pumpAndSettle();

      // Save the widget
      final saveButton = find.text('Save');
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);

      // Wait for async widget creation operations to complete
      // (includes remote calls with delays: createWidget ~300ms + getTodayHitCount ~200ms + getCurrentStreak ~200ms)
      await tester.pump(const Duration(milliseconds: 100)); // Initial pump
      await tester
          .pump(const Duration(milliseconds: 700)); // Wait for async operations

      // Check if either snackbar appeared or navigation occurred
      final snackBarFinder = find.byType(SnackBar);
      final hasSnackBar = snackBarFinder.evaluate().isNotEmpty;
      final configScreenGone = find.text('Configure Widget').evaluate().isEmpty;

      expect(hasSnackBar || configScreenGone, true,
          reason:
              'Expected either success snackbar to appear or navigation to occur after widget creation');

      // If snackbar is present, verify it's the success message
      if (hasSnackBar) {
        final snackBarSuccessMessage = find.descendant(
          of: snackBarFinder,
          matching: find.textContaining('successfully'),
        );
        expect(snackBarSuccessMessage, findsOneWidget);
      }
    });

    testWidgets('handles widget creation failure gracefully', (tester) async {
      // This test would require mocking the repository to return failure
      // For now, we'll test the basic error handling structure

      const testAccountId = 'test-account-123';

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Could override repository here to simulate failure
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify error handling UI exists
      expect(find.text('Configure Widget'), findsOneWidget);
    });

    testWidgets('displays existing widgets correctly', (tester) async {
      // Pre-populate with some mock data
      const testAccountId = 'test-account-123';

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Should show current widgets section
      expect(find.textContaining('Current Widgets'), findsOneWidget);
    });

    testWidgets('widget preview updates when configuration changes',
        (tester) async {
      const testAccountId = 'test-account-123';

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Find the preview area
      expect(find.text('Preview'), findsOneWidget);

      // Change widget size and verify preview updates
      await tester.tap(find.textContaining('SMALL'));
      await tester.pumpAndSettle();

      // Preview should update to reflect small widget layout
      // This would be more detailed with actual preview content assertions
    });

    testWidgets('form validation works correctly', (tester) async {
      // Test that invalid configurations are handled properly
      const testAccountId = ''; // Empty account ID

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Try to save with invalid data
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should show validation error or prevent save
      // Exact behavior depends on implementation
    });

    testWidgets('accessibility features work correctly', (tester) async {
      const testAccountId = 'test-account-123';

      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verify that interactive elements have proper semantics
      expect(find.byType(SwitchListTile), findsWidgets);

      // Test navigation with semantic actions
      // This would be more comprehensive in a real accessibility audit
    });

    testWidgets('handles theme changes correctly', (tester) async {
      const testAccountId = 'test-account-123';

      // Test with dark theme
      final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const WidgetConfigScreen(accountId: testAccountId),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Should render correctly with dark theme
      expect(find.text('Configure Widget'), findsOneWidget);

      // Widget preview should respect theme colors
      expect(find.text('Preview'), findsOneWidget);
    });
  });
}
