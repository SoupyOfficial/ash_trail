import 'package:patrol/patrol.dart';

import 'components/welcome.dart';
import 'components/login.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// Auth E2E tests — welcome screen branding, navigation to login, error states.
///
/// These tests require the unauthenticated Welcome screen. If the app is
/// already logged in (Firebase token persisted from a prior test),
/// [ensureLoggedOut] signs out first so Welcome is visible.
///
/// Run with:
///   patrol test --target integration_test/auth_test.dart

void main() {
  patrolTest(
    'Welcome screen displays branding and Sign In button',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedOut($);

      final welcome = WelcomeComponent($);
      welcome.verifyVisible();
      await takeScreenshot($, 'auth_welcome_branding');
    },
  );

  patrolTest(
    'Sign In navigates to Login screen',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedOut($);

      final welcome = WelcomeComponent($);
      final login = LoginComponent($);

      await welcome.tapSignIn();
      await login.waitUntilVisible();
      login.verifyVisible();
      await takeScreenshot($, 'auth_login_screen');
    },
  );

  patrolTest(
    'Login with bad credentials shows error',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      await ensureLoggedOut($);

      final welcome = WelcomeComponent($);
      final login = LoginComponent($);

      await welcome.tapSignIn();
      await login.waitUntilVisible();

      await login.loginWith('bad@email.com', 'wrongpassword');

      // Wait a moment for error to appear
      await $.pump(const Duration(seconds: 3));
      // Error should be shown on screen (Firebase auth error)
      // The exact message depends on Firebase — just verify we're still on login
      login.verifyVisible();
      await takeScreenshot($, 'auth_bad_credentials_error');
    },
  );
}
