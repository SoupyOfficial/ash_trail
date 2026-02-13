import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ash_trail/services/account_integration_service.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/account_session_manager.dart';
import 'package:ash_trail/services/auth_service.dart';
import 'package:ash_trail/services/token_service.dart';

// ── Diagnostics ──────────────────────────────────────────────────────────────

void _bypassLog(String message) {
  final ts = DateTime.now().toIso8601String().substring(11, 23);
  final line = '[$ts] AUTH_BYPASS: $message';
  File(
    '/tmp/ash_trail_test_diagnostics.log',
  ).writeAsStringSync('$line\n', mode: FileMode.append);
}

// ── Constants ────────────────────────────────────────────────────────────────

/// Firebase custom token passed via `--dart-define=FIREBASE_TEST_TOKEN=...`.
///
/// When non-empty, [attemptAuthBypass] will use this token to sign in
/// programmatically via `signInWithCustomToken()`, bypassing the native
/// Google Sign-In OAuth flow entirely.
///
/// Generate a token by calling the existing Cloud Function:
/// ```bash
/// curl -X POST \
///   https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token \
///   -H 'Content-Type: application/json' \
///   -d '{"uid": "<FIREBASE_UID>"}'
/// ```
///
/// Then pass it to Patrol:
/// ```bash
/// patrol test --target integration_test/gmail_multi_account_test.dart \
///   --dart-define=FIREBASE_TEST_TOKEN=<token>
/// ```
const _firebaseTestToken = String.fromEnvironment('FIREBASE_TEST_TOKEN');

/// Optional: override the expected email for CI token-based sign-in.
/// If not set, the bypass will accept any email from the token.
const _firebaseTestEmail = String.fromEnvironment('FIREBASE_TEST_EMAIL');

// ── Public API ───────────────────────────────────────────────────────────────

/// Whether a Firebase test token was provided via `--dart-define`.
bool get hasAuthBypassToken => _firebaseTestToken.isNotEmpty;

/// Attempt to sign in programmatically using a Firebase custom token.
///
/// This is the **industry-standard approach** for CI testing with Firebase
/// Auth — it bypasses the native OAuth flow (ASWebAuthenticationSession)
/// entirely, which cannot be automated by any framework.
///
/// Returns `true` if sign-in succeeded and the Hive account was synced.
/// Returns `false` if no token was provided or sign-in failed.
///
/// **Prerequisites:**
/// - Firebase must be initialized (call after `AppComponent.launch()`)
/// - The token must be valid (generated within the last 48 hours)
///
/// **What this does:**
/// 1. Calls `FirebaseAuth.instance.signInWithCustomToken(token)`
/// 2. Syncs the Firebase user to a Hive `Account` via
///    `AccountIntegrationService.syncAccountFromFirebaseUser()`
/// 3. Sets the account as active
///
/// **What this does NOT do:**
/// - Launch the app (caller must call `AppComponent.launch()` first)
/// - Wait for UI to update (caller should pump/settle after)
Future<bool> attemptAuthBypass({String? expectedEmail}) async {
  if (!hasAuthBypassToken) {
    _bypassLog('No FIREBASE_TEST_TOKEN provided — skipping bypass');
    return false;
  }

  _bypassLog('FIREBASE_TEST_TOKEN present — attempting programmatic sign-in');

  try {
    // 1. Sign in with custom token
    final credential = await FirebaseAuth.instance.signInWithCustomToken(
      _firebaseTestToken,
    );
    final user = credential.user;

    if (user == null) {
      _bypassLog('signInWithCustomToken returned null user — bypass failed');
      return false;
    }

    _bypassLog(
      'Firebase sign-in succeeded: '
      'uid=${user.uid.substring(0, 8)}... '
      'email=${user.email ?? 'null'}',
    );

    // Check email match if requested
    final targetEmail = expectedEmail ?? _firebaseTestEmail;
    if (targetEmail.isNotEmpty && user.email != targetEmail) {
      _bypassLog(
        'WARNING: Signed-in email ${user.email} does not match '
        'expected $targetEmail — continuing anyway',
      );
    }

    // 2. Sync to Hive via AccountIntegrationService
    // This creates or updates the local Account and sets it as active,
    // which is required for the app's AuthWrapper to show MainNavigation.
    _bypassLog('Syncing Firebase user to Hive account...');
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

    final account = await integrationService.syncAccountFromFirebaseUser(
      user,
      makeActive: true,
    );

    _bypassLog(
      'Hive account synced: '
      'email=${account.email}, '
      'userId=${account.userId.substring(0, 8)}..., '
      'isActive=${account.isActive}',
    );

    // 3. Verify token can refresh
    try {
      await user.getIdToken();
      _bypassLog('Token refresh OK — bypass complete');
    } catch (e) {
      _bypassLog('Token refresh warning (non-fatal): $e');
    }

    return true;
  } catch (e, stack) {
    _bypassLog('Auth bypass FAILED: $e');
    _bypassLog('Stack: ${stack.toString().split('\n').take(5).join('\n')}');
    return false;
  }
}

/// Generate a custom Firebase token by calling the existing Cloud Function.
///
/// This is a convenience for CI scripts that need to generate tokens
/// dynamically. The Cloud Function at
/// `https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token`
/// accepts a UID and returns a custom token valid for 48 hours.
///
/// **Security note:** The Cloud Function has no authentication guard.
/// This is acceptable for test accounts but should not be used with
/// production UIDs.
///
/// For shell-based token generation, use:
/// ```bash
/// TOKEN=$(curl -s -X POST \
///   https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token \
///   -H 'Content-Type: application/json' \
///   -d '{"uid": "<UID>"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['customToken'])")
/// ```
Future<String?> generateTestToken(String uid) async {
  _bypassLog('Generating custom token for uid=$uid via Cloud Function...');
  try {
    final tokenService = TokenService();
    final result = await tokenService.generateCustomToken(uid);
    final token = result['customToken'] as String?;
    if (token != null) {
      _bypassLog(
        'Token generated: ${token.length} chars, '
        'expiresIn=${result['expiresIn']}s',
      );
    }
    return token;
  } catch (e) {
    _bypassLog('Token generation failed: $e');
    return null;
  }
}
