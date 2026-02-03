import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:ash_trail/main.dart' as app;

/// Patrol-based E2E tests for the Accounts screen.
/// Run with: patrol test --target integration_test/accounts_screen_test.dart
void main() {
  group('Accounts Screen Tests', () {
    patrolTest(
      'Accounts page loads without spinner and displays accounts',
      tags: ['smoke', 'accounts'],
      ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      // Navigate to Accounts screen: tap account icon (by Key or icon)
      if ($(Key('app_bar_account')).exists) {
        await $(Key('app_bar_account')).tap();
      } else if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
      } else {
        // Welcome screen: tap Sign In to get to login, or skip
        if ($(Key('sign_in_button')).exists) {
          await $(Key('sign_in_button')).tap();
          await $.pumpAndSettle(timeout: const Duration(seconds: 5));
        }
        return;
      }
      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      // Verify we're on Accounts screen
      expect($('Accounts').exists, isTrue);

      await $.pumpAndSettle(timeout: const Duration(seconds: 3));

      // No loading spinner when loading completes
      expect($(CircularProgressIndicator).exists, isFalse);

      // Page has content: account list, empty state, or add account
      final hasAccountsList = $(Card).exists;
      final hasEmptyState = $('No Accounts').exists;
      final hasAddAccount =
          $(Key('accounts_add_account')).exists || $('Add Another Account').exists;

      expect(
        hasAccountsList || hasEmptyState || hasAddAccount,
        isTrue,
        reason:
            'Accounts page should display either account list, empty state, or add account',
      );

      if (hasAccountsList) {
        expect($(ListTile).exists, isTrue);
      }
    });

    patrolTest(
      'Can tap Add account button to navigate to login',
      tags: ['auth', 'accounts'],
      ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      // Navigate to Accounts screen
      if ($(Key('app_bar_account')).exists) {
        await $(Key('app_bar_account')).tap();
      } else if ($(Icons.account_circle).exists) {
        await $(Icons.account_circle).tap();
      } else {
        return;
      }
      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      // Tap Add account (by Key or text)
      if ($(Key('accounts_add_account')).exists) {
        await $(Key('accounts_add_account')).tap();
      } else if ($('Add Another Account').exists) {
        await $('Add Another Account').tap();
      } else {
        expect(false, isTrue, reason: 'Add account button not found');
      }
      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      // Should be on login/sign-in screen
      final hasLoginElements =
          $(TextField).exists || $('Sign in').exists || $('Email').exists;
      expect(
        hasLoginElements,
        isTrue,
        reason:
            'Should navigate to login/sign-in screen after tapping Add account',
      );
    });
  });
}
