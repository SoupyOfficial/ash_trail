import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ash_trail/services/account_session_manager.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/account_repository.dart';
import 'dart:convert';

/// Mock FlutterSecureStorage for testing
class MockSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _storage = {};
  bool throwError = false;

  void reset() {
    _storage.clear();
    throwError = false;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    return _storage[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    _storage.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    return Map.from(_storage);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    _storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwError) throw Exception('Mock storage error');
    return _storage.containsKey(key);
  }

  // Helper to access storage for testing
  Map<String, String> get storage => _storage;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

/// Mock AccountRepository for testing
class MockAccountRepository implements AccountRepository {
  final List<Account> _accounts = [];
  bool throwError = false;

  void reset() {
    _accounts.clear();
    throwError = false;
  }

  @override
  Future<List<Account>> getAll() async {
    if (throwError) throw Exception('Mock error');
    return List.from(_accounts);
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    if (throwError) throw Exception('Mock error');
    try {
      return _accounts.firstWhere((a) => a.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Account?> getActive() async {
    if (throwError) throw Exception('Mock error');
    try {
      return _accounts.firstWhere((a) => a.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Account> save(Account account) async {
    if (throwError) throw Exception('Mock error');
    final index = _accounts.indexWhere((a) => a.userId == account.userId);
    if (index >= 0) {
      _accounts[index] = account;
    } else {
      _accounts.add(account);
    }
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    if (throwError) throw Exception('Mock error');
    _accounts.removeWhere((a) => a.userId == userId);
  }

  @override
  Future<void> setActive(String userId) async {
    if (throwError) throw Exception('Mock error');
    for (final account in _accounts) {
      account.isActive = account.userId == userId;
    }
  }

  @override
  Future<void> clearActive() async {
    if (throwError) throw Exception('Mock error');
    for (final account in _accounts) {
      account.isActive = false;
    }
  }

  @override
  Stream<Account?> watchActive() {
    return Stream.value(_accounts.cast<Account?>().firstWhere(
      (a) => a?.isActive == true,
      orElse: () => null,
    ));
  }

  @override
  Stream<List<Account>> watchAll() {
    return Stream.value(List.from(_accounts));
  }

  // Helper to add account directly for testing setup
  void addAccount(Account account) {
    _accounts.add(account);
  }
}

/// Mock LogRecordService for testing
class MockLogRecordService implements LogRecordService {
  final Set<String> deletedAccountIds = {};
  
  @override
  Future<void> deleteAllByAccount(String accountId) async {
    deletedAccountIds.add(accountId);
  }

  void reset() {
    deletedAccountIds.clear();
  }
  
  // Implement all other methods as stubs
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockSecureStorage mockStorage;
  late MockAccountRepository mockRepository;
  late MockLogRecordService mockLogRecordService;
  late AccountService accountService;
  late AccountSessionManager sessionManager;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockRepository = MockAccountRepository();
    mockLogRecordService = MockLogRecordService();
    accountService = AccountService(
      repository: mockRepository,
      logRecordService: mockLogRecordService,
    );
    sessionManager = AccountSessionManager(
      accountService: accountService,
      secureStorage: mockStorage,
    );
  });

  tearDown(() {
    mockStorage.reset();
    mockRepository.reset();
    mockLogRecordService.reset();
  });

  Account _createAccount({
    required String userId,
    String email = 'test@example.com',
    bool isActive = false,
    bool isLoggedIn = false,
    AuthProvider authProvider = AuthProvider.email,
  }) {
    return Account.create(
      userId: userId,
      email: email,
      authProvider: authProvider,
      isActive: isActive,
      isLoggedIn: isLoggedIn,
    );
  }

  group('AccountSessionManager - Session Storage', () {
    test('storeSession stores session data in secure storage', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1'));

      await sessionManager.storeSession(
        userId: 'user-1',
        refreshToken: 'refresh-token',
        accessToken: 'access-token',
        tokenExpiresAt: DateTime(2024, 12, 31),
      );

      final sessionJson = mockStorage.storage['session_user-1'];
      expect(sessionJson, isNotNull);
      final session = jsonDecode(sessionJson!);
      expect(session['userId'], equals('user-1'));
      expect(session['refreshToken'], equals('refresh-token'));
      expect(session['accessToken'], equals('access-token'));
    });

    test('storeSession updates account isLoggedIn state', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: false));

      await sessionManager.storeSession(
        userId: 'user-1',
        refreshToken: 'token',
        accessToken: 'access',
      );

      final account = await mockRepository.getByUserId('user-1');
      expect(account!.isLoggedIn, isTrue);
    });

    test('getSession returns stored session', () async {
      mockStorage.storage['session_user-1'] = jsonEncode({
        'userId': 'user-1',
        'refreshToken': 'stored-refresh',
        'accessToken': 'stored-access',
      });

      final session = await sessionManager.getSession('user-1');

      expect(session, isNotNull);
      expect(session!['refreshToken'], equals('stored-refresh'));
    });

    test('getSession returns null for non-existent session', () async {
      final session = await sessionManager.getSession('non-existent');
      expect(session, isNull);
    });

    test('getSession handles malformed JSON gracefully', () async {
      mockStorage.storage['session_bad'] = 'not valid json{';

      final session = await sessionManager.getSession('bad');

      expect(session, isNull);
    });
  });

  group('AccountSessionManager - Custom Token Management', () {
    test('storeCustomToken stores token with timestamp', () async {
      await sessionManager.storeCustomToken('user-1', 'custom-token-value');

      expect(mockStorage.storage['custom_token_user-1'], equals('custom-token-value'));
      expect(mockStorage.storage['custom_token_timestamp_user-1'], isNotNull);
    });

    test('getValidCustomToken returns token when valid', () async {
      // Store token with current timestamp
      mockStorage.storage['custom_token_user-1'] = 'valid-token';
      mockStorage.storage['custom_token_timestamp_user-1'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      final token = await sessionManager.getValidCustomToken('user-1');

      expect(token, equals('valid-token'));
    });

    test('getValidCustomToken returns null for expired token', () async {
      // Store token with old timestamp (48+ hours ago)
      mockStorage.storage['custom_token_user-1'] = 'expired-token';
      final oldTimestamp = DateTime.now()
          .subtract(const Duration(hours: 50))
          .millisecondsSinceEpoch;
      mockStorage.storage['custom_token_timestamp_user-1'] = oldTimestamp.toString();

      final token = await sessionManager.getValidCustomToken('user-1');

      expect(token, isNull);
      // Should also remove the expired token
      expect(mockStorage.storage['custom_token_user-1'], isNull);
    });

    test('getValidCustomToken returns null when no token exists', () async {
      final token = await sessionManager.getValidCustomToken('non-existent');
      expect(token, isNull);
    });

    test('getValidCustomToken returns null when no timestamp exists', () async {
      mockStorage.storage['custom_token_user-1'] = 'token-without-timestamp';
      // No timestamp stored

      final token = await sessionManager.getValidCustomToken('user-1');

      expect(token, isNull);
    });

    test('removeCustomToken removes token and timestamp', () async {
      mockStorage.storage['custom_token_user-1'] = 'token';
      mockStorage.storage['custom_token_timestamp_user-1'] = '12345';

      await sessionManager.removeCustomToken('user-1');

      expect(mockStorage.storage['custom_token_user-1'], isNull);
      expect(mockStorage.storage['custom_token_timestamp_user-1'], isNull);
    });

    test('hasValidCustomToken returns true for valid token', () async {
      mockStorage.storage['custom_token_user-1'] = 'valid';
      mockStorage.storage['custom_token_timestamp_user-1'] =
          DateTime.now().millisecondsSinceEpoch.toString();

      final hasToken = await sessionManager.hasValidCustomToken('user-1');

      expect(hasToken, isTrue);
    });

    test('hasValidCustomToken returns false for no token', () async {
      final hasToken = await sessionManager.hasValidCustomToken('non-existent');
      expect(hasToken, isFalse);
    });
  });

  group('AccountSessionManager - Session Clearing', () {
    test('clearSession removes session data', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: true));
      mockStorage.storage['session_user-1'] = jsonEncode({'userId': 'user-1'});
      mockStorage.storage['custom_token_user-1'] = 'token';
      mockStorage.storage['logged_in_accounts'] = jsonEncode(['user-1']);

      await sessionManager.clearSession('user-1');

      expect(mockStorage.storage['session_user-1'], isNull);
      expect(mockStorage.storage['custom_token_user-1'], isNull);
    });

    test('clearSession updates account state', () async {
      final account = _createAccount(userId: 'user-1', isLoggedIn: true);
      account.refreshToken = 'token';
      account.accessToken = 'access';
      mockRepository.addAccount(account);

      await sessionManager.clearSession('user-1');

      final updated = await mockRepository.getByUserId('user-1');
      expect(updated!.isLoggedIn, isFalse);
      expect(updated.refreshToken, isNull);
      expect(updated.accessToken, isNull);
    });

    test('clearAllSessions clears all logged-in accounts', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: true));
      mockRepository.addAccount(_createAccount(userId: 'user-2', isLoggedIn: true));
      mockStorage.storage['logged_in_accounts'] = jsonEncode(['user-1', 'user-2']);
      mockStorage.storage['session_user-1'] = jsonEncode({'userId': 'user-1'});
      mockStorage.storage['session_user-2'] = jsonEncode({'userId': 'user-2'});

      await sessionManager.clearAllSessions();

      expect(mockStorage.storage['session_user-1'], isNull);
      expect(mockStorage.storage['session_user-2'], isNull);
      expect(mockStorage.storage['logged_in_accounts'], isNull);
      expect(mockStorage.storage['active_session_user_id'], isNull);
    });
  });

  group('AccountSessionManager - Active Account Management', () {
    test('setActiveAccount stores active user ID', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1'));

      await sessionManager.setActiveAccount('user-1');

      expect(mockStorage.storage['active_session_user_id'], equals('user-1'));
    });

    test('setActiveAccount updates lastAccessedAt', () async {
      final account = _createAccount(userId: 'user-1');
      mockRepository.addAccount(account);
      final beforeSet = DateTime.now();

      await Future.delayed(const Duration(milliseconds: 10));
      await sessionManager.setActiveAccount('user-1');

      final updated = await mockRepository.getByUserId('user-1');
      expect(updated!.lastAccessedAt, isNotNull);
      expect(updated.lastAccessedAt!.isAfter(beforeSet), isTrue);
    });

    test('getActiveUserId returns stored active user', () async {
      mockStorage.storage['active_session_user_id'] = 'active-user';

      final userId = await sessionManager.getActiveUserId();

      expect(userId, equals('active-user'));
    });

    test('getActiveUserId returns null when no active user', () async {
      final userId = await sessionManager.getActiveUserId();
      expect(userId, isNull);
    });
  });

  group('AccountSessionManager - Logged-in Accounts', () {
    test('getLoggedInAccounts returns accounts with isLoggedIn true', () async {
      mockRepository.addAccount(_createAccount(
        userId: 'logged-in-1',
        isLoggedIn: true,
      ));
      mockRepository.addAccount(_createAccount(
        userId: 'logged-in-2',
        isLoggedIn: true,
      ));
      mockRepository.addAccount(_createAccount(
        userId: 'logged-out',
        isLoggedIn: false,
      ));

      final loggedIn = await sessionManager.getLoggedInAccounts();

      expect(loggedIn.length, equals(2));
      expect(loggedIn.every((a) => a.isLoggedIn), isTrue);
    });

    test('getLoggedInAccounts returns empty when none logged in', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: false));

      final loggedIn = await sessionManager.getLoggedInAccounts();

      expect(loggedIn, isEmpty);
    });

    test('hasLoggedInAccounts returns true when accounts logged in', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: true));

      final hasAccounts = await sessionManager.hasLoggedInAccounts();

      expect(hasAccounts, isTrue);
    });

    test('hasLoggedInAccounts returns false when none logged in', () async {
      final hasAccounts = await sessionManager.hasLoggedInAccounts();
      expect(hasAccounts, isFalse);
    });

    test('getLoggedInCount returns correct count', () async {
      mockRepository.addAccount(_createAccount(userId: 'u1', isLoggedIn: true));
      mockRepository.addAccount(_createAccount(userId: 'u2', isLoggedIn: true));
      mockRepository.addAccount(_createAccount(userId: 'u3', isLoggedIn: false));

      final count = await sessionManager.getLoggedInCount();

      expect(count, equals(2));
    });
  });

  group('AccountSessionManager - Add Account Session', () {
    test('addAccountSession creates new account when not exists', () async {
      final account = await sessionManager.addAccountSession(
        userId: 'new-user',
        email: 'new@test.com',
        displayName: 'New User',
        authProvider: AuthProvider.gmail,
        refreshToken: 'refresh',
        accessToken: 'access',
      );

      expect(account.userId, equals('new-user'));
      expect(account.email, equals('new@test.com'));
      expect(account.isLoggedIn, isTrue);

      final saved = await mockRepository.getByUserId('new-user');
      expect(saved, isNotNull);
    });

    test('addAccountSession updates existing account', () async {
      mockRepository.addAccount(_createAccount(
        userId: 'existing',
        email: 'old@test.com',
        isLoggedIn: false,
      ));

      await sessionManager.addAccountSession(
        userId: 'existing',
        email: 'new@test.com',
        displayName: 'Updated Name',
        authProvider: AuthProvider.gmail,
      );

      final updated = await mockRepository.getByUserId('existing');
      expect(updated!.email, equals('new@test.com'));
      expect(updated.displayName, equals('Updated Name'));
      expect(updated.isLoggedIn, isTrue);
    });

    test('addAccountSession stores session credentials', () async {
      await sessionManager.addAccountSession(
        userId: 'user-1',
        email: 'test@test.com',
        authProvider: AuthProvider.email,
        refreshToken: 'session-refresh',
        accessToken: 'session-access',
      );

      final sessionJson = mockStorage.storage['session_user-1'];
      expect(sessionJson, isNotNull);
      final session = jsonDecode(sessionJson!);
      expect(session['refreshToken'], equals('session-refresh'));
    });
  });

  group('AccountSessionManager - Remove Account Session', () {
    test('removeAccountSession clears session without deleting data', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: true));
      mockStorage.storage['session_user-1'] = jsonEncode({'userId': 'user-1'});
      mockStorage.storage['logged_in_accounts'] = jsonEncode(['user-1']);

      await sessionManager.removeAccountSession('user-1', deleteData: false);

      // Account should still exist but session cleared
      final account = await mockRepository.getByUserId('user-1');
      expect(account, isNotNull);
      expect(account!.isLoggedIn, isFalse);
      expect(mockStorage.storage['session_user-1'], isNull);
    });

    test('removeAccountSession with deleteData removes account', () async {
      mockRepository.addAccount(_createAccount(userId: 'user-1', isLoggedIn: true));
      mockStorage.storage['active_session_user_id'] = 'user-1';

      await sessionManager.removeAccountSession('user-1', deleteData: true);

      final account = await mockRepository.getByUserId('user-1');
      expect(account, isNull);
    });

    test('removeAccountSession switches active account when removing active', () async {
      mockRepository.addAccount(_createAccount(userId: 'active', isLoggedIn: true, isActive: true));
      mockRepository.addAccount(_createAccount(userId: 'other', isLoggedIn: true, isActive: false));
      mockStorage.storage['active_session_user_id'] = 'active';
      mockStorage.storage['logged_in_accounts'] = jsonEncode(['active', 'other']);

      await sessionManager.removeAccountSession('active');

      // Should switch to 'other' as active
      final activeUserId = await sessionManager.getActiveUserId();
      expect(activeUserId, equals('other'));
    });
  });

  group('AccountSessionManager - Edge Cases', () {
    test('handles storage errors gracefully for storeCustomToken', () async {
      mockStorage.throwError = true;

      expect(
        () => sessionManager.storeCustomToken('user-1', 'token'),
        throwsException,
      );
    });

    test('handles empty logged-in list', () async {
      mockStorage.storage['logged_in_accounts'] = jsonEncode([]);

      final accounts = await sessionManager.getLoggedInAccounts();
      expect(accounts, isEmpty);
    });

    test('handles malformed logged-in list JSON', () async {
      mockStorage.storage['logged_in_accounts'] = 'not valid json';

      // Should not throw, just return empty
      await sessionManager.clearAllSessions();
      // Test passes if no exception thrown
    });

    test('getValidCustomToken handles parse errors', () async {
      mockStorage.storage['custom_token_user-1'] = 'token';
      mockStorage.storage['custom_token_timestamp_user-1'] = 'not-a-number';

      // Should handle gracefully
      final token = await sessionManager.getValidCustomToken('user-1');
      expect(token, isNull);
    });
  });

  group('AccountSessionManager - Multi-Account Scenarios', () {
    test('supports multiple logged-in accounts simultaneously', () async {
      await sessionManager.addAccountSession(
        userId: 'account-1',
        email: 'a1@test.com',
        authProvider: AuthProvider.gmail,
      );
      await sessionManager.addAccountSession(
        userId: 'account-2',
        email: 'a2@test.com',
        authProvider: AuthProvider.apple,
      );
      await sessionManager.addAccountSession(
        userId: 'account-3',
        email: 'a3@test.com',
        authProvider: AuthProvider.email,
      );

      final loggedIn = await sessionManager.getLoggedInAccounts();
      expect(loggedIn.length, equals(3));
    });

    test('switching accounts preserves other sessions', () async {
      mockRepository.addAccount(_createAccount(userId: 'a1', isLoggedIn: true));
      mockRepository.addAccount(_createAccount(userId: 'a2', isLoggedIn: true));
      mockStorage.storage['session_a1'] = jsonEncode({'userId': 'a1'});
      mockStorage.storage['session_a2'] = jsonEncode({'userId': 'a2'});

      await sessionManager.setActiveAccount('a2');

      expect(mockStorage.storage['session_a1'], isNotNull);
      expect(mockStorage.storage['session_a2'], isNotNull);
      final a1 = await mockRepository.getByUserId('a1');
      expect(a1!.isLoggedIn, isTrue);
    });

    test('clearing one session does not affect others', () async {
      mockRepository.addAccount(_createAccount(userId: 'keep', isLoggedIn: true));
      mockRepository.addAccount(_createAccount(userId: 'clear', isLoggedIn: true));
      mockStorage.storage['session_keep'] = jsonEncode({'userId': 'keep'});
      mockStorage.storage['session_clear'] = jsonEncode({'userId': 'clear'});
      mockStorage.storage['logged_in_accounts'] = jsonEncode(['keep', 'clear']);

      await sessionManager.clearSession('clear');

      expect(mockStorage.storage['session_keep'], isNotNull);
      final keepAccount = await mockRepository.getByUserId('keep');
      expect(keepAccount!.isLoggedIn, isTrue);
    });
  });
}
