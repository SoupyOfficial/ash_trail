import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'components/accounts.dart';
import 'components/home.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Accounts screen E2E tests — load, cards, add account.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// (Welcome vs Home) and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/accounts_test.dart

void main() {
  patrolTest(
    'Accounts screen loads without spinner',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      accounts.verifyVisible();
      await takeScreenshot($, 'accounts_screen_loaded');
    },
  );

  patrolTest(
    'Account card displays with active indicator',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();

      accounts.verifyAccountCount(1);
      expect(
        find.textContaining('Active'),
        findsOneWidget,
        reason: 'Active account indicator should be visible',
      );
      await takeScreenshot($, 'accounts_active_indicator');
    },
  );

  patrolTest(
    'Add account navigates to login',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();

      await accounts.tapAddAccount();
      await $.pump(const Duration(seconds: 2));

      // Should navigate to login screen for adding another account
      expect(
        find.byKey(const Key('email-input')),
        findsOneWidget,
        reason: 'Login screen should appear for adding new account',
      );
      await takeScreenshot($, 'accounts_add_account_login');
    },
  );
}
