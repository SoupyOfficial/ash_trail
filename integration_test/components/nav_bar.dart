import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// Bottom navigation bar component.
class NavBarComponent {
  final PatrolIntegrationTester $;
  NavBarComponent(this.$);

  // ── Finders ──
  Finder get homeTab => find.byKey(const Key('nav_home'));
  Finder get analyticsTab => find.byKey(const Key('nav_analytics'));
  Finder get historyTab => find.byKey(const Key('nav_history'));

  // ── Actions ──
  Future<void> tapHome() async {
    await $(homeTab).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($);
  }

  Future<void> tapAnalytics() async {
    await $(analyticsTab).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($);
  }

  Future<void> tapHistory() async {
    await $(historyTab).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($);
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(homeTab, findsOneWidget, reason: 'Home nav tab should be visible');
    expect(
      analyticsTab,
      findsOneWidget,
      reason: 'Analytics nav tab should be visible',
    );
    expect(
      historyTab,
      findsOneWidget,
      reason: 'History nav tab should be visible',
    );
  }
}
