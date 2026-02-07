import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// HomeScreen component — the main dashboard after login.
class HomeComponent {
  final PatrolIntegrationTester $;
  HomeComponent(this.$);

  // ── Finders ──
  Finder get appBar => find.byKey(const Key('app_bar_home'));
  Finder get navHome => find.byKey(const Key('nav_home'));
  Finder get holdToRecordButton =>
      find.byKey(const Key('hold_to_record_button'));
  Finder get moodSlider => find.byKey(const Key('quick_log_mood_slider'));
  Finder get physicalSlider =>
      find.byKey(const Key('quick_log_physical_slider'));
  Finder get timeSinceLastHit => find.byKey(const Key('time_since_last_hit'));
  Finder get accountIcon => find.byKey(const Key('app_bar_account'));
  Finder get backdateFab => find.byKey(const Key('fab_backdate'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, navHome, timeout: const Duration(seconds: 120));
    // Extra settle — Home has providers, animations, and streams that need
    // time to finish after the nav bar first appears.
    await settle($);
  }

  // ── Actions ──
  Future<void> tapAccountIcon() async {
    await $(accountIcon).tap(settlePolicy: SettlePolicy.noSettle);
  }

  Future<void> tapBackdateFab() async {
    await $(backdateFab).tap(settlePolicy: SettlePolicy.noSettle);
  }

  /// Long-press the hold-to-record button for [duration].
  Future<void> holdToRecord({
    Duration duration = const Duration(seconds: 3),
  }) async {
    final center = $.tester.getCenter(holdToRecordButton);
    final gesture = await $.tester.startGesture(center);
    await $.pump(duration);
    await gesture.up();
    await $.pump(const Duration(milliseconds: 500));
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(appBar, findsOneWidget, reason: 'Home AppBar should be visible');
    expect(navHome, findsOneWidget, reason: 'Home nav tab should be visible');
  }

  void verifyQuickLogVisible() {
    expect(
      moodSlider,
      findsOneWidget,
      reason: 'Quick log mood slider should be visible',
    );
    expect(
      physicalSlider,
      findsOneWidget,
      reason: 'Quick log physical slider should be visible',
    );
    expect(
      holdToRecordButton,
      findsOneWidget,
      reason: 'Hold-to-record button should be visible',
    );
  }

  void verifyTimeSinceLastVisible() {
    expect(
      timeSinceLastHit,
      findsOneWidget,
      reason: 'Time since last hit widget should be visible',
    );
  }
}
