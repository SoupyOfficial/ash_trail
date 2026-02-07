import 'package:patrol/patrol.dart';

import 'components/analytics.dart';
import 'components/nav_bar.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Analytics screen E2E tests — load, stats, charts.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/analytics_test.dart

void main() {
  patrolTest(
    'Analytics screen loads',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final analytics = AnalyticsComponent($);

      await nav.tapAnalytics();
      await handlePermissionDialogs($);
      await analytics.waitUntilVisible();
      analytics.verifyVisible();
      await takeScreenshot($, 'analytics_screen_loaded');
    },
  );

  patrolTest(
    'Analytics shows stats content',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final analytics = AnalyticsComponent($);

      await nav.tapAnalytics();
      await handlePermissionDialogs($);
      await analytics.waitUntilVisible();
      analytics.verifyVisible();

      // Pump extra to let charts render
      await $.pump(const Duration(seconds: 3));
      await takeScreenshot($, 'analytics_stats_content');
    },
  );

  patrolTest(
    'Charts render without crash',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final analytics = AnalyticsComponent($);

      await nav.tapAnalytics();
      await handlePermissionDialogs($);
      await analytics.waitUntilVisible();

      // Just pump for 3s and not crash
      await $.pump(const Duration(seconds: 3));
      analytics.verifyVisible();
      await takeScreenshot($, 'analytics_charts_rendered');
    },
  );
}
