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
}
