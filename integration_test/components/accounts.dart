import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../helpers/pump.dart';

/// AccountsScreen component.
class AccountsComponent {
  final PatrolIntegrationTester $;
  AccountsComponent(this.$);

  // ── Finders ──
  Finder get appBar => find.byKey(const Key('app_bar_accounts'));
  Finder get addAccountTile => find.byKey(const Key('accounts_add_account'));
  Finder accountCard(int index) => find.byKey(Key('account_card_$index'));

  // ── Waiters ──
  Future<void> waitUntilVisible() async {
    await pumpUntilFound($, appBar);
    await settle($, frames: 10);
  }

  // ── Actions ──
  Future<void> tapAddAccount() async {
    testLog('ACCOUNTS: tapping Add Account tile');
    await $(addAccountTile).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  Future<void> tapAccountCard(int index) async {
    testLog('ACCOUNTS: tapping account card $index');
    await $(accountCard(index)).tap(settlePolicy: SettlePolicy.noSettle);
    await settle($, frames: 10);
  }

  /// Switch to account at [index] (non-active card) and wait for the UI
  /// to reflect the switch (snackbar "Switched to..." appears).
  Future<void> switchToAccount(int index) async {
    testLog('ACCOUNTS: switching to account card $index');
    await debugLogActiveUser('before switchToAccount($index)');
    await tapAccountCard(index);

    // Wait for the "Switched to" snackbar to appear and dismiss
    testLog('ACCOUNTS: waiting for "Switched to" snackbar...');
    await pumpUntilFound(
      $,
      find.textContaining('Switched to'),
      timeout: const Duration(seconds: 15),
    );
    testLog('ACCOUNTS: snackbar appeared — settling...');
    await settle($, frames: 20);
    await debugLogActiveUser('after switchToAccount($index)');
  }

  // ── Assertions ──
  void verifyVisible() {
    expect(appBar, findsOneWidget, reason: 'Accounts AppBar should be visible');
  }

  void verifyAccountCount(int n) {
    for (int i = 0; i < n; i++) {
      expect(
        accountCard(i),
        findsOneWidget,
        reason: 'Account card $i should be visible',
      );
    }
  }

  /// Verify the text "Active • \<email>" is visible on screen for [email].
  void verifyActiveAccount(String email) {
    expect(
      find.textContaining('Active • $email'),
      findsOneWidget,
      reason: 'Account $email should show "Active •" indicator',
    );
  }

  /// Verify the text "Tap to switch • \<email>" is visible for [email].
  void verifySwitchableAccount(String email) {
    expect(
      find.textContaining('Tap to switch • $email'),
      findsOneWidget,
      reason: 'Account $email should show "Tap to switch •" indicator',
    );
  }

  /// Dump all visible account card text to diagnostics for debugging.
  Future<void> debugDumpCards() async {
    testLog('ACCOUNTS: === Card dump ===');
    for (int i = 0; i < 5; i++) {
      final finder = accountCard(i);
      if ($.tester.any(finder)) {
        // Read the text within this card's subtree
        final element = finder.evaluate().first;
        final texts = <String>[];
        element.visitChildElements((child) {
          _extractText(child, texts);
        });
        testLog('  Card $i: ${texts.join(' | ')}');
      } else {
        break; // No more cards
      }
    }
    testLog('ACCOUNTS: === End card dump ===');
  }
}

/// Recursively extract Text widget data from an element tree.
void _extractText(Element element, List<String> results) {
  if (element.widget is Text) {
    final text = (element.widget as Text).data;
    if (text != null && text.isNotEmpty) {
      results.add(text);
    }
  }
  element.visitChildElements((child) => _extractText(child, results));
}
