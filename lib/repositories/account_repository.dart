import '../models/account.dart';
import 'account_repository_stub.dart'
    if (dart.library.io) 'account_repository_native.dart'
    if (dart.library.js_interop) 'account_repository_web.dart';

/// Abstract repository interface for Account data access
/// Platform-specific implementations handle Isar (native) or Hive (web)
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

  /// Watch active account changes
  Stream<Account?> watchActive();

  /// Watch all accounts
  Stream<List<Account>> watchAll();
}

/// Factory to create platform-specific AccountRepository
AccountRepository createAccountRepository([dynamic context]) {
  // On native: context is ignored, uses IsarService.instance
  // On web: context should be the boxes map from database service
  if (context is Map<String, dynamic>) {
    return AccountRepositoryWeb(context);
  }
  return AccountRepositoryNative();
}
