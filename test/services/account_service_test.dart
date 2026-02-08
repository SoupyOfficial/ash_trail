import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/account_repository.dart';
import 'package:ash_trail/repositories/log_record_repository.dart' as lr;

/// Mock AccountRepository for testing
class MockAccountRepository implements AccountRepository {
  final List<Account> _accounts = [];
  bool throwError = false;
  String? activeUserId;

  void reset() {
    _accounts.clear();
    throwError = false;
    activeUserId = null;
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
    if (activeUserId == userId) {
      activeUserId = null;
    }
  }

  @override
  Future<void> setActive(String userId) async {
    if (throwError) throw Exception('Mock error');
    for (final account in _accounts) {
      account.isActive = account.userId == userId;
    }
    activeUserId = userId;
  }

  @override
  Future<void> clearActive() async {
    if (throwError) throw Exception('Mock error');
    for (final account in _accounts) {
      account.isActive = false;
    }
    activeUserId = null;
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
}

/// Mock LogRecordService for testing account deletion
class MockLogRecordService extends LogRecordService {
  final Set<String> deletedAccountIds = {};
  bool throwError = false;

  MockLogRecordService() : super(repository: _MockLogRecordRepo());

  @override
  Future<void> deleteAllByAccount(String accountId) async {
    if (throwError) throw Exception('Mock error');
    deletedAccountIds.add(accountId);
  }

  void reset() {
    deletedAccountIds.clear();
    throwError = false;
  }
}

/// Minimal mock for LogRecordRepository
class _MockLogRecordRepo implements lr.LogRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late MockAccountRepository mockRepository;
  late MockLogRecordService mockLogRecordService;
  late AccountService accountService;

  setUp(() {
    mockRepository = MockAccountRepository();
    mockLogRecordService = MockLogRecordService();
    accountService = AccountService(
      repository: mockRepository,
      logRecordService: mockLogRecordService,
    );
  });

  tearDown(() {
    mockRepository.reset();
    mockLogRecordService.reset();
  });

  Account createAccount({
    required String userId,
    String email = 'test@example.com',
    String? displayName,
    bool isActive = false,
    bool isLoggedIn = false,
    AuthProvider authProvider = AuthProvider.email,
  }) {
    return Account.create(
      userId: userId,
      email: email,
      displayName: displayName ?? 'Test User',
      authProvider: authProvider,
      isActive: isActive,
      isLoggedIn: isLoggedIn,
    );
  }

  group('AccountService - Get Operations', () {
    test('getAllAccounts returns empty list when no accounts', () async {
      final accounts = await accountService.getAllAccounts();
      expect(accounts, isEmpty);
    });

    test('getAllAccounts returns all accounts', () async {
      await mockRepository.save(createAccount(userId: 'user-1'));
      await mockRepository.save(createAccount(userId: 'user-2'));
      await mockRepository.save(createAccount(userId: 'user-3'));

      final accounts = await accountService.getAllAccounts();

      expect(accounts.length, equals(3));
    });

    test('getActiveAccount returns null when no active account', () async {
      await mockRepository.save(createAccount(userId: 'inactive', isActive: false));

      final active = await accountService.getActiveAccount();

      expect(active, isNull);
    });

    test('getActiveAccount returns active account', () async {
      await mockRepository.save(createAccount(userId: 'inactive', isActive: false));
      await mockRepository.save(createAccount(userId: 'active', isActive: true));

      final active = await accountService.getActiveAccount();

      expect(active, isNotNull);
      expect(active!.userId, equals('active'));
    });

    test('getAccountByUserId returns null for non-existent user', () async {
      final account = await accountService.getAccountByUserId('non-existent');
      expect(account, isNull);
    });

    test('getAccountByUserId returns account when exists', () async {
      await mockRepository.save(createAccount(userId: 'target', email: 'target@test.com'));

      final account = await accountService.getAccountByUserId('target');

      expect(account, isNotNull);
      expect(account!.email, equals('target@test.com'));
    });
  });

  group('AccountService - Save Operations', () {
    test('saveAccount creates new account', () async {
      final account = createAccount(userId: 'new-user');

      final saved = await accountService.saveAccount(account);

      expect(saved.userId, equals('new-user'));
      final retrieved = await mockRepository.getByUserId('new-user');
      expect(retrieved, isNotNull);
    });

    test('saveAccount updates existing account', () async {
      final account = createAccount(userId: 'existing', displayName: 'Original');
      await accountService.saveAccount(account);

      account.displayName = 'Updated';
      await accountService.saveAccount(account);

      final retrieved = await mockRepository.getByUserId('existing');
      expect(retrieved!.displayName, equals('Updated'));
    });
  });

  group('AccountService - Active Account Management', () {
    test('setActiveAccount activates specified account', () async {
      await mockRepository.save(createAccount(userId: 'user-1', isActive: false));

      await accountService.setActiveAccount('user-1');

      final account = await mockRepository.getByUserId('user-1');
      expect(account!.isActive, isTrue);
    });

    test('setActiveAccount deactivates other accounts', () async {
      await mockRepository.save(createAccount(userId: 'was-active', isActive: true));
      await mockRepository.save(createAccount(userId: 'new-active', isActive: false));

      await accountService.setActiveAccount('new-active');

      final wasActive = await mockRepository.getByUserId('was-active');
      expect(wasActive!.isActive, isFalse);
    });

    test('deactivateAllAccounts clears all active flags', () async {
      await mockRepository.save(createAccount(userId: 'a1', isActive: true));
      await mockRepository.save(createAccount(userId: 'a2', isActive: true));

      await accountService.deactivateAllAccounts();

      final accounts = await mockRepository.getAll();
      expect(accounts.every((a) => !a.isActive), isTrue);
    });
  });

  group('AccountService - Delete Operations', () {
    test('deleteAccount removes account', () async {
      await mockRepository.save(createAccount(userId: 'to-delete'));

      await accountService.deleteAccount('to-delete');

      final account = await mockRepository.getByUserId('to-delete');
      expect(account, isNull);
    });

    test('deleteAccount deletes associated log records first', () async {
      await mockRepository.save(createAccount(userId: 'user-with-logs'));

      await accountService.deleteAccount('user-with-logs');

      expect(mockLogRecordService.deletedAccountIds, contains('user-with-logs'));
    });

    test('deleteAccount preserves other accounts', () async {
      await mockRepository.save(createAccount(userId: 'keep'));
      await mockRepository.save(createAccount(userId: 'remove'));

      await accountService.deleteAccount('remove');

      expect(await mockRepository.getByUserId('keep'), isNotNull);
    });
  });

  group('AccountService - Watch Operations', () {
    test('watchActiveAccount emits stream', () async {
      await mockRepository.save(createAccount(userId: 'active', isActive: true));

      final stream = accountService.watchActiveAccount();

      await expectLater(stream, emits(isA<Account>()));
    });

    test('watchAllAccounts emits stream', () async {
      await mockRepository.save(createAccount(userId: 'user-1'));

      final stream = accountService.watchAllAccounts();

      await expectLater(stream, emits(isA<List<Account>>()));
    });
  });

  group('AccountService - Utility Methods', () {
    test('accountExists returns true for existing account', () async {
      await mockRepository.save(createAccount(userId: 'existing'));

      final exists = await accountService.accountExists('existing');

      expect(exists, isTrue);
    });

    test('accountExists returns false for non-existent account', () async {
      final exists = await accountService.accountExists('non-existent');

      expect(exists, isFalse);
    });

    test('getAllAccountIds returns all user IDs', () async {
      await mockRepository.save(createAccount(userId: 'id-1'));
      await mockRepository.save(createAccount(userId: 'id-2'));
      await mockRepository.save(createAccount(userId: 'id-3'));

      final ids = await accountService.getAllAccountIds();

      expect(ids, containsAll(['id-1', 'id-2', 'id-3']));
      expect(ids.length, equals(3));
    });

    test('getAllAccountIds returns empty set when no accounts', () async {
      final ids = await accountService.getAllAccountIds();

      expect(ids, isEmpty);
    });
  });

  group('AccountService - Multi-Account Scenarios', () {
    test('supports multiple logged-in accounts', () async {
      await accountService.saveAccount(createAccount(
        userId: 'a1',
        isLoggedIn: true,
        isActive: true,
      ));
      await accountService.saveAccount(createAccount(
        userId: 'a2',
        isLoggedIn: true,
        isActive: false,
      ));

      final accounts = await accountService.getAllAccounts();
      final loggedIn = accounts.where((a) => a.isLoggedIn).length;

      expect(loggedIn, equals(2));
    });

    test('switching active account preserves login state', () async {
      await mockRepository.save(createAccount(
        userId: 'first',
        isActive: true,
        isLoggedIn: true,
      ));
      await mockRepository.save(createAccount(
        userId: 'second',
        isActive: false,
        isLoggedIn: true,
      ));

      await accountService.setActiveAccount('second');

      final first = await mockRepository.getByUserId('first');
      final second = await mockRepository.getByUserId('second');

      expect(first!.isLoggedIn, isTrue);
      expect(first.isActive, isFalse);
      expect(second!.isLoggedIn, isTrue);
      expect(second.isActive, isTrue);
    });
  });

  group('AccountService - Auth Provider Handling', () {
    test('handles email provider accounts', () async {
      await accountService.saveAccount(createAccount(
        userId: 'email-user',
        authProvider: AuthProvider.email,
      ));

      final account = await accountService.getAccountByUserId('email-user');
      expect(account!.authProvider, equals(AuthProvider.email));
    });

    test('handles Google provider accounts', () async {
      await accountService.saveAccount(createAccount(
        userId: 'google-user',
        authProvider: AuthProvider.gmail,
      ));

      final account = await accountService.getAccountByUserId('google-user');
      expect(account!.authProvider, equals(AuthProvider.gmail));
    });

    test('handles Apple provider accounts', () async {
      await accountService.saveAccount(createAccount(
        userId: 'apple-user',
        authProvider: AuthProvider.apple,
      ));

      final account = await accountService.getAccountByUserId('apple-user');
      expect(account!.authProvider, equals(AuthProvider.apple));
    });
  });

  group('AccountService - Edge Cases', () {
    test('handles account with all fields populated', () async {
      final account = Account.create(
        userId: 'full-account',
        email: 'full@test.com',
        displayName: 'Full User',
        firstName: 'Full',
        lastName: 'User',
        photoUrl: 'https://example.com/photo.jpg',
        authProvider: AuthProvider.gmail,
        isActive: true,
        isLoggedIn: true,
      );
      account.lastAccessedAt = DateTime.now();
      account.accessToken = 'token';
      account.refreshToken = 'refresh';

      await accountService.saveAccount(account);
      final retrieved = await accountService.getAccountByUserId('full-account');

      expect(retrieved!.displayName, equals('Full User'));
      expect(retrieved.photoUrl, equals('https://example.com/photo.jpg'));
    });

    test('handles account with minimal fields', () async {
      final account = Account.create(
        userId: 'minimal',
        email: 'minimal@test.com',
      );

      await accountService.saveAccount(account);
      final retrieved = await accountService.getAccountByUserId('minimal');

      expect(retrieved, isNotNull);
      expect(retrieved!.email, equals('minimal@test.com'));
    });

    test('delete non-existent account does not throw', () async {
      // Should not throw
      await accountService.deleteAccount('non-existent');
    });

    test('setActiveAccount with non-existent user does not throw', () async {
      // Should not throw (but won't activate anything)
      await accountService.setActiveAccount('non-existent');
    });
  });
}
