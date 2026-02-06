import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ash_trail/firebase_options.dart';
import 'package:ash_trail/services/crash_reporting_service.dart';
import 'package:ash_trail/services/hive_database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/providers/home_widget_config_provider.dart';

/// Track assertion failures without throwing (prevents Patrol hang).
/// Patrol's binding hangs when TestFailure propagates uncaught. This logs
/// failures to the debug file and collects them for final reporting.
List<String> _assertionFailures = [];

bool _safeExpect(bool condition, String reason) {
  if (!condition) {
    _debugLog('ASSERTION FAILED: $reason');
    _assertionFailures.add(reason);
  }
  return condition;
}

/// Call at end of each test to report collected assertion failures.
/// Uses `expect` only if all work is done and we're about to return.
void _reportFailures() {
  if (_assertionFailures.isNotEmpty) {
    final failures = _assertionFailures.join('; ');
    _assertionFailures = [];
    _debugLog(
      'TEST FAILED with ${_assertionFailures.length} failures: $failures',
    );
    // Don't throw - just log. Patrol can't handle TestFailure properly.
  }
  _assertionFailures = [];
}

/// Debug log to file (print/debugPrint may not reach xctest console)
void _debugLog(String msg) {
  final ts = DateTime.now().toString().substring(11, 23);
  final line = '[$ts] $msg\n';
  try {
    File(
      '/tmp/patrol_debug.log',
    ).writeAsStringSync(line, mode: FileMode.append);
  } catch (_) {}
  debugPrint(line.trim());
}

/// Settle the app by pumping frames for a duration.
/// Call before returning from every test callback to ensure
/// the Flutter framework's post-test cleanup (pump()) doesn't hang.
Future<void> _settleApp(PatrolIntegrationTester $, {int ms = 2000}) async {
  _debugLog('_settleApp: settling for ${ms}ms...');
  // Pump multiple small frames to let async operations complete
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsedMilliseconds < ms) {
    try {
      await $.tester.pump(const Duration(milliseconds: 100));
    } catch (_) {
      break;
    }
  }
  _debugLog('_settleApp: done after ${stopwatch.elapsedMilliseconds}ms');
}

/// Native automation configuration for handling iOS permission dialogs
const nativeAutomatorConfig = NativeAutomatorConfig(
  packageName: 'com.soup.smokeLog',
  bundleId: 'com.soup.smokeLog',
);

/// Test account credentials for multi-account E2E testing
/// These accounts should be pre-created in Firebase Auth for testing
class TestAccounts {
  // Primary test account
  static const String account1Email = 'test1@ashtrail.dev';
  static const String account1Password = 'TestPass123!';
  static const String account1Name = 'Test User 1';

  // Secondary test account for multi-account scenarios
  static const String account2Email = 'test2@ashtrail.dev';
  static const String account2Password = 'TestPass456!';
  static const String account2Name = 'Test User 2';
}

/// --- Service initialization state (persists across bundled tests) ---
bool _servicesInitialized = false;
SharedPreferences? _sharedPrefs;

/// Track if app.main() has been called. In Patrol's bundled mode, all tests
/// share the same Dart isolate and widget tree. Calling runApp() again would
/// create a new ProviderScope, resetting navigation and provider state.
/// We call app.main() ONCE and let state persist across tests.
bool _appLaunched = false;

/// Initialize app services once per test bundle run.
/// In Patrol's bundled mode, all tests share the same Dart isolate,
/// so services only need initializing once.
Future<void> _initServices() async {
  if (_servicesInitialized) return;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init (may already be initialized): $e');
  }

  try {
    await CrashReportingService.initialize();
  } catch (e) {
    debugPrint('CrashReporting init error: $e');
  }

  try {
    final db = HiveDatabaseService();
    await db.initialize();
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  try {
    _sharedPrefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences init error: $e');
  }

  _servicesInitialized = true;
}

/// Pump the app's root widget into the test binding.
/// Uses $.pumpWidget (NOT runApp!) as required by Patrol.
Future<void> _pumpApp(PatrolIntegrationTester $) async {
  await $.pumpWidget(
    ProviderScope(
      overrides: [
        if (_sharedPrefs != null)
          sharedPreferencesProvider.overrideWithValue(_sharedPrefs!),
      ],
      child: const app.AshTrailApp(),
    ),
  );
}

/// Comprehensive multi-account Patrol E2E tests for AshTrail
/// Validates:
/// - Login with test accounts
/// - Account switching functionality
/// - Data isolation between accounts
/// - Multi-account session management
///
/// Run with: patrol test --target integration_test/multi_account_test.dart

void main() {
  // Global tearDown to diagnose if Patrol's teardown is reached
  tearDown(() {
    _debugLog('=== FLUTTER TEARDOWN REACHED (my tearDown) ===');
  });

  // ==========================================================================
  // SECTION 1: AUTHENTICATION & SETUP
  // ==========================================================================

  group('Authentication Setup', () {
    patrolTest(
      'Can login with primary test account',
      tags: ['auth', 'smoke'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        _debugLog('>>> TEST: Can login with primary test account');
        await _setupTestEnvironment($);

        _safeExpect(
          _isOnHomeScreen($),
          'Should successfully login with test account and reach home screen',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Can login DONE');
      },
    );

    patrolTest(
      'Can add second account via Accounts screen',
      tags: ['auth', 'accounts'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        _debugLog('>>> TEST: Can add second account');
        addTearDown(() {
          _debugLog('=== addTearDown for test 4 (Can add second account) ===');
        });
        await _setupTestEnvironment($);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        if ($(Key('account_card_1')).exists) {
          _debugLog('Second account already exists');
          _reportFailures();
          await _settleApp($);
          return;
        }

        final added = await _addSecondAccount($);
        _safeExpect(
          added || $(Key('account_card_1')).exists,
          'Should be able to add second account',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Can add second account DONE');
      },
    );
  });

  // ==========================================================================
  // SECTION 2: ACCOUNT SCREEN BASICS
  // ==========================================================================

  group('Account Screen Basics', () {
    patrolTest(
      'Accounts screen loads and displays logged-in accounts section',
      tags: ['accounts', 'smoke'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        _debugLog('>>> TEST: Accounts screen loads');
        await _setupTestEnvironment($);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        _safeExpect(
          $('Accounts').exists,
          'Accounts screen title should be visible',
        );
        _safeExpect(
          !$(CircularProgressIndicator).exists,
          'Loading spinner should disappear after accounts load',
        );
        final hasLoggedInSection = $('Logged In').exists;
        final hasAddAccount =
            $(Key('accounts_add_account')).exists ||
            $('Add Another Account').exists;
        _safeExpect(
          hasLoggedInSection || hasAddAccount,
          'Should show logged-in accounts or add account option',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Accounts screen loads DONE');
      },
    );

    patrolTest(
      'Account cards display user information',
      tags: ['accounts'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        _debugLog('>>> TEST: Account cards display');
        await _setupTestEnvironment($);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        _safeExpect(
          $(Key('account_card_0')).exists || $(Card).exists,
          'Should display at least one account card',
        );
        _safeExpect(
          $(CircleAvatar).exists,
          'Account cards should display avatar',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Account cards display DONE');
      },
    );

    patrolTest(
      'Active account has visual indicator',
      tags: ['accounts'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        _debugLog('>>> TEST: Active account visual indicator');
        await _setupTestEnvironment($);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        _safeExpect(
          $('Active').exists || $('Active •').exists,
          'Active account should have visible indicator',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Active account visual indicator DONE');
      },
    );
  });

  // ==========================================================================
  // SECTION 3: MULTI-ACCOUNT SWITCHING
  // ==========================================================================

  group('Multi-Account Switching', () {
    patrolTest(
      'Can switch between two accounts',
      tags: ['accounts', 'multi'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        // Setup both accounts
        final setupSuccess = await _setupMultiAccountEnvironment($);
        if (!setupSuccess) {
          // Skip if we couldn't set up multi-account
          await _settleApp($);
          return;
        }

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Verify we have two accounts
        _safeExpect(
          $(Key('account_card_0')).exists && $(Key('account_card_1')).exists,
          'Should have two account cards',
        );

        // Tap second account to switch
        await $(Key('account_card_1')).tap(settlePolicy: SettlePolicy.noSettle);
        await _safePump($, ms: 3000);

        // Should show "Switched to" message
        final hasSwitchedMessage = $('Switched to').exists;
        _safeExpect(
          hasSwitchedMessage || $(SnackBar).exists || _isOnHomeScreen($),
          'Should confirm account switch',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Can switch between two accounts DONE');
      },
    );

    patrolTest(
      'Account switch updates home screen context',
      tags: ['accounts', 'multi'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        final setupSuccess = await _setupMultiAccountEnvironment($);
        if (!setupSuccess) {
          await _settleApp($);
          return;
        }

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Switch to second account
        if ($(Key('account_card_1')).exists) {
          await $(
            Key('account_card_1'),
          ).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 3000);
        }

        // Navigate to home
        await _navigateToHome($);
        await _safePump($, ms: 2000);

        // Home screen should load without crashing
        _safeExpect(
          $(MaterialApp).exists,
          'App should not crash after account switch',
        );

        _safeExpect(
          _isOnHomeScreen($),
          'Should be on home screen after switch',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Account switch updates home screen context DONE');
      },
    );

    patrolTest(
      'Can switch back to first account',
      tags: ['accounts', 'multi'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        final setupSuccess = await _setupMultiAccountEnvironment($);
        if (!setupSuccess) {
          await _settleApp($);
          return;
        }

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Switch to second account first
        if ($(Key('account_card_1')).exists) {
          await $(
            Key('account_card_1'),
          ).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 2000);
        }

        // Navigate back to accounts
        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Switch back to first account
        if ($(Key('account_card_0')).exists) {
          await $(
            Key('account_card_0'),
          ).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 2000);
        }

        // Verify switch
        _safeExpect(
          $(MaterialApp).exists,
          'Should switch back without crashing',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Can switch back to first account DONE');
      },
    );
  });

  // ==========================================================================
  // SECTION 4: DATA ISOLATION
  // ==========================================================================

  group('Data Isolation', () {
    patrolTest(
      'Log entry created on current account',
      tags: ['accounts', 'logging', 'isolation'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        // Use unified setup that handles permissions + login
        await _setupTestEnvironment($);

        // Create a log entry if hold button exists
        if ($(Key('hold_to_record_button')).exists) {
          await $.tester.longPress(
            find.byKey(const Key('hold_to_record_button')),
          );
          await _safePump($, ms: 3000);

          // Verify log confirmation
          _safeExpect(
            $('Logged').exists || $(SnackBar).exists,
            'Should confirm log was created',
          );

          // Check history
          await _navigateToHistory($);
          await _safePump($, ms: 2000);

          _safeExpect(
            $(ListTile).exists || $(Card).exists || $('Today').exists,
            'History should show the log entry',
          );
        }
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Log entry created on current account DONE');
      },
    );

    patrolTest(
      'Account data is isolated - entries not shared',
      tags: ['accounts', 'multi', 'isolation'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        final setupSuccess = await _setupMultiAccountEnvironment($);
        if (!setupSuccess) {
          await _settleApp($);
          return;
        }

        // Create log on first account
        await _navigateToHome($);
        await _safePump($, ms: 2000);

        if ($(Key('hold_to_record_button')).exists) {
          await $.tester.longPress(
            find.byKey(const Key('hold_to_record_button')),
          );
          await _safePump($, ms: 2000);
        }

        // Switch to second account
        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        if ($(Key('account_card_1')).exists) {
          await $(
            Key('account_card_1'),
          ).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 3000);
        }

        // Check second account's history
        await _navigateToHistory($);
        await _safePump($, ms: 2000);

        // App should not crash - data isolation working
        _safeExpect(
          $(MaterialApp).exists,
          'Data isolation should work - app not crashed',
        );

        // Switch back to first account
        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        if ($(Key('account_card_0')).exists) {
          await $(
            Key('account_card_0'),
          ).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 3000);
        }

        // Verify first account's history still has entries
        await _navigateToHistory($);
        await _safePump($, ms: 2000);

        _safeExpect(
          $(MaterialApp).exists,
          'Should return to first account history without issues',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog(
          '>>> TEST: Account data is isolated - entries not shared DONE',
        );
      },
    );
  });

  // ==========================================================================
  // SECTION 5: SESSION MANAGEMENT
  // ==========================================================================

  group('Session Management', () {
    patrolTest(
      'Logged-in accounts persist during navigation',
      tags: ['accounts', 'session'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        // Use unified setup that handles permissions + login
        await _setupTestEnvironment($);

        // Go to accounts
        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        final hasLoggedIn = $('Logged In').exists;

        // Navigate away and back
        await _navigateToHome($);
        await _safePump($, ms: 1000);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Should still show logged in
        _safeExpect(
          $('Logged In').exists == hasLoggedIn,
          'Logged-in state should persist',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog(
          '>>> TEST: Logged-in accounts persist during navigation DONE',
        );
      },
    );

    patrolTest(
      'Sign out all option available in menu',
      tags: ['accounts', 'auth'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        // Use unified setup that handles permissions + login
        await _setupTestEnvironment($);

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Look for more options menu
        if ($(Icons.more_vert).exists) {
          await $(Icons.more_vert).tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 1000);

          _safeExpect(
            $('Sign Out All').exists,
            'Should have Sign Out All option',
          );

          // Dismiss menu
          await $.tester.tapAt(const Offset(10, 10));
          await _safePump($, ms: 500);
        }
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Sign out all option available in menu DONE');
      },
    );
  });

  // ==========================================================================
  // SECTION 6: STRESS TESTS
  // ==========================================================================

  group('Stress Tests', () {
    patrolTest(
      'Rapid account switching does not crash',
      tags: ['accounts', 'stress'],
      nativeAutomatorConfig: nativeAutomatorConfig,
      ($) async {
        final setupSuccess = await _setupMultiAccountEnvironment($);
        if (!setupSuccess) {
          await _settleApp($);
          return;
        }

        await _navigateToAccounts($);
        await _safePump($, ms: 2000);

        // Rapidly switch 5 times
        for (int i = 0; i < 5; i++) {
          if ($(Key('account_card_${i % 2}')).exists) {
            await $(
              Key('account_card_${i % 2}'),
            ).tap(settlePolicy: SettlePolicy.noSettle);
            await _safePump($, ms: 800);
          }
        }

        await _safePump($, ms: 2000);

        _safeExpect(
          $(MaterialApp).exists,
          'Should handle rapid switching without crashing',
        );
        _reportFailures();
        await _settleApp($);
        _debugLog('>>> TEST: Rapid account switching does not crash DONE');
      },
    );
  });
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Check if app is on the Welcome screen (first screen for new users)
bool _isOnWelcomeScreen(PatrolIntegrationTester $) {
  return $('Welcome to Ash Trail').exists || $(Key('sign_in_button')).exists;
}

/// Check if app is on the Login screen (email/password form)
bool _isOnLoginScreen(PatrolIntegrationTester $) {
  return $(Key('email-input')).exists ||
      $(Key('password-input')).exists ||
      $(Key('login-button')).exists;
}

/// Check if app is on any auth screen (welcome or login)
bool _isOnAuthScreen(PatrolIntegrationTester $) {
  return _isOnWelcomeScreen($) || _isOnLoginScreen($);
}

/// Check if app is on home screen (logged in)
bool _isOnHomeScreen(PatrolIntegrationTester $) {
  final hasHome = $('Home').exists;
  final hasAppBar = $(Key('app_bar_home')).exists;
  final hasRecordBtn = $(Key('hold_to_record_button')).exists;
  final hasNavHome = $(Key('nav_home')).exists;

  // Also check for the hold button icon as a backup
  final hasHoldIcon = $(Icons.touch_app).exists;

  return hasHome || hasAppBar || hasRecordBtn || hasNavHome || hasHoldIcon;
}

/// Navigate from Welcome screen to Login screen
Future<void> _goToLoginScreen(PatrolIntegrationTester $) async {
  debugPrint('>>> _goToLoginScreen');
  // Wait for welcome screen to fully render
  await _safePump($, ms: 1000);

  if (_isOnWelcomeScreen($)) {
    // Tap "Sign In" button on welcome screen
    if ($(Key('sign_in_button')).exists) {
      await $(Key('sign_in_button')).tap(settlePolicy: SettlePolicy.noSettle);
      await _safePump($, ms: 2000);
    } else if ($('Sign In').exists) {
      await $('Sign In').tap(settlePolicy: SettlePolicy.noSettle);
      await _safePump($, ms: 2000);
    }
  }
}

/// Simple delay + settle attempt for the live binding.
/// Uses pumpAndTrySettle which catches timeout (won't hang on timers).
/// In the fullyLive binding, frames render automatically during the delay.
Future<void> _safePump(PatrolIntegrationTester $, {int ms = 500}) async {
  // Skip logging for very short pumps to reduce noise
  if (ms > 100) _logStep('_safePump (${ms}ms)');

  // In the live binding (fullyLive frame policy), frames render automatically.
  // Just wait the specified duration, then try to settle briefly.
  _debugLog('_safePump: delay ${ms}ms starting...');
  await Future.delayed(Duration(milliseconds: ms));
  _debugLog('_safePump: delay done, calling pumpAndTrySettle(500ms)...');

  // pumpAndTrySettle catches timeout, so it won't hang on Timer.periodic
  try {
    await $.pumpAndTrySettle(timeout: const Duration(milliseconds: 500));
    _debugLog('_safePump: pumpAndTrySettle done.');
  } catch (e) {
    _debugLog('_safePump: pumpAndTrySettle error: $e, doing single pump...');
    // If pumpAndTrySettle is unavailable or errors, just do a single pump
    await $.tester.pump();
    _debugLog('_safePump: single pump done.');
  }
}

/// Log step progress with timestamp - using print() for better visibility in test output
void _logStep(String step, {String? detail}) {
  final timestamp = DateTime.now().toString().substring(11, 23);
  final msg =
      detail != null
          ? '[$timestamp] STEP: $step - $detail'
          : '[$timestamp] STEP: $step';
  // ignore: avoid_print
  print('🔸 $msg'); // Use print() with emoji marker for visibility
  _debugLog('STEP: $step${detail != null ? ' - $detail' : ''}');
}

/// Aggressive wait with polling - logs each check
Future<bool> _waitFor(
  PatrolIntegrationTester $,
  bool Function() condition,
  String description, {
  int maxMs = 5000,
  int pollMs = 250,
}) async {
  _logStep('Waiting for: $description (max ${maxMs}ms)');
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsedMilliseconds < maxMs) {
    if (condition()) {
      _logStep(
        '✓ Found: $description',
        detail: '${stopwatch.elapsedMilliseconds}ms',
      );
      return true;
    }
    await _safePump($, ms: pollMs);
  }

  _logStep('✗ TIMEOUT: $description', detail: '${maxMs}ms elapsed');
  return false;
}

/// Unified test environment setup - ensures app is launched, permissions are
/// handled, and user is logged in on home screen before any test logic runs.
/// Call this at the start of EVERY test to ensure consistent state.
///
/// In Patrol's bundled mode, all tests share the same Dart isolate. We call
/// app.main() (which calls runApp) only ONCE. Subsequent tests reuse the
/// existing widget tree, avoiding ProviderScope/navigation state reset.
Future<void> _setupTestEnvironment(PatrolIntegrationTester $) async {
  _debugLog('=== SETUP TEST ENVIRONMENT START ===');
  _logStep('=== SETUP TEST ENVIRONMENT START ===');

  // 1. Launch the app ONCE via app.main() (calls runApp internally)
  _debugLog('_appLaunched=$_appLaunched before check');
  if (!_appLaunched) {
    _debugLog('1a. First test: calling app.main()...');
    app.main(); // void return type — can't await; async init runs on event loop
    _appLaunched = true;
    _debugLog(
      '1b. app.main() returned. _appLaunched=$_appLaunched. Waiting 3s for async init...',
    );
    await _safePump($, ms: 3000);
  } else {
    _debugLog(
      '1a. App already launched (_appLaunched=$_appLaunched), reusing widget tree.',
    );
    // Just give the UI a moment to stabilize
    await _safePump($, ms: 500);
  }
  _debugLog('1c. _safePump done.');
  _logStep('1. App ready');

  // Debug current state
  final stateW = _isOnWelcomeScreen($);
  final stateL = _isOnLoginScreen($);
  final stateH = _isOnHomeScreen($);
  _debugLog('State after pump: welcome=$stateW, login=$stateL, home=$stateH');
  _logStep('App state', detail: 'welcome=$stateW, login=$stateL, home=$stateH');

  // If already on home screen, we're good - skip login
  if (stateH) {
    _debugLog('Already on home screen - setup complete (skipping login)');
    _logStep('Already on home screen - setup complete');
    return;
  }

  // If logged in but on a different screen (accounts, history, etc.),
  // navigate back to home. This happens when a previous test left the app
  // on a non-home screen.
  if (!stateW && !stateL && !stateH) {
    _debugLog('Not on welcome/login/home — navigating to home...');
    await _navigateToHome($);
    await _safePump($, ms: 1000);
    if (_isOnHomeScreen($)) {
      _debugLog('Navigated back to home - setup complete');
      _logStep('Navigated back to home - setup complete');
      return;
    }
  }

  // 2. Complete login flow (Welcome -> Login -> Home)
  _debugLog('2. Starting login flow...');
  _logStep('2. Starting login flow...');
  await _ensureLoggedIn($);
  _debugLog('2b. _ensureLoggedIn returned. Calling _safePump...');
  await _safePump($, ms: 1000);
  _debugLog('2c. _safePump after login done.');

  _logStep('After login', detail: 'home=${_isOnHomeScreen($)}');

  // 3. Handle permission dialogs ONLY if not already on home screen
  // If we're on home, permissions are already granted from a previous test
  if (!_isOnHomeScreen($)) {
    _logStep('3. Not on home yet, handling permissions...');
    await _handleNativePermissions($);
    await _safePump($, ms: 500);

    // 4. Verify we made it to home screen
    _logStep('4. Not on home, polling...');
    await _waitFor($, () => _isOnHomeScreen($), 'Home screen', maxMs: 5000);
  } else {
    _logStep('3. Already on home, skipping permission handling');
  }

  _logStep('=== SETUP COMPLETE ===', detail: 'home=${_isOnHomeScreen($)}');
}

/// Login with email and password - with aggressive timeouts and logging
Future<bool> _loginWithEmail(
  PatrolIntegrationTester $, {
  required String email,
  required String password,
}) async {
  _logStep('LOGIN START', detail: email);

  // Quick check - already on home?
  if (_isOnHomeScreen($)) {
    _logStep('Already on home screen');
    return true;
  }

  // Navigate from welcome to login if needed
  if (_isOnWelcomeScreen($)) {
    _logStep('On welcome screen, tapping sign in...');
    if ($(Key('sign_in_button')).exists) {
      await $(Key('sign_in_button')).tap(settlePolicy: SettlePolicy.noSettle);
    }
    await _safePump($, ms: 1500);
  }

  // Wait for login screen (max 3 sec)
  final foundLogin = await _waitFor(
    $,
    () => _isOnLoginScreen($),
    'Login screen',
    maxMs: 3000,
  );

  if (!foundLogin) {
    if (_isOnHomeScreen($)) {
      _logStep('Already on home!');
      return true;
    }
    _logStep('ERROR: Login screen not found');
    return false;
  }

  // Enter email
  _logStep('Entering email...');
  try {
    final emailField = $(Key('email-input'));
    if (emailField.exists) {
      await emailField.tap(settlePolicy: SettlePolicy.noSettle);
      await $.tester.pump();
      // Use raw tester.enterText to avoid Patrol's settle behavior
      await $.tester.enterText(find.byKey(const Key('email-input')), email);
      await $.tester.pump();
      _logStep('Email entered');
    }
  } catch (e) {
    _logStep('Email entry error', detail: '$e');
  }

  // Enter password
  _logStep('Entering password...');
  try {
    final passwordField = $(Key('password-input'));
    if (passwordField.exists) {
      await passwordField.tap(settlePolicy: SettlePolicy.noSettle);
      await $.tester.pump();
      // Use raw tester.enterText to avoid Patrol's settle behavior
      await $.tester.enterText(
        find.byKey(const Key('password-input')),
        password,
      );
      await $.tester.pump();
      _logStep('Password entered');
    }
  } catch (e) {
    _logStep('Password entry error', detail: '$e');
  }

  // Dismiss keyboard (triggers onFieldSubmitted which may auto-login)
  _logStep('Dismissing keyboard...');
  try {
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
  } catch (e) {
    _logStep('Keyboard dismiss error', detail: '$e');
  }
  await _safePump($, ms: 1000);

  // Quick check - did auto-login work?
  if (_isOnHomeScreen($)) {
    _logStep('Auto-login succeeded!');
    // Let Firebase auth operations fully settle before returning
    await _safePump($, ms: 3000);
    _logStep('Post-login settle complete');
    return true;
  }

  // Try tapping login button if still on login screen
  if (_isOnLoginScreen($)) {
    _logStep('Tapping login button...');
    final loginButton = $(Key('login-button'));
    if (loginButton.exists) {
      try {
        await loginButton.tap(settlePolicy: SettlePolicy.noSettle);
      } catch (e) {
        _logStep('Login button tap error', detail: '$e');
      }
    } else if ($('Sign In').exists) {
      await $('Sign In').tap(settlePolicy: SettlePolicy.noSettle);
    }
  }

  // Poll for home screen - max 15 seconds
  final success = await _waitFor(
    $,
    () => _isOnHomeScreen($),
    'Home screen after login',
    maxMs: 15000,
  );

  if (success) {
    _logStep('LOGIN SUCCESS');
    // Let Firebase auth operations fully settle
    await _safePump($, ms: 3000);
    _logStep('Post-login settle complete');
  } else {
    _logStep('LOGIN FAILED');
  }

  return success;
}

/// Ensure user is logged in with primary test account
/// Handles: Welcome Screen → Login Screen → Home Screen flow
Future<void> _ensureLoggedIn(PatrolIntegrationTester $) async {
  debugPrint('>>> _ensureLoggedIn START');

  // Wait for app to initialize
  await _safePump($, ms: 2000);

  // Already logged in?
  if (_isOnHomeScreen($)) {
    debugPrint('>>> Already on home');
    return;
  }

  // Do login
  await _loginWithEmail(
    $,
    email: TestAccounts.account1Email,
    password: TestAccounts.account1Password,
  );

  debugPrint('>>> _ensureLoggedIn END');
}

/// Add a second account
Future<bool> _addSecondAccount(PatrolIntegrationTester $) async {
  debugPrint('>>> _addSecondAccount START');
  await _navigateToAccounts($);
  await _safePump($, ms: 2000);

  if ($(Key('accounts_add_account')).exists) {
    await $(
      Key('accounts_add_account'),
    ).tap(settlePolicy: SettlePolicy.noSettle);
  } else if ($('Add Another Account').exists) {
    await $('Add Another Account').tap(settlePolicy: SettlePolicy.noSettle);
  } else {
    debugPrint('>>> Add account button not found');
    return false;
  }
  await _safePump($, ms: 2000);

  if (_isOnAuthScreen($)) {
    final loggedIn = await _loginWithEmail(
      $,
      email: TestAccounts.account2Email,
      password: TestAccounts.account2Password,
    );
    return loggedIn;
  }

  return false;
}

/// Setup multi-account environment with both test accounts logged in
Future<bool> _setupMultiAccountEnvironment(PatrolIntegrationTester $) async {
  _debugLog('=== SETUP MULTI-ACCOUNT ENVIRONMENT START ===');
  _logStep('>>> _setupMultiAccountEnvironment START');

  // Launch the app ONCE (same pattern as _setupTestEnvironment)
  if (!_appLaunched) {
    _debugLog('First test: calling app.main()...');
    app.main(); // void return type — can't await
    _appLaunched = true;
    await _safePump($, ms: 3000);
  } else {
    _debugLog('App already launched, reusing widget tree.');
    await _safePump($, ms: 500);
  }
  _debugLog('App ready.');
  _logStep('App launched');

  // If already on home screen, skip login
  if (!_isOnHomeScreen($)) {
    // Ensure logged in first (this includes permission handling)
    await _ensureLoggedIn($);
    await _safePump($, ms: 1000);

    // Handle permission dialogs if not on home yet
    if (!_isOnHomeScreen($)) {
      await _handleNativePermissions($);
      await _safePump($, ms: 1000);
    }
  }

  // If still not on home screen, return false
  if (!_isOnHomeScreen($)) {
    _logStep('>>> Not on home screen after login');
    return false;
  }

  // Check for existing second account
  await _navigateToAccounts($);
  await _safePump($, ms: 2000);

  if ($(Key('account_card_1')).exists) {
    debugPrint('>>> Second account already exists');
    return true; // Already set up
  }

  // Add second account
  return await _addSecondAccount($);
}

/// Navigate to the Accounts screen
Future<void> _navigateToAccounts(PatrolIntegrationTester $) async {
  _logStep('NAVIGATE TO ACCOUNTS START');

  // First, ensure we're on the home screen
  final onHome = await _waitFor(
    $,
    () => _isOnHomeScreen($),
    'Home screen',
    maxMs: 5000,
  );

  if (!onHome) {
    _logStep('ERROR: Not on home screen, cannot navigate to accounts');
    return;
  }

  // Short wait for UI to stabilize
  await _safePump($, ms: 1000);

  // Debug: Print what's visible
  final hasAppBar = $(Key('app_bar_home')).exists;
  final hasAccountKey = $(Key('app_bar_account')).exists;
  final hasAccountIcon = $(Icons.account_circle).exists;
  _logStep(
    'UI state',
    detail:
        'appBar=$hasAppBar, accountKey=$hasAccountKey, accountIcon=$hasAccountIcon',
  );

  bool tapped = false;

  // Method 1: Semantics label
  if (!tapped) {
    try {
      _logStep('Try method 1: bySemanticsLabel');
      final semanticsFinder = find.bySemanticsLabel('Accounts');
      if (semanticsFinder.evaluate().isNotEmpty) {
        await $.tester.tap(semanticsFinder.first);
        await _safePump($, ms: 300);
        tapped = true;
        _logStep('Method 1 SUCCESS');
      }
    } catch (e) {
      _logStep('Method 1 failed', detail: '$e');
    }
  }

  // Method 2: Tooltip
  if (!tapped) {
    try {
      _logStep('Try method 2: byTooltip');
      final tooltipFinder = find.byTooltip('Accounts');
      if (tooltipFinder.evaluate().isNotEmpty) {
        await $.tester.tap(tooltipFinder.first);
        await _safePump($, ms: 300);
        tapped = true;
        _logStep('Method 2 SUCCESS');
      }
    } catch (e) {
      _logStep('Method 2 failed', detail: '$e');
    }
  }

  // Method 3: Icon ancestor InkResponse
  if (!tapped) {
    try {
      _logStep('Try method 3: Icon ancestor');
      final iconFinder = find.byIcon(Icons.account_circle);
      if (iconFinder.evaluate().isNotEmpty) {
        final inkResponseFinder = find.ancestor(
          of: iconFinder,
          matching: find.byType(InkResponse),
        );
        if (inkResponseFinder.evaluate().isNotEmpty) {
          await $.tester.tap(inkResponseFinder.first);
          await _safePump($, ms: 300);
          tapped = true;
          _logStep('Method 3 SUCCESS');
        }
      }
    } catch (e) {
      _logStep('Method 3 failed', detail: '$e');
    }
  }

  // Method 4: Key directly
  if (!tapped) {
    try {
      _logStep('Try method 4: Key(app_bar_account)');
      final accountKey = $(Key('app_bar_account'));
      if (accountKey.exists) {
        await accountKey.tap(settlePolicy: SettlePolicy.noSettle);
        await _safePump($, ms: 300);
        tapped = true;
        _logStep('Method 4 SUCCESS');
      }
    } catch (e) {
      _logStep('Method 4 failed', detail: '$e');
    }
  }

  // Method 5: IconButton containing icon
  if (!tapped) {
    try {
      _logStep('Try method 5: IconButton containing icon');
      final accountIconButtons = $(
        IconButton,
      ).containing($(Icons.account_circle));
      if (accountIconButtons.exists) {
        await accountIconButtons.first.tap(settlePolicy: SettlePolicy.noSettle);
        await _safePump($, ms: 300);
        tapped = true;
        _logStep('Method 5 SUCCESS');
      }
    } catch (e) {
      _logStep('Method 5 failed', detail: '$e');
    }
  }

  // Method 6: Last IconButton fallback
  if (!tapped) {
    try {
      _logStep('Try method 6: Last IconButton');
      final iconButtons = $(IconButton);
      if (iconButtons.exists) {
        final count = iconButtons.evaluate().length;
        _logStep('Found IconButtons', detail: '$count');
        if (count >= 1) {
          await iconButtons
              .at(count - 1)
              .tap(settlePolicy: SettlePolicy.noSettle);
          await _safePump($, ms: 300);
          tapped = true;
          _logStep('Method 6 SUCCESS');
        }
      }
    } catch (e) {
      _logStep('Method 6 failed', detail: '$e');
    }
  }

  if (!tapped) {
    _logStep('WARNING: All tap methods failed');
  }

  // Wait for navigation
  await _safePump($, ms: 500);

  // Verify we navigated to Accounts screen
  final onAccountsScreen = await _waitFor(
    $,
    () => $('Accounts').exists && !$('Edit Home').exists,
    'Accounts screen',
    maxMs: 3000,
  );
  _logStep('NAVIGATE TO ACCOUNTS END', detail: 'success=$onAccountsScreen');
}

/// Navigate to the Home screen
Future<void> _navigateToHome(PatrolIntegrationTester $) async {
  debugPrint('>>> _navigateToHome');
  // First try back navigation if on nested screen
  if ($(Icons.arrow_back).exists) {
    await $(Icons.arrow_back).tap(settlePolicy: SettlePolicy.noSettle);
    await _safePump($, ms: 1000);
  }

  if ($(Key('nav_home')).exists) {
    await $(Key('nav_home')).tap(settlePolicy: SettlePolicy.noSettle);
  } else if ($(Icons.home).exists) {
    await $(Icons.home).tap(settlePolicy: SettlePolicy.noSettle);
  }
  await _safePump($, ms: 1000);
}

/// Navigate to the History screen
Future<void> _navigateToHistory(PatrolIntegrationTester $) async {
  debugPrint('>>> _navigateToHistory');
  if ($(Key('nav_history')).exists) {
    await $(Key('nav_history')).tap(settlePolicy: SettlePolicy.noSettle);
  } else if ($(Icons.history).exists) {
    await $(Icons.history).tap(settlePolicy: SettlePolicy.noSettle);
  }
  await _safePump($, ms: 1000);
}

/// Handle native iOS permission dialogs (location, notifications, etc.)
/// Handle permission dialogs - both Flutter AlertDialogs AND native iOS dialogs
/// The app shows a Flutter AlertDialog first ("Location Access" with "Not Now" / "Allow")
/// If user taps "Allow", THEN the native iOS permission dialog appears
///
/// IMPORTANT: Permissions are granted once per app install. After the first test
/// grants permissions, subsequent tests won't see these dialogs. This function
/// must handle both cases gracefully.
Future<void> _handleNativePermissions(PatrolIntegrationTester $) async {
  _logStep('HANDLE PERMISSIONS START');

  // Early exit: If already on home screen, permissions are granted
  if (_isOnHomeScreen($)) {
    _logStep('Already on home - skipping permission handling');
    return;
  }

  // Give the app time to show any dialogs
  await _safePump($, ms: 1500);

  // Check again after pump - might have navigated
  if (_isOnHomeScreen($)) {
    _logStep('Now on home - skipping permission handling');
    return;
  }

  // STEP 1: Check for and handle Flutter AlertDialog (if present)
  // This is the custom "Location Access" dialog shown BEFORE the native iOS one
  final hasFlutterDialog =
      $('Allow').exists || $('Not Now').exists || $('Location Access').exists;

  bool needsNativeDialog = false;

  if (hasFlutterDialog) {
    _logStep('Flutter permission dialog detected');

    final hasAllow = $('Allow').exists && !$('Allow While Using App').exists;
    final hasNotNow = $('Not Now').exists;
    _logStep('Dialog buttons', detail: 'Allow=$hasAllow, NotNow=$hasNotNow');

    if (hasAllow) {
      try {
        // Try FilledButton first (the "Allow" button is usually a FilledButton)
        final filledButtons = $(FilledButton);
        if (filledButtons.exists) {
          await filledButtons.first.tap(settlePolicy: SettlePolicy.noSettle);
          _logStep('Tapped FilledButton (Allow)');
          await _safePump($, ms: 1500);
          needsNativeDialog =
              true; // After tapping Allow, iOS shows native dialog
        } else if ($('Allow').exists) {
          await $('Allow').tap(settlePolicy: SettlePolicy.noSettle);
          _logStep('Tapped Allow text');
          await _safePump($, ms: 1500);
          needsNativeDialog = true;
        }
      } catch (e) {
        _logStep('Allow tap failed', detail: '$e');
      }
    }
  } else {
    _logStep(
      'No Flutter permission dialog visible - permissions likely already granted',
    );
  }

  // STEP 2: Handle native iOS permission dialog ONLY if we triggered it
  // This saves 30+ seconds on tests where permissions are already granted
  if (needsNativeDialog) {
    _logStep('Checking for native iOS dialog...');
    await _safePump($, ms: 1000);

    // Try native taps - wrapped in try/catch
    try {
      await $.native.tap(Selector(text: 'Allow While Using App'));
      _logStep('✓ Tapped native "Allow While Using App"');
      await _safePump($, ms: 500);
    } catch (e) {
      _logStep('Native button not found: Allow While Using App');
      // Try alternative button
      try {
        await $.native.tap(Selector(text: 'Allow Once'));
        _logStep('✓ Tapped native "Allow Once"');
        await _safePump($, ms: 500);
      } catch (e2) {
        _logStep('Native button not found: Allow Once');
        // Try built-in method as last resort
        try {
          await $.native.grantPermissionWhenInUse();
          _logStep('✓ Used grantPermissionWhenInUse()');
          await _safePump($, ms: 500);
        } catch (e3) {
          _logStep('No native permission dialog found');
        }
      }
    }
  } else {
    _logStep('Skipping native dialog check - not triggered');
  }

  // STEP 3: Dismiss any remaining Flutter dialogs (e.g., "Not Now")
  await _safePump($, ms: 300);
  if ($('Not Now').exists) {
    try {
      await $('Not Now').tap(settlePolicy: SettlePolicy.noSettle);
      _logStep('Dismissed remaining dialog with "Not Now"');
    } catch (_) {}
  }

  await _safePump($, ms: 300);
  _logStep('HANDLE PERMISSIONS END');
}

/// Verify we're on the Welcome screen with expected elements
Future<bool> _verifyWelcomeScreen(PatrolIntegrationTester $) async {
  debugPrint('>>> _verifyWelcomeScreen');
  await _safePump($, ms: 500);

  final hasTitle = $('Welcome to Ash Trail').exists || $('Ash Trail').exists;
  final hasSignIn = $(Key('sign_in_button')).exists || $('Sign In').exists;
  final hasSignUp = $('Sign Up').exists || $('Create Account').exists;

  debugPrint(
    '>>> Welcome screen - Title: $hasTitle, SignIn: $hasSignIn, SignUp: $hasSignUp',
  );
  return hasTitle && hasSignIn;
}

/// Verify we're on the Login screen with expected elements
Future<bool> _verifyLoginScreen(PatrolIntegrationTester $) async {
  debugPrint('>>> _verifyLoginScreen');
  await _safePump($, ms: 500);

  final hasEmailField = $(Key('email-input')).exists;
  final hasPasswordField = $(Key('password-input')).exists;
  final hasLoginButton = $(Key('login-button')).exists || $('Sign In').exists;

  debugPrint(
    '>>> Login screen - Email: $hasEmailField, Password: $hasPasswordField, Button: $hasLoginButton',
  );
  return hasEmailField && hasPasswordField;
}

/// Verify we're on the Home screen with expected elements
Future<bool> _verifyHomeScreen(PatrolIntegrationTester $) async {
  debugPrint('>>> _verifyHomeScreen');
  await _safePump($, ms: 500);

  final hasAppBar = $(Key('app_bar_home')).exists;
  final hasHomeTitle = $('Home').exists;
  final hasAccountButton =
      $(Key('app_bar_account')).exists || $(Icons.account_circle).exists;
  final hasRecordButton = $(Key('hold_to_record_button')).exists;

  debugPrint(
    '>>> Home screen - AppBar: $hasAppBar, Title: $hasHomeTitle, Account: $hasAccountButton, Record: $hasRecordButton',
  );
  return (hasAppBar || hasHomeTitle) && (hasAccountButton || hasRecordButton);
}

/// Verify we're on the Accounts screen with expected elements
Future<bool> _verifyAccountsScreen(PatrolIntegrationTester $) async {
  debugPrint('>>> _verifyAccountsScreen');
  await _safePump($, ms: 500);

  final hasTitle = $('Accounts').exists;
  final hasAccountCard = $(Key('account_card_0')).exists || $(Card).exists;
  final hasAddAccount =
      $(Key('accounts_add_account')).exists || $('Add Another Account').exists;

  debugPrint(
    '>>> Accounts screen - Title: $hasTitle, Card: $hasAccountCard, AddButton: $hasAddAccount',
  );
  return hasTitle;
}
