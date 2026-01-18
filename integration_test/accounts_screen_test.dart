import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Accounts Screen Tests', () {
    testWidgets('Accounts page loads without spinner and displays accounts', (
      WidgetTester tester,
    ) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Accounts screen by tapping the account icon in the app bar
      // First check if we're on Home or Welcome screen
      final accountButtonFinder = find.byIcon(Icons.account_circle);

      if (accountButtonFinder.evaluate().isNotEmpty) {
        // We're on Home screen, tap account button
        await tester.tap(accountButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      } else {
        // Might be on Welcome screen, look for Sign In or navigation option
        final signInButton = find.byType(ElevatedButton).first;
        if (signInButton.evaluate().isNotEmpty) {
          await tester.tap(signInButton);
          await tester.pumpAndSettle(const Duration(seconds: 3));
        }
      }

      // Verify we're on Accounts screen
      expect(find.text('Accounts'), findsWidgets);

      // Wait for the accounts stream to emit data
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify there is NO loading spinner (CircularProgressIndicator)
      // The loading spinner should NOT be visible
      final spinnerFinder = find.byType(CircularProgressIndicator);
      expect(
        spinnerFinder,
        findsNothing,
        reason:
            'Accounts screen should not show spinner when loading completes',
      );

      // Verify the page has rendered content (either accounts or empty state)
      // Look for either account cards or the "No Accounts" message or "Add account" button
      final hasAccountsList = find.byType(Card).evaluate().isNotEmpty;
      final hasEmptyState = find.text('No Accounts').evaluate().isNotEmpty;
      final hasAddAccountButton =
          find.text('Add account').evaluate().isNotEmpty;

      expect(
        hasAccountsList || hasEmptyState || hasAddAccountButton,
        true,
        reason:
            'Accounts page should display either account list, empty state, or add account button',
      );

      // If there are accounts, verify at least one is shown
      if (hasAccountsList) {
        final accountCards = find.byType(Card);
        expect(
          accountCards,
          findsWidgets,
          reason: 'Should have at least one account card',
        );

        // Verify active account indicator or email text
        final accountText = find.byType(ListTile);
        expect(
          accountText,
          findsWidgets,
          reason: 'Should display account details',
        );
      }

      // Print success
      debugPrint('✓ Accounts screen loaded successfully without spinner');
    });

    testWidgets('Can tap Add account button to navigate to login', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Accounts screen
      final accountButtonFinder = find.byIcon(Icons.account_circle);
      if (accountButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(accountButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // Wait for accounts to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tap "Add account" button
      final addAccountButton = find.text('Add account');
      expect(addAccountButton, findsWidgets);
      await tester.tap(addAccountButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we navigated to login or sign-in screen
      // Look for common auth screen elements
      final hasLoginElements =
          find.byType(TextField).evaluate().isNotEmpty ||
          find.text('Sign in').evaluate().isNotEmpty ||
          find.text('Email').evaluate().isNotEmpty;

      expect(
        hasLoginElements,
        true,
        reason:
            'Should navigate to login/sign-in screen after tapping Add account',
      );

      debugPrint('✓ Add account navigation works correctly');
    });
  });
}
