import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/account.dart';
import '../models/enums.dart';
import 'account_service.dart';

/// Manages multiple authenticated sessions for multi-account support.
///
/// Firebase Auth only supports one active user at a time, so this service:
/// 1. Stores refresh tokens for each logged-in account securely
/// 2. Tracks which accounts have valid sessions
/// 3. Enables quick switching between accounts by restoring sessions
///
/// Data isolation is maintained by:
/// - All data queries filter by the active account's userId
/// - Each account's data syncs independently to Firestore
/// - Switching accounts changes which data is displayed, not who is authenticated
class AccountSessionManager {
  // Singleton instance
  static final AccountSessionManager _instance =
      AccountSessionManager._internal();
  static AccountSessionManager get instance => _instance;

  factory AccountSessionManager() => _instance;

  AccountSessionManager._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AccountService _accountService = AccountService.instance;

  // Storage keys
  static const String _sessionPrefix = 'session_';
  static const String _activeSessionKey = 'active_session_user_id';
  static const String _loggedInAccountsKey = 'logged_in_accounts';

  /// Get list of all accounts that have active sessions (logged in)
  Future<List<Account>> getLoggedInAccounts() async {
    debugPrint('\n🔐 [AccountSessionManager] getLoggedInAccounts()');

    final allAccounts = await _accountService.getAllAccounts();
    final loggedInAccounts = allAccounts.where((a) => a.isLoggedIn).toList();

    debugPrint('   📊 Found ${loggedInAccounts.length} logged-in accounts');
    return loggedInAccounts;
  }

  /// Store session credentials for an account
  Future<void> storeSession({
    required String userId,
    required String? refreshToken,
    required String? accessToken,
    DateTime? tokenExpiresAt,
  }) async {
    debugPrint('\n🔐 [AccountSessionManager] storeSession($userId)');

    final sessionData = {
      'userId': userId,
      'refreshToken': refreshToken,
      'accessToken': accessToken,
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
      'storedAt': DateTime.now().toIso8601String(),
    };

    await _secureStorage.write(
      key: '$_sessionPrefix$userId',
      value: jsonEncode(sessionData),
    );

    // Update the account's session state
    final account = await _accountService.getAccountByUserId(userId);
    if (account != null) {
      account.isLoggedIn = true;
      account.refreshToken = refreshToken;
      account.accessToken = accessToken;
      account.tokenExpiresAt = tokenExpiresAt;
      account.lastAccessedAt = DateTime.now();
      await _accountService.saveAccount(account);
    }

    // Track this account in logged-in list
    await _addToLoggedInList(userId);

    debugPrint('   ✅ Session stored for $userId');
  }

  /// Retrieve stored session for an account
  Future<Map<String, dynamic>?> getSession(String userId) async {
    final sessionJson = await _secureStorage.read(
      key: '$_sessionPrefix$userId',
    );
    if (sessionJson == null) return null;

    try {
      return jsonDecode(sessionJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('   ❌ Failed to decode session: $e');
      return null;
    }
  }

  /// Clear session for a specific account (sign out single account)
  Future<void> clearSession(String userId) async {
    debugPrint('\n🔐 [AccountSessionManager] clearSession($userId)');

    await _secureStorage.delete(key: '$_sessionPrefix$userId');

    // Update account state
    final account = await _accountService.getAccountByUserId(userId);
    if (account != null) {
      account.isLoggedIn = false;
      account.refreshToken = null;
      account.accessToken = null;
      account.tokenExpiresAt = null;
      await _accountService.saveAccount(account);
    }

    // Remove from logged-in list
    await _removeFromLoggedInList(userId);

    debugPrint('   ✅ Session cleared for $userId');
  }

  /// Clear all sessions (sign out all accounts)
  Future<void> clearAllSessions() async {
    debugPrint('\n🔐 [AccountSessionManager] clearAllSessions()');

    final loggedInUserIds = await _getLoggedInList();
    for (final userId in loggedInUserIds) {
      await _secureStorage.delete(key: '$_sessionPrefix$userId');

      final account = await _accountService.getAccountByUserId(userId);
      if (account != null) {
        account.isLoggedIn = false;
        account.refreshToken = null;
        account.accessToken = null;
        account.tokenExpiresAt = null;
        await _accountService.saveAccount(account);
      }
    }

    await _secureStorage.delete(key: _loggedInAccountsKey);
    await _secureStorage.delete(key: _activeSessionKey);

    debugPrint('   ✅ All sessions cleared');
  }

  /// Set the active account for data viewing
  /// This doesn't change Firebase auth state, just which account's data we show
  Future<void> setActiveAccount(String userId) async {
    debugPrint('\n🔐 [AccountSessionManager] setActiveAccount($userId)');

    await _secureStorage.write(key: _activeSessionKey, value: userId);
    await _accountService.setActiveAccount(userId);

    // Update last accessed time
    final account = await _accountService.getAccountByUserId(userId);
    if (account != null) {
      account.lastAccessedAt = DateTime.now();
      await _accountService.saveAccount(account);
    }

    debugPrint('   ✅ Active account set to $userId');
  }

  /// Get currently active account's userId
  Future<String?> getActiveUserId() async {
    return await _secureStorage.read(key: _activeSessionKey);
  }

  /// Add a new account to the multi-account session
  /// Called after successful authentication
  Future<Account> addAccountSession({
    required String userId,
    required String email,
    String? displayName,
    String? photoUrl,
    required AuthProvider authProvider,
    String? refreshToken,
    String? accessToken,
    DateTime? tokenExpiresAt,
  }) async {
    debugPrint('\n🔐 [AccountSessionManager] addAccountSession($userId)');

    // Check if account already exists
    Account? account = await _accountService.getAccountByUserId(userId);

    if (account != null) {
      // Update existing account
      account.email = email;
      account.displayName = displayName ?? account.displayName;
      account.photoUrl = photoUrl ?? account.photoUrl;
      account.authProvider = authProvider;
      account.isLoggedIn = true;
      account.lastAccessedAt = DateTime.now();
      account.refreshToken = refreshToken;
      account.accessToken = accessToken;
      account.tokenExpiresAt = tokenExpiresAt;
    } else {
      // Create new account
      account = Account.create(
        userId: userId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        authProvider: authProvider,
        isActive: false,
        isLoggedIn: true,
        lastAccessedAt: DateTime.now(),
        refreshToken: refreshToken,
        accessToken: accessToken,
        tokenExpiresAt: tokenExpiresAt,
      );
    }

    await _accountService.saveAccount(account);

    // Store session securely
    await storeSession(
      userId: userId,
      refreshToken: refreshToken,
      accessToken: accessToken,
      tokenExpiresAt: tokenExpiresAt,
    );

    debugPrint('   ✅ Account session added for $userId');
    return account;
  }

  /// Remove an account from multi-account session
  /// Optionally deletes all account data
  Future<void> removeAccountSession(
    String userId, {
    bool deleteData = false,
  }) async {
    debugPrint(
      '\n🔐 [AccountSessionManager] removeAccountSession($userId, deleteData: $deleteData)',
    );

    await clearSession(userId);

    if (deleteData) {
      await _accountService.deleteAccount(userId);
      debugPrint('   🗑️ Account data deleted');
    }

    // If this was the active account, switch to another logged-in account
    final activeUserId = await getActiveUserId();
    if (activeUserId == userId) {
      final loggedInAccounts = await getLoggedInAccounts();
      if (loggedInAccounts.isNotEmpty) {
        await setActiveAccount(loggedInAccounts.first.userId);
      } else {
        await _secureStorage.delete(key: _activeSessionKey);
      }
    }

    debugPrint('   ✅ Account session removed');
  }

  /// Check if there are any logged-in accounts
  Future<bool> hasLoggedInAccounts() async {
    final accounts = await getLoggedInAccounts();
    return accounts.isNotEmpty;
  }

  /// Get the number of logged-in accounts
  Future<int> getLoggedInCount() async {
    final accounts = await getLoggedInAccounts();
    return accounts.length;
  }

  // Private helpers for managing logged-in accounts list

  Future<List<String>> _getLoggedInList() async {
    final listJson = await _secureStorage.read(key: _loggedInAccountsKey);
    if (listJson == null) return [];

    try {
      final list = jsonDecode(listJson) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> _addToLoggedInList(String userId) async {
    final list = await _getLoggedInList();
    if (!list.contains(userId)) {
      list.add(userId);
      await _secureStorage.write(
        key: _loggedInAccountsKey,
        value: jsonEncode(list),
      );
    }
  }

  Future<void> _removeFromLoggedInList(String userId) async {
    final list = await _getLoggedInList();
    list.remove(userId);
    await _secureStorage.write(
      key: _loggedInAccountsKey,
      value: jsonEncode(list),
    );
  }
}
