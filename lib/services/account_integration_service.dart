import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/account_service.dart';
import '../services/crash_reporting_service.dart';
import '../providers/auth_provider.dart';
import '../models/account.dart';

/// Provider for account service
final accountIntegrationServiceProvider = Provider<AccountIntegrationService>((
  ref,
) {
  return AccountIntegrationService(
    authService: ref.watch(authServiceProvider),
    accountService: AccountService(),
  );
});

/// Service to integrate Firebase Auth with local Account management
/// Automatically creates/updates local Account when user authenticates
class AccountIntegrationService {
  final AuthService authService;
  final AccountService accountService;

  AccountIntegrationService({
    required this.authService,
    required this.accountService,
  });

  /// Create or update local account from Firebase user
  /// Called after successful authentication
  Future<Account> syncAccountFromFirebaseUser(User firebaseUser) async {
    // Check if account already exists
    Account? existingAccount = await accountService.getAccountByUserId(
      firebaseUser.uid,
    );

    if (existingAccount != null) {
      // Update existing account
      existingAccount.email = firebaseUser.email ?? existingAccount.email;
      existingAccount.displayName =
          firebaseUser.displayName ?? existingAccount.displayName;
      existingAccount.photoUrl =
          firebaseUser.photoURL ?? existingAccount.photoUrl;
      existingAccount.lastSyncedAt = DateTime.now();

      await accountService.saveAccount(existingAccount);
      await accountService.setActiveAccount(firebaseUser.uid);

      return existingAccount;
    } else {
      // Create new account
      final newAccount = Account.create(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? 'no-email@ashtrail.app',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await accountService.saveAccount(newAccount);
      await accountService.setActiveAccount(firebaseUser.uid);

      return newAccount;
    }
  }

  /// Sign up and create local account
  Future<Account> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final userCredential = await authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to create user');
    }

    return await syncAccountFromFirebaseUser(userCredential.user!);
  }

  /// Sign in and sync local account
  Future<Account> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (userCredential.user == null) {
      throw Exception('Failed to sign in');
    }

    return await syncAccountFromFirebaseUser(userCredential.user!);
  }

  /// Sign in with Google and sync local account
  Future<Account> signInWithGoogle() async {
    try {
      final userCredential = await authService.signInWithGoogle();

      if (userCredential.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      final account = await syncAccountFromFirebaseUser(userCredential.user!);

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
  Future<Account> signInWithApple() async {
    final userCredential = await authService.signInWithApple();

    if (userCredential.user == null) {
      throw Exception('Failed to sign in with Apple');
    }

    return await syncAccountFromFirebaseUser(userCredential.user!);
  }

  /// Sign out and deactivate local account
  Future<void> signOut() async {
    await authService.signOut();
    // Local account remains but is no longer active
    // This allows preserving local data for multi-account scenarios
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
