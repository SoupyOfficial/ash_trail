import 'package:patrol/patrol.dart';

import 'components/home.dart';
import 'components/nav_bar.dart';
import 'components/history.dart';
import 'components/analytics.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Main E2E test suite — exercises the core app flows on iOS.
///
/// Covers: login, home screen, navigation, and quick-log.
///
/// Run with:
///   patrol test --target integration_test/app_e2e_test.dart
///   ./scripts/run_e2e_tests.sh

void main() {
  patrolTest(
    'Login and verify home screen',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      home.verifyVisible();
      home.verifyQuickLogVisible();
      await takeScreenshot($, 'e2e_home_after_login');
    },
  );

  patrolTest(
    'Navigate through all tabs',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final home = HomeComponent($);
      final history = HistoryComponent($);
      final analytics = AnalyticsComponent($);

      // Home (already on this tab after login)
      nav.verifyVisible();
      home.verifyVisible();
      await takeScreenshot($, 'e2e_tab_home');

      // Analytics
      await nav.tapAnalytics();
      await analytics.waitUntilVisible();
      analytics.verifyVisible();
      await takeScreenshot($, 'e2e_tab_analytics');

      // History
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await takeScreenshot($, 'e2e_tab_history');

      // Back to Home
      await nav.tapHome();
      await home.waitUntilVisible();
      home.verifyVisible();
      await takeScreenshot($, 'e2e_tab_home_return');
    },
  );

  patrolTest(
    'Quick log via hold-to-record',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final home = HomeComponent($);
      home.verifyQuickLogVisible();

      await home.holdToRecord(duration: const Duration(seconds: 3));
      await handlePermissionDialogs($);

      // Wait for confirmation UI
      await $.pump(const Duration(seconds: 2));
      await takeScreenshot($, 'e2e_quick_log_result');
    },
  );
}
