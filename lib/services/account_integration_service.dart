import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/account_session_manager.dart';
import '../services/crash_reporting_service.dart';
import '../services/token_service.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';
import '../models/enums.dart' as enums;

/// Provider for account service
final accountIntegrationServiceProvider = Provider<AccountIntegrationService>((
  ref,
) {
  return AccountIntegrationService(
    authService: ref.watch(authServiceProvider),
    accountService: AccountService.instance,
    sessionManager: AccountSessionManager.instance,
  );
});

/// Service to integrate Firebase Auth with local Account management
/// Supports multi-account: multiple users can be logged in simultaneously
/// Automatically creates/updates local Account when user authenticates
class AccountIntegrationService {
  final AuthService authService;
  final AccountService accountService;
  final AccountSessionManager sessionManager;

  AccountIntegrationService({
    required this.authService,
    required this.accountService,
    required this.sessionManager,
  });

  /// Create or update local account from Firebase user
  /// Called after successful authentication
  /// In multi-account mode, this adds the account to the logged-in list
  /// Also generates a custom token for seamless future account switching
  Future<Account> syncAccountFromFirebaseUser(
    User firebaseUser, {
    bool makeActive = true,
  }) async {
    debugPrint('\n🔄 [AccountIntegrationService] syncAccountFromFirebaseUser');
    debugPrint('   User: ${firebaseUser.uid} (${firebaseUser.email})');
    debugPrint('   Make active: $makeActive');

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

      debugPrint('   ✅ Updated existing account');
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

      debugPrint('   ✅ Created new account');
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
      debugPrint('   🔑 Generating custom token for seamless switching...');
      final tokenService = TokenService.instance;
      final tokenData = await tokenService.generateCustomToken(uid);
      final customToken = tokenData['customToken'] as String;
      await sessionManager.storeCustomToken(uid, customToken);
      debugPrint('   ✅ Custom token generated and stored for $uid');
    } catch (e) {
      // Non-fatal: User can still use the app, but may need to re-auth on switch
      debugPrint('   ⚠️ Failed to generate custom token: $e');
      debugPrint('   ⚠️ Account switching may require re-authentication');
      // Don't rethrow - this is not critical to sign-in success
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
    debugPrint('\n🔐 [AccountIntegrationService] signInWithEmail');

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
      debugPrint('\n🔐 [AccountIntegrationService] signInWithGoogle');
      CrashReportingService.logMessage('Starting Google sign-in');

      final userCredential = await authService.signInWithGoogle();

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      final account = await syncAccountFromFirebaseUser(
        userCredential.user!,
        makeActive: makeActive,
      );

      // Set user ID in crashlytics for crash tracking
      await CrashReportingService.setUserId(account.userId);
      CrashReportingService.logMessage('User signed in: ${account.email}');

      return account;
    } catch (e) {
      CrashReportingService.recordError(
        e,
        StackTrace.current,
        reason: 'Failed to sign in with Google and sync account',
      );
      rethrow;
    }
  }

  /// Sign in with Apple and sync local account
  /// In multi-account mode, adds this account to the logged-in list
  Future<Account> signInWithApple({bool makeActive = true}) async {
    debugPrint('\n🔐 [AccountIntegrationService] signInWithApple');

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
    debugPrint('\n🔐 [AccountIntegrationService] signOut (all accounts)');

    await authService.signOut();
    await sessionManager.clearAllSessions();
    await accountService.deactivateAllAccounts();

    debugPrint('   ✅ All accounts signed out');
  }

  /// Sign out a single account while keeping others logged in
  Future<void> signOutAccount(String userId) async {
    debugPrint('\n🔐 [AccountIntegrationService] signOutAccount($userId)');

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

    debugPrint('   ✅ Account signed out: $userId');
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
