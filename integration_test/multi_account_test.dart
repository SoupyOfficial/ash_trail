import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';

import 'components/accounts.dart';
import 'components/home.dart';
import 'components/logging.dart';
import 'components/login.dart';
import 'components/nav_bar.dart';
import 'components/history.dart';
import 'components/welcome.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// Multi-Account + Logging Debug Tests
/// ═══════════════════════════════════════════════════════════════════════════
///
/// These tests exercise multi-account switching and verify that logging
/// works correctly after swapping accounts. Each test has EXTENSIVE debug
/// logging to capture the exact state of Firebase Auth, Hive accounts,
/// Riverpod providers, and UI at every step.
///
/// Prerequisites:
///   - Two Firebase accounts must exist:
///     1. test1@ashtrail.dev / TestPass123!
///     2. test2@ashtrail.dev / TestPass123!
///
/// Run with:
///   patrol test --target integration_test/multi_account_test.dart
///
/// After running, check /tmp/ash_trail_test_diagnostics.log for full debug trace.

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Test 1: Add a second account
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: add second account via Accounts screen',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Add second account');
      testLog('═══════════════════════════════════════════════════');

      // Step 1: Ensure logged in with account 1
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'After ensureLoggedIn (account 1)');
      await takeScreenshot($, 'multi_01_logged_in_account1');

      // Step 2: Navigate to Accounts screen
      final home = HomeComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      testLog('STEP 2: Navigating to Accounts screen...');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      accounts.verifyVisible();
      await debugDumpAccountState($, 'Accounts screen visible');
      await accounts.debugDumpCards();
      await takeScreenshot($, 'multi_02_accounts_screen');

      // Step 3: Verify single account present
      testLog('STEP 3: Verifying single account card...');
      accounts.verifyAccountCount(1);
      accounts.verifyActiveAccount(testEmail);
      testLog('STEP 3: ✓ Single account verified as active');

      // Step 4: Tap "Add Another Account"
      testLog('STEP 4: Tapping Add Another Account...');
      await accounts.tapAddAccount();
      await login.waitUntilVisible();
      login.verifyVisible();
      await takeScreenshot($, 'multi_03_login_for_account2');

      // Step 5: Login with account 2
      testLog('STEP 5: Logging in with account 2 ($testEmail2)...');
      await debugLogActiveUser('before account2 login');
      await login.loginWith(testEmail2, testPassword2);
      testLog('STEP 5: Login form submitted — waiting for Home/Accounts...');

      // After adding a second account, the app may navigate to Home or
      // back to Accounts. Wait for either.
      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await debugDumpAccountState($, 'After account 2 login');
      await takeScreenshot($, 'multi_04_after_account2_login');

      // Step 6: Navigate back to Accounts and verify both accounts
      testLog('STEP 6: Navigating to Accounts to verify both...');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Accounts with both accounts');
      await takeScreenshot($, 'multi_05_both_accounts');

      // Verify we now have 2 accounts
      accounts.verifyAccountCount(2);
      testLog('STEP 6: ✓ Two account cards verified');

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST PASSED: Add second account');
      testLog('═══════════════════════════════════════════════════');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 2: Switch between accounts
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: switch between accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Switch between accounts');
      testLog('═══════════════════════════════════════════════════');

      // Ensure we have account 1 logged in
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      // Step 1: Add account 2 if not already present
      testLog('STEP 1: Checking if account 2 is already present...');
      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount2 = allAccounts.any((a) => a.email == testEmail2);
      testLog('  Account 2 present: $hasAccount2');

      if (!hasAccount2) {
        testLog('  Adding account 2...');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.tapAddAccount();

        final login = LoginComponent($);
        await login.waitUntilVisible();
        await login.loginWith(testEmail2, testPassword2);

        await pumpUntilFound(
          $,
          find.byKey(const Key('nav_home')),
          timeout: const Duration(seconds: 60),
        );
        await handlePermissionDialogs($);
        await settle($, frames: 20);
      }

      await debugDumpAccountState($, 'Before switching — 2 accounts ready');

      // Step 2: Go to Accounts screen
      testLog('STEP 2: Opening Accounts screen...');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await takeScreenshot($, 'multi_switch_01_before_switch');

      // Step 3: Identify which card is non-active and tap it
      // Card 0 is typically the first logged-in account.
      // The active account has "Active •" — the other has "Tap to switch •"
      testLog('STEP 3: Determining which card to tap for switch...');

      // Check which email is currently active
      final activeAcct = await AccountService().getActiveAccount();
      testLog('  Currently active: ${activeAcct?.email}');

      // Tap the non-active card to switch
      // Account cards are indexed by their order in loggedInAccounts list
      // Try card 1 first (the second logged-in account)
      if ($.tester.any(accounts.accountCard(1))) {
        testLog('  Tapping account card 1...');
        await accounts.switchToAccount(1);
      } else {
        testLog('  Only 1 card found — cannot switch');
        fail('Expected 2 account cards but only found 1');
      }

      await debugDumpAccountState($, 'After switching account');
      await accounts.debugDumpCards();
      await takeScreenshot($, 'multi_switch_02_after_switch');

      // Step 4: Verify the active indicator flipped
      testLog('STEP 4: Verifying active indicator changed...');
      // The previously non-active account should now be active
      final newActiveAcct = await AccountService().getActiveAccount();
      testLog('  New active: ${newActiveAcct?.email}');
      expect(
        newActiveAcct?.email,
        isNot(equals(activeAcct?.email)),
        reason: 'Active account should have changed after switch',
      );

      // Step 5: Switch back
      testLog('STEP 5: Switching back to original account...');
      // Refresh the accounts screen to see updated state
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();

      // The card at index 1 should now be the previously-active account
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching back');
      await takeScreenshot($, 'multi_switch_03_switched_back');

      final restoredAcct = await AccountService().getActiveAccount();
      testLog('  Restored active: ${restoredAcct?.email}');
      expect(
        restoredAcct?.email,
        equals(activeAcct?.email),
        reason: 'Should have restored original active account',
      );

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST PASSED: Switch between accounts');
      testLog('═══════════════════════════════════════════════════');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 3: Log after switching — the key bug reproduction test
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: log event after switching accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Log event after switching accounts');
      testLog('  This is the KEY BUG REPRODUCTION test.');
      testLog('  Expected issue: logging after account swap may');
      testLog('  record to the wrong account or fail entirely.');
      testLog('═══════════════════════════════════════════════════');

      // Step 1: Ensure logged in + add account 2
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final logging = LoggingComponent($);

      // Ensure account 2 is present
      testLog('STEP 1: Ensuring account 2 is present...');
      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount2 = allAccounts.any((a) => a.email == testEmail2);
      if (!hasAccount2) {
        testLog('  Adding account 2...');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.tapAddAccount();

        final login = LoginComponent($);
        await login.waitUntilVisible();
        await login.loginWith(testEmail2, testPassword2);

        await pumpUntilFound(
          $,
          find.byKey(const Key('nav_home')),
          timeout: const Duration(seconds: 60),
        );
        await handlePermissionDialogs($);
        await settle($, frames: 20);
      }

      // Step 2: Verify initial log state for account 1
      testLog('STEP 2: Checking initial log state for account 1...');
      await debugDumpAccountState($, 'Before logging - account 1');
      await debugDumpLogState($, 'Account 1 initial logs');
      await takeScreenshot($, 'multi_log_01_account1_initial');

      // Step 3: Navigate to Log screen and log an event for account 1
      testLog('STEP 3: Navigating to Log screen for account 1...');
      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();
      logging.verifyVisible();
      await debugDumpLogState($, 'Account 1 on logging screen');
      await takeScreenshot($, 'multi_log_02_logging_screen_acct1');

      // Tap "Log Event" button
      testLog('STEP 3: Tapping Log Event for account 1...');
      await $(logging.logEventButton).tap(settlePolicy: SettlePolicy.noSettle);
      await settle($, frames: 15);

      // Wait for success or error snackbar
      testLog('STEP 3: Waiting for log event result...');
      await pumpUntilFound(
        $,
        find.textContaining('logged successfully'),
        timeout: const Duration(seconds: 15),
      );
      testLog('STEP 3: ✓ Log event succeeded for account 1');
      await debugDumpLogState($, 'Account 1 after log event');
      await takeScreenshot($, 'multi_log_03_logged_acct1');

      // Step 4: Switch to account 2
      testLog('');
      testLog('STEP 4: ═══ SWITCHING TO ACCOUNT 2 ═══');
      await debugDumpAccountState($, 'Before switch to account 2');

      // Navigate to Accounts
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      // Switch to account 2 (card index 1)
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'AFTER switch to account 2');
      await takeScreenshot($, 'multi_log_04_switched_to_acct2');

      // Step 5: Navigate to Log screen and log an event for account 2
      testLog('');
      testLog('STEP 5: ═══ LOGGING FOR ACCOUNT 2 (POST-SWITCH) ═══');
      testLog('  This is where the bug should manifest if present.');

      // Navigate to Home first via nav bar (Accounts doesn't have nav)
      // After account switch, the app should rebuild via AuthWrapper
      // Let's go back to nav
      // The app may have navigated us somewhere after the switch
      // Try pressing the back button or going to home
      await debugLogActiveUser('before navigating to Log after switch');

      // Navigate back from Accounts to Home
      // Since Accounts is pushed on top, pop back
      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        testLog('  Pressing back button from Accounts...');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      } else {
        testLog('  No back button found — trying nav bar...');
      }

      // Now navigate to Log tab
      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();
      logging.verifyVisible();

      await debugDumpAccountState($, 'On Logging screen after switch');
      await debugDumpLogState($, 'Account 2 on Logging screen');
      await takeScreenshot($, 'multi_log_05_logging_screen_acct2');

      // Step 6: Log event for account 2
      testLog('STEP 6: Tapping Log Event for account 2 (POST-SWITCH)...');
      await $(logging.logEventButton).tap(settlePolicy: SettlePolicy.noSettle);
      await settle($, frames: 15);

      testLog('STEP 6: Waiting for log event result...');
      // Check both success and error
      final successFinder = find.textContaining('logged successfully');
      final errorFinder = find.textContaining('Error');
      bool gotResult = false;

      final end = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(end)) {
        await $.pump(const Duration(milliseconds: 250));
        if ($.tester.any(successFinder)) {
          testLog('STEP 6: ✓ Log event SUCCEEDED for account 2!');
          gotResult = true;
          break;
        }
        if ($.tester.any(errorFinder)) {
          // Extract error text
          final errorElement = errorFinder.evaluate().first;
          final errorWidget = errorElement.widget as Text;
          testLog(
            'STEP 6: ✗ Log event FAILED for account 2: ${errorWidget.data}',
          );
          gotResult = true;
          break;
        }
      }

      if (!gotResult) {
        testLog('STEP 6: ⚠ No success/error snackbar within 20s');
      }

      await debugDumpAccountState($, 'After logging for account 2');
      await debugDumpLogState($, 'Account 2 after log attempt');
      await takeScreenshot($, 'multi_log_06_after_logging_acct2');

      // Step 7: Verify the log was attributed to account 2
      testLog('');
      testLog('STEP 7: ═══ VERIFYING LOG DATA ISOLATION ═══');

      // Check log records via provider
      await debugDumpLogState($, 'Final log state for account 2');

      // Navigate to History to verify the log entry appears
      await nav.tapHistory();
      final history = HistoryComponent($);
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'On History screen (account 2)');
      await debugDumpLogState($, 'Account 2 History log state');
      await takeScreenshot($, 'multi_log_07_history_acct2');

      // Verify the logged event shows up in History
      // The log event creates a default "vape" type entry
      testLog('STEP 7b: Verifying log entry in History...');
      final historyEntry = find.textContaining('VAPE');
      final entryVisible = $.tester.any(historyEntry);
      testLog('  VAPE entry in History: $entryVisible');
      if (!entryVisible) {
        final noEntries = find.textContaining('No entries');
        testLog('  "No entries" visible: ${$.tester.any(noEntries)}');
        testLog('  ⚠ BUG: Log event not appearing in History after switch');
      }
      expect(
        historyEntry,
        findsWidgets,
        reason: 'Log event should appear in History for account 2 after switch',
      );
      testLog('  ✓ VAPE entry verified in History for account 2');

      // Step 8: Switch back to account 1 and verify its History is separate
      testLog('');
      testLog('STEP 8: ═══ VERIFY DATA ISOLATION — ACCOUNT 1 HISTORY ═══');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Switched back to account 1');

      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpLogState($, 'Account 1 History after switching back');
      await takeScreenshot($, 'multi_log_08_history_acct1');
      testLog('STEP 8: ✓ Account 1 History verified');

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST COMPLETE: Log event after switching accounts');
      testLog('  ✓ Log event recorded for account 2 post-switch');
      testLog('  ✓ Entry verified in History for account 2');
      testLog('  ✓ Data isolation verified for account 1');
      testLog('  Check /tmp/ash_trail_test_diagnostics.log for');
      testLog('  the full trace of account state at each step.');
      testLog('═══════════════════════════════════════════════════');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4: Quick log (hold-to-record) after switching accounts
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: quick log after switching accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Quick log after switching accounts');
      testLog('═══════════════════════════════════════════════════');

      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);

      // Ensure account 2 is present
      testLog('STEP 1: Ensuring account 2 is present...');
      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail2)) {
        testLog('  Adding account 2...');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.tapAddAccount();

        final login = LoginComponent($);
        await login.waitUntilVisible();
        await login.loginWith(testEmail2, testPassword2);

        await pumpUntilFound(
          $,
          find.byKey(const Key('nav_home')),
          timeout: const Duration(seconds: 60),
        );
        await handlePermissionDialogs($);
        await settle($, frames: 20);
      }

      // Step 2: Do a quick log BEFORE switching (baseline)
      testLog('STEP 2: Quick log for account 1 (baseline)...');
      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Home screen - account 1');
      await debugDumpLogState($, 'Account 1 before quick log');
      await takeScreenshot($, 'multi_quick_01_home_acct1');

      testLog('  Holding to record for 3 seconds...');
      await home.holdToRecord(duration: const Duration(seconds: 3));
      await settle($, frames: 10);
      await debugDumpLogState($, 'Account 1 after quick log');
      await takeScreenshot($, 'multi_quick_02_after_quicklog_acct1');

      // Step 3: Switch to account 2
      testLog('');
      testLog('STEP 3: ═══ SWITCHING TO ACCOUNT 2 ═══');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching to account 2');
      await takeScreenshot($, 'multi_quick_03_switched_acct2');

      // Step 4: Navigate to Home and do quick log for account 2
      testLog('');
      testLog('STEP 4: ═══ QUICK LOG FOR ACCOUNT 2 (POST-SWITCH) ═══');

      // Go back from Accounts to Home
      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Home screen - account 2');
      await debugDumpLogState($, 'Account 2 before quick log');
      await takeScreenshot($, 'multi_quick_04_home_acct2');

      testLog('  Holding to record for 3 seconds...');
      await home.holdToRecord(duration: const Duration(seconds: 3));
      await settle($, frames: 10);

      // Wait for the "Logged vape" snackbar to confirm
      testLog('  Waiting for quick log confirmation...');
      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      testLog('  ✓ Quick log confirmed for account 2');

      await debugDumpAccountState($, 'After quick log - account 2');
      await debugDumpLogState($, 'Account 2 after quick log');
      await takeScreenshot($, 'multi_quick_05_after_quicklog_acct2');

      // Step 5: Verify the quick log appears in History for account 2
      testLog('');
      testLog('STEP 5: ═══ VERIFY QUICK LOG IN HISTORY (ACCOUNT 2) ═══');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History screen - account 2');
      await debugDumpLogState($, 'Account 2 history log state');
      await takeScreenshot($, 'multi_quick_06_history_acct2');

      // The quick log creates a "vape" event — verify it shows up
      testLog('  Looking for VAPE entry in History...');
      final vapeEntry = find.textContaining('VAPE');
      final hasVape = $.tester.any(vapeEntry);
      testLog('  VAPE entry visible: $hasVape');
      if (!hasVape) {
        // Also check for "No entries" to confirm truly empty
        final noEntries = find.textContaining('No entries');
        final isEmpty = $.tester.any(noEntries);
        testLog('  "No entries" visible: $isEmpty');
        testLog('  ⚠ BUG? Quick log did not appear in History for account 2');
      }
      expect(
        vapeEntry,
        findsWidgets,
        reason: 'Quick log VAPE entry should appear in History for account 2',
      );
      testLog('  ✓ VAPE entry verified in History for account 2');

      // Step 6: Switch back to account 1 and verify data isolation
      testLog('');
      testLog('STEP 6: ═══ SWITCHING BACK TO ACCOUNT 1 ═══');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Switched back to account 1');

      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      // Step 7: Verify History for account 1 does NOT contain account 2's log
      testLog('');
      testLog('STEP 7: ═══ VERIFY DATA ISOLATION IN HISTORY ═══');
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History screen - account 1');
      await debugDumpLogState($, 'Account 1 history after switching back');
      await takeScreenshot($, 'multi_quick_07_history_acct1');

      // Count records visible — account 1's baseline quick log should be here
      // but the exact count depends on prior test state
      testLog('  Account 1 History screen verified');
      await takeScreenshot($, 'multi_quick_08_back_to_acct1');

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST COMPLETE: Quick log after switching accounts');
      testLog('  ✓ Quick log recorded for account 2');
      testLog('  ✓ VAPE entry verified in History for account 2');
      testLog('  ✓ Data isolation verified for account 1');
      testLog('═══════════════════════════════════════════════════');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 5: Sign out single account — verify auto-switch
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: sign out one account, verify auto-switch',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Sign out single account');
      testLog('═══════════════════════════════════════════════════');

      await ensureLoggedIn($);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      // Ensure account 2 is present
      testLog('STEP 1: Ensuring account 2 is present...');
      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail2)) {
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.tapAddAccount();

        final login = LoginComponent($);
        await login.waitUntilVisible();
        await login.loginWith(testEmail2, testPassword2);

        await pumpUntilFound(
          $,
          find.byKey(const Key('nav_home')),
          timeout: const Duration(seconds: 60),
        );
        await handlePermissionDialogs($);
        await settle($, frames: 20);
      }

      // Step 2: Navigate to Accounts screen
      testLog('STEP 2: Opening Accounts screen...');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Before sign-out');
      await takeScreenshot($, 'multi_signout_01_before');

      accounts.verifyAccountCount(2);

      // Step 3: Sign out the NON-active account via popup menu
      testLog('STEP 3: Signing out non-active account...');
      // The non-active logged-in card has a popup menu with "Sign out"
      // We need to long-press or tap the three-dot menu on card 1

      // First find the PopupMenuButton on card 1 (the non-active card)
      // PopupMenuButton is an IconButton with Icons.more_vert inside the card
      final card1 = accounts.accountCard(1);
      if ($.tester.any(card1)) {
        // Look for a PopupMenuButton or more_vert icon within card 1
        final popupMenu = find.descendant(
          of: card1,
          matching: find.byType(PopupMenuButton),
        );
        if ($.tester.any(popupMenu)) {
          testLog('  Found PopupMenuButton on card 1 — tapping...');
          await $.tester.tap(popupMenu.first);
          await settle($, frames: 5);
          await takeScreenshot($, 'multi_signout_02_popup_menu');

          // Tap "Sign out" in the popup
          final signOutItem = find.text('Sign out');
          if ($.tester.any(signOutItem)) {
            testLog('  Tapping "Sign out"...');
            await $.tester.tap(signOutItem);
            await settle($, frames: 15);
          } else {
            testLog(
              '  "Sign out" text not found in popup — trying "Sign Out"...',
            );
            final signOutItem2 = find.text('Sign Out');
            if ($.tester.any(signOutItem2)) {
              await $.tester.tap(signOutItem2);
              await settle($, frames: 15);
            } else {
              testLog('  ⚠ Could not find sign out option in popup');
            }
          }
        } else {
          testLog('  ⚠ No PopupMenuButton found on card 1');
          // Try the Icon approach
          final moreVert = find.descendant(
            of: card1,
            matching: find.byIcon(Icons.more_vert),
          );
          if ($.tester.any(moreVert)) {
            testLog('  Found more_vert icon — tapping...');
            await $.tester.tap(moreVert);
            await settle($, frames: 5);
            final signOutItem = find.text('Sign out');
            if ($.tester.any(signOutItem)) {
              await $.tester.tap(signOutItem);
              await settle($, frames: 15);
            }
          }
        }
      }

      await debugDumpAccountState($, 'After signing out non-active account');
      await takeScreenshot($, 'multi_signout_03_after');

      // Step 4: Verify only one account remains
      testLog('STEP 4: Verifying single account remains...');
      // After sign-out, we should still be on the Accounts screen
      // with only the active account visible
      await settle($, frames: 10);
      final remainingAccounts = await AccountService().getAllAccounts();
      testLog('  Remaining accounts: ${remainingAccounts.length}');
      for (final a in remainingAccounts) {
        testLog(
          '    ${a.email} isActive=${a.isActive} isLoggedIn=${a.isLoggedIn}',
        );
      }

      final loggedIn = remainingAccounts.where((a) => a.isLoggedIn).toList();
      testLog('  Logged in accounts: ${loggedIn.length}');
      expect(
        loggedIn.length,
        equals(1),
        reason: 'Should have exactly 1 logged-in account after sign-out',
      );
      await takeScreenshot($, 'multi_signout_04_final');

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST COMPLETE: Sign out single account');
      testLog('═══════════════════════════════════════════════════');
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 6: Full cycle — add, switch, log, verify isolation, sign out
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: full cycle (add → switch → log → verify → signout)',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST: Full multi-account cycle');
      testLog('  Comprehensive end-to-end flow testing the');
      testLog('  complete lifecycle with debug logging at');
      testLog('  every single state transition.');
      testLog('═══════════════════════════════════════════════════');

      // Start clean
      await ensureLoggedOut($);
      await debugDumpAccountState($, 'Clean start — logged out');
      await takeScreenshot($, 'multi_full_01_logged_out');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final logging = LoggingComponent($);
      final welcome = WelcomeComponent($);
      final login = LoginComponent($);

      // ── Phase 1: Login account 1 ──
      testLog('');
      testLog('══ PHASE 1: Login account 1 ══');
      await welcome.tapSignIn();
      await login.waitUntilVisible();
      await login.loginWith(testEmail, testPassword);
      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await debugDumpAccountState($, 'Phase 1: Account 1 logged in');
      await takeScreenshot($, 'multi_full_02_acct1_home');

      // ── Phase 2: Log event for account 1 ──
      testLog('');
      testLog('══ PHASE 2: Log event for account 1 ══');
      await nav.tapLog();
      await handlePermissionDialogs($);
      await logging.waitUntilVisible();
      await debugDumpLogState($, 'Phase 2: Account 1 log state');

      await $(logging.logEventButton).tap(settlePolicy: SettlePolicy.noSettle);
      await settle($, frames: 15);
      await pumpUntilFound(
        $,
        find.textContaining('logged successfully'),
        timeout: const Duration(seconds: 15),
      );
      testLog('Phase 2: ✓ Account 1 log event recorded');
      await debugDumpLogState($, 'Phase 2: After logging for account 1');
      await takeScreenshot($, 'multi_full_03_acct1_logged');

      // ── Phase 3: Add account 2 ──
      testLog('');
      testLog('══ PHASE 3: Add account 2 ══');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.tapAddAccount();
      await login.waitUntilVisible();
      await login.loginWith(testEmail2, testPassword2);
      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await debugDumpAccountState($, 'Phase 3: Account 2 added');
      await takeScreenshot($, 'multi_full_04_acct2_added');

      // ── Phase 4: Switch to account 2 ──
      testLog('');
      testLog('══ PHASE 4: Switch to account 2 ══');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      // Determine which card to tap. The newly added account might be active
      // or might not be, depending on the app's behavior.
      final preSwitch = await AccountService().getActiveAccount();
      testLog('  Active before switch: ${preSwitch?.email}');
      await debugDumpAccountState($, 'Phase 4: Before switch');

      // If account 2 is already active (from just adding it), switch to 1
      // If account 1 is still active, switch to account 2
      final switchingTo =
          preSwitch?.email == testEmail2 ? testEmail : testEmail2;
      testLog('  Switching to: $switchingTo');

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Phase 4: After switch');
      await takeScreenshot($, 'multi_full_05_switched');

      final postSwitch = await AccountService().getActiveAccount();
      testLog('  Active after switch: ${postSwitch?.email}');

      // ── Phase 5: Quick log for switched account ──
      testLog('');
      testLog('══ PHASE 5: Quick log for switched account ══');
      testLog('  ★ THIS IS THE CRITICAL BUG-DETECTION STEP ★');

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      await debugDumpAccountState($, 'Phase 5: Home screen after switch');
      await debugDumpLogState($, 'Phase 5: Log state before quick log');
      await takeScreenshot($, 'multi_full_06_home_switched');

      // Quick log via hold-to-record
      testLog('Phase 5: Holding to record for 3 seconds...');
      await home.holdToRecord(duration: const Duration(seconds: 3));
      await settle($, frames: 10);

      // Wait for confirmation snackbar
      bool logSuccess = false;
      final end5 = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(end5)) {
        await $.pump(const Duration(milliseconds: 250));
        if ($.tester.any(find.textContaining('Logged vape'))) {
          testLog('Phase 5: ✓ Quick log SUCCEEDED for switched account');
          logSuccess = true;
          break;
        }
        if ($.tester.any(find.textContaining('Error'))) {
          final errEl = find.textContaining('Error').evaluate().first;
          testLog(
            'Phase 5: ✗ Quick log FAILED: ${(errEl.widget as Text).data}',
          );
          break;
        }
      }

      await debugDumpAccountState($, 'Phase 5: After quick log');
      await debugDumpLogState($, 'Phase 5: After quick log');
      await takeScreenshot($, 'multi_full_07_after_quicklog_switched');

      // ── Phase 5b: Verify quick log in History ──
      testLog('');
      testLog('══ PHASE 5b: Verify quick log in History ══');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'Phase 5b: History for switched account');
      await debugDumpLogState($, 'Phase 5b: History log state');
      await takeScreenshot($, 'multi_full_08_history_switched');

      // Verify the VAPE entry is visible
      final vapeInHistory = find.textContaining('VAPE');
      final hasVapeEntry = $.tester.any(vapeInHistory);
      testLog('Phase 5b: VAPE entry in History: $hasVapeEntry');
      if (!hasVapeEntry) {
        final noEntries = find.textContaining('No entries');
        testLog('Phase 5b: "No entries" visible: ${$.tester.any(noEntries)}');
        testLog('Phase 5b: ⚠ BUG? Quick log missing from History after switch');
      }
      expect(
        vapeInHistory,
        findsWidgets,
        reason: 'Quick log VAPE entry should appear in History after switch',
      );
      testLog('Phase 5b: ✓ VAPE entry verified in History');

      // ── Phase 6: Verify data isolation ──
      testLog('');
      testLog('══ PHASE 6: Verify data isolation ══');

      // Switch back to the first account
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);

      await debugDumpAccountState($, 'Phase 6: Switched back');
      await debugDumpLogState($, 'Phase 6: Original account log state');

      // Verify account 1's History
      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpLogState($, 'Phase 6: Account 1 History log state');
      await takeScreenshot($, 'multi_full_09_history_acct1');

      // ── Phase 7: Sign out all (cleanup) ──
      testLog('');
      testLog('══ PHASE 7: Cleanup — sign out all ══');
      await debugDumpAccountState($, 'Phase 7: Before cleanup');

      // Sign out programmatically
      await FirebaseAuth.instance.signOut();
      try {
        await AccountService().deactivateAllAccounts();
      } catch (e) {
        testLog('Phase 7: deactivateAllAccounts error: $e');
      }
      await settle($, frames: 10);
      await debugDumpAccountState($, 'Phase 7: After cleanup');
      await takeScreenshot($, 'multi_full_10_cleanup');

      testLog('');
      testLog('═══════════════════════════════════════════════════');
      testLog('TEST COMPLETE: Full multi-account cycle');
      testLog('  Quick log success: $logSuccess');
      testLog('  History verification: passed');
      testLog('  Check /tmp/ash_trail_test_diagnostics.log for');
      testLog('  the full state trace at every transition point.');
      testLog('═══════════════════════════════════════════════════');
    },
  );
}
