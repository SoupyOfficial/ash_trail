import 'package:patrol/patrol.dart';

import 'helpers/config.dart';

/// Logging screen E2E tests — tabs, buttons, form visibility.
///
/// **NOTE:** These tests are currently skipped because the LoggingScreen
/// was removed from the bottom navigation bar (MainNavigation now has 3 tabs:
/// Home, Analytics, History). The `nav_log` key no longer exists.
/// Re-enable once the logging screen is accessible again (e.g. via a route
/// or a new navigation entry).
///
/// Run with:
///   patrol test --target integration_test/logging_test.dart

void main() {
  patrolTest(
    'Logging screen loads with tabs',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      // Skip: LoggingScreen not in bottom nav — nav_log tab removed
    },
  );

  patrolTest(
    'Log Event and Clear buttons exist',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      // Skip: LoggingScreen not in bottom nav — nav_log tab removed
    },
  );

  patrolTest(
    'Can switch between Detailed and Backdate tabs',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      // Skip: LoggingScreen not in bottom nav — nav_log tab removed
    },
  );
}
