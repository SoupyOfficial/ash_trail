import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/app_logger.dart';
import 'dart:convert';
import '../models/account.dart';
import '../models/enums.dart';
import 'account_service.dart';

/// Manages multiple authenticated sessions for multi-account support.
///
/// Firebase Auth only supports one active user at a time, so this service:
/// 1. Stores custom Firebase tokens for each logged-in account securely
/// 2. Tracks which accounts have valid sessions
/// 3. Enables seamless switching between accounts using signInWithCustomToken()
///
/// Custom tokens are generated via a Cloud Function and are valid for 48 hours.
/// When switching accounts, we use the stored custom token to instantly
/// authenticate as that user without requiring any user interaction.
///
/// Data isolation is maintained by:
/// - All data queries filter by the active account's userId
/// - Each account's data syncs independently to Firestore
/// - Switching accounts changes both the displayed data AND the Firebase Auth user
class AccountSessionManager {
  static final _log = AppLogger.logger('AccountSessionManager');
  final FlutterSecureStorage _secureStorage;
  final AccountService _accountService;

  /// Create an AccountSessionManager with the given dependencies.
  AccountSessionManager({
    required AccountService accountService,
    FlutterSecureStorage? secureStorage,
  }) : _accountService = accountService,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // Storage keys
  static const String _sessionPrefix = 'session_';
  static const String _activeSessionKey = 'active_session_user_id';
  static const String _loggedInAccountsKey = 'logged_in_accounts';
  
  // Custom token storage keys (for seamless multi-account switching)
  static const String _customTokenPrefix = 'custom_token_';
  static const String _customTokenTimestampPrefix = 'custom_token_timestamp_';

  /// Get list of all accounts that have active sessions (logged in)
  Future<List<Account>> getLoggedInAccounts() async {
    _log.d('getLoggedInAccounts()');
    final allAccounts = await _accountService.getAllAccounts();
    final loggedInAccounts = allAccounts.where((a) => a.isLoggedIn).toList();
    _log.d('Found ${loggedInAccounts.length} logged-in accounts');
    return loggedInAccounts;
  }

  /// Store session credentials for an account
  Future<void> storeSession({
    required String userId,
    required String? refreshToken,
    required String? accessToken,
    DateTime? tokenExpiresAt,
  }) async {
    _log.d('storeSession($userId)');

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

    _log.i('Session stored for $userId');
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
      _log.e('Failed to decode session', error: e);
      return null;
    }
  }

  // ============================================
  // Custom Token Management (for seamless switching)
  // ============================================

  /// Store a custom Firebase token for an account.
  ///
  /// Custom tokens enable seamless account switching without user interaction.
  /// They are valid for 48 hours from the time they were generated.
  Future<void> storeCustomToken(String uid, String customToken) async {
    try {
      _log.d('Storing custom token for $uid');

      // Store the custom token
      await _secureStorage.write(
        key: '$_customTokenPrefix$uid',
        value: customToken,
      );

      // Store the timestamp when this token was received
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(
        key: '$_customTokenTimestampPrefix$uid',
        value: timestamp,
      );

      _log.i('Custom token stored for $uid');
    } catch (e) {
      _log.e('Error storing custom token', error: e);
      rethrow;
    }
  }

  /// Retrieve a valid (non-expired) custom token for an account.
  ///
  /// Returns null if:
  /// - No token is stored for this user
  /// - The token has expired (older than 47 hours - 1 hour buffer before 48hr expiry)
  ///
  /// If the token is expired, it will be automatically removed from storage.
  Future<String?> getValidCustomToken(String uid) async {
    try {
      // Get the token
      final customToken = await _secureStorage.read(
        key: '$_customTokenPrefix$uid',
      );
      if (customToken == null) {
        _log.d('No custom token found for $uid');
        return null;
      }

      // Get the timestamp
      final timestampStr = await _secureStorage.read(
        key: '$_customTokenTimestampPrefix$uid',
      );
      if (timestampStr == null) {
        _log.d('No timestamp found for custom token $uid');
        return null;
      }

      // Check if token is still valid (within 47 hours to have buffer time)
      final timestamp = int.parse(timestampStr);
      final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      const maxAge = 47 * 60 * 60 * 1000; // 47 hours in milliseconds

      if (tokenAge > maxAge) {
        final ageHours = tokenAge / 3600000;
        _log.w('Custom token for $uid has expired (age: ${ageHours.toStringAsFixed(1)} hours)');
        // Remove expired token
        await removeCustomToken(uid);
        return null;
      }

      final ageHours = tokenAge / 3600000;
      _log.d('Retrieved valid custom token for $uid (age: ${ageHours.toStringAsFixed(1)} hours)');
      return customToken;
    } catch (e) {
      _log.e('Error retrieving custom token', error: e);
      return null;
    }
  }

  /// Remove custom token for an account.
  ///
  /// Called when:
  /// - Token has expired
  /// - User explicitly signs out of an account
  /// - Account is deleted
  Future<void> removeCustomToken(String uid) async {
    try {
      await _secureStorage.delete(key: '$_customTokenPrefix$uid');
      await _secureStorage.delete(key: '$_customTokenTimestampPrefix$uid');
      _log.i('Removed custom token for $uid');
    } catch (e) {
      _log.e('Error removing custom token', error: e);
    }
  }

  /// Check if a valid custom token exists for an account.
  Future<bool> hasValidCustomToken(String uid) async {
    final token = await getValidCustomToken(uid);
    return token != null;
  }

  /// Clear session for a specific account (sign out single account)
  Future<void> clearSession(String userId) async {
    _log.d('clearSession($userId)');

    await _secureStorage.delete(key: '$_sessionPrefix$userId');
    
    // Also remove custom token for this account
    await removeCustomToken(userId);

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

    _log.i('Session cleared for $userId');
  }

  /// Clear all sessions (sign out all accounts)
  Future<void> clearAllSessions() async {
    _log.d('clearAllSessions()');

    final loggedInUserIds = await _getLoggedInList();
    for (final userId in loggedInUserIds) {
      await _secureStorage.delete(key: '$_sessionPrefix$userId');
      
      // Also remove custom tokens
      await removeCustomToken(userId);

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

    _log.i('All sessions cleared');
  }

  /// Set the active account for data viewing
  /// This doesn't change Firebase auth state, just which account's data we show
  Future<void> setActiveAccount(String userId) async {
    _log.d('setActiveAccount($userId)');

    await _secureStorage.write(key: _activeSessionKey, value: userId);
    await _accountService.setActiveAccount(userId);

    // Update last accessed time
    final account = await _accountService.getAccountByUserId(userId);
    if (account != null) {
      account.lastAccessedAt = DateTime.now();
      await _accountService.saveAccount(account);
    }

    _log.i('Active account set to $userId');
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
    _log.d('addAccountSession($userId)');

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

    _log.i('Account session added for $userId');
    return account;
  }

  /// Remove an account from multi-account session
  /// Optionally deletes all account data
  Future<void> removeAccountSession(
    String userId, {
    bool deleteData = false,
  }) async {
    _log.d('removeAccountSession($userId, deleteData: $deleteData)');

    await clearSession(userId);

    if (deleteData) {
      await _accountService.deleteAccount(userId);
      _log.i('Account data deleted');
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

    _log.i('Account session removed');
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
