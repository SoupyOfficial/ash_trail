import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// LoggingScreen component.
class LoggingComponent {
  final PatrolIntegrationTester $;
  LoggingComponent(this.$);

  // ── Finders ──
  Finder get appBar => find.byKey(const Key('app_bar_logging'));
  Finder get detailedTab => find.byKey(const Key('tab_detailed'));
  Finder get backdateTab => find.byKey(const Key('tab_backdate'));
  Finder get clearButton => find.byKey(const Key('logging_clear_button'));
  Finder get logEventButton =>
      find.byKey(const Key('logging_log_event_button'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, appBar);
    await settle($, frames: 10);
  }

  // ── Actions ──
  Future<void> tapDetailedTab() async {
    await $(detailedTab).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  Future<void> tapBackdateTab() async {
    await $(backdateTab).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(appBar, findsOneWidget, reason: 'Logging AppBar should be visible');
  }

  void verifyTabsVisible() {
    expect(
      detailedTab,
      findsOneWidget,
      reason: 'Detailed tab should be visible',
    );
    expect(
      backdateTab,
      findsOneWidget,
      reason: 'Backdate tab should be visible',
    );
  }
}
