import 'package:patrol/patrol.dart';

import 'components/home.dart';
import 'components/nav_bar.dart';
import 'components/history.dart';
import 'components/analytics.dart';
import 'components/logging.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Navigation E2E tests — verify all nav tabs work and correct screens show.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/navigation_test.dart

void main() {
  patrolTest(
    'All 4 nav tabs reachable with correct screens',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final home = HomeComponent($);
      final history = HistoryComponent($);
      final analytics = AnalyticsComponent($);
      final logging = LoggingComponent($);

      // Already on Home
      nav.verifyVisible();
      home.verifyVisible();
      await takeScreenshot($, 'nav_home_tab');

      // Navigate to History
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await takeScreenshot($, 'nav_history_tab');

      // Navigate to Analytics
      await nav.tapAnalytics();
      await analytics.waitUntilVisible();
      analytics.verifyVisible();
      await takeScreenshot($, 'nav_analytics_tab');

      // Navigate to Log
      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();
      logging.verifyVisible();
      await takeScreenshot($, 'nav_logging_tab');

      // Navigate back to Home
      await nav.tapHome();
      await home.waitUntilVisible();
      home.verifyVisible();
      await takeScreenshot($, 'nav_back_to_home');
    },
  );

  patrolTest(
    'Rapid navigation cycle does not crash',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final home = HomeComponent($);

      // Cycle through tabs 3 times rapidly
      for (int i = 0; i < 3; i++) {
        await nav.tapHistory();
        await nav.tapAnalytics();
        await nav.tapLog();
        await nav.tapHome();
      }

      // Should still be on Home, no crash
      home.verifyVisible();
      await takeScreenshot($, 'nav_rapid_cycle_complete');
    },
  );
}
