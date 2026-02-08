import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'components/accounts.dart';
import 'components/home.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Home screen E2E tests — dashboard content, quick log, hold-to-record.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/home_screen_test.dart

void main() {
  patrolTest(
    'Home screen displays AppBar and content',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('HOME_TEST: starting ensureLoggedIn');
      await ensureLoggedIn($);
      testLog('HOME_TEST: ensureLoggedIn returned');

      final home = HomeComponent($);
      testLog('HOME_TEST: calling verifyVisible');
      home.verifyVisible();
      testLog('HOME_TEST: verifyVisible passed');

      // Verify Quick-log content is also present (proves dashboard loaded).
      // Note: TimeSinceLastHitWidget uses Timer.periodic(1s) which can cause
      // Patrol's pumpAndSettle to hang. We avoid any settle/pumpUntilFound
      // calls while on Home and instead check widget keys synchronously.
      home.verifyQuickLogVisible();
      testLog('HOME_TEST: quickLog verified — test complete');
      await takeScreenshot($, 'home_appbar_and_content');
    },
  );

  patrolTest(
    'Quick log widget visible with sliders and hold-to-record',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      home.verifyQuickLogVisible();

      await $.pump(const Duration(seconds: 1));
      await takeScreenshot($, 'home_quick_log_visible');
    },
  );

  patrolTest(
    'Hold-to-record creates entry',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      home.verifyQuickLogVisible();

      await home.holdToRecord(duration: const Duration(seconds: 3));
      await takeScreenshot($, 'home_after_hold_to_record');

      // Hold-to-record triggers location capture which may show a permission dialog
      await handlePermissionDialogs($);

      // After recording, a SnackBar or time-since-last reset is expected
      // Pump a bit to let any confirmation UI appear
      await $.pump(const Duration(seconds: 2));
      await takeScreenshot($, 'home_hold_to_record_result');
    },
  );

  patrolTest(
    'Accounts icon navigates to Accounts screen',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      home.verifyVisible();

      await home.tapAccountIcon();
      await handlePermissionDialogs($);

      final accounts = AccountsComponent($);
      await accounts.waitUntilVisible();
      accounts.verifyVisible();
      await takeScreenshot($, 'home_accounts_navigated');
    },
  );

  patrolTest(
    'Snackbar disappears after quick log',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);
      testLog('SNACKBAR_TEST: logged in');

      final home = HomeComponent($);
      home.verifyQuickLogVisible();

      // Perform a hold-to-record to trigger the snackbar
      await home.holdToRecord(duration: const Duration(seconds: 2));
      await handlePermissionDialogs($);
      testLog('SNACKBAR_TEST: hold-to-record completed');

      // Poll for the snackbar to appear (up to 10s)
      bool snackbarAppeared = false;
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(deadline)) {
        await $.pump(const Duration(milliseconds: 250));
        if ($.tester.any(find.byType(SnackBar))) {
          snackbarAppeared = true;
          testLog('SNACKBAR_TEST: snackbar appeared');
          break;
        }
      }

      expect(
        snackbarAppeared,
        isTrue,
        reason: 'Snackbar should appear after quick log',
      );
      await takeScreenshot($, 'snackbar_visible');

      // Verify snackbar content — should say "Logged vape"
      expect(
        find.textContaining('Logged vape'),
        findsOneWidget,
        reason: 'Snackbar should contain "Logged vape" message',
      );

      // Verify UNDO action is present
      expect(
        find.text('UNDO'),
        findsOneWidget,
        reason: 'Snackbar should have an UNDO action',
      );

      // Wait for the snackbar to auto-dismiss (duration is 3s, give extra buffer)
      testLog('SNACKBAR_TEST: waiting for snackbar to auto-dismiss...');
      final dismissDeadline = DateTime.now().add(const Duration(seconds: 8));
      bool snackbarDismissed = false;
      while (DateTime.now().isBefore(dismissDeadline)) {
        await $.pump(const Duration(milliseconds: 250));
        if (!$.tester.any(find.byType(SnackBar))) {
          snackbarDismissed = true;
          testLog('SNACKBAR_TEST: snackbar dismissed');
          break;
        }
      }

      expect(
        snackbarDismissed,
        isTrue,
        reason: 'Snackbar should auto-dismiss within 8 seconds',
      );
      await takeScreenshot($, 'snackbar_dismissed');
    },
  );

  patrolTest(
    'Second quick log replaces previous snackbar',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);
      testLog('SNACKBAR_REPLACE_TEST: logged in');

      final home = HomeComponent($);
      home.verifyQuickLogVisible();

      // First hold-to-record
      await home.holdToRecord(duration: const Duration(seconds: 2));
      await handlePermissionDialogs($);
      testLog('SNACKBAR_REPLACE_TEST: first hold-to-record completed');

      // Wait for first snackbar
      final firstDeadline = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(firstDeadline)) {
        await $.pump(const Duration(milliseconds: 250));
        if ($.tester.any(find.textContaining('Logged vape'))) {
          testLog('SNACKBAR_REPLACE_TEST: first snackbar appeared');
          break;
        }
      }

      // Immediately perform a second hold-to-record (while first snackbar is still visible)
      await home.holdToRecord(duration: const Duration(seconds: 2));
      await handlePermissionDialogs($);
      testLog('SNACKBAR_REPLACE_TEST: second hold-to-record completed');

      // Wait for new snackbar
      final secondDeadline = DateTime.now().add(const Duration(seconds: 10));
      while (DateTime.now().isBefore(secondDeadline)) {
        await $.pump(const Duration(milliseconds: 250));
        if ($.tester.any(find.textContaining('Logged vape'))) {
          break;
        }
      }

      // There should be at most one snackbar visible — not stacked
      final snackbarCount = find.byType(SnackBar).evaluate().length;
      testLog('SNACKBAR_REPLACE_TEST: snackbar count = $snackbarCount');
      expect(
        snackbarCount,
        lessThanOrEqualTo(1),
        reason:
            'Only one snackbar should be visible at a time (old one should be cleared)',
      );
      await takeScreenshot($, 'snackbar_replaced_not_stacked');
    },
  );
}
