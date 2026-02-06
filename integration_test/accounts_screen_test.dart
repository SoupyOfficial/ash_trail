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
        // Use pump instead of pumpAndSettle for apps with continuous timers
        await $.pump(const Duration(seconds: 2));

        // Skip if on auth screen
        if ($('Sign in').exists || $('Continue with Google').exists) {
          return;
        }

        // Navigate to Accounts screen: tap account icon (by Key or icon)
        if ($(Key('app_bar_account')).exists) {
          await $(Key('app_bar_account')).tap(settlePolicy: SettlePolicy.noSettle);
        } else if ($(Icons.account_circle).exists) {
          await $(Icons.account_circle).tap(settlePolicy: SettlePolicy.noSettle);
        } else {
          return;
        }
        await $.pump(const Duration(seconds: 2));

        // Verify we're on Accounts screen
        expect($('Accounts').exists, isTrue);

        await $.pump(const Duration(seconds: 2));

        // No loading spinner when loading completes
        expect($(CircularProgressIndicator).exists, isFalse);

        // Page has content: account list, empty state, or add account
        final hasAccountsList = $(Card).exists;
        final hasEmptyState = $('No Accounts').exists;
        final hasAddAccount =
            $(Key('accounts_add_account')).exists ||
            $('Add Another Account').exists;

        expect(
          hasAccountsList || hasEmptyState || hasAddAccount,
          isTrue,
          reason:
              'Accounts page should display either account list, empty state, or add account',
        );

        if (hasAccountsList) {
          expect($(ListTile).exists, isTrue);
        }
      },
    );

    patrolTest(
      'Can tap Add account button to navigate to login',
      tags: ['auth', 'accounts'],
      ($) async {
        app.main();
        await $.pump(const Duration(seconds: 2));

        // Skip if on auth screen
        if ($('Sign in').exists || $('Continue with Google').exists) {
          return;
        }

        // Navigate to Accounts screen
        if ($(Key('app_bar_account')).exists) {
          await $(Key('app_bar_account')).tap(settlePolicy: SettlePolicy.noSettle);
        } else if ($(Icons.account_circle).exists) {
          await $(Icons.account_circle).tap(settlePolicy: SettlePolicy.noSettle);
        } else {
          return;
        }
        await $.pump(const Duration(seconds: 2));

        // Tap Add account (by Key or text)
        if ($(Key('accounts_add_account')).exists) {
          await $(Key('accounts_add_account')).tap(settlePolicy: SettlePolicy.noSettle);
        } else if ($('Add Another Account').exists) {
          await $('Add Another Account').tap(settlePolicy: SettlePolicy.noSettle);
        } else {
          expect(false, isTrue, reason: 'Add account button not found');
        }
        await $.pump(const Duration(seconds: 2));

        // Should be on login/sign-in screen
        final hasLoginElements =
            $(TextField).exists || $('Sign in').exists || $('Email').exists;
        expect(
          hasLoginElements,
          isTrue,
          reason:
              'Should navigate to login/sign-in screen after tapping Add account',
        );
      },
    );

    patrolTest(
      'Account cards have proper visual hierarchy',
      tags: ['accounts'],
      ($) async {
        app.main();
        await $.pump(const Duration(seconds: 2));

        if ($('Sign in').exists || $('Continue with Google').exists) {
          return;
        }

        // Navigate to Accounts screen
        if ($(Key('app_bar_account')).exists) {
          await $(Key('app_bar_account')).tap(settlePolicy: SettlePolicy.noSettle);
        } else if ($(Icons.account_circle).exists) {
          await $(Icons.account_circle).tap(settlePolicy: SettlePolicy.noSettle);
        } else {
          return;
        }
        await $.pump(const Duration(seconds: 2));

        // Verify accounts screen
        expect($('Accounts').exists, isTrue);

        // Check for logged-in accounts section if accounts exist
        if ($(Key('account_card_0')).exists || $(Card).exists) {
          // Should show "Logged In" section header
          final hasLoggedInSection = $('Logged In').exists;

          // Account cards should have avatars
          final hasAvatars = $(CircleAvatar).exists;

          expect(
            hasLoggedInSection || hasAvatars,
            isTrue,
            reason: 'Account cards should display proper visual hierarchy',
          );
        }
      },
    );

    patrolTest(
      'Active account is clearly indicated',
      tags: ['accounts'],
      ($) async {
        app.main();
        await $.pump(const Duration(seconds: 2));

        if ($('Sign in').exists || $('Continue with Google').exists) {
          return;
        }

        // Navigate to Accounts screen
        if ($(Key('app_bar_account')).exists) {
          await $(Key('app_bar_account')).tap(settlePolicy: SettlePolicy.noSettle);
        } else if ($(Icons.account_circle).exists) {
          await $(Icons.account_circle).tap(settlePolicy: SettlePolicy.noSettle);
        } else {
          return;
        }
        await $.pump(const Duration(seconds: 2));

        // If we have account cards, one should be marked as active
        if ($(Key('account_card_0')).exists) {
          // Look for "Active" indicator text
          final hasActiveIndicator = $('Active').exists || $('Active •').exists;

          expect(
            hasActiveIndicator,
            isTrue,
            reason: 'Active account should have visible indicator',
          );
        }
      },
    );
  });
}
