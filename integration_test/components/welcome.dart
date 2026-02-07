import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// WelcomeScreen component — the first screen shown to unauthenticated users.
class WelcomeComponent {
  final PatrolIntegrationTester $;
  WelcomeComponent(this.$);

  // ── Finders ──
  Finder get welcomeText => find.text('Welcome to Ash Trail');
  Finder get signInButton => find.byKey(const Key('sign_in_button'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, welcomeText);
    await settle($, frames: 5);
  }

  // ── Actions ──
  Future<void> tapSignIn() async {
    await $(signInButton).tap(settlePolicy: SettlePolicy.noSettle);
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(
      welcomeText,
      findsOneWidget,
      reason: 'Welcome text should be visible',
    );
    expect(
      signInButton,
      findsOneWidget,
      reason: 'Sign In button should be visible',
    );
  }
}
