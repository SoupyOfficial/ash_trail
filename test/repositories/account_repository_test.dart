/// Unit tests for AccountRepositoryHive
/// Uses in-memory map-based mock to test repository logic
/// without actual Hive storage concerns
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/account_repository.dart';

/// In-memory implementation of AccountRepository for testing
/// Mimics AccountRepositoryHive behavior without Hive dependencies
class InMemoryAccountRepository implements AccountRepository {
  final Map<String, Account> _accounts = {};
  final _allController = StreamController<List<Account>>.broadcast();
  final _activeController = StreamController<Account?>.broadcast();

  @override
  Future<Account> save(Account account) async {
    // Store a copy to avoid mutation issues
    _accounts[account.userId] = account.copyWith();
    _notifyAll();
    _notifyActive();
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    _accounts.remove(userId);
    _notifyAll();
    _notifyActive();
  }

  @override
  Future<List<Account>> getAll() async {
    return _accounts.values.map((a) => a.copyWith()).toList();
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    final account = _accounts[userId];
    return account?.copyWith();
  }

  @override
  Future<Account?> getActive() async {
    final accounts = await getAll();
    try {
      return accounts.firstWhere((a) => a.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setActive(String userId) async {
    // Clear all active flags
    for (final key in _accounts.keys.toList()) {
      final account = _accounts[key]!;
      _accounts[key] = account.copyWith(isActive: false);
    }
    // Set the specified account as active
    if (_accounts.containsKey(userId)) {
      final account = _accounts[userId]!;
      _accounts[userId] = account.copyWith(isActive: true);
    }
    _notifyAll();
    _notifyActive();
  }

  @override
  Future<void> clearActive() async {
    for (final key in _accounts.keys.toList()) {
      final account = _accounts[key]!;
      _accounts[key] = account.copyWith(isActive: false);
    }
    _notifyAll();
    _notifyActive();
  }

  @override
  Stream<List<Account>> watchAll() => _allController.stream;

  @override
  Stream<Account?> watchActive() => _activeController.stream;

  void _notifyAll() async {
    _allController.add(await getAll());
  }

  void _notifyActive() async {
    _activeController.add(await getActive());
  }

  void dispose() {
    _allController.close();
    _activeController.close();
  }
}

void main() {
  late InMemoryAccountRepository repository;

  Account _createTestAccount({
    required String userId,
    String email = 'test@example.com',
    String? displayName,
    AuthProvider authProvider = AuthProvider.email,
    bool isActive = false,
    bool isLoggedIn = false,
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

  setUp(() {
    repository = InMemoryAccountRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('AccountRepository - CRUD Operations', () {
    test('save() creates new account', () async {
      final account = _createTestAccount(userId: 'user-1');

      final saved = await repository.save(account);

      expect(saved.userId, equals('user-1'));
      expect(saved.email, equals('test@example.com'));
    });

    test('save() updates existing account', () async {
      final account = _createTestAccount(userId: 'user-1', displayName: 'Original');
      await repository.save(account);

      account.displayName = 'Updated';
      final updated = await repository.save(account);

      expect(updated.displayName, equals('Updated'));
      final retrieved = await repository.getByUserId('user-1');
      expect(retrieved?.displayName, equals('Updated'));
    });

    test('getAll() returns empty list when no accounts', () async {
      final accounts = await repository.getAll();

      expect(accounts, isEmpty);
    });

    test('getAll() returns all saved accounts', () async {
      await repository.save(_createTestAccount(userId: 'user-1', email: 'one@test.com'));
      await repository.save(_createTestAccount(userId: 'user-2', email: 'two@test.com'));
      await repository.save(_createTestAccount(userId: 'user-3', email: 'three@test.com'));

      final accounts = await repository.getAll();

      expect(accounts.length, equals(3));
    });

    test('getByUserId() returns null for non-existent user', () async {
      final result = await repository.getByUserId('non-existent');

      expect(result, isNull);
    });

    test('getByUserId() returns correct account', () async {
      await repository.save(_createTestAccount(userId: 'user-1', email: 'one@test.com'));
      await repository.save(_createTestAccount(userId: 'user-2', email: 'two@test.com'));

      final result = await repository.getByUserId('user-2');

      expect(result, isNotNull);
      expect(result!.email, equals('two@test.com'));
    });

    test('delete() removes account', () async {
      await repository.save(_createTestAccount(userId: 'user-1'));
      await repository.save(_createTestAccount(userId: 'user-2'));

      await repository.delete('user-1');

      final accounts = await repository.getAll();
      expect(accounts.length, equals(1));
      expect(accounts.first.userId, equals('user-2'));
    });

    test('delete() clears active status when deleting active account', () async {
      final account = _createTestAccount(userId: 'user-1', isActive: true);
      await repository.save(account);
      await repository.setActive('user-1');

      await repository.delete('user-1');

      final active = await repository.getActive();
      expect(active, isNull);
    });
  });

  group('AccountRepository - Active Account Operations', () {
    test('setActive() sets account as active', () async {
      await repository.save(_createTestAccount(userId: 'user-1'));

      await repository.setActive('user-1');

      final active = await repository.getActive();
      expect(active, isNotNull);
      expect(active!.userId, equals('user-1'));
      expect(active.isActive, isTrue);
    });

    test('setActive() deactivates previous active account', () async {
      final user1 = _createTestAccount(userId: 'user-1', isActive: true);
      final user2 = _createTestAccount(userId: 'user-2');
      await repository.save(user1);
      await repository.setActive('user-1');
      await repository.save(user2);

      await repository.setActive('user-2');

      final retrievedUser1 = await repository.getByUserId('user-1');
      final retrievedUser2 = await repository.getByUserId('user-2');
      expect(retrievedUser1!.isActive, isFalse);
      expect(retrievedUser2!.isActive, isTrue);
    });

    test('getActive() returns null when no active account', () async {
      await repository.save(_createTestAccount(userId: 'user-1', isActive: false));

      final active = await repository.getActive();

      expect(active, isNull);
    });

    test('clearActive() deactivates all accounts', () async {
      final user1 = _createTestAccount(userId: 'user-1', isActive: true);
      final user2 = _createTestAccount(userId: 'user-2', isActive: true);
      await repository.save(user1);
      await repository.save(user2);
      await repository.setActive('user-1');

      await repository.clearActive();

      final all = await repository.getAll();
      expect(all.every((a) => !a.isActive), isTrue);
    });
  });

  group('AccountRepository - Auth Provider Filtering', () {
    test('saves and retrieves accounts with gmail provider', () async {
      final account = _createTestAccount(
        userId: 'google-user',
        authProvider: AuthProvider.gmail,
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('google-user');
      expect(retrieved?.authProvider, equals(AuthProvider.gmail));
    });

    test('saves and retrieves accounts with apple provider', () async {
      final account = _createTestAccount(
        userId: 'apple-user',
        authProvider: AuthProvider.apple,
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('apple-user');
      expect(retrieved?.authProvider, equals(AuthProvider.apple));
    });

    test('saves and retrieves accounts with email provider', () async {
      final account = _createTestAccount(
        userId: 'email-user',
        authProvider: AuthProvider.email,
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('email-user');
      expect(retrieved?.authProvider, equals(AuthProvider.email));
    });
  });

  group('AccountRepository - Login State', () {
    test('tracks logged in status', () async {
      final account = _createTestAccount(userId: 'user-1', isLoggedIn: true);
      await repository.save(account);

      final retrieved = await repository.getByUserId('user-1');
      expect(retrieved!.isLoggedIn, isTrue);
    });

    test('updates login status', () async {
      final account = _createTestAccount(userId: 'user-1', isLoggedIn: false);
      await repository.save(account);

      account.isLoggedIn = true;
      await repository.save(account);

      final retrieved = await repository.getByUserId('user-1');
      expect(retrieved!.isLoggedIn, isTrue);
    });
  });

  group('AccountRepository - Reactive Streams', () {
    test('watchAll() emits updates on save', () async {
      final stream = repository.watchAll();
      final emittedLists = <List<Account>>[];
      final subscription = stream.listen((accounts) {
        emittedLists.add(accounts);
      });

      await Future.delayed(const Duration(milliseconds: 10));
      await repository.save(_createTestAccount(userId: 'user-1'));
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();

      expect(emittedLists.isNotEmpty, isTrue);
      expect(emittedLists.last.length, equals(1));
    });

    test('watchActive() emits updates when active changes', () async {
      final stream = repository.watchActive();
      final emittedAccounts = <Account?>[];
      final subscription = stream.listen((account) {
        emittedAccounts.add(account);
      });

      await Future.delayed(const Duration(milliseconds: 10));
      await repository.save(_createTestAccount(userId: 'user-1'));
      await repository.setActive('user-1');
      await Future.delayed(const Duration(milliseconds: 10));

      await subscription.cancel();

      expect(emittedAccounts.isNotEmpty, isTrue);
    });
  });

  group('AccountRepository - Edge Cases', () {
    test('handles account with all optional fields populated', () async {
      final account = Account.create(
        userId: 'full-user',
        email: 'full@test.com',
        displayName: 'Full User',
        authProvider: AuthProvider.gmail,
        isActive: true,
        isLoggedIn: true,
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('full-user');
      expect(retrieved, isNotNull);
      expect(retrieved!.email, equals('full@test.com'));
      expect(retrieved.displayName, equals('Full User'));
      expect(retrieved.authProvider, equals(AuthProvider.gmail));
      expect(retrieved.isLoggedIn, isTrue);
    });

    test('handles special characters in email', () async {
      final account = _createTestAccount(
        userId: 'special-user',
        email: 'test+tag@sub.example.com',
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('special-user');
      expect(retrieved!.email, equals('test+tag@sub.example.com'));
    });

    test('handles unicode in display name', () async {
      final account = _createTestAccount(
        userId: 'unicode-user',
        displayName: '日本語ユーザー 🎉',
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('unicode-user');
      expect(retrieved!.displayName, equals('日本語ユーザー 🎉'));
    });

    test('handles empty display name', () async {
      final account = _createTestAccount(
        userId: 'empty-name',
        displayName: '',
      );
      await repository.save(account);

      final retrieved = await repository.getByUserId('empty-name');
      expect(retrieved!.displayName, equals(''));
    });

    test('setActive with non-existent userId does not throw', () async {
      await repository.save(_createTestAccount(userId: 'existing', isActive: false));

      // Should not throw
      await repository.setActive('non-existent');

      // Existing should remain unchanged
      final existing = await repository.getByUserId('existing');
      expect(existing!.isActive, isFalse);
    });

    test('delete non-existent userId does not throw', () async {
      // Should not throw
      await repository.delete('non-existent');
    });
  });

  group('AccountRepository - Multi-Account Scenarios', () {
    test('supports multiple logged-in accounts', () async {
      await repository.save(_createTestAccount(userId: 'account-1', isLoggedIn: true));
      await repository.setActive('account-1');
      await repository.save(_createTestAccount(userId: 'account-2', isLoggedIn: true));
      await repository.save(_createTestAccount(userId: 'account-3', isLoggedIn: true));

      final accounts = await repository.getAll();
      final loggedIn = accounts.where((a) => a.isLoggedIn).length;

      expect(loggedIn, equals(3));
    });

    test('only one account can be active at a time', () async {
      await repository.save(_createTestAccount(userId: 'a1'));
      await repository.save(_createTestAccount(userId: 'a2'));
      await repository.save(_createTestAccount(userId: 'a3'));

      await repository.setActive('a2');

      final all = await repository.getAll();
      final activeCount = all.where((a) => a.isActive).length;

      expect(activeCount, equals(1));
    });

    test('switching accounts preserves login state', () async {
      final logged1 = _createTestAccount(userId: 'logged-1', isLoggedIn: true);
      final logged2 = _createTestAccount(userId: 'logged-2', isLoggedIn: true);
      await repository.save(logged1);
      await repository.setActive('logged-1');
      await repository.save(logged2);

      await repository.setActive('logged-2');

      final user1 = await repository.getByUserId('logged-1');
      final user2 = await repository.getByUserId('logged-2');

      expect(user1!.isLoggedIn, isTrue);
      expect(user1.isActive, isFalse);
      expect(user2!.isLoggedIn, isTrue);
      expect(user2.isActive, isTrue);
    });
  });
}
