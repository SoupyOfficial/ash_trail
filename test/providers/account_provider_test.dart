import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/firebase_options.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/account_session_manager.dart';
import 'package:ash_trail/services/token_service.dart';

/// Mock AccountSessionManager for testing
class MockAccountSessionManager implements AccountSessionManager {
  final List<Account> _loggedInAccounts = [];
  bool hasSessionsStored = false;
  String? _activeUserId;
  AccountService? _accountService; // Optional reference to mock account service
  bool throwOnSetActive = false; // For testing error handling

  void setAccountService(AccountService service) {
    _accountService = service;
  }

  void setLoggedInAccounts(List<Account> accounts) {
    _loggedInAccounts.clear();
    _loggedInAccounts.addAll(accounts);
  }

  @override
  Future<List<Account>> getLoggedInAccounts() async => _loggedInAccounts;

  @override
  Future<bool> hasLoggedInAccounts() async => _loggedInAccounts.isNotEmpty;

  @override
  Future<void> storeSession({
    required String userId,
    required String? refreshToken,
    required String? accessToken,
    DateTime? tokenExpiresAt,
  }) async {
    hasSessionsStored = true;
  }

  @override
  Future<void> clearSession(String userId) async {
    _loggedInAccounts.removeWhere((a) => a.userId == userId);
  }

  @override
  Future<void> clearAllSessions() async {
    _loggedInAccounts.clear();
    hasSessionsStored = false;
  }

  @override
  Future<void> setActiveAccount(String userId) async {
    if (throwOnSetActive) throw Exception('Mock setActive error');
    _activeUserId = userId;
  }

  @override
  Future<String?> getActiveUserId() async => _activeUserId;

  @override
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
    final account = Account.create(
      userId: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      authProvider: authProvider,
      isLoggedIn: true,
    );
    _loggedInAccounts.add(account);
    return account;
  }

  @override
  Future<void> removeAccountSession(
    String userId, {
    bool deleteData = false,
  }) async {
    _loggedInAccounts.removeWhere((a) => a.userId == userId);
    // If deleteData and we have a reference to account service, delete there too
    if (deleteData && _accountService != null) {
      await _accountService!.deleteAccount(userId);
    }
  }

  @override
  Future<Map<String, dynamic>?> getSession(String userId) async => null;

  @override
  Future<int> getLoggedInCount() async => _loggedInAccounts.length;

  // Custom token management methods for multi-account switching
  final Map<String, String> _customTokens = {};
  final Map<String, int> _customTokenTimestamps = {};

  @override
  Future<void> storeCustomToken(String uid, String customToken) async {
    _customTokens[uid] = customToken;
    _customTokenTimestamps[uid] = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<String?> getValidCustomToken(String uid) async {
    return _customTokens[uid];
  }

  @override
  Future<void> removeCustomToken(String uid) async {
    _customTokens.remove(uid);
    _customTokenTimestamps.remove(uid);
  }

  @override
  Future<bool> hasValidCustomToken(String uid) async {
    return _customTokens.containsKey(uid);
  }
}

/// Mock TokenService for testing (avoids Firebase/HTTP in unit tests)
class MockTokenService implements TokenService {
  @override
  Future<Map<String, dynamic>> generateCustomToken(String uid) async {
    throw Exception('Mock: no token in unit tests');
  }

  @override
  Future<bool> isEndpointReachable() async => false;
}

/// Mock AccountService for testing
class MockAccountService implements AccountService {
  final StreamController<Account?> _activeAccountController =
      StreamController<Account?>.broadcast();
  final StreamController<List<Account>> _allAccountsController =
      StreamController<List<Account>>.broadcast();
  final List<Account> _accounts = [];
  Account? _activeAccount;
  bool throwOnSave = false;
  bool throwOnDelete = false;
  bool throwOnSetActive = false;

  @override
  Stream<Account?> watchActiveAccount() => _activeAccountController.stream;

  @override
  Stream<List<Account>> watchAllAccounts() => _allAccountsController.stream;

  @override
  Future<Account?> getActiveAccount() async => _activeAccount;

  @override
  Future<List<Account>> getAllAccounts() async => _accounts.toList();

  @override
  Future<Account?> getAccountByUserId(String userId) async {
    try {
      return _accounts.firstWhere((a) => a.userId == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Account> saveAccount(Account account) async {
    if (throwOnSave) throw Exception('Mock save error');

    final index = _accounts.indexWhere((a) => a.userId == account.userId);
    if (index >= 0) {
      _accounts[index] = account;
    } else {
      _accounts.add(account);
    }
    _allAccountsController.add(_accounts.toList());

    if (account.isActive) {
      _activeAccount = account;
      _activeAccountController.add(account);
    }

    return account;
  }

  @override
  Future<void> setActiveAccount(String userId) async {
    if (throwOnSetActive) throw Exception('Mock setActive error');

    for (var i = 0; i < _accounts.length; i++) {
      final wasActive = _accounts[i].userId == userId;
      _accounts[i] = _accounts[i].copyWith(isActive: wasActive);
    }

    _activeAccount = _accounts.where((a) => a.isActive).firstOrNull;
    _activeAccountController.add(_activeAccount);
    _allAccountsController.add(_accounts.toList());
  }

  @override
  Future<void> deleteAccount(String userId) async {
    if (throwOnDelete) throw Exception('Mock delete error');

    _accounts.removeWhere((a) => a.userId == userId);

    if (_activeAccount?.userId == userId) {
      _activeAccount = null;
      _activeAccountController.add(null);
    }

    _allAccountsController.add(_accounts.toList());
  }

  @override
  Future<void> deactivateAllAccounts() async {
    for (var i = 0; i < _accounts.length; i++) {
      _accounts[i] = _accounts[i].copyWith(isActive: false);
    }
    _activeAccount = null;
    _activeAccountController.add(null);
    _allAccountsController.add(_accounts.toList());
  }

  void emitActiveAccount(Account? account) {
    _activeAccount = account;
    _activeAccountController.add(account);
  }

  void emitAllAccounts(List<Account> accounts) {
    _accounts.clear();
    _accounts.addAll(accounts);
    _allAccountsController.add(accounts);
  }

  void dispose() {
    _activeAccountController.close();
    _allAccountsController.close();
  }

  @override
  Future<bool> accountExists(String userId) async {
    return await getAccountByUserId(userId) != null;
  }

  @override
  Future<Set<String>> getAllAccountIds() async {
    final accounts = await getAllAccounts();
    return accounts.map((a) => a.userId).toSet();
  }
}

void main() {
  group('Account Provider Tests', () {
    late MockAccountService mockAccountService;
    late MockAccountSessionManager mockSessionManager;

    setUpAll(() async {
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
      } catch (_) {
        // Already initialized (e.g. from another test file)
      }
    });

    setUp(() {
      mockAccountService = MockAccountService();
      mockSessionManager = MockAccountSessionManager();
      // Link session manager to account service for deleteAccount operations
      mockSessionManager.setAccountService(mockAccountService);
    });

    tearDown(() {
      mockAccountService.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          accountServiceProvider.overrideWithValue(mockAccountService),
          accountSessionManagerProvider.overrideWithValue(mockSessionManager),
          tokenServiceProvider.overrideWithValue(MockTokenService()),
          // Override FutureProviders that depend on session manager
          loggedInAccountsProvider.overrideWith((ref) async {
            return mockSessionManager.getLoggedInAccounts();
          }),
          hasLoggedInAccountsProvider.overrideWith((ref) async {
            return mockSessionManager.hasLoggedInAccounts();
          }),
        ],
      );
    }

    Account createTestAccount({
      required String userId,
      String email = 'test@example.com',
      String? displayName,
      bool isActive = false,
      AuthProvider authProvider = AuthProvider.email,
    }) {
      return Account.create(
        userId: userId,
        email: email,
        displayName: displayName,
        isActive: isActive,
        authProvider: authProvider,
      );
    }

    group('activeAccountProvider', () {
      test('emits null when no active account', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          activeAccountProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);
        mockAccountService.emitActiveAccount(null);
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value, isNull);
      });

      test('emits account when active', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final testAccount = createTestAccount(
          userId: 'user-123',
          email: 'active@example.com',
          isActive: true,
        );

        final subscription = container.listen(
          activeAccountProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);
        mockAccountService.emitActiveAccount(testAccount);
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value?.userId, equals('user-123'));
        expect(state.value?.email, equals('active@example.com'));
      });

      test('handles account switches', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final account1 = createTestAccount(
          userId: 'user-1',
          email: 'user1@example.com',
        );
        final account2 = createTestAccount(
          userId: 'user-2',
          email: 'user2@example.com',
        );

        final userIds = <String?>[];
        container.listen(activeAccountProvider, (previous, next) {
          if (next.hasValue) {
            userIds.add(next.value?.userId);
          }
        });

        await Future.delayed(Duration.zero);
        mockAccountService.emitActiveAccount(account1);
        await Future.delayed(Duration.zero);
        mockAccountService.emitActiveAccount(account2);
        await Future.delayed(Duration.zero);

        expect(userIds, [account1.userId, account2.userId]);
      });
    });

    group('allAccountsProvider', () {
      test('emits empty list when no accounts', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final subscription = container.listen(
          allAccountsProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);
        mockAccountService.emitAllAccounts([]);
        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value, isEmpty);
      });

      test('emits all accounts', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final accounts = [
          createTestAccount(userId: 'user-1'),
          createTestAccount(userId: 'user-2'),
          createTestAccount(userId: 'user-3'),
        ];

        // Add accounts BEFORE subscribing (FutureProvider calls getAllAccounts() once)
        mockAccountService.emitAllAccounts(accounts);

        final subscription = container.listen(
          allAccountsProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);

        final state = subscription.read();
        expect(state.value?.length, equals(3));
      });

      test('updates when accounts change', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Add initial account BEFORE subscribing
        mockAccountService.emitAllAccounts([
          createTestAccount(userId: 'user-1'),
        ]);

        final subscription = container.listen(
          allAccountsProvider,
          (previous, next) {},
        );

        await Future.delayed(Duration.zero);
        expect(subscription.read().value?.length, equals(1));

        // Update accounts and invalidate provider to refresh (FutureProvider is cached)
        mockAccountService.emitAllAccounts([
          createTestAccount(userId: 'user-1'),
          createTestAccount(userId: 'user-2'),
        ]);
        // Invalidate to force refresh
        container.invalidate(allAccountsProvider);
        await Future.delayed(Duration.zero);

        expect(subscription.read().value?.length, equals(2));
      });
    });

    group('isAnonymousModeProvider', () {
      test('returns true when no active account', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        container.listen(activeAccountProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAccountService.emitActiveAccount(null);
        await Future.delayed(Duration.zero);

        final isAnonymous = container.read(isAnonymousModeProvider);
        expect(isAnonymous, isTrue);
      });

      test('returns true for anonymous account', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final anonymousAccount = createTestAccount(
          userId: 'anon_123',
          email: 'anonymous@local',
          authProvider: AuthProvider.anonymous,
        );

        container.listen(activeAccountProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAccountService.emitActiveAccount(anonymousAccount);
        await Future.delayed(Duration.zero);

        final isAnonymous = container.read(isAnonymousModeProvider);
        expect(isAnonymous, isTrue);
      });

      test('returns false for authenticated account', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final authenticatedAccount = createTestAccount(
          userId: 'user-123',
          email: 'user@example.com',
          authProvider: AuthProvider.email,
        );

        container.listen(activeAccountProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAccountService.emitActiveAccount(authenticatedAccount);
        await Future.delayed(Duration.zero);

        final isAnonymous = container.read(isAnonymousModeProvider);
        expect(isAnonymous, isFalse);
      });

      test('returns false for Google-authenticated account', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final googleAccount = createTestAccount(
          userId: 'google-user',
          email: 'user@gmail.com',
          authProvider: AuthProvider.gmail,
        );

        container.listen(activeAccountProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        mockAccountService.emitActiveAccount(googleAccount);
        await Future.delayed(Duration.zero);

        final isAnonymous = container.read(isAnonymousModeProvider);
        expect(isAnonymous, isFalse);
      });

      test('returns true during loading state', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Don't emit anything - still loading
        final isAnonymous = container.read(isAnonymousModeProvider);
        expect(isAnonymous, isTrue);
      });
    });

    group('AccountSwitcher', () {
      // Note: switchAccount tests removed - they require FirebaseAuth which cannot
      // be initialized in unit tests. Account switching is tested in integration tests.

      test('addAccount creates new account', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        final newAccount = createTestAccount(
          userId: 'new-user',
          email: 'new@example.com',
        );

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.addAccount(newAccount);
        await Future.delayed(Duration.zero);

        final state = container.read(accountSwitcherProvider);
        expect(state.hasError, isFalse);

        // Verify account was added
        final accounts = await mockAccountService.getAllAccounts();
        expect(accounts.any((a) => a.userId == 'new-user'), isTrue);
      });

      test('addAccount handles errors', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        mockAccountService.throwOnSave = true;
        final newAccount = createTestAccount(userId: 'new-user');

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.addAccount(newAccount);
        await Future.delayed(Duration.zero);

        final state = container.read(accountSwitcherProvider);
        expect(state.hasError, isTrue);
      });

      test('deleteAccount removes account', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Setup accounts
        mockAccountService.emitAllAccounts([
          createTestAccount(userId: 'user-1'),
          createTestAccount(userId: 'user-2'),
        ]);
        await Future.delayed(Duration.zero);

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.deleteAccount('user-1');
        await Future.delayed(Duration.zero);

        final accounts = await mockAccountService.getAllAccounts();
        expect(accounts.any((a) => a.userId == 'user-1'), isFalse);
        expect(accounts.length, equals(1));
      });

      test('deleteAccount handles errors', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        mockAccountService.throwOnDelete = true;

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.deleteAccount('user-1');
        await Future.delayed(Duration.zero);

        final state = container.read(accountSwitcherProvider);
        expect(state.hasError, isTrue);
      });

      test(
        'createAnonymousAccount creates and activates anonymous account',
        () async {
          final container = createContainer();
          addTearDown(container.dispose);

          final switcher = container.read(accountSwitcherProvider.notifier);
          final account = await switcher.createAnonymousAccount();
          await Future.delayed(Duration.zero);

          expect(account.userId, startsWith('anon_'));
          expect(account.email, equals('anonymous@local'));
          expect(account.authProvider, equals(AuthProvider.anonymous));
          expect(account.isActive, isTrue);
        },
      );

      test('createAnonymousAccount handles errors', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        mockAccountService.throwOnSave = true;

        final switcher = container.read(accountSwitcherProvider.notifier);

        await expectLater(
          () => switcher.createAnonymousAccount(),
          throwsException,
        );

        final state = container.read(accountSwitcherProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('Edge Cases', () {
      test('handles concurrent operations', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final switcher = container.read(accountSwitcherProvider.notifier);

        // Start multiple operations
        final futures = [
          switcher.addAccount(createTestAccount(userId: 'user-1')),
          switcher.addAccount(createTestAccount(userId: 'user-2')),
          switcher.addAccount(createTestAccount(userId: 'user-3')),
        ];

        await Future.wait(futures);
        await Future.delayed(Duration.zero);

        final accounts = await mockAccountService.getAllAccounts();
        expect(accounts.length, equals(3));
      });

      test('deleting active account clears active state', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final activeAccount = createTestAccount(
          userId: 'active-user',
          isActive: true,
        );
        mockAccountService.emitActiveAccount(activeAccount);
        mockAccountService.emitAllAccounts([activeAccount]);
        await Future.delayed(Duration.zero);

        container.listen(activeAccountProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.deleteAccount('active-user');
        await Future.delayed(Duration.zero);

        final active = await mockAccountService.getActiveAccount();
        expect(active, isNull);
      });

      test('provider state transitions through loading', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        final states = <AsyncValue<void>>[];
        container.listen(accountSwitcherProvider, (previous, next) {
          states.add(next);
        });

        final switcher = container.read(accountSwitcherProvider.notifier);
        await switcher.addAccount(createTestAccount(userId: 'user-1'));
        await Future.delayed(Duration.zero);

        // Should have loading state followed by data state
        expect(states.any((s) => s.isLoading), isTrue);
        expect(states.last.hasValue, isTrue);
      });

      test('multiple accounts with different auth providers', () async {
        final container = createContainer();
        addTearDown(container.dispose);

        // Add accounts BEFORE listening (since it's a FutureProvider that calls getAllAccounts())
        mockAccountService.emitAllAccounts([
          createTestAccount(
            userId: 'email-user',
            authProvider: AuthProvider.email,
          ),
          createTestAccount(
            userId: 'google-user',
            authProvider: AuthProvider.gmail,
          ),
          createTestAccount(
            userId: 'anon-user',
            authProvider: AuthProvider.anonymous,
          ),
        ]);

        // Listen after emitting
        final subscription = container.listen(allAccountsProvider, (_, __) {});
        await Future.delayed(Duration.zero);

        final accounts = subscription.read().value ?? [];
        expect(accounts.length, equals(3));

        final authProviders = accounts.map((a) => a.authProvider).toSet();
        expect(
          authProviders,
          containsAll([
            AuthProvider.email,
            AuthProvider.gmail,
            AuthProvider.anonymous,
          ]),
        );
      });
    });
  });
}
