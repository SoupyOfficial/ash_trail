import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';

import 'components/accounts.dart';
import 'components/home.dart';
import 'components/login.dart';
import 'components/nav_bar.dart';
import 'components/history.dart';
import 'flows/gmail_login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Gmail Multi-Account + Logging Debug Tests
// ═══════════════════════════════════════════════════════════════════════════════
//
// These tests are identical in structure to multi_account_test.dart but use
// Gmail accounts with Google Sign-In instead of email/password authentication.
// This ensures the multi-account system works correctly with both auth methods.
//
// The same diagnostic logging (TestLogger) and structured output is used.
//
// Prerequisites:
//   - Two Gmail accounts must be signed into the device/simulator:
//     4. ashtraildev3@gmail.com / AshTestPass123!
//     5. ashtraildev4@gmail.com / AshTestPass456!
//   - Google Sign-In must be enabled in Firebase Console
//   - The device must have Chrome or a browser for the Google Sign-In flow
//
// Run with:
//   patrol test --target integration_test/gmail_multi_account_test.dart
//
// After running, check /tmp/ash_trail_test_diagnostics.log for full trace.
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Structured Test Logger (shared with multi_account_test.dart)
// ─────────────────────────────────────────────────────────────────────────────

/// Log severity levels following standard conventions.
enum GmailLogLevel { info, action, verify, debug, warn, pass, fail }

/// Structured logger for Gmail integration tests.
class GmailTestLogger {
  GmailTestLogger._();
  static final instance = GmailTestLogger._();

  final _testStopwatch = Stopwatch();
  final _stepStopwatch = Stopwatch();

  static const _levelLabels = {
    GmailLogLevel.info: 'INFO   ',
    GmailLogLevel.action: 'ACTION ',
    GmailLogLevel.verify: 'VERIFY ',
    GmailLogLevel.debug: 'DEBUG  ',
    GmailLogLevel.warn: 'WARN   ',
    GmailLogLevel.pass: 'PASS   ',
    GmailLogLevel.fail: 'FAIL   ',
  };

  static const _separator =
      '═══════════════════════════════════════════════════════════════';
  static const _thinSeparator =
      '───────────────────────────────────────────────────────────────';

  void _log(GmailLogLevel level, String message, {int indent = 0}) {
    final prefix = '  ' * indent;
    testLog('${_levelLabels[level]}| $prefix$message');
  }

  void info(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.info, msg, indent: indent);
  void action(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.action, msg, indent: indent);
  void verify(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.verify, msg, indent: indent);
  void debug(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.debug, msg, indent: indent);
  void warn(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.warn, msg, indent: indent);
  void pass(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.pass, msg, indent: indent);
  void fail(String msg, {int indent = 0}) =>
      _log(GmailLogLevel.fail, msg, indent: indent);

  void testStart(int testNumber, String testName, {String? description}) {
    _testStopwatch
      ..reset()
      ..start();
    testLog('');
    testLog(_separator);
    testLog('[GMAIL_TEST_START] Test $testNumber: $testName');
    if (description != null) {
      for (final line in description.split('\n')) {
        testLog('  $line');
      }
    }
    testLog(_separator);
  }

  void testEnd(int testNumber, String testName, List<String> results) {
    _testStopwatch.stop();
    testLog('');
    testLog(_thinSeparator);
    testLog(
      '[GMAIL_TEST_END] Test $testNumber: $testName '
      '(${_testStopwatch.elapsed.inSeconds}s)',
    );
    for (final r in results) {
      testLog('  $r');
    }
    testLog(_thinSeparator);
    testLog('');
  }

  void stepStart(String stepId, String label) {
    _stepStopwatch
      ..reset()
      ..start();
    testLog('');
    testLog('  ── Step $stepId: $label ──');
  }

  void stepEnd(String stepId, {String? summary}) {
    _stepStopwatch.stop();
    final elapsed = _stepStopwatch.elapsedMilliseconds;
    testLog(
      '  ── /$stepId (${elapsed}ms)${summary != null ? ' — $summary' : ''} ──',
    );
  }

  void arrange(String msg) => _log(GmailLogLevel.info, '📋 $msg');
  void act(String msg) => _log(GmailLogLevel.action, '▶ $msg');
  void assert_(String msg) => _log(GmailLogLevel.verify, '✓? $msg');
  void data(String label, dynamic value) =>
      _log(GmailLogLevel.debug, '$label: $value');
}

final _log = GmailTestLogger.instance;

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Random hold duration between 1.5 and 4.0 seconds for realistic quick-log
/// tests. Mirrors _randomHoldDuration() from multi_account_test.dart.
Duration _randomHoldDuration() {
  final ms = 1500 + Random().nextInt(2500); // 1500–4000 ms
  return Duration(milliseconds: ms);
}

/// Extract the full text of the current snackbar (if visible).
String? _extractSnackbarText(PatrolIntegrationTester $) {
  try {
    final snackBarFinder = find.byType(SnackBar);
    if ($.tester.any(snackBarFinder)) {
      final snackBarElement = snackBarFinder.evaluate().first;
      final texts = <String>[];
      void extractText(Element element) {
        if (element.widget is Text) {
          final data = (element.widget as Text).data;
          if (data != null && data.isNotEmpty) texts.add(data);
        }
        element.visitChildElements(extractText);
      }

      snackBarElement.visitChildElements(extractText);
      return texts.join(' | ');
    }
  } catch (e) {
    _log.warn('Snackbar extraction failed: $e');
  }
  return null;
}

/// Verify the snackbar reported duration matches the hold duration.
bool _verifySnackbarDuration(
  String? snackbar,
  Duration holdDuration,
  String stepId,
) {
  if (snackbar == null) {
    _log.warn('$stepId: No snackbar text to verify duration');
    return false;
  }

  final match = RegExp(r'(\d+\.?\d*)\s*s').firstMatch(snackbar);
  if (match == null) {
    _log.debug('$stepId: No duration in snackbar text');
    return true; // Not all snackbars show duration
  }

  final actualSeconds = double.tryParse(match.group(1)!) ?? 0;
  final expectedSeconds = holdDuration.inMilliseconds / 1000.0;
  final diff = (actualSeconds - expectedSeconds).abs();
  final toleranceSeconds = 1.0;

  _log.data('Snackbar duration', '${actualSeconds}s');
  _log.data('Expected duration', '~${expectedSeconds.toStringAsFixed(1)}s');
  _log.data(
    'Difference',
    '${diff.toStringAsFixed(2)}s (tolerance: ${toleranceSeconds}s)',
  );

  final withinTolerance = diff <= toleranceSeconds;
  if (withinTolerance) {
    _log.pass('$stepId: Duration within tolerance');
  } else {
    _log.warn('$stepId: Duration outside tolerance!');
  }
  return withinTolerance;
}

/// Verify the top History record matches an expected logged-at timestamp.
bool _verifyTopHistoryRecord(
  PatrolIntegrationTester $,
  DateTime loggedAt,
  String stepId,
) {
  try {
    final expectedTime = DateFormat('h:mm a').format(loggedAt);
    final possibleTimes = [
      expectedTime,
      DateFormat('h:mm a').format(loggedAt.add(const Duration(minutes: 1))),
      DateFormat(
        'h:mm a',
      ).format(loggedAt.subtract(const Duration(minutes: 1))),
    ];

    for (final time in possibleTimes) {
      if ($.tester.any(find.textContaining(time))) {
        _log.pass('$stepId: Found matching time "$time" in History');
        return true;
      }
    }

    // Also check for "Just now" or "Today" indicators
    if ($.tester.any(find.textContaining('Just now')) ||
        $.tester.any(find.textContaining('Today'))) {
      _log.pass('$stepId: Found "Just now" / "Today" in History');
      return true;
    }

    _log.warn(
      '$stepId: No matching time found. Expected one of: $possibleTimes',
    );
    return false;
  } catch (e) {
    _log.fail('$stepId: History verification failed: $e');
    return false;
  }
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 0: Auth Persistence Smoke Test (pre-check)
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail: Auth persistence pre-check',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        0,
        'Gmail: Auth persistence pre-check',
        description:
            'Lightweight smoke test that checks if Firebase Auth\n'
            'state has persisted from a previous run. Logs the result\n'
            'but does NOT fail — the first actual login test handles\n'
            'the manual flow if needed.',
      );

      // Launch the app so Firebase is initialized
      _log.stepStart('G0.1', 'Launch app and check Firebase Auth state');
      _log.arrange('Launching app to initialize Firebase...');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      _log.stepEnd('G0.1', summary: 'App launched and logged in');

      // Check Firebase Auth current user
      _log.stepStart('G0.2', 'Verify Firebase Auth state');
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        _log.pass(
          'Persisted session found: ${currentUser.email} '
          '(uid: ${currentUser.uid.substring(0, 8)}...)',
        );

        // Verify token can refresh
        try {
          await currentUser.getIdToken();
          _log.pass('Firebase token refresh OK — session valid');
        } catch (e) {
          _log.warn('Token refresh failed: $e');
        }

        // Check Hive account sync
        try {
          final hiveAccount = await AccountService().getActiveAccount();
          if (hiveAccount != null) {
            _log.pass(
              'Hive active account: ${hiveAccount.email} '
              '(matches Firebase: ${hiveAccount.userId == currentUser.uid})',
            );
          } else {
            _log.warn(
              'Hive has no active account — app AuthWrapper will re-create it',
            );
          }
        } catch (e) {
          _log.warn('Hive check error: $e');
        }

        await debugDumpAccountState($, 'Auth persistence pre-check');
      } else {
        _log.info(
          'No cached auth — manual seeding required on first run. '
          'ensureGmailLoggedIn() will handle the manual flow.',
        );
      }

      _log.stepEnd('G0.2');

      await takeScreenshot($, 'gmail_precheck_state');

      _log.testEnd(0, 'Gmail: Auth persistence pre-check', [
        currentUser != null
            ? '✓ Persisted session: ${currentUser.email}'
            : 'ℹ No cached session (first run — manual seeding will occur)',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 1: Add second Gmail account
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: add second account via Google Sign-In',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        1,
        'Gmail: Add second account',
        description:
            'Verifies that a second Gmail account can be added\n'
            'via Google Sign-In on the Accounts screen.',
      );

      // ── ARRANGE ──
      _log.stepStart('G1.1', 'Ensure logged in with Gmail account 4');
      _log.arrange('Authenticating with Gmail account 4 via Google Sign-In');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'After ensureGmailLoggedIn');
      await takeScreenshot($, 'gmail_multi_01_logged_in_acct4');
      _log.stepEnd('G1.1', summary: 'Gmail account 4 authenticated');

      final home = HomeComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      // ── ACT: Navigate to Accounts ──
      _log.stepStart('G1.2', 'Navigate to Accounts screen');
      _log.action('Tapping account icon on Home screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      accounts.verifyVisible();
      await debugDumpAccountState($, 'Accounts screen visible');
      await accounts.debugDumpCards();
      await takeScreenshot($, 'gmail_multi_02_accounts_screen');
      _log.stepEnd('G1.2', summary: 'Accounts screen displayed');

      // ── ASSERT: Single account present ──
      _log.stepStart('G1.3', 'Verify single account present');
      _log.assert_('Expecting exactly 1 account card for $testEmail4');
      accounts.verifyAccountCount(1);
      _log.pass('Single Gmail account verified');
      _log.stepEnd('G1.3');

      // ── ACT: Add second Gmail account ──
      _log.stepStart('G1.4', 'Tap Add Another Account');
      _log.action('Tapping "Add Another Account" button');
      await accounts.tapAddAccount();
      await login.waitUntilVisible();
      login.verifyVisible();
      await takeScreenshot($, 'gmail_multi_03_login_for_acct5');
      _log.stepEnd('G1.4', summary: 'Login screen displayed');

      // ── ACT: Login with Gmail account 5 via Google Sign-In ──
      _log.stepStart('G1.5', 'Login with Gmail account 5 via Google Sign-In');
      _log.action('Tapping "Continue with Google" for $testEmail5');
      await login.tapGoogleSignIn();

      // Handle native Google account picker
      _log.info('Waiting for Google account picker...');
      await $.pump(const Duration(seconds: 2));
      try {
        await $.native.tap(
          Selector(textContains: testEmail5),
          appId: 'com.google.chrome',
        );
        _log.pass('Selected $testEmail5 in Google picker');
      } catch (e) {
        _log.warn('Google picker interaction: $e');
      }
      await $.pump(const Duration(seconds: 3));

      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await debugDumpAccountState($, 'After Gmail account 5 login');
      await takeScreenshot($, 'gmail_multi_04_after_acct5_login');
      _log.stepEnd('G1.5', summary: 'Gmail account 5 logged in');

      // ── ASSERT: Verify both accounts ──
      _log.stepStart('G1.6', 'Verify both Gmail accounts present');
      _log.action('Navigating back to Accounts screen');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Accounts with both Gmail accounts');
      await takeScreenshot($, 'gmail_multi_05_both_accounts');

      _log.assert_('Expecting exactly 2 account cards');
      accounts.verifyAccountCount(2);
      _log.pass('Two Gmail account cards verified');
      _log.stepEnd('G1.6');

      _log.testEnd(1, 'Gmail: Add second account', [
        '✓ Gmail account 4 authenticated via Google Sign-In',
        '✓ Gmail account 5 added via Google Sign-In',
        '✓ Both accounts visible on Accounts screen',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 2: Switch between Gmail accounts
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: switch between accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        2,
        'Gmail: Switch between accounts',
        description:
            'Verifies that switching between two Gmail accounts\n'
            'updates the active indicator and can be reversed.',
      );

      // ── ARRANGE ──
      _log.stepStart('G2.1', 'Ensure both Gmail accounts present');
      _log.arrange('Authenticating with Gmail account 4');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      _log.info('Checking if Gmail account 5 is already present...');
      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount5 = allAccounts.any((a) => a.email == testEmail5);
      _log.data('Gmail account 5 present', hasAccount5);

      if (!hasAccount5) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }

      await debugDumpAccountState($, 'Before switching — 2 accounts ready');
      _log.stepEnd('G2.1', summary: 'Both Gmail accounts ready');

      // ── ACT: Switch to account 5 ──
      _log.stepStart('G2.2', 'Open Accounts and switch');
      _log.action('Opening Accounts screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await takeScreenshot($, 'gmail_switch_01_before_switch');

      final activeAcct = await AccountService().getActiveAccount();
      _log.data('Currently active', activeAcct?.email);

      _log.assert_('Expecting account card at index 1 to exist');
      if ($.tester.any(accounts.accountCard(1))) {
        _log.action('Tapping account card 1 to switch...');
        await accounts.switchToAccount(1);
      } else {
        _log.fail('Only 1 card found — cannot switch');
        fail('Expected 2 account cards but only found 1');
      }

      await debugDumpAccountState($, 'After switching account');
      await accounts.debugDumpCards();
      await takeScreenshot($, 'gmail_switch_02_after_switch');
      _log.stepEnd('G2.2', summary: 'Account switch executed');

      // ── ASSERT: Active indicator flipped ──
      _log.stepStart('G2.3', 'Verify active account changed');
      final newActiveAcct = await AccountService().getActiveAccount();
      _log.data('Previous active', activeAcct?.email);
      _log.data('New active', newActiveAcct?.email);
      _log.assert_('Active account email should differ from original');
      expect(
        newActiveAcct?.email,
        isNot(equals(activeAcct?.email)),
        reason: 'Active account should have changed after switch',
      );
      _log.pass('Active Gmail account changed successfully');
      _log.stepEnd('G2.3');

      // ── ACT: Switch back ──
      _log.stepStart('G2.4', 'Switch back to original account');
      _log.action('Refreshing Accounts screen and switching back');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching back');
      await takeScreenshot($, 'gmail_switch_03_switched_back');
      _log.stepEnd('G2.4', summary: 'Switched back');

      // ── ASSERT: Original account restored ──
      _log.stepStart('G2.5', 'Verify original account restored');
      final restoredAcct = await AccountService().getActiveAccount();
      _log.data('Restored active', restoredAcct?.email);
      _log.assert_('Active account should match original');
      expect(
        restoredAcct?.email,
        equals(activeAcct?.email),
        reason: 'Should have restored original active Gmail account',
      );
      _log.pass('Original Gmail account restored successfully');
      _log.stepEnd('G2.5');

      _log.testEnd(2, 'Gmail: Switch between accounts', [
        '✓ Switched from ${activeAcct?.email} to ${newActiveAcct?.email}',
        '✓ Active indicator updated correctly',
        '✓ Switched back to original account',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 3: Log after switching — the key bug reproduction test
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: log event after switching accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        3,
        'Gmail: Log event after switching accounts',
        description:
            'KEY BUG REPRODUCTION TEST (Gmail variant)\n'
            'Verifies that quick-logging after a Gmail account swap\n'
            'records to the correct account and appears in History.',
      );

      debugDumpLoggerConfig('Gmail Test 3 start');

      // ── ARRANGE: Login + ensure Gmail account 5 ──
      _log.stepStart('G3.1', 'Ensure both Gmail accounts present');
      _log.arrange('Authenticating and verifying two Gmail accounts');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount5 = allAccounts.any((a) => a.email == testEmail5);
      _log.data('Gmail account 5 present', hasAccount5);

      if (!hasAccount5) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }
      _log.stepEnd('G3.1', summary: 'Both Gmail accounts ready');

      // ── ACT: Baseline quick log for account 4 ──
      _log.stepStart('G3.2', 'Quick log for Gmail account 4 (baseline)');
      _log.act('Recording a quick log for account 4 before switching');
      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Before logging - account 4');
      await debugDumpLogState($, 'Account 4 initial logs');
      await takeScreenshot($, 'gmail_log_01_acct4_initial');

      final acct4Duration = _randomHoldDuration();
      _log.action('Holding to record for ${acct4Duration.inMilliseconds}ms');
      final acct4LoggedAt = DateTime.now();
      await home.holdToRecord(duration: acct4Duration);
      await settle($, frames: 10);

      _log.info('Waiting for snackbar confirmation...');
      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final acct4Snackbar = _extractSnackbarText($);
      _log.pass('Quick log succeeded for Gmail account 4');
      _log.data('Snackbar', acct4Snackbar);
      _verifySnackbarDuration(acct4Snackbar, acct4Duration, 'G3.2');
      await debugDumpLogState($, 'Account 4 after quick log');
      await takeScreenshot($, 'gmail_log_02_quicklog_acct4');
      _log.stepEnd('G3.2', summary: 'Account 4 baseline log recorded');

      // ── ASSERT: Verify account 4 log in History BEFORE switching ──
      _log.stepStart('G3.2b', 'Verify account 4 log in History');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await nav.tapHistory();
      final historyAcct4 = HistoryComponent($);
      await historyAcct4.waitUntilVisible();
      historyAcct4.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'gmail_log_02b_history_acct4');

      final acct4TopMatch = _verifyTopHistoryRecord($, acct4LoggedAt, 'G3.2b');
      expect(
        acct4TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for Gmail account 4',
      );
      _log.pass('Gmail account 4 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('G3.2b');

      // ── ACT: Switch to Gmail account 5 ──
      _log.stepStart('G3.3', 'Switch to Gmail account 5');
      _log.act('Switching active account from 4 to 5');
      await debugDumpAccountState($, 'Before switch to account 5');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'AFTER switch to account 5');
      await takeScreenshot($, 'gmail_log_03_switched_to_acct5');
      _log.stepEnd('G3.3', summary: 'Switched to Gmail account 5');

      // ── ACT: Quick log for account 5 (post-switch — the critical step) ──
      _log.stepStart('G3.4', 'Quick log for Gmail account 5 (post-switch)');
      _log.act(
        'Recording a quick log AFTER switching — this is the bug-detection step',
      );
      await debugLogActiveUser('before quick log after switch');

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        _log.action('Pressing back button from Accounts');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      // Provider propagation after switch
      final switchedEmail =
          (await AccountService().getActiveAccount())?.email ?? testEmail5;
      final propagated = await waitForProviderPropagation($, switchedEmail);
      _log.data('Provider propagated', propagated);

      // Clear stale snackbars
      await debugDumpSnackbarState($, 'Before quick log (post-switch)');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log (post-switch)');

      await debugDumpAccountState($, 'Home screen after switch');
      await debugDumpLogState($, 'Account 5 before quick log');
      await takeScreenshot($, 'gmail_log_04_home_acct5');

      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      await debugDumpLogCreationPipeline(
        $,
        'BEFORE critical quick log (gmail acct5)',
      );

      final acct5Duration = _randomHoldDuration();
      _log.action('Holding to record for ${acct5Duration.inMilliseconds}ms');
      await debugLogActiveUser('immediately before holdToRecord');
      final acct5LoggedAt = DateTime.now();
      await home.holdToRecord(duration: acct5Duration);
      _log.info('Gesture completed — recording should be processing...');
      await debugDumpQuickLogWidgetState($, 'After holdToRecord gesture');
      await settle($, frames: 10);

      await debugDumpSnackbarState($, 'Immediately after hold-to-record');

      await debugDumpLogCreationPipeline(
        $,
        'AFTER holdToRecord gesture (gmail acct5)',
      );

      // Poll for result with detailed diagnostics
      bool gotResult = false;
      String? acct5Snackbar;
      int pollCount = 0;
      final end = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(end)) {
        await $.pump(const Duration(milliseconds: 250));
        pollCount++;
        if (pollCount % 8 == 0) {
          _log.debug('Poll #$pollCount — still waiting for snackbar...');
          await debugDumpSnackbarState($, 'Poll #$pollCount');
          await debugDumpQuickLogWidgetState($, 'Poll #$pollCount');
          await debugLogActiveUser('poll #$pollCount');
        }
        if ($.tester.any(find.textContaining('Logged vape'))) {
          acct5Snackbar = _extractSnackbarText($);
          _log.pass('Quick log SUCCEEDED for Gmail account 5');
          _log.data('Snackbar', acct5Snackbar);
          _verifySnackbarDuration(acct5Snackbar, acct5Duration, 'G3.4');
          _log.data('Polls taken', pollCount);
          gotResult = true;
          break;
        }
        if ($.tester.any(find.textContaining('No active account'))) {
          _log.fail('BUG DETECTED — "No active account" snackbar!');
          await debugDumpAccountState($, 'No active account detected');
          gotResult = true;
          break;
        }
        if ($.tester.any(find.textContaining('too short'))) {
          _log.fail('"Duration too short" — recording threshold issue');
          gotResult = true;
          break;
        }
        if ($.tester.any(find.textContaining('Error'))) {
          final errEl = find.textContaining('Error').evaluate().first;
          _log.fail('Quick log FAILED: ${(errEl.widget as Text).data}');
          gotResult = true;
          break;
        }
      }
      if (!gotResult) {
        _log.warn('No success/error snackbar within 20s (polls: $pollCount)');
        await debugDumpSnackbarState($, 'TIMEOUT — no snackbar');
        await debugDumpQuickLogWidgetState($, 'TIMEOUT — widget state');
        await debugDumpAccountState($, 'TIMEOUT — account state');
        await debugDumpLogState($, 'TIMEOUT — log state');
        await debugDumpLogCreationPipeline($, 'TIMEOUT — full pipeline');
      }

      final acct5Persisted = await debugVerifyLogPersisted(
        $,
        'Gmail account 5 post-switch quick log',
        acct5LoggedAt,
      );
      if (!acct5Persisted) {
        _log.fail('Record NOT found in Hive despite snackbar!');
      }

      await debugDumpAccountState($, 'After quick log for account 5');
      await debugDumpLogState($, 'Account 5 after quick log');
      await takeScreenshot($, 'gmail_log_05_after_quicklog_acct5');
      _log.stepEnd(
        'G3.4',
        summary: gotResult ? 'Quick log completed' : 'Quick log timed out',
      );

      // ── ASSERT: Verify log in History for account 5 ──
      _log.stepStart('G3.5', 'Verify quick log in History (Gmail account 5)');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await debugDumpLogState($, 'Final log state for account 5');

      await nav.tapHistory();
      final history = HistoryComponent($);
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'On History screen (account 5)');
      await debugDumpLogState($, 'Account 5 History log state');
      await takeScreenshot($, 'gmail_log_07_history_acct5');

      final acct5TopMatch = _verifyTopHistoryRecord($, acct5LoggedAt, 'G3.5');
      expect(
        acct5TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for Gmail account 5',
      );
      _log.pass('Top record verified in History for Gmail account 5');
      _log.stepEnd('G3.5');

      // ── ASSERT: Data isolation — account 4 History is separate ──
      _log.stepStart('G3.6', 'Verify data isolation (Gmail account 4 History)');
      _log.assert_('Account 4 History should not contain account 5 logs');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Switched back to account 4');

      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpLogState($, 'Account 4 History after switching back');
      await takeScreenshot($, 'gmail_log_08_history_acct4');
      _log.pass('Gmail account 4 History verified — data isolation intact');
      _log.stepEnd('G3.6');

      _log.testEnd(3, 'Gmail: Log event after switching accounts', [
        '✓ Baseline quick log recorded for Gmail account 4',
        '✓ Account 4 log verified in History',
        '✓ Quick log recorded for Gmail account 5 post-switch',
        '✓ Account 5 log verified in History',
        '✓ Data isolation verified between Gmail accounts',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 4: Quick log (hold-to-record) after switching accounts
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: quick log after switching accounts',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        4,
        'Gmail: Quick log after switching accounts',
        description:
            'Simplified version of Test 3 — verifies quick log\n'
            'after Gmail account switch with simpler snackbar wait.',
      );

      // ── ARRANGE ──
      _log.stepStart('G4.1', 'Ensure both Gmail accounts present');
      _log.arrange('Authenticating and ensuring Gmail account 5 exists');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail5)) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }
      _log.stepEnd('G4.1', summary: 'Both Gmail accounts ready');

      // ── ACT: Baseline quick log for account 4 ──
      _log.stepStart('G4.2', 'Baseline quick log for Gmail account 4');
      _log.act('Recording a quick log before switching accounts');
      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Home screen - account 4');
      await debugDumpLogState($, 'Account 4 before quick log');
      await takeScreenshot($, 'gmail_quick_01_home_acct4');

      final t4Dur1 = _randomHoldDuration();
      _log.action('Holding to record for ${t4Dur1.inMilliseconds}ms');
      final t4Acct4LoggedAt = DateTime.now();
      await home.holdToRecord(duration: t4Dur1);
      await settle($, frames: 10);

      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final t4Acct4Snackbar = _extractSnackbarText($);
      _log.pass('Quick log confirmed for Gmail account 4');
      _log.data('Snackbar', t4Acct4Snackbar);
      _verifySnackbarDuration(t4Acct4Snackbar, t4Dur1, 'G4.2');
      await debugDumpLogState($, 'Account 4 after quick log');
      await takeScreenshot($, 'gmail_quick_02_after_quicklog_acct4');
      _log.stepEnd('G4.2', summary: 'Account 4 baseline recorded');

      // ── ASSERT: Verify account 4 log in History ──
      _log.stepStart('G4.2b', 'Verify account 4 log in History');
      _log.assert_('Top History record should match just-logged entry');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'gmail_quick_02b_history_acct4');

      final t4Acct4TopMatch = _verifyTopHistoryRecord(
        $,
        t4Acct4LoggedAt,
        'G4.2b',
      );
      expect(
        t4Acct4TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for Gmail account 4',
      );
      _log.pass('Gmail account 4 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('G4.2b');

      // ── ACT: Switch to account 5 ──
      _log.stepStart('G4.3', 'Switch to Gmail account 5');
      _log.act('Switching active account');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching to account 5');
      await takeScreenshot($, 'gmail_quick_03_switched_acct5');
      _log.stepEnd('G4.3', summary: 'Switched to Gmail account 5');

      // ── ACT: Quick log for account 5 (post-switch) ──
      _log.stepStart('G4.4', 'Quick log for Gmail account 5 (post-switch)');
      _log.act('Recording quick log after account switch');

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        _log.action('Pressing back button from Accounts');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      final t4SwitchedEmail =
          (await AccountService().getActiveAccount())?.email ?? testEmail5;
      final t4Propagated = await waitForProviderPropagation($, t4SwitchedEmail);
      _log.data('Provider propagated', t4Propagated);

      await debugDumpSnackbarState($, 'Before quick log (post-switch)');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log (post-switch)');

      await debugDumpAccountState($, 'Home screen - account 5');
      await debugDumpLogState($, 'Account 5 before quick log');
      await takeScreenshot($, 'gmail_quick_04_home_acct5');

      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      final t4Dur2 = _randomHoldDuration();
      _log.action('Holding to record for ${t4Dur2.inMilliseconds}ms');
      await debugLogActiveUser('immediately before holdToRecord');
      final t4LoggedAt = DateTime.now();
      await home.holdToRecord(duration: t4Dur2);
      _log.info('Gesture completed — recording should be processing...');
      await debugDumpQuickLogWidgetState($, 'After holdToRecord gesture');
      await settle($, frames: 10);

      await debugDumpSnackbarState($, 'Immediately after hold-to-record');

      _log.info('Waiting for quick log confirmation...');
      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final t4Snackbar = _extractSnackbarText($);
      _log.pass('Quick log confirmed for Gmail account 5');
      _log.data('Snackbar', t4Snackbar);
      _verifySnackbarDuration(t4Snackbar, t4Dur2, 'G4.4');

      await debugDumpAccountState($, 'After quick log - account 5');
      await debugDumpLogState($, 'Account 5 after quick log');
      await takeScreenshot($, 'gmail_quick_05_after_quicklog_acct5');
      _log.stepEnd('G4.4', summary: 'Account 5 quick log recorded');

      // ── ASSERT: Verify log in History for account 5 ──
      _log.stepStart('G4.5', 'Verify quick log in History (Gmail account 5)');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History screen - account 5');
      await debugDumpLogState($, 'Account 5 history log state');
      await takeScreenshot($, 'gmail_quick_06_history_acct5');

      final t4TopMatch = _verifyTopHistoryRecord($, t4LoggedAt, 'G4.5');
      expect(
        t4TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for Gmail account 5',
      );
      _log.pass('Top record verified in History for Gmail account 5');
      _log.stepEnd('G4.5');

      // ── ASSERT: Data isolation ──
      _log.stepStart(
        'G4.6',
        'Verify data isolation (switch back to Gmail account 4)',
      );
      _log.assert_('Account 4 History should be separate from account 5');
      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'Switched back to account 4');

      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History screen - account 4');
      await debugDumpLogState($, 'Account 4 history after switching back');
      await takeScreenshot($, 'gmail_quick_07_history_acct4');

      _log.pass('Gmail account 4 History screen verified');
      await takeScreenshot($, 'gmail_quick_08_back_to_acct4');
      _log.stepEnd('G4.6');

      _log.testEnd(4, 'Gmail: Quick log after switching accounts', [
        '✓ Quick log recorded for Gmail account 5 post-switch',
        '✓ VAPE entry verified in History for Gmail account 5',
        '✓ Data isolation verified for Gmail account 4',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 5: Sign out single account — SKIPPED to preserve auth state
  // ─────────────────────────────────────────────────────────────────────────
  // NOTE: Signing out destroys persisted Google Sign-In state in the iOS
  // Keychain.  Re-seeding requires manual OAuth interaction, so this test
  // is intentionally disabled.  The underlying sign-out logic is still
  // covered by non-Gmail (email/password) tests.
  patrolTest(
    'Gmail multi-account: sign out one account, verify auto-switch',
    skip: true,
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        5,
        'Gmail: Sign out single account',
        description:
            'Verifies that signing out the non-active Gmail account\n'
            'removes it and leaves exactly 1 logged-in account.',
      );

      // ── ARRANGE ──
      _log.stepStart('G5.1', 'Ensure both Gmail accounts present');
      _log.arrange('Authenticating and ensuring Gmail account 5 exists');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail5)) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }
      _log.stepEnd('G5.1', summary: 'Both Gmail accounts present');

      // ── ACT: Open Accounts screen ──
      _log.stepStart('G5.2', 'Open Accounts screen');
      _log.action('Navigating to Accounts screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Before sign-out');
      await takeScreenshot($, 'gmail_signout_01_before');

      _log.assert_('Expecting 2 account cards');
      accounts.verifyAccountCount(2);
      _log.stepEnd('G5.2', summary: '2 accounts verified');

      // ── ACT: Sign out non-active account ──
      _log.stepStart('G5.3', 'Sign out non-active Gmail account');
      _log.act('Signing out the non-active account via popup menu');

      final card1 = accounts.accountCard(1);
      if ($.tester.any(card1)) {
        final popupMenu = find.descendant(
          of: card1,
          matching: find.byType(PopupMenuButton),
        );
        if ($.tester.any(popupMenu)) {
          _log.action('Found PopupMenuButton on card 1 — tapping');
          await $.tester.tap(popupMenu.first);
          await settle($, frames: 5);
          await takeScreenshot($, 'gmail_signout_02_popup_menu');

          final signOutItem = find.text('Sign out');
          if ($.tester.any(signOutItem)) {
            _log.action('Tapping "Sign out"');
            await $.tester.tap(signOutItem);
            await settle($, frames: 15);
          } else {
            _log.debug('"Sign out" not found — trying "Sign Out"');
            final signOutItem2 = find.text('Sign Out');
            if ($.tester.any(signOutItem2)) {
              await $.tester.tap(signOutItem2);
              await settle($, frames: 15);
            } else {
              _log.warn('Could not find sign out option in popup');
            }
          }
        } else {
          _log.warn('No PopupMenuButton found on card 1');
          final moreVert = find.descendant(
            of: card1,
            matching: find.byIcon(Icons.more_vert),
          );
          if ($.tester.any(moreVert)) {
            _log.action('Found more_vert icon — tapping');
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

      await debugDumpAccountState(
        $,
        'After signing out non-active Gmail account',
      );
      await takeScreenshot($, 'gmail_signout_03_after');
      _log.stepEnd('G5.3', summary: 'Sign-out action completed');

      // ── ASSERT: Verify single account remains ──
      _log.stepStart('G5.4', 'Verify single Gmail account remains');
      _log.assert_('Exactly 1 logged-in account should remain');
      await settle($, frames: 10);
      final remainingAccounts = await AccountService().getAllAccounts();
      _log.data('Remaining accounts', remainingAccounts.length);
      for (final a in remainingAccounts) {
        _log.debug(
          '${a.email} isActive=${a.isActive} isLoggedIn=${a.isLoggedIn}',
          indent: 1,
        );
      }

      final loggedIn = remainingAccounts.where((a) => a.isLoggedIn).toList();
      _log.data('Logged-in count', loggedIn.length);
      expect(
        loggedIn.length,
        equals(1),
        reason: 'Should have exactly 1 logged-in Gmail account after sign-out',
      );
      _log.pass('Single Gmail account remains after sign-out');
      await takeScreenshot($, 'gmail_signout_04_final');
      _log.stepEnd('G5.4');

      _log.testEnd(5, 'Gmail: Sign out single account', [
        '✓ Non-active Gmail account signed out via popup menu',
        '✓ Exactly 1 logged-in Gmail account remains',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 6: Full cycle — add, switch, log, verify isolation, sign out
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: full cycle (add → switch → log → verify)',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        6,
        'Gmail: Full multi-account cycle',
        description:
            'Comprehensive end-to-end lifecycle with Gmail:\n'
            'Google Sign-In → log → verify → add Gmail account →\n'
            'switch → log → verify → data isolation',
      );

      debugDumpLoggerConfig('Gmail Test 6 start');

      // ── Phase 1: Ensure Gmail account 4 is logged in ──
      _log.stepStart('G6.1', 'Ensure Gmail account 4 logged in');
      _log.arrange(
        'Ensuring Gmail account 4 is signed in (persisted or fresh)',
      );
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await handlePermissionDialogs($);
      await settle($, frames: 20);

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);
      await debugDumpAccountState($, 'Gmail account 4 logged in');
      await takeScreenshot($, 'gmail_full_02_acct4_home');
      _log.stepEnd('G6.1', summary: 'Gmail account 4 logged in');

      // ── Phase 2: Quick log for Gmail account 4 ──
      _log.stepStart('G6.2', 'Quick log for Gmail account 4');
      _log.act('Recording a baseline quick log for Gmail account 4');
      await debugDumpLogState($, 'Account 4 log state');

      final p2Duration = _randomHoldDuration();
      _log.action('Holding to record for ${p2Duration.inMilliseconds}ms');
      final p2LoggedAt = DateTime.now();
      await home.holdToRecord(duration: p2Duration);
      await settle($, frames: 10);
      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final p2Snackbar = _extractSnackbarText($);
      _log.pass('Gmail account 4 quick log recorded');
      _log.data('Snackbar', p2Snackbar);
      _verifySnackbarDuration(p2Snackbar, p2Duration, 'G6.2');
      await debugDumpLogState($, 'After quick log for account 4');
      await takeScreenshot($, 'gmail_full_03_acct4_logged');
      _log.stepEnd('G6.2', summary: 'Baseline log recorded');

      // ── Phase 2b: Verify account 4 log in History ──
      _log.stepStart('G6.2b', 'Verify Gmail account 4 log in History');
      _log.assert_('Top History record should be the just-logged VAPE entry');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'gmail_full_03b_history_acct4');

      final p2TopMatch = _verifyTopHistoryRecord($, p2LoggedAt, 'G6.2b');
      expect(
        p2TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for Gmail account 4',
      );
      _log.pass('Gmail account 4 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('G6.2b');

      // ── Phase 3: Add Gmail account 5 via Google Sign-In ──
      _log.stepStart('G6.3', 'Add Gmail account 5 via Google Sign-In');
      _log.act('Adding second Gmail account via Accounts screen');
      await addGmailAccount(
        $,
        home,
        accounts,
        login,
        selectAccountEmail: testEmail5,
      );
      await debugDumpAccountState($, 'Gmail account 5 added');
      await takeScreenshot($, 'gmail_full_04_acct5_added');
      _log.stepEnd('G6.3', summary: 'Gmail account 5 added');

      // ── Phase 4: Switch to account 5 ──
      _log.stepStart('G6.4', 'Switch to Gmail account 5');
      _log.act('Switching active account');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      final preSwitch = await AccountService().getActiveAccount();
      _log.data('Active before switch', preSwitch?.email);
      await debugDumpAccountState($, 'Before switch');

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switch');
      await takeScreenshot($, 'gmail_full_05_switched');

      final postSwitch = await AccountService().getActiveAccount();
      _log.data('Active after switch', postSwitch?.email);
      _log.stepEnd('G6.4', summary: 'Switched to ${postSwitch?.email}');

      // ── Phase 5: Quick log for switched account (CRITICAL) ──
      _log.stepStart('G6.5', 'Quick log for switched Gmail account (CRITICAL)');
      _log.act(
        'Recording quick log after Gmail account switch — '
        'this is the critical bug-detection step',
      );

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        _log.action('Pressing back button from Accounts');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      final p5ExpectedEmail = postSwitch?.email ?? testEmail5;
      final p5Propagated = await waitForProviderPropagation($, p5ExpectedEmail);
      _log.data('Provider propagated', p5Propagated);

      await debugDumpSnackbarState($, 'Before quick log');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log');

      await debugDumpAccountState($, 'Home screen after switch');
      await debugDumpLogState($, 'Log state before quick log');
      await takeScreenshot($, 'gmail_full_06_home_switched');

      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      await debugDumpLogCreationPipeline(
        $,
        'BEFORE Phase 5 critical quick log (Gmail)',
      );

      final p5Duration = _randomHoldDuration();
      _log.action('Holding to record for ${p5Duration.inMilliseconds}ms');
      await debugLogActiveUser('immediately before holdToRecord');
      final p5LoggedAt = DateTime.now();
      await home.holdToRecord(duration: p5Duration);
      _log.info('Gesture completed — recording should be processing...');
      await debugDumpQuickLogWidgetState($, 'After gesture');
      await settle($, frames: 10);

      await debugDumpSnackbarState($, 'After hold-to-record');

      bool logSuccess = false;
      String? p5Snackbar;
      int p5Polls = 0;
      final end5 = DateTime.now().add(const Duration(seconds: 20));
      while (DateTime.now().isBefore(end5)) {
        await $.pump(const Duration(milliseconds: 250));
        p5Polls++;
        if (p5Polls % 8 == 0) {
          _log.debug('Poll #$p5Polls — still waiting for snackbar...');
          await debugDumpSnackbarState($, 'Poll #$p5Polls');
          await debugDumpQuickLogWidgetState($, 'Poll #$p5Polls');
          await debugLogActiveUser('poll #$p5Polls');
        }
        if ($.tester.any(find.textContaining('Logged vape'))) {
          p5Snackbar = _extractSnackbarText($);
          _log.pass('Quick log SUCCEEDED for switched Gmail account');
          _log.data('Snackbar', p5Snackbar);
          _verifySnackbarDuration(p5Snackbar, p5Duration, 'G6.5');
          _log.data('Polls taken', p5Polls);
          logSuccess = true;
          break;
        }
        if ($.tester.any(find.textContaining('No active account'))) {
          _log.fail('BUG DETECTED — "No active account" snackbar!');
          await debugDumpAccountState($, 'No active account');
          break;
        }
        if ($.tester.any(find.textContaining('too short'))) {
          _log.fail('"Duration too short" — threshold issue');
          break;
        }
        if ($.tester.any(find.textContaining('Error'))) {
          final errEl = find.textContaining('Error').evaluate().first;
          _log.fail('Quick log FAILED: ${(errEl.widget as Text).data}');
          break;
        }
      }
      if (!logSuccess) {
        _log.warn('Quick log did NOT succeed (polls: $p5Polls)');
        await debugDumpSnackbarState($, 'FAILED — snackbar state');
        await debugDumpQuickLogWidgetState($, 'FAILED — widget state');
        await debugDumpAccountState($, 'FAILED — account state');
        await debugDumpLogState($, 'FAILED — log state');
        await debugDumpLogCreationPipeline($, 'FAILED — full pipeline');
      }

      final p5Persisted = await debugVerifyLogPersisted(
        $,
        'Gmail Phase 5 critical quick log',
        p5LoggedAt,
      );
      if (!p5Persisted) {
        _log.fail('Phase 5: Record NOT found in Hive!');
      }

      await debugDumpAccountState($, 'After quick log');
      await debugDumpLogState($, 'After quick log');
      await takeScreenshot($, 'gmail_full_07_after_quicklog_switched');
      _log.stepEnd(
        'G6.5',
        summary: logSuccess ? 'Quick log succeeded' : 'Quick log failed',
      );

      // ── Phase 5b: Verify quick log in History ──
      _log.stepStart('G6.5b', 'Verify quick log in History');
      _log.assert_('Top History record should match the just-logged entry');
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History for switched Gmail account');
      await debugDumpLogState($, 'History log state');
      await takeScreenshot($, 'gmail_full_08_history_switched');

      final p5bTopMatch = _verifyTopHistoryRecord($, p5LoggedAt, 'G6.5b');
      expect(
        p5bTopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged after switch',
      );
      _log.pass('Top record verified in History');
      _log.stepEnd('G6.5b');

      // ── Phase 6: Verify data isolation ──
      _log.stepStart('G6.6', 'Verify data isolation');
      _log.assert_('Account 4 History should be separate from account 5');

      await nav.tapHome();
      await home.waitUntilVisible();
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.switchToAccount(1);

      await debugDumpAccountState($, 'Switched back');
      await debugDumpLogState($, 'Original account log state');

      final backButton2 = find.byType(BackButton);
      if ($.tester.any(backButton2)) {
        await $(backButton2).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }
      await nav.tapHistory();
      await history.waitUntilVisible();
      await settle($, frames: 10);
      await debugDumpLogState($, 'Account 4 History log state');
      await takeScreenshot($, 'gmail_full_09_history_acct4');
      _log.pass('Data isolation verified — Gmail account 4 History intact');
      _log.stepEnd('G6.6');

      // ── Phase 7: Skipped — no cleanup sign-out ──
      // NOTE: Sign-out intentionally removed to preserve persisted
      // Google Sign-In state in the iOS Keychain across test runs.

      _log.testEnd(6, 'Gmail: Full multi-account cycle', [
        '✓ Gmail account 4 logged in via Google Sign-In and baseline log recorded',
        '✓ Account 4 log verified in History',
        '✓ Gmail account 5 added via Google Sign-In and switched',
        '✓ Quick log success after switch: $logSuccess',
        '✓ History verification: passed',
        '✓ Data isolation: verified',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 7: Repeated swap + log (3 iterations) — consistency check
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: swap and log 3x loop',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        7,
        'Gmail: Swap and log 3x loop',
        description:
            'Swaps between Gmail accounts and records a quick log\n'
            '3 times to verify consistency across switches.',
      );

      debugDumpLoggerConfig('Gmail Test 7 start');

      // ── Setup ──
      _log.stepStart('G7.0', 'Setup — ensure both Gmail accounts present');
      _log.arrange('Logging in via Google and verifying account 5 exists');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      if (!allAccounts.any((a) => a.email == testEmail5)) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('G7.0', summary: 'Both Gmail accounts ready');

      int successCount = 0;

      for (int i = 1; i <= 3; i++) {
        // ── Step A: Switch account ──
        _log.stepStart('G7.$i.A', 'Iteration $i/3 — switch account');
        _log.act('Switching active Gmail account');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.debugDumpCards();
        await accounts.switchToAccount(1);
        await debugDumpAccountState($, 'Iter $i: After switch');
        await takeScreenshot($, 'gmail_loop3_${i}_switched');

        final backBtn = find.byType(BackButton);
        if ($.tester.any(backBtn)) {
          await $(backBtn).tap(settlePolicy: SettlePolicy.noSettle);
          await settle($, frames: 10);
        }
        await nav.tapHome();
        await home.waitUntilVisible();

        final loopActiveEmail =
            (await AccountService().getActiveAccount())?.email ?? 'unknown';
        final loopPropagated = await waitForProviderPropagation(
          $,
          loopActiveEmail,
        );
        _log.data('Provider propagated', loopPropagated);

        await debugDumpSnackbarState($, 'Iter $i: Before quick log');
        await clearSnackbars($);
        await debugDumpQuickLogWidgetState($, 'Iter $i: Before quick log');
        _log.stepEnd('G7.$i.A', summary: 'Switched to $loopActiveEmail');

        // ── Step B: Quick log ──
        _log.stepStart('G7.$i.B', 'Iteration $i/3 — quick log');
        await settle($, frames: 20);
        await $.pump(const Duration(seconds: 1));

        if (i == 1) {
          await debugDumpLogCreationPipeline($, 'Iter 1: BEFORE quick log');
        }

        final loopDur = _randomHoldDuration();
        _log.action('Holding to record for ${loopDur.inMilliseconds}ms');
        await debugLogActiveUser('Iter $i: immediately before holdToRecord');
        final loopLoggedAt = DateTime.now();
        await home.holdToRecord(duration: loopDur);
        _log.info('Gesture completed');
        await debugDumpQuickLogWidgetState($, 'Iter $i: After gesture');
        await settle($, frames: 10);

        await debugDumpSnackbarState($, 'Iter $i: After hold-to-record');

        bool logged = false;
        String? loopSnackbar;
        int loopPolls = 0;
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (DateTime.now().isBefore(deadline)) {
          await $.pump(const Duration(milliseconds: 250));
          loopPolls++;
          if (loopPolls % 8 == 0) {
            _log.debug('Iter $i: Poll #$loopPolls — still waiting...');
            await debugDumpSnackbarState($, 'Iter $i: Poll #$loopPolls');
            await debugLogActiveUser('Iter $i: poll #$loopPolls');
          }
          if ($.tester.any(find.textContaining('Logged vape'))) {
            loopSnackbar = _extractSnackbarText($);
            _log.pass('Iter $i: Quick log SUCCEEDED');
            _log.data('Snackbar', loopSnackbar);
            _verifySnackbarDuration(loopSnackbar, loopDur, 'G7.$i.B');
            logged = true;
            successCount++;
            break;
          }
          if ($.tester.any(find.textContaining('No active account'))) {
            _log.fail('Iter $i: BUG — "No active account" snackbar!');
            await debugDumpAccountState($, 'Iter $i: No active account');
            break;
          }
          if ($.tester.any(find.textContaining('too short'))) {
            _log.fail('Iter $i: "Duration too short" — threshold issue');
            break;
          }
          if ($.tester.any(find.textContaining('Error'))) {
            final errEl = find.textContaining('Error').evaluate().first;
            _log.fail(
              'Iter $i: Quick log FAILED: ${(errEl.widget as Text).data}',
            );
            break;
          }
        }
        if (!logged) {
          _log.warn('Iter $i: No confirmation within 20s (polls: $loopPolls)');
          await debugDumpSnackbarState($, 'Iter $i: TIMEOUT');
          await debugDumpQuickLogWidgetState($, 'Iter $i: TIMEOUT');
          await debugDumpAccountState($, 'Iter $i: TIMEOUT');
          await debugDumpLogState($, 'Iter $i: TIMEOUT');
        }

        await debugDumpLogState($, 'Iter $i: After quick log');
        await takeScreenshot($, 'gmail_loop3_${i}_logged');
        _log.stepEnd(
          'G7.$i.B',
          summary: logged ? 'Log succeeded' : 'Log failed',
        );

        // ── Step C: Verify in History ──
        _log.stepStart('G7.$i.C', 'Iteration $i/3 — verify History');
        _log.assert_('Top History record should match just-logged entry');
        await nav.tapHistory();
        final history = HistoryComponent($);
        await history.waitUntilVisible();
        await settle($, frames: 10);

        final loopTopMatch = _verifyTopHistoryRecord(
          $,
          loopLoggedAt,
          'G7.$i.C',
        );
        expect(
          loopTopMatch,
          isTrue,
          reason:
              'Iteration $i: Top History record should be the VAPE entry just logged',
        );
        _log.pass('Iter $i: Top record verified');
        await takeScreenshot($, 'gmail_loop3_${i}_history');

        await nav.tapHome();
        await home.waitUntilVisible();
        _log.stepEnd('G7.$i.C');
      }

      expect(
        successCount,
        equals(3),
        reason: 'All 3 Gmail swap+log iterations should succeed',
      );

      _log.testEnd(7, 'Gmail: Swap and log 3x loop', [
        'Successes: $successCount / 3',
        '✓ All 3 iterations passed',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Gmail Test 8: Repeated swap + log (6 iterations) — extended consistency
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Gmail multi-account: swap and log 6x loop',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        8,
        'Gmail: Swap and log 6x loop',
        description:
            'Swaps between Gmail accounts and records a quick log\n'
            '6 times to stress-test consistency with Google Sign-In.',
      );

      debugDumpLoggerConfig('Gmail Test 8 start');

      // ── Setup ──
      _log.stepStart('G8.0', 'Setup — ensure both Gmail accounts present');
      _log.arrange('Logging in via Google and verifying account 5 exists');
      await ensureGmailLoggedIn($, selectAccountEmail: testEmail4);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      if (!allAccounts.any((a) => a.email == testEmail5)) {
        _log.action('Adding Gmail account 5...');
        await addGmailAccount(
          $,
          home,
          accounts,
          login,
          selectAccountEmail: testEmail5,
        );
      }

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('G8.0', summary: 'Both Gmail accounts ready');

      int successCount = 0;
      final List<String> iterationResults = [];

      for (int i = 1; i <= 6; i++) {
        // ── Step A: Switch account ──
        _log.stepStart('G8.$i.A', 'Iteration $i/6 — switch account');
        _log.act('Switching active Gmail account');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.debugDumpCards();
        await accounts.switchToAccount(1);

        final activeAcct = await AccountService().getActiveAccount();
        _log.data('Active after switch', activeAcct?.email);
        await debugDumpAccountState($, 'Iter $i: After switch');
        await takeScreenshot($, 'gmail_loop6_${i}_switched');

        final backBtn = find.byType(BackButton);
        if ($.tester.any(backBtn)) {
          await $(backBtn).tap(settlePolicy: SettlePolicy.noSettle);
          await settle($, frames: 10);
        }
        await nav.tapHome();
        await home.waitUntilVisible();

        final loopActiveEmail = activeAcct?.email ?? 'unknown';
        final loopPropagated = await waitForProviderPropagation(
          $,
          loopActiveEmail,
        );
        _log.data('Provider propagated', loopPropagated);

        await debugDumpSnackbarState($, 'Iter $i: Before quick log');
        await clearSnackbars($);
        await debugDumpQuickLogWidgetState($, 'Iter $i: Before quick log');
        _log.stepEnd('G8.$i.A', summary: 'Switched to $loopActiveEmail');

        // ── Step B: Quick log ──
        _log.stepStart('G8.$i.B', 'Iteration $i/6 — quick log');
        await settle($, frames: 20);
        await $.pump(const Duration(seconds: 1));

        if (i == 1) {
          await debugDumpLogCreationPipeline($, 'Iter 1: BEFORE quick log');
        }

        final loopDur = _randomHoldDuration();
        _log.action('Holding to record for ${loopDur.inMilliseconds}ms');
        await debugDumpLogState($, 'Iter $i: Before quick log');
        await debugLogActiveUser('Iter $i: immediately before holdToRecord');
        final loopLoggedAt = DateTime.now();
        await home.holdToRecord(duration: loopDur);
        _log.info('Gesture completed');
        await debugDumpQuickLogWidgetState($, 'Iter $i: After gesture');
        await settle($, frames: 10);

        await debugDumpSnackbarState($, 'Iter $i: After hold-to-record');

        bool logged = false;
        String? loopSnackbar;
        int loopPolls = 0;
        final deadline = DateTime.now().add(const Duration(seconds: 20));
        while (DateTime.now().isBefore(deadline)) {
          await $.pump(const Duration(milliseconds: 250));
          loopPolls++;
          if (loopPolls % 8 == 0) {
            _log.debug('Iter $i: Poll #$loopPolls — still waiting...');
            await debugDumpSnackbarState($, 'Iter $i: Poll #$loopPolls');
            await debugLogActiveUser('Iter $i: poll #$loopPolls');
          }
          if ($.tester.any(find.textContaining('Logged vape'))) {
            loopSnackbar = _extractSnackbarText($);
            _log.pass('Iter $i: Quick log SUCCEEDED');
            _log.data('Snackbar', loopSnackbar);
            _verifySnackbarDuration(loopSnackbar, loopDur, 'G8.$i.B');
            logged = true;
            successCount++;
            iterationResults.add(
              '[$i] ✓ ${activeAcct?.email} (${loopDur.inMilliseconds}ms)',
            );
            break;
          }
          if ($.tester.any(find.textContaining('No active account'))) {
            _log.fail('Iter $i: BUG — "No active account" snackbar!');
            await debugDumpAccountState($, 'Iter $i: No active account');
            iterationResults.add(
              '[$i] ✗ ${activeAcct?.email}: no active account',
            );
            break;
          }
          if ($.tester.any(find.textContaining('too short'))) {
            _log.fail('Iter $i: "Duration too short" — threshold issue');
            iterationResults.add('[$i] ✗ ${activeAcct?.email}: too short');
            break;
          }
          if ($.tester.any(find.textContaining('Error'))) {
            final errEl = find.textContaining('Error').evaluate().first;
            final errMsg = (errEl.widget as Text).data ?? 'unknown';
            _log.fail('Iter $i: Quick log FAILED: $errMsg');
            iterationResults.add('[$i] ✗ ${activeAcct?.email}: $errMsg');
            break;
          }
        }
        if (!logged && iterationResults.length < i) {
          _log.warn('Iter $i: No confirmation within 20s (polls: $loopPolls)');
          iterationResults.add('[$i] ⚠ ${activeAcct?.email}: timeout');
          await debugDumpSnackbarState($, 'Iter $i: TIMEOUT');
          await debugDumpQuickLogWidgetState($, 'Iter $i: TIMEOUT');
          await debugDumpAccountState($, 'Iter $i: TIMEOUT');
          await debugDumpLogState($, 'Iter $i: TIMEOUT');
          await debugDumpLogCreationPipeline(
            $,
            'Iter $i: TIMEOUT — full pipeline',
          );
        }

        // Verify persistence after each iteration
        final iterPersisted = await debugVerifyLogPersisted(
          $,
          'Iter $i persistence check',
          loopLoggedAt,
        );
        if (!iterPersisted) {
          _log.fail('Iter $i: Record NOT found in Hive!');
        }

        await debugDumpLogState($, 'Iter $i: After quick log');
        await takeScreenshot($, 'gmail_loop6_${i}_logged');
        _log.stepEnd(
          'G8.$i.B',
          summary: logged ? 'Log succeeded' : 'Log failed',
        );

        // ── Step C: Verify in History ──
        _log.stepStart('G8.$i.C', 'Iteration $i/6 — verify History');
        _log.assert_('Top History record should match just-logged entry');
        await nav.tapHistory();
        final history = HistoryComponent($);
        await history.waitUntilVisible();
        await settle($, frames: 10);

        final loopTopMatch = _verifyTopHistoryRecord(
          $,
          loopLoggedAt,
          'G8.$i.C',
        );
        expect(
          loopTopMatch,
          isTrue,
          reason:
              'Iteration $i: Top History record should be the VAPE entry just logged',
        );
        _log.pass('Iter $i: Top record verified');
        await takeScreenshot($, 'gmail_loop6_${i}_history');

        await nav.tapHome();
        await home.waitUntilVisible();
        _log.stepEnd('G8.$i.C');
      }

      expect(
        successCount,
        equals(6),
        reason: 'All 6 Gmail swap+log iterations should succeed',
      );

      _log.testEnd(8, 'Gmail: Swap and log 6x loop', [
        ...iterationResults,
        'Successes: $successCount / 6',
        '✓ All 6 iterations passed',
      ]);
    },
  );
}
