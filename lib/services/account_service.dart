import '../models/account.dart';
import '../models/log_entry.dart';
import '../repositories/account_repository.dart';
import 'database_service.dart';

class AccountService {
  late final AccountRepository _repository;

  AccountService() {
    // Initialize repository with Hive database
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;

    // Pass Hive boxes map to repository
    _repository = createAccountRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
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
