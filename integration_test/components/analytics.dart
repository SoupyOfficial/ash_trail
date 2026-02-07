import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// AnalyticsScreen component.
class AnalyticsComponent {
  final PatrolIntegrationTester $;
  AnalyticsComponent(this.$);

  // ── Finders ──
  Finder get appBar => find.byKey(const Key('app_bar_analytics'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, appBar);
    await settle($, frames: 10);
  }

  // ── Actions ──
  // Future: tap chart segments, change date range

  // ── Assertions ──
  void verifyVisible() {
    expect(
      appBar,
      findsOneWidget,
      reason: 'Analytics AppBar should be visible',
    );
  }
}
