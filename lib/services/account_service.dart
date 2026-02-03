import '../logging/app_logger.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';
import 'database_service.dart';
import 'log_record_service.dart';

class AccountService {
  static final _log = AppLogger.logger('AccountService');
  final AccountRepository _repository;
  final LogRecordService _logRecordService;

  /// Create an AccountService with the given dependencies.
  /// 
  /// If [repository] is not provided, it will be created from DatabaseService.
  /// If [logRecordService] is not provided, a new instance will be created.
  AccountService({
    AccountRepository? repository,
    LogRecordService? logRecordService,
  }) : _repository = repository ?? _createDefaultRepository(),
       _logRecordService = logRecordService ?? LogRecordService() {
    _log.d('Initialized at ${DateTime.now()}');
  }

  /// Create the default repository using DatabaseService
  static AccountRepository _createDefaultRepository() {
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;
    final repo = createAccountRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
    );
    return repo;
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
    _log.d('watchActiveAccount called');
    return _repository.watchActive();
  }

  /// Watch all accounts
  Stream<List<Account>> watchAllAccounts() {
    _log.d('watchAllAccounts called');
    return _repository.watchAll();
  }

  /// Check if an account exists by userId
  Future<bool> accountExists(String userId) async {
    final account = await _repository.getByUserId(userId);
    return account != null;
  }

  /// Get all account IDs (for data integrity checks)
  Future<Set<String>> getAllAccountIds() async {
    final accounts = await _repository.getAll();
    return accounts.map((a) => a.userId).toSet();
  }
}
