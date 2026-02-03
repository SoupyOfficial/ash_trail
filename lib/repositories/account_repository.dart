import '../logging/app_logger.dart';
import '../models/account.dart';
import 'account_repository_hive.dart';

/// Abstract repository interface for Account data access
/// Uses Hive for local storage on all platforms
abstract class AccountRepository {
  /// Get all accounts
  Future<List<Account>> getAll();

  /// Get account by userId
  Future<Account?> getByUserId(String userId);

  /// Get active account
  Future<Account?> getActive();

  /// Save account (create or update)
  Future<Account> save(Account account);

  /// Delete account by userId
  Future<void> delete(String userId);

  /// Set active account (deactivates all others)
  Future<void> setActive(String userId);

  /// Clear active account flag on all accounts
  Future<void> clearActive();

  /// Watch active account changes
  Stream<Account?> watchActive();

  /// Watch all accounts
  Stream<List<Account>> watchAll();
}

final _createAccountRepoLog = AppLogger.logger('createAccountRepository');

/// Factory to create AccountRepository using Hive (singleton pattern)
AccountRepository createAccountRepository([dynamic context]) {
  if (context == null) {
    _createAccountRepoLog.w('Context is NULL - this may cause issues');
  }
  return AccountRepositoryHive(context as Map<String, dynamic>);
}
