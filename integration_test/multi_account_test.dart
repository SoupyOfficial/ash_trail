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
import 'components/welcome.dart';
import 'flows/login_flow.dart';
import 'helpers/config.dart';
import 'helpers/pump.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Multi-Account + Logging Debug Tests
// ═══════════════════════════════════════════════════════════════════════════════
//
// These tests exercise multi-account switching and verify that logging
// works correctly after swapping accounts. Each test uses structured
// diagnostic logging (TestLogger) to capture the exact state of Firebase
// Auth, Hive accounts, Riverpod providers, and UI at every step.
//
// Log Levels:
//   INFO    — High-level test flow (steps, phases, results)
//   ACTION  — User interactions (taps, gestures, navigation)
//   VERIFY  — Assertions and validation checks
//   DEBUG   — Detailed state dumps (accounts, providers, widgets)
//   WARN    — Non-fatal issues or unexpected states
//   PASS    — Successful validation / test completion
//   FAIL    — Failed validation / bug detection
//
// Prerequisites:
//   - Two Firebase accounts must exist:
//     1. test1@ashtrail.dev / TestPass123!
//     2. test2@ashtrail.dev / TestPass456!
//
// Run with:
//   patrol test --target integration_test/multi_account_test.dart
//
// After running, check /tmp/ash_trail_test_diagnostics.log for full trace.
// ═══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// Structured Test Logger
// ─────────────────────────────────────────────────────────────────────────────

/// Log severity levels following standard conventions.
enum LogLevel { info, action, verify, debug, warn, pass, fail }

/// Structured logger for integration tests.
///
/// Provides consistent, machine-parseable output with:
/// - Severity-tagged log lines: `[HH:mm:ss.SSS] LEVEL  | message`
/// - Test lifecycle markers: `[TEST_START]`, `[TEST_END]`
/// - Step lifecycle markers: `[STEP_START]`, `[STEP_END]`
/// - Elapsed timing on steps and tests
/// - Hierarchical indentation for sub-actions
class TestLogger {
  TestLogger._();
  static final instance = TestLogger._();

  final _testStopwatch = Stopwatch();
  final _stepStopwatch = Stopwatch();

  static const _levelLabels = {
    LogLevel.info: 'INFO   ',
    LogLevel.action: 'ACTION ',
    LogLevel.verify: 'VERIFY ',
    LogLevel.debug: 'DEBUG  ',
    LogLevel.warn: 'WARN   ',
    LogLevel.pass: 'PASS   ',
    LogLevel.fail: 'FAIL   ',
  };

  static const _separator =
      '═══════════════════════════════════════════════════════════════';
  static const _thinSeparator =
      '───────────────────────────────────────────────────────────────';

  /// Core log method — all other methods delegate here.
  void _log(LogLevel level, String message, {int indent = 0}) {
    final prefix = '  ' * indent;
    testLog('${_levelLabels[level]}| $prefix$message');
  }

  // ── Convenience methods by level ──

  void info(String msg, {int indent = 0}) =>
      _log(LogLevel.info, msg, indent: indent);
  void action(String msg, {int indent = 0}) =>
      _log(LogLevel.action, msg, indent: indent);
  void verify(String msg, {int indent = 0}) =>
      _log(LogLevel.verify, msg, indent: indent);
  void debug(String msg, {int indent = 0}) =>
      _log(LogLevel.debug, msg, indent: indent);
  void warn(String msg, {int indent = 0}) =>
      _log(LogLevel.warn, msg, indent: indent);
  void pass(String msg, {int indent = 0}) =>
      _log(LogLevel.pass, msg, indent: indent);
  void fail(String msg, {int indent = 0}) =>
      _log(LogLevel.fail, msg, indent: indent);

  // ── Test lifecycle ──

  /// Mark the start of a test. Resets step counter and starts timing.
  void testStart(int testNumber, String testName, {String? description}) {
    _testStopwatch
      ..reset()
      ..start();
    testLog('');
    testLog(_separator);
    testLog('[TEST_START] Test $testNumber: $testName');
    if (description != null) {
      for (final line in description.split('\n')) {
        testLog('  $line');
      }
    }
    testLog(_separator);
  }

  /// Mark the end of a test with a summary of results.
  void testEnd(int testNumber, String testName, List<String> results) {
    _testStopwatch.stop();
    final elapsed = _formatElapsed(_testStopwatch.elapsed);
    testLog('');
    testLog(_separator);
    testLog('[TEST_END] Test $testNumber: $testName  ($elapsed)');
    for (final r in results) {
      testLog('  $r');
    }
    testLog(_separator);
  }

  // ── Step lifecycle ──

  /// Begin a numbered step within the current test.
  void stepStart(String stepId, String description) {
    _stepStopwatch
      ..reset()
      ..start();
    testLog('');
    testLog(_thinSeparator);
    testLog('[STEP_START] $stepId: $description');
    testLog(_thinSeparator);
  }

  /// End the current step with an optional summary.
  void stepEnd(String stepId, {String? summary}) {
    _stepStopwatch.stop();
    final elapsed = _formatElapsed(_stepStopwatch.elapsed);
    if (summary != null) {
      info('$stepId completed: $summary  ($elapsed)');
    } else {
      info('$stepId completed  ($elapsed)');
    }
  }

  // ── Semantic helpers ──

  /// Log the start of an Arrange / Given phase.
  void arrange(String msg) => _log(LogLevel.info, '[ARRANGE] $msg');

  /// Log the start of an Act / When phase.
  void act(String msg) => _log(LogLevel.action, '[ACT] $msg');

  /// Log the start of an Assert / Then phase.
  void assert_(String msg) => _log(LogLevel.verify, '[ASSERT] $msg');

  /// Log a key=value data point (e.g. account email, record count).
  void data(String key, Object? value, {int indent = 1}) {
    _log(LogLevel.debug, '$key: $value', indent: indent);
  }

  /// Format elapsed duration as human-readable string.
  String _formatElapsed(Duration d) {
    if (d.inMinutes > 0) {
      final secs = (d.inMilliseconds % 60000) / 1000.0;
      return '${d.inMinutes}m ${secs.toStringAsFixed(1)}s';
    }
    return '${(d.inMilliseconds / 1000.0).toStringAsFixed(1)}s';
  }
}

/// Global logger instance for test convenience.
final _log = TestLogger.instance;

// ─────────────────────────────────────────────────────────────────────────────
// Test Utilities
// ─────────────────────────────────────────────────────────────────────────────

final _random = Random();

/// Generate a random hold duration between [minMs] and [maxMs] milliseconds.
Duration _randomHoldDuration({int minMs = 2000, int maxMs = 6000}) {
  final ms = minMs + _random.nextInt(maxMs - minMs);
  _log.debug('Generated random hold duration: ${ms}ms (range: $minMs–$maxMs)');
  return Duration(milliseconds: ms);
}

/// Extract the snackbar text containing 'Logged vape' from the widget tree.
///
/// Strategy:
/// 1. Search direct Text widget matches for 'Logged vape'
/// 2. Search RichText matches for 'Logged vape'
/// 3. Fallback: search all Text descendants inside SnackBar widgets
///
/// Returns the full snackbar text, or null if not found.
String? _extractSnackbarText(PatrolIntegrationTester $) {
  _log.debug('Extracting snackbar text...');

  // Strategy 1: Direct Text widget match
  final textFinder = find.textContaining('Logged vape');
  if ($.tester.any(textFinder)) {
    for (final element in textFinder.evaluate()) {
      final widget = element.widget;
      if (widget is Text && widget.data != null) {
        _log.debug('Found snackbar via Text widget: "${widget.data}"');
        return widget.data;
      }
      if (widget is RichText) {
        final plain = widget.text.toPlainText();
        if (plain.contains('Logged vape')) {
          _log.debug('Found snackbar via RichText: "$plain"');
          return plain;
        }
      }
    }
  }

  // Strategy 2: Search SnackBar descendants directly
  final snackbarFinder = find.byType(SnackBar);
  if ($.tester.any(snackbarFinder)) {
    _log.debug('Searching SnackBar descendants...');
    final textInSnackbar = find.descendant(
      of: snackbarFinder,
      matching: find.byType(Text),
    );
    for (final element in textInSnackbar.evaluate()) {
      final widget = element.widget;
      if (widget is Text &&
          widget.data != null &&
          widget.data!.contains('Logged vape')) {
        _log.debug('Found snackbar via SnackBar descendant: "${widget.data}"');
        return widget.data;
      }
    }
  }

  _log.warn('Could not extract snackbar text — no "Logged vape" match found');
  return null;
}

/// Verify the TOP (most recent) record in History matches the expected event.
///
/// Checks:
/// 1. At least one Card widget exists on the History screen
/// 2. The first Card contains "VAPE" as the event type title
/// 3. The first Card contains the expected formatted timestamp
/// 4. Fallback: checks ±1 minute for timing boundary tolerance
///
/// Returns true if both event type and timestamp match.
bool _verifyTopHistoryRecord(
  PatrolIntegrationTester $,
  DateTime loggedAt,
  String label,
) {
  final expectedTimestamp = DateFormat.yMMMd().add_jm().format(loggedAt);
  _log.verify('$label: Checking top History record...');
  _log.data('Expected timestamp', '"$expectedTimestamp"');

  // Find all Cards on the History screen
  final allCards = find.byType(Card);
  final hasCards = $.tester.any(allCards);
  if (!hasCards) {
    _log.fail('$label: No record Cards found on History screen');
    final noEntries = find.textContaining('No entries');
    _log.data('"No entries" visible', $.tester.any(noEntries));
    _log.fail('$label: Quick log not appearing in History — possible data bug');
    return false;
  }

  final cardCount = allCards.evaluate().length;
  _log.data('Record cards found', cardCount);

  // The first Card is the top/newest record (descending sort)
  final topCard = allCards.first;

  // Check event type
  final titleFinder = find.descendant(of: topCard, matching: find.text('VAPE'));
  final hasVape = $.tester.any(titleFinder);
  _log.data('Top record event type is VAPE', hasVape);

  if (!hasVape) {
    _log.fail('$label: Top record is not VAPE — dumping actual content:');
    final anyText = find.descendant(of: topCard, matching: find.byType(Text));
    if ($.tester.any(anyText)) {
      for (final element in anyText.evaluate().take(5)) {
        final w = element.widget;
        if (w is Text) _log.debug('Top card text: "${w.data}"', indent: 2);
      }
    }
    return false;
  }

  // Check timestamp
  final tsFinder = find.descendant(
    of: topCard,
    matching: find.textContaining(expectedTimestamp),
  );
  final hasTimestamp = $.tester.any(tsFinder);
  _log.data('Timestamp exact match', hasTimestamp);

  if (!hasTimestamp) {
    _log.warn('$label: Exact timestamp not found — dumping top card texts:');
    final subtitleTexts = find.descendant(
      of: topCard,
      matching: find.byType(Text),
    );
    for (final element in subtitleTexts.evaluate()) {
      final w = element.widget;
      if (w is Text && w.data != 'VAPE') {
        _log.debug('Top card text: "${w.data}"', indent: 2);
      }
    }

    // Check ±1 minute for timing boundary
    final altBefore = DateFormat.yMMMd().add_jm().format(
      loggedAt.subtract(const Duration(minutes: 1)),
    );
    final altAfter = DateFormat.yMMMd().add_jm().format(
      loggedAt.add(const Duration(minutes: 1)),
    );
    _log.debug('Checking ±1 min: "$altBefore" / "$altAfter"');
    final hasAlt =
        $.tester.any(
          find.descendant(
            of: topCard,
            matching: find.textContaining(altBefore),
          ),
        ) ||
        $.tester.any(
          find.descendant(of: topCard, matching: find.textContaining(altAfter)),
        );
    _log.data('±1 min match in top record', hasAlt);
    return hasAlt;
  }

  _log.pass('$label: Top record verified — VAPE @ $expectedTimestamp');
  return true;
}

/// Validate the snackbar's reported duration against the expected hold duration.
///
/// Parses the "(X.Xs)" pattern from the snackbar text and compares it to
/// the expected duration with a configurable tolerance (default 1.5s).
///
/// Returns true if the duration matches within tolerance.
bool _verifySnackbarDuration(
  String? snackbarText,
  Duration expectedDuration,
  String label, {
  double toleranceSeconds = 1.5,
}) {
  _log.verify('$label: Validating snackbar duration...');

  if (snackbarText == null) {
    _log.warn('$label: No snackbar text to extract duration from');
    return false;
  }

  final match = RegExp(r'\((\d+\.?\d*)s\)').firstMatch(snackbarText);
  if (match == null) {
    _log.warn('$label: Could not parse duration from: "$snackbarText"');
    return false;
  }

  final actualSeconds = double.parse(match.group(1)!);
  final expectedSeconds = expectedDuration.inMilliseconds / 1000.0;
  final diff = (actualSeconds - expectedSeconds).abs();

  _log.data('Snackbar duration', '${actualSeconds}s');
  _log.data('Expected duration', '~${expectedSeconds.toStringAsFixed(1)}s');
  _log.data(
    'Difference',
    '${diff.toStringAsFixed(2)}s (tolerance: ${toleranceSeconds}s)',
  );

  final withinTolerance = diff <= toleranceSeconds;
  if (withinTolerance) {
    _log.pass('$label: Duration within tolerance');
  } else {
    _log.warn('$label: Duration outside tolerance!');
  }
  return withinTolerance;
}

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Test 1: Add a second account
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: add second account via Accounts screen',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        1,
        'Add second account',
        description:
            'Verifies that a second Firebase account can be added\n'
            'via the Accounts screen and both accounts appear as cards.',
      );

      // ── ARRANGE ──
      _log.stepStart('1.1', 'Ensure logged in with account 1');
      _log.arrange('Authenticating with primary test account');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'After ensureLoggedIn');
      await takeScreenshot($, 'multi_01_logged_in_account1');
      _log.stepEnd('1.1', summary: 'Account 1 authenticated');

      final home = HomeComponent($);
      final accounts = AccountsComponent($);
      final login = LoginComponent($);

      // ── ACT: Navigate to Accounts ──
      _log.stepStart('1.2', 'Navigate to Accounts screen');
      _log.action('Tapping account icon on Home screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      accounts.verifyVisible();
      await debugDumpAccountState($, 'Accounts screen visible');
      await accounts.debugDumpCards();
      await takeScreenshot($, 'multi_02_accounts_screen');
      _log.stepEnd('1.2', summary: 'Accounts screen displayed');

      // ── ASSERT: Single account present ──
      _log.stepStart('1.3', 'Verify single account present');
      _log.assert_('Expecting exactly 1 account card for $testEmail');
      accounts.verifyAccountCount(1);
      accounts.verifyActiveAccount(testEmail);
      _log.pass('Single account verified as active');
      _log.stepEnd('1.3');

      // ── ACT: Add second account ──
      _log.stepStart('1.4', 'Tap Add Another Account');
      _log.action('Tapping "Add Another Account" button');
      await accounts.tapAddAccount();
      await login.waitUntilVisible();
      login.verifyVisible();
      await takeScreenshot($, 'multi_03_login_for_account2');
      _log.stepEnd('1.4', summary: 'Login screen displayed');

      // ── ACT: Login with account 2 ──
      _log.stepStart('1.5', 'Login with account 2');
      _log.action('Submitting credentials for $testEmail2');
      await debugLogActiveUser('before account2 login');
      await login.loginWith(testEmail2, testPassword2);
      _log.info('Login form submitted — waiting for navigation...');

      await pumpUntilFound(
        $,
        find.byKey(const Key('nav_home')),
        timeout: const Duration(seconds: 60),
      );
      await handlePermissionDialogs($);
      await settle($, frames: 20);
      await debugDumpAccountState($, 'After account 2 login');
      await takeScreenshot($, 'multi_04_after_account2_login');
      _log.stepEnd('1.5', summary: 'Account 2 logged in');

      // ── ASSERT: Verify both accounts ──
      _log.stepStart('1.6', 'Verify both accounts present');
      _log.action('Navigating back to Accounts screen');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Accounts with both accounts');
      await takeScreenshot($, 'multi_05_both_accounts');

      _log.assert_('Expecting exactly 2 account cards');
      accounts.verifyAccountCount(2);
      _log.pass('Two account cards verified');
      _log.stepEnd('1.6');

      _log.testEnd(1, 'Add second account', [
        '✓ Account 1 authenticated and active',
        '✓ Account 2 added via login flow',
        '✓ Both accounts visible on Accounts screen',
      ]);
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
      _log.testStart(
        2,
        'Switch between accounts',
        description:
            'Verifies that switching between two logged-in accounts\n'
            'updates the active indicator and can be reversed.',
      );

      // ── ARRANGE ──
      _log.stepStart('2.1', 'Ensure both accounts present');
      _log.arrange('Authenticating with primary test account');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      _log.info('Checking if account 2 is already present...');
      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount2 = allAccounts.any((a) => a.email == testEmail2);
      _log.data('Account 2 present', hasAccount2);

      if (!hasAccount2) {
        _log.action('Adding account 2...');
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
      _log.stepEnd('2.1', summary: 'Both accounts ready');

      // ── ACT: Switch to account 2 ──
      _log.stepStart('2.2', 'Open Accounts and switch');
      _log.action('Opening Accounts screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await takeScreenshot($, 'multi_switch_01_before_switch');

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
      await takeScreenshot($, 'multi_switch_02_after_switch');
      _log.stepEnd('2.2', summary: 'Account switch executed');

      // ── ASSERT: Active indicator flipped ──
      _log.stepStart('2.3', 'Verify active account changed');
      final newActiveAcct = await AccountService().getActiveAccount();
      _log.data('Previous active', activeAcct?.email);
      _log.data('New active', newActiveAcct?.email);
      _log.assert_('Active account email should differ from original');
      expect(
        newActiveAcct?.email,
        isNot(equals(activeAcct?.email)),
        reason: 'Active account should have changed after switch',
      );
      _log.pass('Active account changed successfully');
      _log.stepEnd('2.3');

      // ── ACT: Switch back ──
      _log.stepStart('2.4', 'Switch back to original account');
      _log.action('Refreshing Accounts screen and switching back');
      await home.tapAccountIcon();
      await accounts.waitUntilVisible();
      await settle($, frames: 10);
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching back');
      await takeScreenshot($, 'multi_switch_03_switched_back');
      _log.stepEnd('2.4', summary: 'Switched back');

      // ── ASSERT: Original account restored ──
      _log.stepStart('2.5', 'Verify original account restored');
      final restoredAcct = await AccountService().getActiveAccount();
      _log.data('Restored active', restoredAcct?.email);
      _log.assert_('Active account should match original');
      expect(
        restoredAcct?.email,
        equals(activeAcct?.email),
        reason: 'Should have restored original active account',
      );
      _log.pass('Original account restored successfully');
      _log.stepEnd('2.5');

      _log.testEnd(2, 'Switch between accounts', [
        '✓ Switched from ${activeAcct?.email} to ${newActiveAcct?.email}',
        '✓ Active indicator updated correctly',
        '✓ Switched back to original account',
      ]);
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
      _log.testStart(
        3,
        'Log event after switching accounts',
        description:
            'KEY BUG REPRODUCTION TEST\n'
            'Verifies that quick-logging after an account swap\n'
            'records to the correct account and appears in History.',
      );

      // ── ARRANGE: Login + ensure account 2 ──
      _log.stepStart('3.1', 'Ensure both accounts present');
      _log.arrange('Authenticating and verifying two accounts');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      final hasAccount2 = allAccounts.any((a) => a.email == testEmail2);
      _log.data('Account 2 present', hasAccount2);

      if (!hasAccount2) {
        _log.action('Adding account 2...');
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
      _log.stepEnd('3.1', summary: 'Both accounts ready');

      // ── ACT: Baseline quick log for account 1 ──
      _log.stepStart('3.2', 'Quick log for account 1 (baseline)');
      _log.act('Recording a quick log for account 1 before switching');
      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Before logging - account 1');
      await debugDumpLogState($, 'Account 1 initial logs');
      await takeScreenshot($, 'multi_log_01_account1_initial');

      final acct1Duration = _randomHoldDuration();
      _log.action('Holding to record for ${acct1Duration.inMilliseconds}ms');
      final acct1LoggedAt = DateTime.now();
      await home.holdToRecord(duration: acct1Duration);
      await settle($, frames: 10);

      _log.info('Waiting for snackbar confirmation...');
      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final acct1Snackbar = _extractSnackbarText($);
      _log.pass('Quick log succeeded for account 1');
      _log.data('Snackbar', acct1Snackbar);
      _verifySnackbarDuration(acct1Snackbar, acct1Duration, '3.2');
      await debugDumpLogState($, 'Account 1 after quick log');
      await takeScreenshot($, 'multi_log_02_quicklog_acct1');
      _log.stepEnd('3.2', summary: 'Account 1 baseline log recorded');

      // ── ASSERT: Verify account 1 log in History BEFORE switching ──
      _log.stepStart('3.2b', 'Verify account 1 log in History');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await nav.tapHistory();
      final historyAcct1 = HistoryComponent($);
      await historyAcct1.waitUntilVisible();
      historyAcct1.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'multi_log_02b_history_acct1');

      final acct1TopMatch = _verifyTopHistoryRecord($, acct1LoggedAt, '3.2b');
      expect(
        acct1TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for account 1',
      );
      _log.pass('Account 1 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('3.2b');

      // ── ACT: Switch to account 2 ──
      _log.stepStart('3.3', 'Switch to account 2');
      _log.act('Switching active account from 1 to 2');
      await debugDumpAccountState($, 'Before switch to account 2');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'AFTER switch to account 2');
      await takeScreenshot($, 'multi_log_03_switched_to_acct2');
      _log.stepEnd('3.3', summary: 'Switched to account 2');

      // ── ACT: Quick log for account 2 (post-switch — the critical step) ──
      _log.stepStart('3.4', 'Quick log for account 2 (post-switch)');
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
          (await AccountService().getActiveAccount())?.email ?? testEmail2;
      final propagated = await waitForProviderPropagation($, switchedEmail);
      _log.data('Provider propagated', propagated);

      // Clear stale snackbars
      await debugDumpSnackbarState($, 'Before quick log (post-switch)');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log (post-switch)');

      await debugDumpAccountState($, 'Home screen after switch');
      await debugDumpLogState($, 'Account 2 before quick log');
      await takeScreenshot($, 'multi_log_04_home_acct2');

      // Extra settle so the widget tree is stable before the gesture.
      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      final acct2Duration = _randomHoldDuration();
      _log.action('Holding to record for ${acct2Duration.inMilliseconds}ms');
      await debugLogActiveUser('immediately before holdToRecord');
      final acct2LoggedAt = DateTime.now();
      await home.holdToRecord(duration: acct2Duration);
      _log.info('Gesture completed — recording should be processing...');
      await debugDumpQuickLogWidgetState($, 'After holdToRecord gesture');
      await settle($, frames: 10);

      await debugDumpSnackbarState($, 'Immediately after hold-to-record');

      // Poll for result with detailed diagnostics
      bool gotResult = false;
      String? acct2Snackbar;
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
          acct2Snackbar = _extractSnackbarText($);
          _log.pass('Quick log SUCCEEDED for account 2');
          _log.data('Snackbar', acct2Snackbar);
          _verifySnackbarDuration(acct2Snackbar, acct2Duration, '3.4');
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
      }

      await debugDumpAccountState($, 'After quick log for account 2');
      await debugDumpLogState($, 'Account 2 after quick log');
      await takeScreenshot($, 'multi_log_05_after_quicklog_acct2');
      _log.stepEnd(
        '3.4',
        summary: gotResult ? 'Quick log completed' : 'Quick log timed out',
      );

      // ── ASSERT: Verify log in History for account 2 ──
      _log.stepStart('3.5', 'Verify quick log in History (account 2)');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await debugDumpLogState($, 'Final log state for account 2');

      await nav.tapHistory();
      final history = HistoryComponent($);
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'On History screen (account 2)');
      await debugDumpLogState($, 'Account 2 History log state');
      await takeScreenshot($, 'multi_log_07_history_acct2');

      final acct2TopMatch = _verifyTopHistoryRecord($, acct2LoggedAt, '3.5');
      expect(
        acct2TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for account 2',
      );
      _log.pass('Top record verified in History for account 2');
      _log.stepEnd('3.5');

      // ── ASSERT: Data isolation — account 1 History is separate ──
      _log.stepStart('3.6', 'Verify data isolation (account 1 History)');
      _log.assert_('Account 1 History should not contain account 2 logs');
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
      _log.pass('Account 1 History verified — data isolation intact');
      _log.stepEnd('3.6');

      _log.testEnd(3, 'Log event after switching accounts', [
        '✓ Baseline quick log recorded for account 1',
        '✓ Account 1 log verified in History',
        '✓ Quick log recorded for account 2 post-switch',
        '✓ Account 2 log verified in History',
        '✓ Data isolation verified between accounts',
      ]);
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
      _log.testStart(
        4,
        'Quick log after switching accounts',
        description:
            'Simplified version of Test 3 — verifies quick log\n'
            'after account switch with simpler snackbar wait.',
      );

      // ── ARRANGE ──
      _log.stepStart('4.1', 'Ensure both accounts present');
      _log.arrange('Authenticating and ensuring account 2 exists');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);

      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail2)) {
        _log.action('Adding account 2...');
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
      _log.stepEnd('4.1', summary: 'Both accounts ready');

      // ── ACT: Baseline quick log for account 1 ──
      _log.stepStart('4.2', 'Baseline quick log for account 1');
      _log.act('Recording a quick log before switching accounts');
      await nav.tapHome();
      await home.waitUntilVisible();
      await debugDumpAccountState($, 'Home screen - account 1');
      await debugDumpLogState($, 'Account 1 before quick log');
      await takeScreenshot($, 'multi_quick_01_home_acct1');

      final t4Dur1 = _randomHoldDuration();
      _log.action('Holding to record for ${t4Dur1.inMilliseconds}ms');
      final t4Acct1LoggedAt = DateTime.now();
      await home.holdToRecord(duration: t4Dur1);
      await settle($, frames: 10);

      await pumpUntilFound(
        $,
        find.textContaining('Logged vape'),
        timeout: const Duration(seconds: 15),
      );
      final t4Acct1Snackbar = _extractSnackbarText($);
      _log.pass('Quick log confirmed for account 1');
      _log.data('Snackbar', t4Acct1Snackbar);
      _verifySnackbarDuration(t4Acct1Snackbar, t4Dur1, '4.2');
      await debugDumpLogState($, 'Account 1 after quick log');
      await takeScreenshot($, 'multi_quick_02_after_quicklog_acct1');
      _log.stepEnd('4.2', summary: 'Account 1 baseline recorded');

      // ── ASSERT: Verify account 1 log in History ──
      _log.stepStart('4.2b', 'Verify account 1 log in History');
      _log.assert_('Top History record should match just-logged entry');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'multi_quick_02b_history_acct1');

      final t4Acct1TopMatch = _verifyTopHistoryRecord(
        $,
        t4Acct1LoggedAt,
        '4.2b',
      );
      expect(
        t4Acct1TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for account 1',
      );
      _log.pass('Account 1 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('4.2b');

      // ── ACT: Switch to account 2 ──
      _log.stepStart('4.3', 'Switch to account 2');
      _log.act('Switching active account');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switching to account 2');
      await takeScreenshot($, 'multi_quick_03_switched_acct2');
      _log.stepEnd('4.3', summary: 'Switched to account 2');

      // ── ACT: Quick log for account 2 (post-switch) ──
      _log.stepStart('4.4', 'Quick log for account 2 (post-switch)');
      _log.act('Recording quick log after account switch');

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        _log.action('Pressing back button from Accounts');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      // Provider propagation after switch
      final t4SwitchedEmail =
          (await AccountService().getActiveAccount())?.email ?? testEmail2;
      final t4Propagated = await waitForProviderPropagation($, t4SwitchedEmail);
      _log.data('Provider propagated', t4Propagated);

      await debugDumpSnackbarState($, 'Before quick log (post-switch)');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log (post-switch)');

      await debugDumpAccountState($, 'Home screen - account 2');
      await debugDumpLogState($, 'Account 2 before quick log');
      await takeScreenshot($, 'multi_quick_04_home_acct2');

      // Extra settle so the widget tree is stable before the gesture.
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
      _log.pass('Quick log confirmed for account 2');
      _log.data('Snackbar', t4Snackbar);
      _verifySnackbarDuration(t4Snackbar, t4Dur2, '4.4');

      await debugDumpAccountState($, 'After quick log - account 2');
      await debugDumpLogState($, 'Account 2 after quick log');
      await takeScreenshot($, 'multi_quick_05_after_quicklog_acct2');
      _log.stepEnd('4.4', summary: 'Account 2 quick log recorded');

      // ── ASSERT: Verify log in History for account 2 ──
      _log.stepStart('4.5', 'Verify quick log in History (account 2)');
      _log.assert_('Top History record should be the VAPE entry just logged');
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History screen - account 2');
      await debugDumpLogState($, 'Account 2 history log state');
      await takeScreenshot($, 'multi_quick_06_history_acct2');

      final t4TopMatch = _verifyTopHistoryRecord($, t4LoggedAt, '4.5');
      expect(
        t4TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for account 2',
      );
      _log.pass('Top record verified in History for account 2');
      _log.stepEnd('4.5');

      // ── ASSERT: Data isolation ──
      _log.stepStart('4.6', 'Verify data isolation (switch back to account 1)');
      _log.assert_('Account 1 History should be separate from account 2');
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
      await debugDumpAccountState($, 'History screen - account 1');
      await debugDumpLogState($, 'Account 1 history after switching back');
      await takeScreenshot($, 'multi_quick_07_history_acct1');

      _log.pass('Account 1 History screen verified');
      await takeScreenshot($, 'multi_quick_08_back_to_acct1');
      _log.stepEnd('4.6');

      _log.testEnd(4, 'Quick log after switching accounts', [
        '✓ Quick log recorded for account 2 post-switch',
        '✓ VAPE entry verified in History for account 2',
        '✓ Data isolation verified for account 1',
      ]);
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
      _log.testStart(
        5,
        'Sign out single account',
        description:
            'Verifies that signing out the non-active account\n'
            'removes it and leaves exactly 1 logged-in account.',
      );

      // ── ARRANGE ──
      _log.stepStart('5.1', 'Ensure both accounts present');
      _log.arrange('Authenticating and ensuring account 2 exists');
      await ensureLoggedIn($);

      final home = HomeComponent($);
      final accounts = AccountsComponent($);

      final allAccts = await AccountService().getAllAccounts();
      if (!allAccts.any((a) => a.email == testEmail2)) {
        _log.action('Adding account 2...');
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
      _log.stepEnd('5.1', summary: 'Both accounts present');

      // ── ACT: Open Accounts screen ──
      _log.stepStart('5.2', 'Open Accounts screen');
      _log.action('Navigating to Accounts screen');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();
      await debugDumpAccountState($, 'Before sign-out');
      await takeScreenshot($, 'multi_signout_01_before');

      _log.assert_('Expecting 2 account cards');
      accounts.verifyAccountCount(2);
      _log.stepEnd('5.2', summary: '2 accounts verified');

      // ── ACT: Sign out non-active account ──
      _log.stepStart('5.3', 'Sign out non-active account');
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
          await takeScreenshot($, 'multi_signout_02_popup_menu');

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

      await debugDumpAccountState($, 'After signing out non-active account');
      await takeScreenshot($, 'multi_signout_03_after');
      _log.stepEnd('5.3', summary: 'Sign-out action completed');

      // ── ASSERT: Verify single account remains ──
      _log.stepStart('5.4', 'Verify single account remains');
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
        reason: 'Should have exactly 1 logged-in account after sign-out',
      );
      _log.pass('Single account remains after sign-out');
      await takeScreenshot($, 'multi_signout_04_final');
      _log.stepEnd('5.4');

      _log.testEnd(5, 'Sign out single account', [
        '✓ Non-active account signed out via popup menu',
        '✓ Exactly 1 logged-in account remains',
      ]);
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
      _log.testStart(
        6,
        'Full multi-account cycle',
        description:
            'Comprehensive end-to-end lifecycle:\n'
            'login → log → verify → add account → switch →\n'
            'log → verify → data isolation → cleanup',
      );

      // ── Phase 1: Start clean → Login account 1 ──
      _log.stepStart('6.1', 'Clean start — login account 1');
      _log.arrange('Logging out all accounts, then signing in with account 1');
      await ensureLoggedOut($);
      await debugDumpAccountState($, 'Clean start — logged out');
      await takeScreenshot($, 'multi_full_01_logged_out');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);
      final welcome = WelcomeComponent($);
      final login = LoginComponent($);

      _log.action('Tapping Sign In on Welcome screen');
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
      await debugDumpAccountState($, 'Account 1 logged in');
      await takeScreenshot($, 'multi_full_02_acct1_home');
      _log.stepEnd('6.1', summary: 'Account 1 logged in');

      // ── Phase 2: Quick log for account 1 ──
      _log.stepStart('6.2', 'Quick log for account 1');
      _log.act('Recording a baseline quick log for account 1');
      await debugDumpLogState($, 'Account 1 log state');

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
      _log.pass('Account 1 quick log recorded');
      _log.data('Snackbar', p2Snackbar);
      _verifySnackbarDuration(p2Snackbar, p2Duration, '6.2');
      await debugDumpLogState($, 'After quick log for account 1');
      await takeScreenshot($, 'multi_full_03_acct1_logged');
      _log.stepEnd('6.2', summary: 'Baseline log recorded');

      // ── Phase 2b: Verify account 1 log in History ──
      _log.stepStart('6.2b', 'Verify account 1 log in History');
      _log.assert_('Top History record should be the just-logged VAPE entry');
      final history = HistoryComponent($);
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await takeScreenshot($, 'multi_full_03b_history_acct1');

      final p2TopMatch = _verifyTopHistoryRecord($, p2LoggedAt, '6.2b');
      expect(
        p2TopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged for account 1',
      );
      _log.pass('Account 1 top record verified in History');

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('6.2b');

      // ── Phase 3: Add account 2 ──
      _log.stepStart('6.3', 'Add account 2');
      _log.act('Adding second account via Accounts screen');
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
      await debugDumpAccountState($, 'Account 2 added');
      await takeScreenshot($, 'multi_full_04_acct2_added');
      _log.stepEnd('6.3', summary: 'Account 2 added');

      // ── Phase 4: Switch to account 2 ──
      _log.stepStart('6.4', 'Switch to account 2');
      _log.act('Switching active account');
      await home.tapAccountIcon();
      await handlePermissionDialogs($);
      await accounts.waitUntilVisible();
      await accounts.debugDumpCards();

      final preSwitch = await AccountService().getActiveAccount();
      _log.data('Active before switch', preSwitch?.email);
      await debugDumpAccountState($, 'Before switch');

      final switchingTo =
          preSwitch?.email == testEmail2 ? testEmail : testEmail2;
      _log.data('Switching to', switchingTo);

      await accounts.switchToAccount(1);
      await debugDumpAccountState($, 'After switch');
      await takeScreenshot($, 'multi_full_05_switched');

      final postSwitch = await AccountService().getActiveAccount();
      _log.data('Active after switch', postSwitch?.email);
      _log.stepEnd('6.4', summary: 'Switched to ${postSwitch?.email}');

      // ── Phase 5: Quick log for switched account (CRITICAL) ──
      _log.stepStart('6.5', 'Quick log for switched account (CRITICAL)');
      _log.act(
        'Recording quick log after account switch — this is the critical bug-detection step',
      );

      final backButton = find.byType(BackButton);
      if ($.tester.any(backButton)) {
        _log.action('Pressing back button from Accounts');
        await $(backButton).tap(settlePolicy: SettlePolicy.noSettle);
        await settle($, frames: 10);
      }

      await nav.tapHome();
      await home.waitUntilVisible();

      // Provider propagation
      final p5ExpectedEmail = postSwitch?.email ?? switchingTo;
      final p5Propagated = await waitForProviderPropagation($, p5ExpectedEmail);
      _log.data('Provider propagated', p5Propagated);

      await debugDumpSnackbarState($, 'Before quick log');
      await clearSnackbars($);
      await debugDumpQuickLogWidgetState($, 'Before quick log');

      await debugDumpAccountState($, 'Home screen after switch');
      await debugDumpLogState($, 'Log state before quick log');
      await takeScreenshot($, 'multi_full_06_home_switched');

      // Extra settle so the widget tree is fully stable after the account
      // switch, snackbar clear, and debug dumps before we start the gesture.
      await settle($, frames: 20);
      await $.pump(const Duration(seconds: 1));

      final p5Duration = _randomHoldDuration();
      _log.action('Holding to record for ${p5Duration.inMilliseconds}ms');
      await debugLogActiveUser('immediately before holdToRecord');
      final p5LoggedAt = DateTime.now();
      await home.holdToRecord(duration: p5Duration);
      _log.info('Gesture completed — recording should be processing...');
      await debugDumpQuickLogWidgetState($, 'After gesture');
      await settle($, frames: 10);

      await debugDumpSnackbarState($, 'After hold-to-record');

      // Poll for confirmation
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
          _log.pass('Quick log SUCCEEDED for switched account');
          _log.data('Snackbar', p5Snackbar);
          _verifySnackbarDuration(p5Snackbar, p5Duration, '6.5');
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
      }

      await debugDumpAccountState($, 'After quick log');
      await debugDumpLogState($, 'After quick log');
      await takeScreenshot($, 'multi_full_07_after_quicklog_switched');
      _log.stepEnd(
        '6.5',
        summary: logSuccess ? 'Quick log succeeded' : 'Quick log failed',
      );

      // ── Phase 5b: Verify quick log in History ──
      _log.stepStart('6.5b', 'Verify quick log in History');
      _log.assert_('Top History record should match the just-logged entry');
      await nav.tapHistory();
      await history.waitUntilVisible();
      history.verifyVisible();
      await settle($, frames: 10);
      await debugDumpAccountState($, 'History for switched account');
      await debugDumpLogState($, 'History log state');
      await takeScreenshot($, 'multi_full_08_history_switched');

      final p5bTopMatch = _verifyTopHistoryRecord($, p5LoggedAt, '6.5b');
      expect(
        p5bTopMatch,
        isTrue,
        reason:
            'Top History record should be the VAPE entry just logged after switch',
      );
      _log.pass('Top record verified in History');
      _log.stepEnd('6.5b');

      // ── Phase 6: Verify data isolation ──
      _log.stepStart('6.6', 'Verify data isolation');
      _log.assert_('Account 1 History should be separate from account 2');

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
      await debugDumpLogState($, 'Account 1 History log state');
      await takeScreenshot($, 'multi_full_09_history_acct1');
      _log.pass('Data isolation verified — account 1 History intact');
      _log.stepEnd('6.6');

      // ── Phase 7: Cleanup ──
      _log.stepStart('6.7', 'Cleanup — sign out all');
      _log.act('Signing out all accounts programmatically');
      await debugDumpAccountState($, 'Before cleanup');

      await FirebaseAuth.instance.signOut();
      try {
        await AccountService().deactivateAllAccounts();
      } catch (e) {
        _log.warn('deactivateAllAccounts error: $e');
      }
      // Give Riverpod providers time to settle before teardown
      await settle($, frames: 30);
      await $.pump(const Duration(seconds: 2));
      await settle($, frames: 10);
      await debugDumpAccountState($, 'After cleanup');
      await takeScreenshot($, 'multi_full_10_cleanup');
      _log.stepEnd('6.7', summary: 'Cleanup complete');

      _log.testEnd(6, 'Full multi-account cycle', [
        '✓ Account 1 logged in and baseline log recorded',
        '✓ Account 1 log verified in History',
        '✓ Account 2 added and switched',
        '✓ Quick log success after switch: $logSuccess',
        '✓ History verification: passed',
        '✓ Data isolation: verified',
        '✓ Cleanup: completed',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 7: Repeated swap + log (3 iterations) — consistency check
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: swap and log 3x loop',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        7,
        'Swap and log 3x loop',
        description:
            'Swaps between accounts and records a quick log\n'
            '3 times to verify consistency across switches.',
      );

      // ── Setup ──
      _log.stepStart('7.0', 'Setup — ensure both accounts present');
      _log.arrange('Logging in and verifying account 2 exists');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      if (!allAccounts.any((a) => a.email == testEmail2)) {
        _log.action('Adding account 2...');
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

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('7.0', summary: 'Both accounts ready');

      int successCount = 0;

      for (int i = 1; i <= 3; i++) {
        // ── Step A: Switch account ──
        _log.stepStart('7.$i.A', 'Iteration $i/3 — switch account');
        _log.act('Switching active account');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.debugDumpCards();
        await accounts.switchToAccount(1);
        await debugDumpAccountState($, 'Iter $i: After switch');
        await takeScreenshot($, 'multi_loop3_${i}_switched');

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
        _log.stepEnd('7.$i.A', summary: 'Switched to $loopActiveEmail');

        // ── Step B: Quick log ──
        _log.stepStart('7.$i.B', 'Iteration $i/3 — quick log');
        // Extra settle so the widget tree is stable before the gesture.
        await settle($, frames: 20);
        await $.pump(const Duration(seconds: 1));

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
            _verifySnackbarDuration(loopSnackbar, loopDur, '7.$i.B');
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
        await takeScreenshot($, 'multi_loop3_${i}_logged');
        _log.stepEnd(
          '7.$i.B',
          summary: logged ? 'Log succeeded' : 'Log failed',
        );

        // ── Step C: Verify in History ──
        _log.stepStart('7.$i.C', 'Iteration $i/3 — verify History');
        _log.assert_('Top History record should match just-logged entry');
        await nav.tapHistory();
        final history = HistoryComponent($);
        await history.waitUntilVisible();
        await settle($, frames: 10);

        final loopTopMatch = _verifyTopHistoryRecord($, loopLoggedAt, '7.$i.C');
        expect(
          loopTopMatch,
          isTrue,
          reason:
              'Iteration $i: Top History record should be the VAPE entry just logged',
        );
        _log.pass('Iter $i: Top record verified');
        await takeScreenshot($, 'multi_loop3_${i}_history');

        await nav.tapHome();
        await home.waitUntilVisible();
        _log.stepEnd('7.$i.C');
      }

      expect(
        successCount,
        equals(3),
        reason: 'All 3 swap+log iterations should succeed',
      );

      _log.testEnd(7, 'Swap and log 3x loop', [
        'Successes: $successCount / 3',
        '✓ All 3 iterations passed',
      ]);
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Test 8: Repeated swap + log (6 iterations) — extended consistency
  // ─────────────────────────────────────────────────────────────────────────
  patrolTest(
    'Multi-account: swap and log 6x loop',
    config: defaultPatrolConfig,
    nativeAutomatorConfig: defaultNativeConfig,
    ($) async {
      _log.testStart(
        8,
        'Swap and log 6x loop',
        description:
            'Swaps between accounts and records a quick log\n'
            '6 times to stress-test consistency.',
      );

      // ── Setup ──
      _log.stepStart('8.0', 'Setup — ensure both accounts present');
      _log.arrange('Logging in and verifying account 2 exists');
      await ensureLoggedIn($);
      await debugDumpAccountState($, 'Initial state');

      final home = HomeComponent($);
      final nav = NavBarComponent($);
      final accounts = AccountsComponent($);

      final allAccounts = await AccountService().getAllAccounts();
      if (!allAccounts.any((a) => a.email == testEmail2)) {
        _log.action('Adding account 2...');
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

      await nav.tapHome();
      await home.waitUntilVisible();
      _log.stepEnd('8.0', summary: 'Both accounts ready');

      int successCount = 0;
      final List<String> iterationResults = [];

      for (int i = 1; i <= 6; i++) {
        // ── Step A: Switch account ──
        _log.stepStart('8.$i.A', 'Iteration $i/6 — switch account');
        _log.act('Switching active account');
        await home.tapAccountIcon();
        await handlePermissionDialogs($);
        await accounts.waitUntilVisible();
        await accounts.debugDumpCards();
        await accounts.switchToAccount(1);

        final activeAcct = await AccountService().getActiveAccount();
        _log.data('Active after switch', activeAcct?.email);
        await debugDumpAccountState($, 'Iter $i: After switch');
        await takeScreenshot($, 'multi_loop6_${i}_switched');

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
        _log.stepEnd('8.$i.A', summary: 'Switched to $loopActiveEmail');

        // ── Step B: Quick log ──
        _log.stepStart('8.$i.B', 'Iteration $i/6 — quick log');
        // Extra settle so the widget tree is stable before the gesture.
        await settle($, frames: 20);
        await $.pump(const Duration(seconds: 1));

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
            _verifySnackbarDuration(loopSnackbar, loopDur, '8.$i.B');
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
        }

        await debugDumpLogState($, 'Iter $i: After quick log');
        await takeScreenshot($, 'multi_loop6_${i}_logged');
        _log.stepEnd(
          '8.$i.B',
          summary: logged ? 'Log succeeded' : 'Log failed',
        );

        // ── Step C: Verify in History ──
        _log.stepStart('8.$i.C', 'Iteration $i/6 — verify History');
        _log.assert_('Top History record should match just-logged entry');
        await nav.tapHistory();
        final history = HistoryComponent($);
        await history.waitUntilVisible();
        await settle($, frames: 10);

        final loopTopMatch = _verifyTopHistoryRecord($, loopLoggedAt, '8.$i.C');
        expect(
          loopTopMatch,
          isTrue,
          reason:
              'Iteration $i: Top History record should be the VAPE entry just logged',
        );
        _log.pass('Iter $i: Top record verified');
        await takeScreenshot($, 'multi_loop6_${i}_history');

        await nav.tapHome();
        await home.waitUntilVisible();
        _log.stepEnd('8.$i.C');
      }

      expect(
        successCount,
        equals(6),
        reason: 'All 6 swap+log iterations should succeed',
      );

      _log.testEnd(8, 'Swap and log 6x loop', [
        ...iterationResults,
        'Successes: $successCount / 6',
        '✓ All 6 iterations passed',
      ]);
    },
  );
}
