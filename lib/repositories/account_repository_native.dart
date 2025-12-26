import 'package:isar/isar.dart';
import '../models/account.dart';
import '../services/isar_service.dart';
import 'account_repository.dart';

/// Native implementation of AccountRepository using Isar
class AccountRepositoryNative implements AccountRepository {
  final Isar _isar = IsarService.instance;

  @override
  Future<List<Account>> getAll() async {
    return await _isar.accounts.where().findAll();
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    return await _isar.accounts.filter().userIdEqualTo(userId).findFirst();
  }

  @override
  Future<Account?> getActive() async {
    return await _isar.accounts.filter().isActiveEqualTo(true).findFirst();
  }

  @override
  Future<Account> save(Account account) async {
    await _isar.writeTxn(() async {
      await _isar.accounts.put(account);
    });
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    await _isar.writeTxn(() async {
      final account = await getByUserId(userId);
      if (account != null) {
        await _isar.accounts.delete(account.id);
      }
    });
  }

  @override
  Future<void> setActive(String userId) async {
    await _isar.writeTxn(() async {
      final allAccounts = await _isar.accounts.where().findAll();
      for (final account in allAccounts) {
        account.isActive = account.userId == userId;
        await _isar.accounts.put(account);
      }
    });
  }

  @override
  Stream<Account?> watchActive() {
    return _isar.accounts
        .filter()
        .isActiveEqualTo(true)
        .watch(fireImmediately: true)
        .map((accounts) => accounts.isEmpty ? null : accounts.first);
  }

  @override
  Stream<List<Account>> watchAll() {
    return _isar.accounts.where().watch(fireImmediately: true);
  }
}
