import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';

/// Log file for test diagnostics — written to a file so we can read it
/// even though Dart print() doesn't reach the host terminal in Patrol iOS tests.
late final File _logFile;
bool _logFileInitialized = false;

/// Resolve the project-root `logs/` directory.
///
/// 1. Try `Platform.script` (works when running from the host CLI).
/// 2. Parse `StackTrace.current` — the Dart VM in debug mode retains the real
///    source paths even inside the iOS simulator, so we can extract the project
///    root from there.
/// 3. Fall back to `/tmp/ash_trail_logs` as a last resort.
Directory _resolveLogsDir() {
  // 1. Platform.script
  try {
    final scriptPath = Platform.script.toFilePath();
    if (scriptPath.contains('integration_test')) {
      return Directory('${scriptPath.split('integration_test').first}logs');
    }
  } catch (_) {}

  // 2. StackTrace (reliable in debug-mode simulator builds)
  try {
    final trace = StackTrace.current.toString();
    final match = RegExp(r'file://(/.+?/)integration_test/').firstMatch(trace);
    if (match != null) {
      return Directory('${match.group(1)}logs');
    }
  } catch (_) {}

  // 3. Fallback
  return Directory('/tmp/ash_trail_logs');
}

void _initLogFile() {
  if (_logFileInitialized) return;
  _logFileInitialized = true;

  final logsDir = _resolveLogsDir();
  if (!logsDir.existsSync()) {
    logsDir.createSync(recursive: true);
  }
  _logFile = File('${logsDir.path}/ash_trail_test_diagnostics.log');
  // Truncate on first init
  _logFile.writeAsStringSync(
    '=== AshTrail Test Diagnostics ===\n'
    'Started: ${DateTime.now()}\n\n',
  );
}

/// Simple timestamped logger for test diagnostics.
/// Writes to /tmp/ash_trail_test_diagnostics.log and also to print/developer.log.
void testLog(String message) {
  _initLogFile();
  final ts = DateTime.now().toIso8601String().substring(11, 23); // HH:mm:ss.mmm
  final line = '[$ts] DIALOG_HANDLER: $message';
  // Write to file (most reliable way to get output from Patrol iOS tests)
  _logFile.writeAsStringSync('$line\n', mode: FileMode.append);
  // Also try print & developer.log (may not reach host terminal)
  // ignore: avoid_print
  print(line);
  developer.log(line, name: 'pump');
}

/// @internal — alias kept for backward compat with existing callers.
void _log(String message) => testLog(message);

/// Dump a summary of the current widget tree to help diagnose finder issues.
void _dumpWidgetSummary(PatrolIntegrationTester $) {
  try {
    // Check for specific dialog-related widgets
    final alertDialogs = find.byType(AlertDialog);
    final dialogs = find.byType(Dialog);
    final overlays = find.byType(ModalBarrier);

    _log('  Widget scan:');
    _log('    AlertDialog widgets: ${alertDialogs.evaluate().length}');
    _log('    Dialog widgets: ${dialogs.evaluate().length}');
    _log('    ModalBarrier widgets: ${overlays.evaluate().length}');

    // Check for the specific text & buttons we care about
    final locationAccessText = find.text('Location Access');
    final notNowText = find.text('Not Now');
    final allowText = find.text('Allow');
    final textButtons = find.byType(TextButton);
    final filledButtons = find.byType(FilledButton);

    _log('    "Location Access" text: ${locationAccessText.evaluate().length}');
    _log('    "Not Now" text: ${notNowText.evaluate().length}');
    _log('    "Allow" text: ${allowText.evaluate().length}');
    _log('    TextButton widgets: ${textButtons.evaluate().length}');
    _log('    FilledButton widgets: ${filledButtons.evaluate().length}');

    // If we find "Not Now", log its widget details
    if (notNowText.evaluate().isNotEmpty) {
      final element = notNowText.evaluate().first;
      _log('    "Not Now" widget: ${element.widget}');
      _log('    "Not Now" renderObject: ${element.renderObject?.runtimeType}');
      _log('    "Not Now" size: ${element.renderObject?.paintBounds}');
    }

    // If we find "Allow", log its widget details
    if (allowText.evaluate().isNotEmpty) {
      final element = allowText.evaluate().first;
      _log('    "Allow" widget: ${element.widget}');
      _log('    "Allow" renderObject: ${element.renderObject?.runtimeType}');
      _log('    "Allow" size: ${element.renderObject?.paintBounds}');
    }
  } catch (e) {
    _log('  Widget scan failed: $e');
  }
}

/// Dismiss any native permission dialog (e.g. location) by granting access.
///
/// Silently does nothing if no dialog is visible. Call this after navigating
/// to any screen that might trigger a system permission prompt.
Future<void> handleNativePermissionDialogs(
  PatrolIntegrationTester $, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  _log(
    'Checking for native permission dialog (timeout: ${timeout.inSeconds}s)...',
  );
  try {
    if (await $.native.isPermissionDialogVisible(timeout: timeout)) {
      _log('Native dialog IS visible — granting permission');
      await $.native.grantPermissionWhenInUse();
      await $.pump(const Duration(milliseconds: 500));
      _log('Native dialog handled');
    } else {
      _log('No native dialog visible');
    }
  } catch (e) {
    _log('Native dialog check error: $e');
  }
}

/// Dismiss the app's own Flutter "Location Access" dialog.
///
/// The LoggingScreen shows this AlertDialog in initState (via IndexedStack,
/// it fires as soon as MainNavigation builds). We tap "Not Now" to dismiss
/// without triggering the native iOS permission flow.
/// If the dialog doesn't appear within a few seconds this is a no-op.
Future<void> handleLocationDialog(PatrolIntegrationTester $) async {
  _log('=== handleLocationDialog START ===');
  _log('Looking for Flutter "Location Access" dialog...');

  // Dump initial widget state
  _dumpWidgetSummary($);

  final notNowText = find.text('Not Now');
  final allowText = find.text('Allow');
  final alertDialogFinder = find.byType(AlertDialog);

  final end = DateTime.now().add(const Duration(seconds: 2));
  int iteration = 0;
  while (DateTime.now().isBefore(end)) {
    await $.pump(const Duration(milliseconds: 250));
    iteration++;

    final hasAlertDialog = $.tester.any(alertDialogFinder);
    final hasNotNow = $.tester.any(notNowText);
    final hasAllow = $.tester.any(allowText);

    if (iteration % 4 == 1) {
      // Log every ~1 second
      _log(
        '  Poll #$iteration: AlertDialog=$hasAlertDialog, '
        '"Not Now"=$hasNotNow, "Allow"=$hasAllow',
      );
    }

    if (hasNotNow) {
      _log('  >>> FOUND "Not Now" button — attempting tap via tester.tap()');
      _dumpWidgetSummary($);
      try {
        await $.tester.tap(notNowText);
        _log('  >>> tester.tap(notNowText) completed');
        await $.pump(const Duration(milliseconds: 500));

        // Verify dialog is gone
        final stillHasDialog = $.tester.any(alertDialogFinder);
        final stillHasNotNow = $.tester.any(notNowText);
        _log(
          '  >>> After tap+pump: AlertDialog=$stillHasDialog, '
          '"Not Now"=$stillHasNotNow',
        );

        if (!stillHasNotNow) {
          _log('  >>> Dialog dismissed successfully!');
        } else {
          _log(
            '  >>> WARNING: "Not Now" still visible after tap — '
            'trying alternative approach with TextButton finder',
          );
          // Try finding the TextButton containing "Not Now"
          final textButtonWithNotNow = find.widgetWithText(
            TextButton,
            'Not Now',
          );
          if ($.tester.any(textButtonWithNotNow)) {
            _log('  >>> Found TextButton with "Not Now" — tapping it');
            await $.tester.tap(textButtonWithNotNow);
            await $.pump(const Duration(milliseconds: 500));
            _log('  >>> TextButton tap completed');
          }

          // Last resort: try tapping the Allow FilledButton instead
          final filledButtonWithAllow = find.widgetWithText(
            FilledButton,
            'Allow',
          );
          if ($.tester.any(find.text('Not Now'))) {
            _log('  >>> Still visible — trying FilledButton "Allow"');
            if ($.tester.any(filledButtonWithAllow)) {
              await $.tester.tap(filledButtonWithAllow);
              await $.pump(const Duration(milliseconds: 500));
              _log('  >>> FilledButton "Allow" tap completed');
              // This will trigger native dialog, handle it
              await handleNativePermissionDialogs($);
            }
          }
        }

        _log('=== handleLocationDialog END (found & tapped) ===');
        return;
      } catch (e) {
        _log('  >>> TAP ERROR: $e');
      }
    }

    if (hasAllow && !hasNotNow) {
      _log(
        '  >>> Found "Allow" but not "Not Now" — trying "Allow" as fallback',
      );
      try {
        await $.tester.tap(allowText);
        _log('  >>> "Allow" tap completed');
        await $.pump(const Duration(milliseconds: 500));
        await handleNativePermissionDialogs($);
        _log('=== handleLocationDialog END (Allow fallback) ===');
        return;
      } catch (e) {
        _log('  >>> "Allow" TAP ERROR: $e');
      }
    }
  }

  _log('  Dialog not found within timeout');
  _dumpWidgetSummary($);
  _log('=== handleLocationDialog END (timeout) ===');
}

/// Handle all permission dialogs — both the app's Flutter dialog and the
/// native iOS dialog. Call this after login or any navigation that may
/// trigger location prompts.
Future<void> handlePermissionDialogs(PatrolIntegrationTester $) async {
  _log('>>> handlePermissionDialogs called');
  // 1. Dismiss the app's own Flutter "Location Access" dialog
  await handleLocationDialog($);
  // 2. Dismiss native iOS permission dialog if it appeared
  //    (e.g. after tapping "Allow" in the Flutter dialog, or triggered
  //    asynchronously by Geolocator.requestPermission)
  await handleNativePermissionDialogs($);
  _log('>>> handlePermissionDialogs finished');
}

/// Pump frames until [finder] matches at least one widget, or until [timeout].
///
/// Uses manual pumping so continuous timers (animations, streams) don't cause
/// `pumpAndSettle` to hang indefinitely.
Future<void> pumpUntilFound(
  PatrolIntegrationTester $,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration interval = const Duration(milliseconds: 250),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await $.pump(interval);
    if ($.tester.any(finder)) return;
  }
  // One final pump to let the framework flush any pending microtasks.
  await $.pump(interval);
}

/// Pump frames until [finder] no longer matches any widget, or until [timeout].
Future<void> pumpUntilGone(
  PatrolIntegrationTester $,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  Duration interval = const Duration(milliseconds: 250),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await $.pump(interval);
    if (!$.tester.any(finder)) return;
  }
  await $.pump(interval);
}

/// Extra settle after navigation — pump [frames] frames with [interval] gaps.
///
/// Use this after transitions to let animations finish and providers update,
/// without relying on `pumpAndSettle` which hangs with perpetual timers.
Future<void> settle(
  PatrolIntegrationTester $, {
  int frames = 40,
  Duration interval = const Duration(milliseconds: 250),
}) async {
  for (int i = 0; i < frames; i++) {
    await $.pump(interval);
  }
}

// ── Screenshots ──────────────────────────────────────────────────────────────

/// Directory where E2E screenshots are saved (relative to project root on the
/// simulator filesystem — accessible from the host via /tmp/).
const _screenshotDir = '/tmp/ash_trail_screenshots';

/// Auto-incrementing counter so screenshots sort chronologically.
int _screenshotCounter = 0;

/// Take a Flutter-level screenshot by rendering the current widget tree.
///
/// Files are saved to [_screenshotDir] as numbered PNGs:
///   001_welcome_screen.png, 002_login_filled.png, etc.
///
/// Returns the path to the saved file, or null if the capture failed.
Future<String?> takeScreenshot(PatrolIntegrationTester $, String name) async {
  try {
    _screenshotCounter++;
    final idx = _screenshotCounter.toString().padLeft(3, '0');
    final sanitized = name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final filename = '${idx}_$sanitized.png';
    final path = '$_screenshotDir/$filename';

    // Pump one frame to make sure the render tree is up-to-date
    await $.tester.pump(const Duration(milliseconds: 100));

    // Find the RepaintBoundary at the root (Patrol wraps the app in one)
    final boundary = _findRepaintBoundary($);
    if (boundary == null) {
      _log('SCREENSHOT: Could not find RepaintBoundary — skipping "$name"');
      return null;
    }

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      _log('SCREENSHOT: toByteData returned null — skipping "$name"');
      return null;
    }

    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    _log('SCREENSHOT: saved $filename');
    return path;
  } catch (e) {
    _log('SCREENSHOT: error capturing "$name": $e');
    return null;
  }
}

/// Find the nearest [RenderRepaintBoundary] that contains the whole app.
RenderRepaintBoundary? _findRepaintBoundary(PatrolIntegrationTester $) {
  // Try MaterialApp first (most common), then WidgetsApp, then any RepaintBoundary
  for (final type in [MaterialApp, WidgetsApp]) {
    final finder = find.byType(type);
    if (finder.evaluate().isNotEmpty) {
      RenderObject? ro = finder.evaluate().first.renderObject;
      // Walk up until we hit a RepaintBoundary
      while (ro != null) {
        if (ro is RenderRepaintBoundary) return ro;
        ro = ro.parent;
      }
    }
  }
  // Fallback: find any RepaintBoundary
  final rpb = find.byType(RepaintBoundary);
  if (rpb.evaluate().isNotEmpty) {
    final ro = rpb.evaluate().first.renderObject;
    if (ro is RenderRepaintBoundary) return ro;
  }
  return null;
}

// ── Multi-Account Debug Diagnostics ──────────────────────────────────────────

/// Find the nearest [ProviderContainer] by walking up from the widget tree.
/// Returns null if none found—Riverpod's [UncontrolledProviderScope] stores
/// the container in its element.
ProviderContainer? _findProviderContainer(PatrolIntegrationTester $) {
  try {
    // Look for ProviderScope (the normal wrapper for Riverpod apps)
    final scope = find.byType(ProviderScope);
    if (scope.evaluate().isNotEmpty) {
      // ProviderScope has a .container accessor exposed through the element
      final element = scope.evaluate().first;
      if (element is StatefulElement) {
        final state = element.state;
        // The ProviderScope state exposes the container
        if (state is ConsumerState) {
          // Walk to UncontrolledProviderScope
        }
      }
    }
    // Alternative: look for UncontrolledProviderScope, which stores
    // the container directly
    final uncontrolled = find.byType(UncontrolledProviderScope);
    if (uncontrolled.evaluate().isNotEmpty) {
      final element = uncontrolled.evaluate().first;
      final widget = element.widget as UncontrolledProviderScope;
      return widget.container;
    }
  } catch (e) {
    _log('DEBUG: _findProviderContainer error: $e');
  }
  return null;
}

/// Dump comprehensive account + auth state to diagnostics log.
///
/// Captures:
/// - Firebase Auth current user (uid, email, providers)
/// - Hive account list (all accounts: userId, email, isActive, isLoggedIn)
/// - Riverpod provider state (activeAccountProvider, activeAccountIdProvider)
/// - Visible UI state (text on screen containing email addresses)
///
/// Call this at EVERY step during multi-account switching to trace exactly
/// where state diverges from expectations.
Future<void> debugDumpAccountState(
  PatrolIntegrationTester $,
  String label,
) async {
  testLog('');
  testLog('╔══════════════════════════════════════════════════════╗');
  testLog('║  ACCOUNT STATE DUMP: $label');
  testLog('╚══════════════════════════════════════════════════════╝');

  // 1. Firebase Auth state
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      testLog('  📱 Firebase Auth:');
      testLog('     uid:   ${user.uid}');
      testLog('     email: ${user.email}');
      testLog(
        '     providers: ${user.providerData.map((p) => p.providerId).join(', ')}',
      );
      testLog('     isAnonymous: ${user.isAnonymous}');
    } else {
      testLog('  📱 Firebase Auth: NOT SIGNED IN (currentUser == null)');
    }
  } catch (e) {
    testLog('  📱 Firebase Auth: ERROR reading state: $e');
  }

  // 2. Hive account state via AccountService
  try {
    final accountService = AccountService();
    final allAccounts = await accountService.getAllAccounts();
    final activeAccount = await accountService.getActiveAccount();
    testLog('  🗄️  Hive Accounts (${allAccounts.length} total):');
    for (final acct in allAccounts) {
      final marker = acct.userId == activeAccount?.userId ? ' ← ACTIVE' : '';
      testLog(
        '     [${acct.userId.substring(0, 8)}...] '
        '${acct.email} '
        'isActive=${acct.isActive} '
        'isLoggedIn=${acct.isLoggedIn}$marker',
      );
    }
    if (activeAccount != null) {
      testLog(
        '  🗄️  Active account: ${activeAccount.email} (${activeAccount.userId})',
      );
    } else {
      testLog('  🗄️  Active account: NONE');
    }
  } catch (e) {
    testLog('  🗄️  Hive Accounts: ERROR reading state: $e');
  }

  // 3. Riverpod provider state
  try {
    final container = _findProviderContainer($);
    if (container != null) {
      testLog('  🔌 Riverpod (ProviderContainer found):');
      try {
        final activeAsync = container.read(activeAccountProvider);
        activeAsync.when(
          data: (account) {
            if (account != null) {
              testLog(
                '     activeAccountProvider: ${account.email} (${account.userId})',
              );
            } else {
              testLog('     activeAccountProvider: null (no active account)');
            }
          },
          loading: () => testLog('     activeAccountProvider: LOADING'),
          error: (e, _) => testLog('     activeAccountProvider: ERROR: $e'),
        );
      } catch (e) {
        testLog('     activeAccountProvider: read error: $e');
      }
      try {
        final accountId = container.read(activeAccountIdProvider);
        testLog('     activeAccountIdProvider: ${accountId ?? 'null'}');
      } catch (e) {
        testLog('     activeAccountIdProvider: read error: $e');
      }
    } else {
      testLog('  🔌 Riverpod: Could not find ProviderContainer in widget tree');
    }
  } catch (e) {
    testLog('  🔌 Riverpod: ERROR: $e');
  }

  // 4. UI state — look for email text on screen
  try {
    testLog('  👁️  UI visible text containing emails:');
    final allText = find.byType(Text);
    final textWidgets = allText.evaluate();
    int emailCount = 0;
    for (final element in textWidgets) {
      final widget = element.widget as Text;
      final text = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      if (text.contains('@') ||
          text.contains('Active') ||
          text.contains('Tap to switch')) {
        testLog('     "$text"');
        emailCount++;
      }
    }
    if (emailCount == 0) {
      testLog('     (no email-related text found on screen)');
    }
  } catch (e) {
    testLog('  👁️  UI scan: ERROR: $e');
  }

  testLog('════════════════════════════════════════════════════════');
  testLog('');
}

/// Dump log record state for the current active account.
///
/// Captures the count and recent log records visible in the provider layer,
/// useful for verifying data isolation after account switching.
Future<void> debugDumpLogState(PatrolIntegrationTester $, String label) async {
  testLog('');
  testLog('┌──────────────────────────────────────────────────────┐');
  testLog('│  LOG STATE DUMP: $label');
  testLog('└──────────────────────────────────────────────────────┘');

  try {
    final container = _findProviderContainer($);
    if (container != null) {
      try {
        final accountId = container.read(activeAccountIdProvider);
        testLog('  📋 Active account ID for logs: ${accountId ?? 'null'}');
      } catch (e) {
        testLog('  📋 activeAccountIdProvider: read error: $e');
      }

      try {
        final logsAsync = container.read(activeAccountLogRecordsProvider);
        logsAsync.when(
          data: (logRecords) {
            testLog('  📋 Log records: ${logRecords.length} total');
            // Show last 5 records
            final recent = logRecords.take(5).toList();
            for (int i = 0; i < recent.length; i++) {
              final lr = recent[i];
              testLog(
                '     [$i] id=${lr.id} '
                'accountId=${lr.accountId.substring(0, 8)}... '
                'date=${lr.eventAt} '
                'type=${lr.eventType.name}',
              );
            }
          },
          loading: () => testLog('  📋 Log records: LOADING'),
          error: (e, _) => testLog('  📋 Log records: ERROR: $e'),
        );
      } catch (e) {
        testLog('  📋 Log records provider: read error: $e');
      }
    } else {
      testLog('  📋 Riverpod: Could not find ProviderContainer');
    }
  } catch (e) {
    testLog('  📋 ERROR: $e');
  }

  testLog('──────────────────────────────────────────────────────');
  testLog('');
}

/// Quick one-liner: log the current Firebase user + active Hive account.
/// Lighter weight than [debugDumpAccountState] — use between small steps.
Future<void> debugLogActiveUser(String step) async {
  final fbUser = FirebaseAuth.instance.currentUser;
  String hiveActive = 'unknown';
  try {
    final acct = await AccountService().getActiveAccount();
    hiveActive =
        acct != null
            ? '${acct.email} (${acct.userId.substring(0, 8)}...)'
            : 'null';
  } catch (_) {}
  testLog(
    '  ⚡ [$step] Firebase=${fbUser?.email ?? 'null'} '
    'Hive=$hiveActive',
  );
}

/// Wait until the Riverpod [activeAccountProvider] reflects [expectedEmail].
///
/// After switching accounts, Firebase Auth + Hive + the Riverpod stream
/// all need time to propagate the new active user. This helper polls until
/// the provider emits the expected email, or times out.
///
/// Returns `true` if the provider converged, `false` on timeout.
Future<bool> waitForProviderPropagation(
  PatrolIntegrationTester $,
  String expectedEmail, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  testLog('  ⏳ Waiting for activeAccountProvider → $expectedEmail ...');
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await $.pump(const Duration(milliseconds: 200));
    final container = _findProviderContainer($);
    if (container != null) {
      try {
        final asyncVal = container.read(activeAccountProvider);
        final email = asyncVal.asData?.value?.email;
        if (email == expectedEmail) {
          testLog('  ✓ Provider propagated to $expectedEmail');
          return true;
        }
        // Also check Hive to see if it's ahead of the provider
        final hiveAcct = await AccountService().getActiveAccount();
        testLog(
          '  ⏳ Provider=${email ?? 'null/loading'} '
          'Hive=${hiveAcct?.email ?? 'null'} '
          '(waiting for $expectedEmail)',
        );
      } catch (e) {
        testLog('  ⏳ Provider read error: $e');
      }
    }
    await settle($, frames: 5);
  }
  testLog(
    '  ⚠ TIMEOUT: Provider did not propagate within ${timeout.inSeconds}s',
  );
  await debugDumpAccountState($, 'Provider propagation TIMEOUT');
  return false;
}

/// Dump all visible snackbar-related widgets on screen for debugging.
///
/// Useful for understanding why a snackbar might be stuck or why a new
/// snackbar isn't appearing (e.g. if a stale one is blocking).
Future<void> debugDumpSnackbarState(
  PatrolIntegrationTester $,
  String label,
) async {
  testLog('');
  testLog('┌── SNACKBAR STATE: $label ──');

  // Look for SnackBar widgets
  final snackbarFinder = find.byType(SnackBar);
  final snackbarCount = snackbarFinder.evaluate().length;
  testLog('  SnackBar widgets on screen: $snackbarCount');

  if (snackbarCount > 0) {
    for (final element in snackbarFinder.evaluate()) {
      final sb = element.widget as SnackBar;
      // Try to get the content text
      if (sb.content is Text) {
        testLog('    Content: "${(sb.content as Text).data}"');
      } else {
        testLog('    Content type: ${sb.content.runtimeType}');
      }
      testLog('    Duration: ${sb.duration}');
      testLog('    Action: ${sb.action?.label ?? 'none'}');
    }
  }

  // Also check for any Text containing common snackbar messages
  final loggedVape = find.textContaining('Logged vape');
  final errorText = find.textContaining('Error');
  final noActive = find.textContaining('No active account');
  final tooShort = find.textContaining('too short');

  testLog('  "Logged vape" visible: ${$.tester.any(loggedVape)}');
  testLog('  "Error" visible: ${$.tester.any(errorText)}');
  testLog('  "No active account" visible: ${$.tester.any(noActive)}');
  testLog('  "too short" visible: ${$.tester.any(tooShort)}');

  // Look for ScaffoldMessenger state
  try {
    final scaffoldFinder = find.byType(Scaffold);
    testLog('  Scaffold widgets: ${scaffoldFinder.evaluate().length}');
  } catch (e) {
    testLog('  Scaffold check error: $e');
  }

  testLog('└── END SNACKBAR STATE ──');
  testLog('');
}

/// Clear any leftover snackbars by finding the ScaffoldMessenger and
/// calling clearSnackBars(). This is important before attempting a new
/// quick log, because a stale snackbar can interfere with detection.
Future<void> clearSnackbars(PatrolIntegrationTester $) async {
  try {
    final scaffoldFinder = find.byType(Scaffold);
    if (scaffoldFinder.evaluate().isNotEmpty) {
      final scaffoldElement = scaffoldFinder.evaluate().first;
      final scaffoldContext = scaffoldElement;
      ScaffoldMessenger.of(scaffoldContext).clearSnackBars();
      testLog('  🧹 Cleared snackbars via ScaffoldMessenger');
      await $.pump(const Duration(milliseconds: 300));
    }
  } catch (e) {
    testLog('  🧹 clearSnackbars error: $e');
  }
}

/// Dump the state of the HomeQuickLogWidget — checks if the recording
/// button is present and captures any visible state indicators.
Future<void> debugDumpQuickLogWidgetState(
  PatrolIntegrationTester $,
  String label,
) async {
  testLog('');
  testLog('┌── QUICK LOG WIDGET STATE: $label ──');

  final holdButton = find.byKey(const Key('hold_to_record_button'));
  testLog(
    '  hold_to_record_button: ${$.tester.any(holdButton) ? 'VISIBLE' : 'NOT FOUND'}',
  );

  // Check for any duration text (timer display while recording)
  final durationText = find.textContaining('s');
  int durationCount = 0;
  for (final element in durationText.evaluate()) {
    final widget = element.widget;
    if (widget is Text) {
      final text = widget.data ?? '';
      // Look for patterns like "2.5s" or "0:03"
      if (RegExp(r'^\d+\.?\d*s?$').hasMatch(text.trim()) ||
          RegExp(r'^\d+:\d{2}$').hasMatch(text.trim())) {
        testLog('  Timer text: "$text"');
        durationCount++;
      }
    }
  }
  if (durationCount == 0) {
    testLog('  No timer/duration text visible (widget idle)');
  }

  // Check for the recording overlay/animation
  final circularProgress = find.byType(CircularProgressIndicator);
  testLog(
    '  CircularProgressIndicator: ${$.tester.any(circularProgress) ? 'VISIBLE (recording?)' : 'not visible'}',
  );

  testLog('└── END QUICK LOG WIDGET STATE ──');
  testLog('');
}
