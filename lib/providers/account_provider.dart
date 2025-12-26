import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
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
