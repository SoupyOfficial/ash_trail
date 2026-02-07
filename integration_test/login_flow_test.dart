import 'package:patrol/patrol.dart';

import 'components/welcome.dart';
import 'components/login.dart';
import 'components/home.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Login flow E2E test — verifies the full welcome → sign in → home journey.
///
/// Uses [ensureLoggedOut] to guarantee the Welcome screen is showing,
/// regardless of whether a previous test already logged in.
///
/// Run with:
///   patrol test --target integration_test/login_flow_test.dart

void main() {
  patrolTest(
    'Login flow: welcome → sign in → home',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedOut($);

      final welcome = WelcomeComponent($);
      final login = LoginComponent($);
      final home = HomeComponent($);

      welcome.verifyVisible();
      await takeScreenshot($, 'login_flow_welcome');

      await welcome.tapSignIn();

      await login.waitUntilVisible();
      login.verifyVisible();
      await takeScreenshot($, 'login_flow_login_screen');

      await login.loginWith(testEmail, testPassword);

      await home.waitUntilVisible();
      home.verifyVisible();
      await takeScreenshot($, 'login_flow_home_arrived');

      // Handle location dialogs that appear after MainNavigation builds
      await handlePermissionDialogs($);
    },
  );
}
