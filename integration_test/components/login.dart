import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// LoginScreen component — email/password authentication form.
class LoginComponent {
  final PatrolIntegrationTester $;
  LoginComponent(this.$);

  // ── Finders ──
  Finder get emailField => find.byKey(const Key('email-input'));
  Finder get passwordField => find.byKey(const Key('password-input'));
  Finder get loginButton => find.byKey(const Key('login-button'));
  Finder get googleSignInButton => find.text('Continue with Google');

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, emailField);
    await settle($, frames: 5);
  }

  // ── Actions ──
  Future<void> enterEmail(String email) async {
    await $.tester.enterText(emailField, email);
    await $.pump(const Duration(milliseconds: 500));
  }

  Future<void> enterPassword(String password) async {
    await $.tester.enterText(passwordField, password);
    await $.pump(const Duration(milliseconds: 500));
  }

  Future<void> tapLogin() async {
    await $(loginButton).tap(settlePolicy: SettlePolicy.noSettle);
  }

  /// Tap the "Continue with Google" button to initiate Google Sign-In.
  Future<void> tapGoogleSignIn() async {
    await $(googleSignInButton).tap(settlePolicy: SettlePolicy.noSettle);
  }

  /// Convenience: fill both fields and tap login in one call.
  Future<void> loginWith(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLogin();
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(
      emailField,
      findsOneWidget,
      reason: 'Login email field should be visible',
    );
    expect(
      passwordField,
      findsOneWidget,
      reason: 'Login password field should be visible',
    );
    expect(
      loginButton,
      findsOneWidget,
      reason: 'Login button should be visible',
    );
  }

  /// Verify an error message is shown on the login screen.
  void verifyError(String message) {
    expect(
      find.text(message),
      findsOneWidget,
      reason: 'Login error "$message" should be visible',
    );
  }
}
