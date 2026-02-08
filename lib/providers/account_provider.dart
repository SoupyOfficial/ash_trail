import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/account_session_manager.dart';
import '../services/token_service.dart';
import 'log_record_provider.dart';

final _accountLog = AppLogger.logger('AccountProvider');

// Token service provider - creates a new instance (stateless service)
final tokenServiceProvider = Provider<TokenService>((ref) {
  _accountLog.d('Creating TokenService instance');
  return TokenService();
});

// Service provider - creates AccountService with dependencies
final accountServiceProvider = Provider<AccountService>((ref) {
  _accountLog.d('Creating AccountService instance');
  return AccountService();
});

// Session manager provider - creates AccountSessionManager with dependencies
final accountSessionManagerProvider = Provider<AccountSessionManager>((ref) {
  _accountLog.d('Creating AccountSessionManager instance');
  final accountService = ref.watch(accountServiceProvider);
  return AccountSessionManager(accountService: accountService);
});

// Active account provider - cache the stream to avoid multiple subscriptions
final activeAccountProvider = StreamProvider<Account?>((ref) {
  _accountLog.d('activeAccountProvider initializing');
  final service = ref.watch(accountServiceProvider);
  final stream = service.watchActiveAccount();
  return stream.handleError((error, stackTrace) {
    _accountLog.e(
      'activeAccountProvider stream error',
      error: error,
      stackTrace: stackTrace,
    );
    throw error;
  });
});

// All accounts provider - uses FutureProvider for simpler state management
// Depends on activeAccountProvider so it refreshes when active user changes
// Caches result to prevent unnecessary reloads while navigation happens
final allAccountsProvider = FutureProvider<List<Account>>((ref) async {
  final active =
      ref
          .watch(activeAccountProvider)
          .maybeWhen(data: (acc) => acc?.userId, orElse: () => null) ??
      'none';
  _accountLog.d('allAccountsProvider initializing (active: $active)');
  final service = ref.watch(accountServiceProvider);
  try {
    final accounts = await service.getAllAccounts();
    _accountLog.d('allAccountsProvider loaded ${accounts.length} accounts');
    return accounts;
  } catch (error, stackTrace) {
    _accountLog.e(
      'allAccountsProvider error',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

/// Provider for all logged-in accounts (accounts with active sessions)
/// Multiple accounts can be logged in simultaneously
final loggedInAccountsProvider = FutureProvider<List<Account>>((ref) async {
  // Watch active account to refresh when it changes
  ref.watch(activeAccountProvider);
  _accountLog.d('loggedInAccountsProvider initializing');
  final sessionManager = ref.watch(accountSessionManagerProvider);
  try {
    final accounts = await sessionManager.getLoggedInAccounts();
    _accountLog.d(
      'loggedInAccountsProvider loaded ${accounts.length} accounts',
    );
    return accounts;
  } catch (error, stackTrace) {
    _accountLog.e(
      'loggedInAccountsProvider error',
      error: error,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});

/// Provider to check if any accounts are logged in
final hasLoggedInAccountsProvider = FutureProvider<bool>((ref) async {
  final sessionManager = ref.watch(accountSessionManagerProvider);
  return await sessionManager.hasLoggedInAccounts();
});

// Account switcher - notifier for switching accounts
final accountSwitcherProvider =
    StateNotifierProvider<AccountSwitcher, AsyncValue<void>>((ref) {
      return AccountSwitcher(ref);
    });

class AccountSwitcher extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AccountSwitcher(this._ref) : super(const AsyncValue.data(null));

  /// Switch to viewing a different account's data AND authenticate as that user.
  ///
  /// This method uses Firebase Custom Tokens to seamlessly switch the Firebase Auth
  /// user without requiring any user interaction. The flow is:
  /// 1. Check if already authenticated as this user (skip auth if so)
  /// 2. Try to get a valid custom token from secure storage
  /// 3. If no valid token, generate a new one via Cloud Function
  /// 4. Sign in with the custom token
  /// 5. Update the active account
  ///
  /// The account must be logged in (have a valid session).
  Future<void> switchAccount(String userId) async {
    _accountLog.d('switchAccount($userId)');
    state = const AsyncValue.loading();
    try {
      final sessionManager = _ref.read(accountSessionManagerProvider);
      final tokenService = _ref.read(tokenServiceProvider);
      final auth = FirebaseAuth.instance;

      // Check if already authenticated as this user
      final currentAuthUid = auth.currentUser?.uid;
      if (currentAuthUid != userId) {
        String? customToken = await sessionManager.getValidCustomToken(userId);

        if (customToken == null) {
          try {
            final tokenData = await tokenService.generateCustomToken(userId);
            customToken = tokenData['customToken'] as String;
            await sessionManager.storeCustomToken(userId, customToken);
          } catch (e) {
            _accountLog.w('Failed to generate custom token', error: e);
          }
        }

        if (customToken != null) {
          try {
            await auth.signInWithCustomToken(customToken);
          } catch (e) {
            _accountLog.w('Failed to sign in with custom token', error: e);
            await sessionManager.removeCustomToken(userId);
            try {
              final tokenData = await tokenService.generateCustomToken(userId);
              customToken = tokenData['customToken'] as String;
              await sessionManager.storeCustomToken(userId, customToken);
              await auth.signInWithCustomToken(customToken);
            } catch (retryError) {
              _accountLog.e('Retry sign-in failed', error: retryError);
            }
          }
        }
      }

      await sessionManager.setActiveAccount(userId);
      _ref.read(logDraftProvider.notifier).reset();
      _invalidateProviders();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      _accountLog.e('switchAccount error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Helper to invalidate all account-related providers
  void _invalidateProviders() {
    _ref.invalidate(activeAccountProvider);
    _ref.invalidate(allAccountsProvider);
    _ref.invalidate(loggedInAccountsProvider);
    _ref.invalidate(activeAccountLogRecordsProvider);
  }

  /// Add a new account (for multi-account support)
  Future<void> addAccount(Account account) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      account.isLoggedIn = true;
      account.lastAccessedAt = DateTime.now();
      await service.saveAccount(account);

      // Invalidate providers
      _ref.invalidate(allAccountsProvider);
      _ref.invalidate(loggedInAccountsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign out a single account (keep other accounts logged in)
  Future<void> signOutAccount(String userId) async {
    state = const AsyncValue.loading();
    try {
      final sessionManager = _ref.read(accountSessionManagerProvider);
      await sessionManager.removeAccountSession(userId, deleteData: false);

      // Invalidate providers
      _ref.invalidate(activeAccountProvider);
      _ref.invalidate(allAccountsProvider);
      _ref.invalidate(loggedInAccountsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete account and all associated data
  Future<void> deleteAccount(String userId) async {
    state = const AsyncValue.loading();
    try {
      final sessionManager = _ref.read(accountSessionManagerProvider);
      await sessionManager.removeAccountSession(userId, deleteData: true);

      // Invalidate providers
      _ref.invalidate(activeAccountProvider);
      _ref.invalidate(allAccountsProvider);
      _ref.invalidate(loggedInAccountsProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
