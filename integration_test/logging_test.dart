import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'components/logging.dart';
import 'components/nav_bar.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Logging screen E2E tests — tabs, buttons, form visibility.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/logging_test.dart

void main() {
  patrolTest(
    'Logging screen loads with tabs',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final logging = LoggingComponent($);

      await nav.tapLog();
      // Logging screen may trigger location permission
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();
      logging.verifyVisible();
      logging.verifyTabsVisible();
      await takeScreenshot($, 'logging_screen_with_tabs');
    },
  );

  patrolTest(
    'Log Event and Clear buttons exist',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final logging = LoggingComponent($);

      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();

      expect(
        logging.logEventButton,
        findsOneWidget,
        reason: 'Log Event button should be visible',
      );
      expect(
        logging.clearButton,
        findsOneWidget,
        reason: 'Clear button should be visible',
      );
      await takeScreenshot($, 'logging_buttons_visible');
    },
  );

  patrolTest(
    'Can switch between Detailed and Backdate tabs',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final logging = LoggingComponent($);

      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();

      await logging.tapBackdateTab();
      await $.pump(const Duration(seconds: 1));
      logging.verifyVisible();
      await takeScreenshot($, 'logging_backdate_tab');

      await logging.tapDetailedTab();
      await $.pump(const Duration(seconds: 1));
      logging.verifyVisible();
      await takeScreenshot($, 'logging_detailed_tab');
    },
  );
}
