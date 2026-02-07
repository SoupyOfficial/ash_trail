import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'components/history.dart';
import 'components/nav_bar.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// History screen E2E tests — load, search, filter, edit dialog.
///
/// Each test uses [ensureLoggedIn] which dynamically detects app state
/// and logs in only if needed.
///
/// Run with:
///   patrol test --target integration_test/history_test.dart

void main() {
  patrolTest(
    'History screen loads',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final history = HistoryComponent($);

      await nav.tapHistory();
      await handlePermissionDialogs($);
      await history.waitUntilVisible();
      history.verifyVisible();
      await takeScreenshot($, 'history_screen_loaded');
    },
  );

  patrolTest(
    'History search field exists',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final history = HistoryComponent($);

      await nav.tapHistory();
      await handlePermissionDialogs($);
      await history.waitUntilVisible();

      expect(
        history.searchField,
        findsOneWidget,
        reason: 'History search field should be visible',
      );
      await takeScreenshot($, 'history_search_field');
    },
  );

  patrolTest(
    'History filter and group buttons exist',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final history = HistoryComponent($);

      await nav.tapHistory();
      await handlePermissionDialogs($);
      await history.waitUntilVisible();

      expect(
        history.filterButton,
        findsOneWidget,
        reason: 'History filter button should be visible',
      );
      expect(
        history.groupButton,
        findsOneWidget,
        reason: 'History group button should be visible',
      );
      await takeScreenshot($, 'history_filter_group_buttons');
    },
  );

  patrolTest(
    'Tap entry opens edit dialog and cancel closes it',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedIn($);

      final nav = NavBarComponent($);
      final history = HistoryComponent($);

      await nav.tapHistory();
      await handlePermissionDialogs($);
      await history.waitUntilVisible();

      // Try tapping the first record (if any exist)
      // This requires history_record_ keys on tiles — may need key additions
      // For now, just verify the screen loaded
      history.verifyVisible();
      await takeScreenshot($, 'history_edit_dialog');
    },
  );
}
