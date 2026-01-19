import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/enums.dart';
import '../services/account_service.dart';
import '../services/account_session_manager.dart';
import '../services/log_record_service.dart';
import 'log_record_provider.dart';

// Service provider - ensure singleton AccountService is used
final accountServiceProvider = Provider<AccountService>((ref) {
  debugPrint(
    '🔧 [accountServiceProvider] Creating/Getting AccountService instance',
  );
  return AccountService.instance;
});

// Session manager provider
final accountSessionManagerProvider = Provider<AccountSessionManager>((ref) {
  debugPrint(
    '🔧 [accountSessionManagerProvider] Creating/Getting AccountSessionManager instance',
  );
  return AccountSessionManager.instance;
});

// Active account provider - cache the stream to avoid multiple subscriptions
final activeAccountProvider = StreamProvider<Account?>((ref) {
  debugPrint('\n🔴 [activeAccountProvider] INITIALIZING at ${DateTime.now()}');
  final service = ref.watch(accountServiceProvider);
  debugPrint('   📞 Calling service.watchActiveAccount()');
  final stream = service.watchActiveAccount();
  debugPrint('   ✅ Stream obtained at ${DateTime.now()}');

  // Create a logging wrapper stream that logs events without consuming them
  final loggingStream = stream
      .asBroadcastStream(
        onListen: (subscription) {
          debugPrint(
            '   👂 [activeAccountProvider] Listener attached at ${DateTime.now()}',
          );
        },
        onCancel: (subscription) {
          debugPrint(
            '   👋 [activeAccountProvider] Listener cancelled at ${DateTime.now()}',
          );
        },
      )
      .map((account) {
        debugPrint(
          '🔴 [activeAccountProvider] Stream EVENT: ${account?.userId ?? "null"} at ${DateTime.now()}',
        );
        return account;
      })
      .handleError((error, stackTrace) {
        debugPrint('🔴 [activeAccountProvider] Stream ERROR: $error');
        debugPrint('   StackTrace: $stackTrace');
        throw error;
      });

  return loggingStream;
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
  debugPrint('\n🟢 [allAccountsProvider] INITIALIZING at ${DateTime.now()}');
  debugPrint('   👤 Active dependency: $active');
  final service = ref.watch(accountServiceProvider);
  debugPrint('   📞 Calling service.getAllAccounts()');

  try {
    final accounts = await service.getAllAccounts();
    debugPrint(
      '🟢 [allAccountsProvider] SUCCESS: Loaded ${accounts.length} accounts at ${DateTime.now()}',
    );
    for (var i = 0; i < accounts.length; i++) {
      debugPrint('      $i: ${accounts[i].userId} - ${accounts[i].email}');
    }
    return accounts;
  } catch (error, stackTrace) {
    debugPrint('🟢 [allAccountsProvider] ERROR: $error');
    debugPrint('   StackTrace: $stackTrace');
    rethrow;
  }
});

/// Provider for all logged-in accounts (accounts with active sessions)
/// Multiple accounts can be logged in simultaneously
final loggedInAccountsProvider = FutureProvider<List<Account>>((ref) async {
  // Watch active account to refresh when it changes
  ref.watch(activeAccountProvider);

  debugPrint(
    '\n🔵 [loggedInAccountsProvider] INITIALIZING at ${DateTime.now()}',
  );
  final sessionManager = ref.watch(accountSessionManagerProvider);

  try {
    final accounts = await sessionManager.getLoggedInAccounts();
    debugPrint(
      '🔵 [loggedInAccountsProvider] SUCCESS: ${accounts.length} logged-in accounts',
    );
    return accounts;
  } catch (error, stackTrace) {
    debugPrint('🔵 [loggedInAccountsProvider] ERROR: $error');
    debugPrint('   StackTrace: $stackTrace');
    rethrow;
  }
});

/// Provider to check if current mode is anonymous (per design doc 8.5)
final isAnonymousModeProvider = Provider<bool>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);
  return activeAccount.maybeWhen(
    data: (account) => account?.isAnonymous ?? true,
    orElse: () => true,
  );
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

  /// Switch to viewing a different account's data
  /// The account must be logged in (have a valid session)
  Future<void> switchAccount(String userId) async {
    debugPrint('\n🔀🔀🔀 [AccountSwitcher.switchAccount] CALLED 🔀🔀🔀');
    debugPrint('   🎯 Target userId: $userId');
    debugPrint('   ⏰ Time: ${DateTime.now()}');

    state = const AsyncValue.loading();
    try {
      final sessionManager = _ref.read(accountSessionManagerProvider);
      debugPrint('   📞 Calling sessionManager.setActiveAccount($userId)...');
      await sessionManager.setActiveAccount(userId);
      debugPrint('   ✅ sessionManager.setActiveAccount completed');

      // Per design doc 8.4.1: Reset session state on account switch
      // Clear draft state when account changes
      debugPrint('   🔄 Resetting logDraftProvider...');
      _ref.read(logDraftProvider.notifier).reset();

      // Invalidate providers to refresh with new account's data
      debugPrint('   ♻️ Invalidating activeAccountProvider...');
      _ref.invalidate(activeAccountProvider);
      debugPrint('   ♻️ Invalidating allAccountsProvider...');
      _ref.invalidate(allAccountsProvider);
      debugPrint('   ♻️ Invalidating loggedInAccountsProvider...');
      _ref.invalidate(loggedInAccountsProvider);

      debugPrint(
        '🔀🔀🔀 [AccountSwitcher.switchAccount] COMPLETE for $userId 🔀🔀🔀\n',
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('   ❌ ERROR in switchAccount: $e');
      state = AsyncValue.error(e, st);
    }
  }

  /// Create and activate an anonymous account (per design doc 8.5)
  Future<Account> createAnonymousAccount() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      final sessionManager = _ref.read(accountSessionManagerProvider);
      const uuid = Uuid();
      final userId = 'anon_${uuid.v4()}';

      final anonymousAccount = Account.create(
        userId: userId,
        email: 'anonymous@local',
        displayName: 'Anonymous User',
        authProvider: AuthProvider.anonymous,
        isActive: true,
        isLoggedIn: true,
        lastAccessedAt: DateTime.now(),
      );

      final saved = await service.saveAccount(anonymousAccount);
      await sessionManager.setActiveAccount(saved.userId);

      // Invalidate providers to refresh
      _ref.invalidate(activeAccountProvider);
      _ref.invalidate(allAccountsProvider);
      _ref.invalidate(loggedInAccountsProvider);

      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Migrate anonymous data to authenticated account (per design doc 8.5.1)
  Future<void> migrateAnonymousToAuthenticated({
    required String anonymousUserId,
    required String authenticatedUserId,
  }) async {
    state = const AsyncValue.loading();
    try {
      debugPrint(
        '\n🔄 [AccountSwitcher] Migrating anonymous data to authenticated account',
      );
      debugPrint('   From: $anonymousUserId');
      debugPrint('   To: $authenticatedUserId');

      final logRecordService = LogRecordService();

      // 1. Get all log records for anonymous account
      final anonymousRecords = await logRecordService.getLogRecords(
        accountId: anonymousUserId,
        includeDeleted: true,
      );
      debugPrint('   📊 Found ${anonymousRecords.length} records to migrate');

      // 2. Update each record's accountId to authenticated account
      for (final record in anonymousRecords) {
        record.accountId = authenticatedUserId;
        record.syncState = SyncState.pending; // Mark for sync
        record.updatedAt = DateTime.now();
        await logRecordService.updateLogRecord(record);
      }

      // 3. Delete anonymous account (but data is now under authenticated account)
      final service = _ref.read(accountServiceProvider);
      final anonAccount = await service.getAccountByUserId(anonymousUserId);
      if (anonAccount != null) {
        anonAccount.isLoggedIn = false;
        anonAccount.isActive = false;
        await service.saveAccount(anonAccount);
        // Don't delete the account record, just deactivate it
        // In case user wants to see it existed
      }

      // 4. Set authenticated account as active
      await _ref
          .read(accountSessionManagerProvider)
          .setActiveAccount(authenticatedUserId);

      // Invalidate providers
      _ref.invalidate(activeAccountProvider);
      _ref.invalidate(allAccountsProvider);
      _ref.invalidate(loggedInAccountsProvider);

      debugPrint('   ✅ Migration complete');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('   ❌ Migration failed: $e');
      state = AsyncValue.error(e, st);
    }
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
