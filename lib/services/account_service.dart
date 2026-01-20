import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';
import 'database_service.dart';
import 'log_record_service.dart';

class AccountService {
  // Singleton instance
  static final AccountService _instance = AccountService._internal();
  static AccountService get instance => _instance;

  factory AccountService({LogRecordService? logRecordService}) => _instance;

  AccountService._internal({LogRecordService? logRecordService}) {
    debugPrint(
      '\n🏗️ [AccountService._internal] Initializing at ${DateTime.now()}',
    );

    // Initialize repository with Hive database
    debugPrint('   📦 Getting DatabaseService instance...');
    final dbService = DatabaseService.instance;
    debugPrint('   ✅ Got DatabaseService instance: ${dbService.runtimeType}');

    debugPrint('   📦 Getting database boxes...');
    final dbBoxes = dbService.boxes;
    debugPrint('   📦 Got database boxes type: ${dbBoxes.runtimeType}');

    if (dbBoxes is Map<String, dynamic>) {
      debugPrint('   ✅ dbBoxes is a Map with keys: ${dbBoxes.keys.toList()}');
    } else {
      debugPrint('   ⚠️ dbBoxes is NOT a Map! Type: ${dbBoxes.runtimeType}');
    }

    // Pass Hive boxes map to repository
    debugPrint('   📞 Calling createAccountRepository...');
    _repository = createAccountRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
    );
    debugPrint('   ✅ Created AccountRepository: ${_repository.runtimeType}');

    // Initialize log record service for cascade deletion
    debugPrint('   📞 Initializing LogRecordService...');
    _logRecordService = logRecordService ?? LogRecordService();
    debugPrint('   ✅ Initialized LogRecordService\\n');
  }

  late final AccountRepository _repository;
  late final LogRecordService _logRecordService;

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
    debugPrint(
      '🔴 [AccountService.watchActiveAccount] Called at ${DateTime.now()}',
    );
    debugPrint('   📞 Delegating to _repository.watchActive()');
    return _repository.watchActive();
  }

  /// Watch all accounts
  Stream<List<Account>> watchAllAccounts() {
    debugPrint(
      '🟢 [AccountService.watchAllAccounts] Called at ${DateTime.now()}',
    );
    debugPrint('   📞 Delegating to _repository.watchAll()');
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
