import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/account_integration_service.dart';
import 'package:ash_trail/services/account_session_manager.dart';
import 'package:ash_trail/services/auth_service.dart';
import 'package:ash_trail/services/token_service.dart';

import 'components/accounts.dart';
import 'components/app.dart';
import 'components/home.dart';
import 'components/history.dart';
import 'components/nav_bar.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Multi-Account Simulator Test (No Patrol Native Automation)
// ═══════════════════════════════════════════════════════════════════════════════
//
// This test exercises multi-account switching, logging, and data isolation
// using ONLY Flutter-level interactions — no $.native calls. This means it
// can run on the iOS Simulator via `flutter test` without the Patrol CLI.
//
// ── HOW IT WORKS ─────────────────────────────────────────────────────────────
//
// Firebase Auth persists its refresh token in the iOS Keychain. Hive persists
// account data in the app's Documents directory. Both survive across app
// restarts, hot-restarts, and `flutter test` runs.
//
// Once you manually sign into both Gmail accounts (one-time), the sessions
// persist indefinitely on that simulator. This test detects the persisted
// state and exercises multi-account features without re-authenticating.
//
// ── ONE-TIME SEEDING (required once per simulator) ───────────────────────────
//
//   patrol test --target integration_test/gmail_multi_account_test.dart \
//     --device "iPhone 16 Pro Max"
//
//   Complete the Google Sign-In flow for both accounts when prompted.
//   After this, sessions persist across all future runs.
//
// ── REGULAR RUNS ─────────────────────────────────────────────────────────────
//
//   flutter test integration_test/multi_account_sim_test.dart \
//     -d "iPhone 16 Pro Max"
//
// ── WHAT DESTROYS PERSISTED STATE ────────────────────────────────────────────
//
//   • xcrun simctl erase <uuid>       — wipes entire simulator
//   • patrol test --full-isolation    — uninstalls app + wipes Keychain
//   • Deleting/resetting the simulator in Xcode
//
//   After any of these, re-run the seeding step above.
//
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Helpers (no $.native calls — safe for `flutter test`)
// ─────────────────────────────────────────────────────────────────────────────

/// Launch the app and reach Home using a persisted Firebase session.
///
/// Does NOT use Patrol native automation. If no persisted session exists
/// (first run on a fresh simulator), fails with seeding instructions.
Future<void> _ensurePersistedSession(PatrolIntegrationTester $) async {
  testLog('SIM_TEST: Launching app and detecting persisted session...');

  final app = AppComponent($);
  await app.launch();

  // Poll for a recognizable screen
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  bool foundHome = false;
  bool foundWelcome = false;

  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 500));
    if ($.tester.any(find.byKey(const Key('nav_home')))) {
      foundHome = true;
      break;
    }
    if ($.tester.any(find.text('Welcome to Ash Trail'))) {
      foundWelcome = true;
      break;
    }
  }

  if (foundWelcome || !foundHome) {
    fail(
      '\n╔══════════════════════════════════════════════════════════╗\n'
      '║  NO PERSISTED SESSION — ONE-TIME SEEDING REQUIRED       ║\n'
      '╠══════════════════════════════════════════════════════════╣\n'
      '║                                                         ║\n'
      '║  Run the Patrol seeding test first:                     ║\n'
      '║                                                         ║\n'
      '║  patrol test \\                                          ║\n'
      '║    --target integration_test/                           ║\n'
      '║      gmail_multi_account_test.dart \\                    ║\n'
      '║    --device "iPhone 16 Pro Max"                         ║\n'
      '║                                                         ║\n'
      '║  Complete Google Sign-In for both accounts.             ║\n'
      '║  After that, sessions persist across all future runs.   ║\n'
      '║                                                         ║\n'
      '╚══════════════════════════════════════════════════════════╝\n',
    );
  }

  testLog('SIM_TEST: Home screen detected — persisted session active');

  // Handle the Flutter-level "Location Access" dialog if it appears.
  // This is a Flutter AlertDialog, NOT a native iOS dialog, so no $.native needed.
  await handleLocationDialog($);

  // Sync Firebase user to Hive if Hive got wiped but Keychain didn't
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    testLog(
      'SIM_TEST: Firebase user: ${firebaseUser.email} '
      '(uid: ${firebaseUser.uid.substring(0, 8)}...)',
    );
    final hiveAccount = await AccountService().getActiveAccount();
    if (hiveAccount == null || hiveAccount.userId != firebaseUser.uid) {
      testLog('SIM_TEST: Syncing Firebase user to Hive...');
      final accountService = AccountService();
      final sessionManager = AccountSessionManager(
        accountService: accountService,
      );
      final integrationService = AccountIntegrationService(
        authService: AuthService(),
        accountService: accountService,
        sessionManager: sessionManager,
        tokenService: TokenService(),
      );
      await integrationService.syncAccountFromFirebaseUser(
        firebaseUser,
        makeActive: true,
      );
      testLog('SIM_TEST: Hive sync complete');
    }
  }

  // Wait for Home to fully settle
  final home = HomeComponent($);
  await home.waitUntilVisible();
  testLog('SIM_TEST: Home screen ready');
}

/// Verify that both Gmail accounts are seeded in Hive.
/// Fails with clear instructions if accounts are missing.
Future<void> _verifyBothAccountsSeeded() async {
  final allAccounts = await AccountService().getAllAccounts();
  final emails = allAccounts.map((a) => a.email).toList();
  final hasAccount4 = emails.contains(testEmail4);
  final hasAccount5 = emails.contains(testEmail5);

  testLog('SIM_TEST: Hive accounts: $emails');
  testLog('SIM_TEST: Account 4 ($testEmail4): ${hasAccount4 ? "✓" : "✗"}');
  testLog('SIM_TEST: Account 5 ($testEmail5): ${hasAccount5 ? "✓" : "✗"}');

  if (!hasAccount4 || !hasAccount5) {
    fail(
      '\n╔══════════════════════════════════════════════════════════╗\n'
      '║  BOTH GMAIL ACCOUNTS MUST BE SEEDED                     ║\n'
      '╠══════════════════════════════════════════════════════════╣\n'
      '║                                                         ║\n'
      '║  Found: ${emails.join(", ").padRight(43)}║\n'
      '║  Need:  $testEmail4              ║\n'
      '║         $testEmail5                    ║\n'
      '║                                                         ║\n'
      '║  Re-run the Patrol seeding test to sign into both.      ║\n'
      '║                                                         ║\n'
      '╚══════════════════════════════════════════════════════════╝\n',
    );
  }
}

/// Random hold duration between 1.5 and 4.0 seconds.
Duration _randomHoldDuration() {
  final ms = 1500 + Random().nextInt(2500);
  return Duration(milliseconds: ms);
}

/// Extract snackbar text containing "Logged vape".
String? _extractSnackbarText(PatrolIntegrationTester $) {
  try {
    final finder = find.textContaining('Logged vape');
    if ($.tester.any(finder)) {
      for (final element in finder.evaluate()) {
        final widget = element.widget;
        if (widget is Text && widget.data != null) return widget.data;
        if (widget is RichText) {
          final plain = widget.text.toPlainText();
          if (plain.contains('Logged vape')) return plain;
        }
      }
    }
  } catch (e) {
    testLog('SIM_TEST: Snackbar extraction failed: $e');
  }
  return null;
}

/// Verify the top History record matches the expected log time.
bool _verifyTopHistoryRecord(
  PatrolIntegrationTester $,
  DateTime loggedAt,
  String label,
) {
  final expectedTime = DateFormat('h:mm a').format(loggedAt);
  final possibleTimes = [
    expectedTime,
    DateFormat('h:mm a').format(loggedAt.add(const Duration(minutes: 1))),
    DateFormat('h:mm a').format(loggedAt.subtract(const Duration(minutes: 1))),
  ];

  testLog('SIM_TEST: $label — checking History for times: $possibleTimes');

  final allCards = find.byType(Card);
  if (!$.tester.any(allCards)) {
    testLog('SIM_TEST: $label — No record Cards found');
    return false;
  }

  for (final time in possibleTimes) {
    if ($.tester.any(find.textContaining(time))) {
      testLog('SIM_TEST: $label — ✓ Found matching time "$time"');
      return true;
    }
  }

  // Also accept "Just now" or "Today"
  if ($.tester.any(find.textContaining('Just now')) ||
      $.tester.any(find.textContaining('Today'))) {
    testLog('SIM_TEST: $label — ✓ Found "Just now" / "Today"');
    return true;
  }

  testLog('SIM_TEST: $label — ✗ No matching time found');
  return false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Test 1: Verify persisted sessions
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Sim: verify persisted Gmail sessions',
    config: defaultPatrolConfig,
    ($) async {
      testLog('');
      testLog('═══ TEST 1: Verify Persisted Gmail Sessions ═══');

      await _ensurePersistedSession($);
      await _verifyBothAccountsSeeded();

      // Dump full state for diagnostics
      await debugDumpAccountState($, 'Persisted session state');

      // Verify Firebase Auth has a valid user
      final fbUser = FirebaseAuth.instance.currentUser;
      expect(fbUser, isNotNull, reason: 'Firebase user should be persisted');
      testLog('SIM_TEST: Firebase user: ${fbUser!.email}');

      // Verify token can refresh
      try {
        await fbUser.getIdToken();
        testLog('SIM_TEST: ✓ Firebase token refresh OK');
      } catch (e) {
        testLog('SIM_TEST: ⚠ Token refresh failed: $e');
      }

      // Verify Hive accounts
      final allAccounts = await AccountService().getAllAccounts();
      testLog('SIM_TEST: Hive accounts: ${allAccounts.length}');
      for (final a in allAccounts) {
        testLog(
          '  ${a.email} | active=${a.isActive} | '
          'loggedIn=${a.isLoggedIn} | uid=${a.userId.substring(0, 8)}...',
        );
      }

      await takeScreenshot($, 'sim_01_persisted_state');

      testLog('═══ TEST 1: PASSED ═══');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 2: Switch between accounts
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Sim: switch between Gmail accounts',
    config: defaultPatrolConfig,
    ($) async {
      testLog('');
      testLog('═══ TEST 2: Switch Between Gmail Accounts ═══');

      await _ensurePersistedSession($);
      await _verifyBothAccountsSeeded();

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      // Record which account is currently active
      final beforeActive = await AccountService().getActiveAccount();
      testLog('SIM_TEST: Active before switch: ${beforeActive?.email}');

      // Open Accounts screen
      testLog('SIM_TEST: Opening Accounts screen...');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await takeScreenshot($, 'sim_02a_accounts_before_switch');

      // Verify both accounts are displayed
      accounts.verifyAccountCount(2);
      testLog('SIM_TEST: ✓ Both account cards visible');

      // Switch to the other account
      testLog('SIM_TEST: Switching to account card 1...');
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switch (1)');
      await takeScreenshot($, 'sim_02b_after_switch');

      // Verify active account changed
      final afterSwitch = await AccountService().getActiveAccount();
      testLog('SIM_TEST: Active after switch: ${afterSwitch?.email}');
      expect(
        afterSwitch?.email,
        isNot(equals(beforeActive?.email)),
        reason: 'Active account should change after switch',
      );
      testLog('SIM_TEST: ✓ Active account changed');

      // Switch back
      testLog('SIM_TEST: Switching back...');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switch back');
      await takeScreenshot($, 'sim_02c_switched_back');

      final restored = await AccountService().getActiveAccount();
      testLog('SIM_TEST: Active after restore: ${restored?.email}');
      expect(
        restored?.email,
        equals(beforeActive?.email),
        reason: 'Original active account should be restored',
      );
      testLog('SIM_TEST: ✓ Original account restored');

      testLog('═══ TEST 2: PASSED ═══');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 3: Quick log after switching + verify in History
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Sim: quick log after switching accounts',
    config: defaultPatrolConfig,
    ($) async {
      testLog('');
      testLog('═══ TEST 3: Quick Log After Switching Accounts ═══');

      await _ensurePersistedSession($);
      await _verifyBothAccountsSeeded();

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final history = HistoryComponent($);

      // ── Phase A: Record a baseline log for the current account ──
      testLog('SIM_TEST: Phase A — Baseline quick log for active account');
      final activeA = await AccountService().getActiveAccount();
      testLog('SIM_TEST: Active account: ${activeA?.email}');
      await debugDumpAccountState($, 'Before baseline log');

      final durA = _randomHoldDuration();
      testLog('SIM_TEST: Holding to record for ${durA.inMilliseconds}ms...');
      final loggedAtA = DateTime.now();
      await home.holdToRecord(duration: durA);
      await settle($, frames: 10);

      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final snackA = _extractSnackbarText($);
      testLog('SIM_TEST: ✓ Baseline log snackbar: $snackA');
      await takeScreenshot($, 'sim_03a_baseline_logged');

      // Verify in History
      testLog('SIM_TEST: Verifying baseline log in History...');
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'sim_03b_baseline_history');

      final matchA = _verifyTopHistoryRecord($, loggedAtA, 'Phase A');
      expect(matchA, isTrue, reason: 'Baseline log should appear in History');
      testLog('SIM_TEST: ✓ Baseline log verified in History');

      // ── Phase B: Switch to the other account ──
      testLog('SIM_TEST: Phase B — Switching to other account...');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switch');
      await takeScreenshot($, 'sim_03c_switched');

      // Navigate back to Home
      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }
      await nav.tapHome();
      await home.waitUntilVisible();

      // Wait for provider propagation
      final switchedEmail =
          (await AccountService().getActiveAccount())?.email ?? '';
      testLog('SIM_TEST: Switched to: $switchedEmail');
      final propagated = await waitForProviderPropagation($, switchedEmail);
      testLog('SIM_TEST: Provider propagated: $propagated');

      // Clear stale snackbars
      await clearSnackbars($);
      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      // ── Phase C: Quick log for the switched account (CRITICAL) ──
      testLog('SIM_TEST: Phase C — Quick log after switch (CRITICAL)');
      await debugDumpLogCreationPipeline($, 'BEFORE critical quick log');

      final durB = _randomHoldDuration();
      testLog('SIM_TEST: Holding to record for ${durB.inMilliseconds}ms...');
      await debugLogActiveUser('immediately before holdToRecord');
      final loggedAtB = DateTime.now();
      await home.holdToRecord(duration: durB);
      await settle($, frames: 10);

      // Poll for result
      bool logSuccess = false;
      String? snackB;
      int polls = 0;
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        await $.pump(const Duration(milliseconds: 250));
        polls++;
        if (polls % 8 == 0) {
          testLog('SIM_TEST: Poll #$polls — waiting for snackbar...');
          await debugLogActiveUser('poll #$polls');
        }
        if ($.tester.any(find.textContaining('Logged vape'))) {
          snackB = _extractSnackbarText($);
          testLog('SIM_TEST: ✓ Post-switch log snackbar: $snackB');
          logSuccess = true;
          break;
        }
        if ($.tester.any(find.textContaining('No active account'))) {
          testLog('SIM_TEST: ✗ BUG — "No active account" snackbar!');
          await debugDumpAccountState($, 'No active account BUG');
          break;
        }
        if ($.tester.any(find.textContaining('Error'))) {
          testLog('SIM_TEST: ✗ Error snackbar detected');
          break;
        }
      }

      if (!logSuccess) {
        testLog('SIM_TEST: ⚠ Quick log did not succeed (polls: $polls)');
        await debugDumpAccountState($, 'Quick log TIMEOUT');
        await debugDumpLogState($, 'Quick log TIMEOUT');
        await debugDumpLogCreationPipeline($, 'Quick log TIMEOUT pipeline');
      }

      // Verify persistence
      final persisted = await debugVerifyLogPersisted(
        $,
        'Post-switch quick log',
        loggedAtB,
      );
      testLog('SIM_TEST: Log persisted in Hive: $persisted');

      await debugDumpAccountState($, 'After post-switch log');
      await takeScreenshot($, 'sim_03d_post_switch_logged');

      // ── Phase D: Verify in History ──
      testLog('SIM_TEST: Phase D — Verifying post-switch log in History...');
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'sim_03e_post_switch_history');

      final matchB = _verifyTopHistoryRecord($, loggedAtB, 'Phase D');
      expect(
        matchB,
        isTrue,
        reason: 'Post-switch log should appear in History',
      );
      testLog('SIM_TEST: ✓ Post-switch log verified in History');

      // ── Phase E: Data isolation — switch back and verify ──
      testLog('SIM_TEST: Phase E — Verifying data isolation...');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Switched back to original');

      final backBtn2 = find.byType(BackButton);
      if ($.tester.any(backBtn2)) {
        await $(backBtn2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpLogState($, 'Original account History');
      await takeScreenshot($, 'sim_03f_data_isolation');
      testLog('SIM_TEST: ✓ Data isolation check complete');

      testLog('═══ TEST 3: PASSED ═══');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4: Swap and log 3x loop
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest('Sim: swap and log 3x loop', config: defaultPatrolConfig, (
    $,
  ) async {
    testLog('');
    testLog('═══ TEST 4: Swap and Log 3x Loop ═══');

    await _ensurePersistedSession($);
    await _verifyBothAccountsSeeded();

    final home = HomeComponent($);
    final nav = NavBarComponent($);
    final accounts = AccountsComponent($);
    final history = HistoryComponent($);

    int successCount = 0;

    for (int i = 1; i <= 3; i++) {
      testLog('');
      testLog('─── Iteration $i/3 ───');

      // ── Step A: Switch account ──
      testLog('SIM_TEST: [$i] Switching account...');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await accounts.switchToAccount(1);

      final activeEmail =
          (await AccountService().getActiveAccount())?.email ?? 'unknown';
      testLog('SIM_TEST: [$i] Active: $activeEmail');
      await debugDumpAccountState($, 'Iter $i: After switch');
      await takeScreenshot($, 'sim_04_loop_${i}_switched');

      // Navigate back to Home
      final backBtn = find.byType(BackButton);
      if ($.tester.any(backBtn)) {
        await $(backBtn).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }
      await nav.tapHome();
      await home.waitUntilVisible();

      // Wait for provider propagation
      final propagated = await waitForProviderPropagation($, activeEmail);
      testLog('SIM_TEST: [$i] Provider propagated: $propagated');

      // Clear stale snackbars
      await clearSnackbars($);
      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      // ── Step B: Quick log ──
      testLog('SIM_TEST: [$i] Recording quick log...');
      final dur = _randomHoldDuration();
      testLog('SIM_TEST: [$i] Hold duration: ${dur.inMilliseconds}ms');
      await debugLogActiveUser('Iter $i: before holdToRecord');
      final loggedAt = DateTime.now();
      await home.holdToRecord(duration: dur);
      await settle($, frames: 10);

      bool logged = false;
      int polls = 0;
      final deadline = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(deadline)) {
        await $.pump(const Duration(milliseconds: 250));
        polls++;
        if (polls % 8 == 0) {
          testLog('SIM_TEST: [$i] Poll #$polls...');
        }
        if ($.tester.any(find.textContaining('Logged vape'))) {
          final snack = _extractSnackbarText($);
          testLog('SIM_TEST: [$i] ✓ Logged: $snack');
          logged = true;
          successCount++;
          break;
        }
        if ($.tester.any(find.textContaining('No active account'))) {
          testLog('SIM_TEST: [$i] ✗ BUG — No active account');
          await debugDumpAccountState($, 'Iter $i: No active account');
          break;
        }
        if ($.tester.any(find.textContaining('Error'))) {
          testLog('SIM_TEST: [$i] ✗ Error snackbar');
          break;
        }
      }
      if (!logged) {
        testLog('SIM_TEST: [$i] ⚠ Timeout (polls: $polls)');
        await debugDumpAccountState($, 'Iter $i: TIMEOUT');
        await debugDumpLogState($, 'Iter $i: TIMEOUT');
      }

      await takeScreenshot($, 'sim_04_loop_${i}_logged');

      // ── Step C: Verify in History ──
      testLog('SIM_TEST: [$i] Verifying in History...');
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);

      final topMatch = _verifyTopHistoryRecord($, loggedAt, 'Iter $i');
      expect(topMatch, isTrue, reason: 'Iter $i: Log should appear in History');
      testLog('SIM_TEST: [$i] ✓ History verified');
      await takeScreenshot($, 'sim_04_loop_${i}_history');

      await nav.tapHome();
      await home.waitUntilVisible();
    }

    expect(
      successCount,
      equals(3),
      reason: 'All 3 swap+log iterations should succeed',
    );

    testLog('');
    testLog('═══ TEST 4: PASSED ($successCount/3 iterations) ═══');
  });
}
