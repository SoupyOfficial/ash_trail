import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/enums.dart';
import '../services/account_service.dart';

// Service provider
final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService();
});

// Active account provider
final activeAccountProvider = StreamProvider<Account?>((ref) {
  final service = ref.watch(accountServiceProvider);
  return service.watchActiveAccount();
});

// All accounts provider
final allAccountsProvider = StreamProvider<List<Account>>((ref) {
  final service = ref.watch(accountServiceProvider);
  return service.watchAllAccounts();
});

/// Provider to check if current mode is anonymous (per design doc 8.5)
final isAnonymousModeProvider = Provider<bool>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);
  return activeAccount.maybeWhen(
    data: (account) => account?.isAnonymous ?? true,
    orElse: () => true,
  );
});

// Account switcher - notifier for switching accounts
final accountSwitcherProvider =
    StateNotifierProvider<AccountSwitcher, AsyncValue<void>>((ref) {
      return AccountSwitcher(ref);
    });

class AccountSwitcher extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AccountSwitcher(this._ref) : super(const AsyncValue.data(null));

  Future<void> switchAccount(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      await service.setActiveAccount(userId);
      // Per design doc 8.4.1: Reset session state on account switch
      // TODO: Clear draft state, caches when account changes
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create and activate an anonymous account (per design doc 8.5)
  Future<Account> createAnonymousAccount() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      const uuid = Uuid();
      final anonymousAccount = Account.create(
        userId: 'anon_${uuid.v4()}',
        email: 'anonymous@local',
        displayName: 'Anonymous User',
        authProvider: AuthProvider.anonymous,
        isActive: true,
      );
      final saved = await service.saveAccount(anonymousAccount);
      await service.setActiveAccount(saved.userId);
      state = const AsyncValue.data(null);
      return saved;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Migrate anonymous data to authenticated account (per design doc 8.5.1)
  /// TODO: Implement full data migration when user authenticates
  Future<void> migrateAnonymousToAuthenticated({
    required String anonymousUserId,
    required String authenticatedUserId,
  }) async {
    state = const AsyncValue.loading();
    try {
      // TODO: Migrate log records from anonymous to authenticated account
      // 1. Get all log records for anonymous account
      // 2. Update accountId to authenticated account
      // 3. Mark for sync
      // 4. Delete anonymous account
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAccount(Account account) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      await service.saveAccount(account);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAccount(String userId) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(accountServiceProvider);
      await service.deleteAccount(userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
