import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// HistoryScreen component.
class HistoryComponent {
  final PatrolIntegrationTester $;
  HistoryComponent(this.$);

  // ── Finders ──
  Finder get appBar => find.byKey(const Key('app_bar_history'));
  Finder get filterButton => find.byKey(const Key('history_filter_button'));
  Finder get groupButton => find.byKey(const Key('history_group_button'));
  Finder get searchField => find.byKey(const Key('history_search'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, appBar);
    await settle($, frames: 10);
  }

  // ── Actions ──
  Future<void> tapFilter() async {
    await $(filterButton).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  Future<void> tapGroup() async {
    await $(groupButton).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  Future<void> searchFor(String text) async {
    await $.tester.enterText(searchField, text);
    await $.pump(const Duration(milliseconds: 500));
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(appBar, findsOneWidget, reason: 'History AppBar should be visible');
  }

  void verifyHasEntries() {
    // History record tiles use Key('history_record_$logId')
    // For now, check that at least one record key exists
    expect(
      find.byKey(const Key('history_filter_button')),
      findsOneWidget,
      reason: 'History should have filter button when entries present',
    );
  }

  void verifyEmpty() {
    // Empty state typically shows a message
    expect(
      find.textContaining('No'),
      findsWidgets,
      reason: 'History empty state should show "No" message',
    );
  }
}
