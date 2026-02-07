import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';

import '../components/app.dart';
import '../components/welcome.dart';
import '../components/login.dart';
import '../components/home.dart';
import '../components/nav_bar.dart';
import '../helpers/config.dart';
import '../helpers/pump.dart';

// ── Diagnostics ──────────────────────────────────────────────────────────────

/// Write a timestamped line to the shared diagnostics log file.
void _flowLog(String message) {
  final ts = DateTime.now().toIso8601String().substring(11, 23);
  final line = '[$ts] SETUP: $message';
  File(
    '/tmp/ash_trail_test_diagnostics.log',
  ).writeAsStringSync('$line\n', mode: FileMode.append);
}

// ── Screen detection ─────────────────────────────────────────────────────────

/// Possible app states after launch.
enum AppScreen { welcome, login, home, loading, unknown }

/// Detect which screen the app is currently showing by probing key finders.
AppScreen detectScreen(PatrolIntegrationTester $) {
  // Nav bar is the most definitive sign of being logged in
  if ($.tester.any(find.byKey(const Key('nav_home')))) return AppScreen.home;
  if ($.tester.any(find.text('Welcome to Ash Trail'))) {
    return AppScreen.welcome;
  }
  if ($.tester.any(find.byKey(const Key('email-input')))) {
    return AppScreen.login;
  }
  if ($.tester.any(find.byType(CircularProgressIndicator))) {
    return AppScreen.loading;
  }
  return AppScreen.unknown;
}

/// Launch the app and wait until a recognisable screen is visible.
///
/// Patrol hot-restarts between each [patrolTest], which resets all Dart
/// statics but keeps platform state (Firebase auth token, Keychain, Hive).
/// So the app may land on Welcome *or* Home depending on whether a previous
/// test already logged in.
Future<AppScreen> launchAndDetect(PatrolIntegrationTester $) async {
  final app = AppComponent($);
  await app.launch();

  _flowLog('App launched — polling for a known screen…');

  // A native iOS permission dialog left over from a previous test may be
  // blocking the UI. Dismiss it before trying to detect the screen.
  await handleNativePermissionDialogs($);

  final end = DateTime.now().add(const Duration(seconds: 60));
  AppScreen screen = AppScreen.unknown;
  while (DateTime.now().isBefore(end)) {
    await $.pump(const Duration(milliseconds: 500));
    screen = detectScreen($);
    if (screen != AppScreen.unknown && screen != AppScreen.loading) break;
  }

  _flowLog('Detected screen: $screen');
  await takeScreenshot($, 'launch_detected_$screen');
  return screen;
}

// ── Public setup helpers ─────────────────────────────────────────────────────

/// Ensure the app is launched and the user is logged in on the **Home** screen.
///
/// Dynamically detects the current state after Patrol's hot-restart:
/// - Already on Home (Firebase token persisted) → tap Home tab
/// - On Welcome screen (first run / after sign-out) → full login flow
/// - On Login screen (edge case) → login directly
Future<void> ensureLoggedIn(PatrolIntegrationTester $) async {
  final screen = await launchAndDetect($);
  await handlePermissionDialogs($);

  switch (screen) {
    case AppScreen.home:
      _flowLog('Already on Home — tapping Home tab');
      final nav = NavBarComponent($);
      await nav.tapHome();
      final home = HomeComponent($);
      await home.waitUntilVisible();
      await handlePermissionDialogs($);
      await takeScreenshot($, 'setup_already_home');

    case AppScreen.welcome:
      _flowLog('On Welcome — performing full login flow');
      final welcome = WelcomeComponent($);
      final login = LoginComponent($);
      final home = HomeComponent($);
      await takeScreenshot($, 'setup_welcome_before_login');
      await welcome.tapSignIn();
      await login.waitUntilVisible();
      await takeScreenshot($, 'setup_login_screen');
      await login.loginWith(testEmail, testPassword);
      await home.waitUntilVisible();
      await handlePermissionDialogs($);
      await takeScreenshot($, 'setup_home_after_login');

    case AppScreen.login:
      _flowLog('On Login — logging in directly');
      final login = LoginComponent($);
      final home = HomeComponent($);
      await login.loginWith(testEmail, testPassword);
      await home.waitUntilVisible();
      await handlePermissionDialogs($);

    default:
      throw Exception(
        'ensureLoggedIn: app did not reach a known screen '
        'within 60 s (got: $screen)',
      );
  }

  _flowLog('ensureLoggedIn complete');
}

/// Ensure the app is launched and showing the **Welcome** screen.
///
/// If Firebase auth has persisted from a previous test, this signs out
/// programmatically (Firebase + Hive active-account) and waits for
/// [AuthWrapper] to rebuild with [WelcomeScreen].
Future<void> ensureLoggedOut(PatrolIntegrationTester $) async {
  final screen = await launchAndDetect($);
  await handlePermissionDialogs($);

  if (screen == AppScreen.welcome) {
    _flowLog('Already on Welcome screen');
    return;
  }

  if (screen == AppScreen.home || screen == AppScreen.login) {
    _flowLog('Logged in — signing out programmatically');
    // 1. Firebase sign-out: authStateProvider stream emits null
    await FirebaseAuth.instance.signOut();
    // 2. Hive account deactivation: activeAccountProvider stream emits null
    //    Together these cause AuthWrapper to rebuild → WelcomeScreen
    try {
      await AccountService().deactivateAllAccounts();
    } catch (e) {
      _flowLog('deactivateAllAccounts error (non-fatal): $e');
    }

    _flowLog('Waiting for Welcome screen after sign-out…');
    await pumpUntilFound(
      $,
      find.text('Welcome to Ash Trail'),
      timeout: const Duration(seconds: 15),
    );
    await settle($, frames: 5);
    _flowLog('Welcome screen visible after sign-out');
    await takeScreenshot($, 'setup_signed_out_welcome');
    return;
  }

  throw Exception(
    'ensureLoggedOut: app did not reach a known screen (got: $screen)',
  );
}

/// Legacy alias — calls [ensureLoggedIn].
Future<void> launchAndLogin(PatrolIntegrationTester $) => ensureLoggedIn($);
