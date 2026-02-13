import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/account_session_manager.dart';
import '../services/crash_reporting_service.dart';
import '../services/token_service.dart';
import '../services/error_reporting_service.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';
import '../models/enums.dart' as enums;

/// Provider for account service
final accountIntegrationServiceProvider = Provider<AccountIntegrationService>((
  ref,
) {
  // Create services with dependency injection
  final accountService = AccountService();
  final sessionManager = AccountSessionManager(accountService: accountService);
  final tokenService = TokenService();

  return AccountIntegrationService(
    authService: ref.watch(authServiceProvider),
    accountService: accountService,
    sessionManager: sessionManager,
    tokenService: tokenService,
  );
});

/// Service to integrate Firebase Auth with local Account management
/// Supports multi-account: multiple users can be logged in simultaneously
/// Automatically creates/updates local Account when user authenticates
class AccountIntegrationService {
  static final _log = AppLogger.logger('AccountIntegrationService');
  final AuthService authService;
  final AccountService accountService;
  final AccountSessionManager sessionManager;
  final TokenService tokenService;

  AccountIntegrationService({
    required this.authService,
    required this.accountService,
    required this.sessionManager,
    required this.tokenService,
  });

  /// Create or update local account from Firebase user
  /// Called after successful authentication
  /// In multi-account mode, this adds the account to the logged-in list
  /// Also generates a custom token for seamless future account switching
  Future<Account> syncAccountFromFirebaseUser(
    User firebaseUser, {
    bool makeActive = true,
  }) async {
    _log.w(
      '[SYNC_ACCOUNT] syncAccountFromFirebaseUser: '
      'uid=${firebaseUser.uid}, email=${firebaseUser.email}, '
      'displayName=${firebaseUser.displayName}, makeActive=$makeActive, '
      'providers=${firebaseUser.providerData.map((p) => p.providerId).toList()}',
    );

    // Check if account already exists
    Account? existingAccount = await accountService.getAccountByUserId(
      firebaseUser.uid,
    );

    // Determine auth provider from Firebase user
    enums.AuthProvider authProvider = enums.AuthProvider.email;
    for (final providerData in firebaseUser.providerData) {
      if (providerData.providerId == 'google.com') {
        authProvider = enums.AuthProvider.gmail;
        break;
      } else if (providerData.providerId == 'apple.com') {
        authProvider = enums.AuthProvider.apple;
        break;
      }
    }

    Account resultAccount;

    if (existingAccount != null) {
      // Update existing account
      existingAccount.email = firebaseUser.email ?? existingAccount.email;
      existingAccount.displayName =
          firebaseUser.displayName ?? existingAccount.displayName;
      existingAccount.photoUrl =
          firebaseUser.photoURL ?? existingAccount.photoUrl;
      existingAccount.authProvider = authProvider;
      existingAccount.isLoggedIn = true;
      existingAccount.lastSyncedAt = DateTime.now();
      existingAccount.lastAccessedAt = DateTime.now();

      await accountService.saveAccount(existingAccount);

      if (makeActive) {
        await sessionManager.setActiveAccount(firebaseUser.uid);
      }

      _log.w(
        '[SYNC_ACCOUNT] Updated EXISTING account: '
        'email=${existingAccount.email}, provider=${existingAccount.authProvider}, '
        'isActive=${makeActive}',
      );
      resultAccount = existingAccount;
    } else {
      // Create new account
      final newAccount = Account.create(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? 'no-email@ashtrail.app',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        authProvider: authProvider,
        isActive: makeActive,
        isLoggedIn: true,
        createdAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
      );

      await accountService.saveAccount(newAccount);

      if (makeActive) {
        await sessionManager.setActiveAccount(firebaseUser.uid);
      }

      _log.w(
        '[SYNC_ACCOUNT] Created NEW account: '
        'userId=${newAccount.userId}, email=${newAccount.email}, '
        'provider=${newAccount.authProvider}, isActive=${makeActive}',
      );
      resultAccount = newAccount;
    }

    // Generate and store custom token for seamless multi-account switching
    // This allows switching to this account later without re-authentication
    await _generateAndStoreCustomToken(firebaseUser.uid);

    return resultAccount;
  }

  /// Generate a custom Firebase token and store it for future account switching.
  ///
  /// This is called after successful authentication to enable seamless
  /// switching back to this account later without user interaction.
  /// Custom tokens are valid for 48 hours.
  Future<void> _generateAndStoreCustomToken(String uid) async {
    try {
      _log.w(
        '[CUSTOM_TOKEN] Generating custom token for uid=$uid (enables seamless switching)',
      );
      final tokenData = await tokenService.generateCustomToken(uid);
      final customToken = tokenData['customToken'] as String;
      final expiresIn = tokenData['expiresIn'];
      await sessionManager.storeCustomToken(uid, customToken);
      _log.w(
        '[CUSTOM_TOKEN] Token stored: ${customToken.length} chars, '
        'expiresIn=${expiresIn}s for uid=$uid',
      );
    } catch (e, st) {
      _log.e(
        '[CUSTOM_TOKEN] FAILED to generate token for uid=$uid — '
        'account switching may require re-authentication',
        error: e,
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'AccountIntegrationService._generateAndStoreCustomToken',
      );
    }
  }

  /// Sign up and create local account
  Future<Account> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    bool makeActive = true,
  }) async {
    final userCredential = await authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to create user');
    }

    return await syncAccountFromFirebaseUser(
      userCredential.user!,
      makeActive: makeActive,
    );
  }

  /// Sign in and sync local account
  /// In multi-account mode, adds this account to the logged-in list
  Future<Account> signInWithEmail({
    required String email,
    required String password,
    bool makeActive = true,
  }) async {
    _log.d('signInWithEmail');

    final userCredential = await authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to sign in');
    }

    return await syncAccountFromFirebaseUser(
      userCredential.user!,
      makeActive: makeActive,
    );
  }

  /// Sign in with Google and sync local account
  /// In multi-account mode, adds this account to the logged-in list
  Future<Account> signInWithGoogle({bool makeActive = true}) async {
    try {
      _log.w('[GMAIL_FLOW_START] signInWithGoogle(makeActive=$makeActive)');
      CrashReportingService.logMessage('Starting Google sign-in');

      final userCredential = await authService.signInWithGoogle();

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      _log.w(
        '[GMAIL_FLOW] Firebase user obtained: uid=${userCredential.user!.uid}, '
        'email=${userCredential.user!.email}',
      );

      final account = await syncAccountFromFirebaseUser(
        userCredential.user!,
        makeActive: makeActive,
      );

      // Set user ID in crashlytics for crash tracking
      await CrashReportingService.setUserId(account.userId);
      CrashReportingService.logMessage('User signed in: ${account.email}');

      _log.w(
        '[GMAIL_FLOW_END] Google sign-in complete: '
        'userId=${account.userId}, email=${account.email}, '
        'provider=${account.authProvider}, isActive=${account.isActive}, '
        'isLoggedIn=${account.isLoggedIn}',
      );
      return account;
    } catch (e, st) {
      _log.e(
        '[GMAIL_FLOW_FAIL] Google sign-in failed: type=${e.runtimeType}',
        error: e,
      );
      CrashReportingService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to sign in with Google and sync account',
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'AccountIntegrationService.signInWithGoogle',
      );
      rethrow;
    }
  }

  /// Sign in with Apple and sync local account
  /// In multi-account mode, adds this account to the logged-in list
  Future<Account> signInWithApple({bool makeActive = true}) async {
    _log.d('signInWithApple');

    final userCredential = await authService.signInWithApple();

    if (userCredential.user == null) {
      throw Exception('Failed to sign in with Apple');
    }

    return await syncAccountFromFirebaseUser(
      userCredential.user!,
      makeActive: makeActive,
    );
  }

  /// Sign out all accounts (clears all sessions)
  Future<void> signOut() async {
    _log.d('signOut (all accounts)');

    await authService.signOut();
    await sessionManager.clearAllSessions();
    await accountService.deactivateAllAccounts();

    _log.i('All accounts signed out');
  }

  /// Sign out a single account while keeping others logged in
  Future<void> signOutAccount(String userId) async {
    _log.d('signOutAccount($userId)');

    // Check if this is the current Firebase auth user
    final currentUser = authService.currentUser;
    if (currentUser?.uid == userId) {
      // Sign out from Firebase
      await authService.signOut();
    }

    // Clear this account's session
    await sessionManager.clearSession(userId);

    // Update account state
    final account = await accountService.getAccountByUserId(userId);
    if (account != null) {
      account.isLoggedIn = false;
      account.isActive = false;
      await accountService.saveAccount(account);
    }

    // If this was the active account, switch to another logged-in account
    final activeAccount = await accountService.getActiveAccount();
    if (activeAccount == null || activeAccount.userId == userId) {
      final loggedInAccounts = await sessionManager.getLoggedInAccounts();
      if (loggedInAccounts.isNotEmpty) {
        await sessionManager.setActiveAccount(loggedInAccounts.first.userId);
      }
    }

    _log.i('Account signed out: $userId');
  }

  /// Update user profile and sync with local account
  Future<Account> updateProfile({String? displayName, String? photoURL}) async {
    await authService.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    final user = authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return await syncAccountFromFirebaseUser(user);
  }

  /// Update user email and sync with local account
  Future<Account> updateEmail(String newEmail) async {
    await authService.updateEmail(newEmail);

    final user = authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return await syncAccountFromFirebaseUser(user);
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Delete user account and all associated local data
  Future<void> deleteAccount(String password) async {
    final user = authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userId = user.uid;

    // Delete from Firebase Auth
    await authService.deleteAccount(password);

    // Delete local account and associated data
    await accountService.deleteAccount(userId);
  }
}
