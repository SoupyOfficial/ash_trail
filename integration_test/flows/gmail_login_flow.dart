import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';

import '../components/app.dart';
import '../components/accounts.dart';
import '../components/welcome.dart';
import '../components/login.dart';
import '../components/home.dart';
import '../components/nav_bar.dart';
import '../helpers/pump.dart';

// ── Diagnostics ──────────────────────────────────────────────────────────────

/// Write a timestamped line to the shared diagnostics log file.
void _flowLog(String message) {
  final ts = DateTime.now().toIso8601String().substring(11, 23);
  final line = '[$ts] GMAIL_SETUP: $message';
  File(
    '/tmp/ash_trail_test_diagnostics.log',
  ).writeAsStringSync('$line\n', mode: FileMode.append);
}

// ── Screen detection ─────────────────────────────────────────────────────────

/// Possible app states after launch.
enum GmailAppScreen { welcome, login, home, loading, unknown }

/// Detect which screen the app is currently showing by probing key finders.
GmailAppScreen detectGmailScreen(PatrolIntegrationTester $) {
  // Nav bar is the most definitive sign of being logged in
  if ($.tester.any(find.byKey(const Key('nav_home')))) {
    return GmailAppScreen.home;
  }
  if ($.tester.any(find.text('Welcome to Ash Trail'))) {
    return GmailAppScreen.welcome;
  }
  if ($.tester.any(find.byKey(const Key('email-input')))) {
    return GmailAppScreen.login;
  }
  if ($.tester.any(find.byType(CircularProgressIndicator))) {
    return GmailAppScreen.loading;
  }
  return GmailAppScreen.unknown;
}

/// Launch the app and wait until a recognisable screen is visible.
Future<GmailAppScreen> gmailLaunchAndDetect(PatrolIntegrationTester $) async {
  final app = AppComponent($);
  await app.launch();

  _flowLog('App launched — polling for a known screen…');

  await handleNativePermissionDialogs($);

  final end = DateTime.now().add(const Duration(seconds: 60));
  GmailAppScreen screen = GmailAppScreen.unknown;
  while (DateTime.now().isBefore(end)) {
    await $.pump(const Duration(milliseconds: 500));
    screen = detectGmailScreen($);
    if (screen != GmailAppScreen.unknown && screen != GmailAppScreen.loading) {
      break;
    }
  }

  _flowLog('Detected screen: $screen');
  await takeScreenshot($, 'gmail_launch_detected_$screen');
  return screen;
}

// ── Public setup helpers ─────────────────────────────────────────────────────

/// Ensure the app is launched and the user is logged in via Google Sign-In
/// on the **Home** screen.
///
/// If no user is logged in, navigates to the login screen and taps
/// "Continue with Google". The native Google Sign-In sheet will appear
/// where the tester must select the appropriate Gmail account.
///
/// For Patrol tests, the Google account picker is a native UI — use
/// Patrol's native automation to select the correct account.
Future<void> ensureGmailLoggedIn(
  PatrolIntegrationTester $, {
  String? selectAccountEmail,
}) async {
  final screen = await gmailLaunchAndDetect($);
  await handlePermissionDialogs($);

  switch (screen) {
    case GmailAppScreen.home:
      _flowLog('Already on Home — tapping Home tab');
      final nav = NavBarComponent($);
      await nav.tapHome();
      final home = HomeComponent($);
      await home.waitUntilVisible();
      await handlePermissionDialogs($);
      await takeScreenshot($, 'gmail_setup_already_home');

    case GmailAppScreen.welcome:
      _flowLog('On Welcome — performing Google Sign-In flow');
      final welcome = WelcomeComponent($);
      final login = LoginComponent($);
      await takeScreenshot($, 'gmail_setup_welcome_before_login');
      await welcome.tapSignIn();
      await login.waitUntilVisible();
      await takeScreenshot($, 'gmail_setup_login_screen');

      // Tap "Continue with Google" instead of email/password
      _flowLog('Tapping "Continue with Google"');
      await login.tapGoogleSignIn();

      // Handle the native Google account picker
      await _handleGoogleAccountPicker($, selectAccountEmail);

      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await takeScreenshot($, 'gmail_setup_home_after_login');

    case GmailAppScreen.login:
      _flowLog('On Login — performing Google Sign-In directly');
      final login = LoginComponent($);

      _flowLog('Tapping "Continue with Google"');
      await login.tapGoogleSignIn();

      await _handleGoogleAccountPicker($, selectAccountEmail);

      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);

    default:
      throw Exception(
        'ensureGmailLoggedIn: app did not reach a known screen '
        'within 60 s (got: $screen)',
      );
  }

  _flowLog('ensureGmailLoggedIn complete');
}

/// Ensure the app is launched and showing the **Welcome** screen.
///
/// If Firebase auth has persisted from a previous test, this signs out
/// programmatically (Firebase + Hive active-account) and waits for
/// [AuthWrapper] to rebuild with [WelcomeScreen].
Future<void> ensureGmailLoggedOut(PatrolIntegrationTester $) async {
  final screen = await gmailLaunchAndDetect($);
  await handlePermissionDialogs($);

  if (screen == GmailAppScreen.welcome) {
    _flowLog('Already on Welcome screen');
    return;
  }

  if (screen == GmailAppScreen.home || screen == GmailAppScreen.login) {
    _flowLog('Logged in — signing out programmatically');
    await FirebaseAuth.instance.signOut();
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
    await takeScreenshot($, 'gmail_setup_signed_out_welcome');
    return;
  }

  throw Exception(
    'ensureGmailLoggedOut: app did not reach a known screen (got: $screen)',
  );
}

/// Handle the add-account flow via Google Sign-In.
///
/// Taps "Add Another Account" on the Accounts screen, then taps
/// "Continue with Google" on the Login screen.
Future<void> addGmailAccount(
  PatrolIntegrationTester $,
  HomeComponent home,
  AccountsComponent accounts,
  LoginComponent login, {
  String? selectAccountEmail,
}) async {
  _flowLog('Adding Gmail account via Google Sign-In...');
  await home.tapAccountIcon();
  await handlePermissionDialogs($);
  await accounts.waitUntilVisible();
  await accounts.tapAddAccount();
  await login.waitUntilVisible();

  _flowLog('Tapping "Continue with Google"');
  await login.tapGoogleSignIn();

  await _handleGoogleAccountPicker($, selectAccountEmail);

  await pumpUntilFound(
    $,
    find.byKey(const Key('nav_home')),
    timeout: const Duration(seconds: 60),
  );
  await handlePermissionDialogs($);
  await settle($, frames: 20);
  _flowLog('Gmail account added');
}

// ── Native Google Account Picker ─────────────────────────────────────────────

/// Handle the native Google account picker that appears after tapping
/// "Continue with Google".
///
/// On iOS, this is a web view or native sheet. On Android, it's a
/// system dialog. Patrol can interact with native UI elements.
///
/// If [selectAccountEmail] is provided, attempts to tap the account
/// matching that email in the native picker. Otherwise, waits for the
/// user to select manually or picks the first available account.
Future<void> _handleGoogleAccountPicker(
  PatrolIntegrationTester $,
  String? selectAccountEmail,
) async {
  _flowLog('Waiting for Google account picker...');
  await $.pump(const Duration(seconds: 2));

  try {
    if (selectAccountEmail != null) {
      _flowLog('Looking for account: $selectAccountEmail');
      // Try to find and tap the specific account email in native UI
      await $.native.tap(
        Selector(textContains: selectAccountEmail),
        appId: 'com.google.chrome',
      );
      _flowLog('Tapped $selectAccountEmail in Google picker');
    } else {
      // Wait for native sign-in to complete automatically
      // (e.g. single account on device auto-selects)
      _flowLog('No specific account — waiting for sign-in to complete...');
    }
  } catch (e) {
    _flowLog('Google picker interaction: $e');
    // The native picker may have completed automatically or the
    // webview-based flow handles it. Continue and let the test
    // wait for the nav_home key to confirm login succeeded.
  }

  // Give the auth flow time to complete
  await $.pump(const Duration(seconds: 3));
  _flowLog('Google account picker handling complete');
}
