import '../models/account.dart';
import '../repositories/account_repository.dart';
import 'database_service.dart';
import 'log_record_service.dart';

class AccountService {
  late final AccountRepository _repository;
  late final LogRecordService _logRecordService;

  AccountService({LogRecordService? logRecordService}) {
    // Initialize repository with Hive database
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;

    // Pass Hive boxes map to repository
    _repository = createAccountRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
    );

    // Initialize log record service for cascade deletion
    _logRecordService = logRecordService ?? LogRecordService();
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

  /// Deactivate all accounts (used on sign-out)
  Future<void> deactivateAllAccounts() async {
    await _repository.clearActive();
  }

  /// Delete account and all associated data
  Future<void> deleteAccount(String userId) async {
    // Delete all log entries for this account first
    await _logRecordService.deleteAllByAccount(userId);
    // Then delete the account
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
