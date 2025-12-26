import '../models/account.dart';
import '../models/log_entry.dart';
import '../repositories/account_repository.dart';
import 'database_service.dart';

class AccountService {
  late final AccountRepository _repository;

  AccountService() {
    // Initialize repository based on platform
    final dbService = DatabaseService.instance;
    final dbInstance = dbService.instance;

    // Pass context for web (boxes map) or native (null, uses IsarService.instance internally)
    _repository = createAccountRepository(
      dbInstance is Map<String, dynamic> ? dbInstance : null,
    );
  }

  /// Get all accounts
  Future<List<Account>> getAllAccounts() async {
    return await _repository.getAll();
  }

  /// Get active account
  Future<Account?> getActiveAccount() async {
    return await _repository.getActive();
  }

  /// Get account by userId
  Future<Account?> getAccountByUserId(String userId) async {
    return await _repository.getByUserId(userId);
  }

  /// Create or update account
  Future<Account> saveAccount(Account account) async {
    return await _repository.save(account);
  }

  /// Set active account (deactivates all others)
  Future<void> setActiveAccount(String userId) async {
    await _repository.setActive(userId);
  }

  /// Delete account and all associated data
  Future<void> deleteAccount(String userId) async {
    // TODO: Delete all log entries for this account
    // This will be handled by repository cascade or explicit deletion
    await _repository.delete(userId);
  }

  /// Watch active account changes
  Stream<Account?> watchActiveAccount() {
    return _repository.watchActive();
  }

  /// Watch all accounts
  Stream<List<Account>> watchAllAccounts() {
    return _repository.watchAll();
  }
}
