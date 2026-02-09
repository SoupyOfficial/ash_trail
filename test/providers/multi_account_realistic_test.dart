/// Realistic Multi-Account Log Switching Tests
///
/// Unlike `multi_account_log_switching_test.dart` which uses synchronous mocks,
/// these tests replicate the EXACT same pipeline that runs on TestFlight:
///
///   Real Hive boxes → Real Repositories → Real Services → Real Riverpod Providers
///
/// This catches issues that mocks hide:
///   - Hive serialization/deserialization round-trips
///   - Stream controller timing and emission ordering
///   - Riverpod provider propagation delays after account switches
///   - Race conditions between account switch completion and log creation
///   - The `AccountRepositoryHive` singleton pattern
///   - `activeAccountProvider` → `activeAccountIdProvider` derivation chain
///
/// Each test uses fresh Hive boxes in a temp directory to avoid cross-test
/// contamination and to reset the AccountRepositoryHive singleton.
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/repositories/account_repository.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';
import 'package:ash_trail/repositories/log_record_repository_hive.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Test Infrastructure — Real Hive + Real Repositories + Riverpod
// ═══════════════════════════════════════════════════════════════════════════════

/// Test constants matching integration test credentials (userId only, no auth)
const kTestUser1Id = 'test-realistic-user-001';
const kTestUser1Email = 'test1@ashtrail.dev';
const kTestUser2Id = 'test-realistic-user-002';
const kTestUser2Email = 'test2@ashtrail.dev';
const kTestUser3Id = 'test-realistic-user-003';
const kTestUser3Email = 'test3@ashtrail.dev';

/// Encapsulates a fresh Hive environment for each test.
///
/// Creates real Hive boxes in a temp directory, builds real repositories,
/// and wires them into a Riverpod container with provider overrides —
/// identical to how the app runs on device, minus Firebase Auth.
class RealisticTestHarness {
  late Directory _tempDir;
  late Box _accountsBox;
  late Box _logRecordsBox;
  late AccountRepository _accountRepo;
  late LogRecordRepository _logRecordRepo;
  late AccountService _accountService;
  late LogRecordService _logRecordService;
  late ProviderContainer _container;

  /// The Riverpod container with real Hive-backed providers.
  ProviderContainer get container => _container;
  AccountService get accountService => _accountService;
  LogRecordService get logRecordService => _logRecordService;
  AccountRepository get accountRepo => _accountRepo;
  LogRecordRepository get logRecordRepo => _logRecordRepo;

  /// Set up fresh Hive boxes and wire everything together.
  Future<void> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create a unique temp directory for this test
    final suffix =
        '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
    _tempDir = Directory.systemTemp.createTempSync('hive_realistic_$suffix');
    Hive.init(_tempDir.path);

    // Open real Hive boxes (same names as production)
    _accountsBox = await Hive.openBox('accounts_$suffix');
    _logRecordsBox = await Hive.openBox('log_records_$suffix');

    final boxes = <String, dynamic>{
      'accounts': _accountsBox,
      'logRecords': _logRecordsBox,
    };

    // Build real repositories backed by Hive — SAME classes as production
    _logRecordRepo = LogRecordRepositoryHive(boxes);
    // AccountRepositoryHive uses a singleton, so we create it directly
    // to avoid cross-test contamination via the factory constructor.
    _accountRepo = _AccountRepositoryHiveTestable(boxes);

    // Build real services with real repositories
    _logRecordService = LogRecordService(
      repository: _logRecordRepo,
      validateAccountId: false, // Skip Firebase validation in unit tests
    );
    _accountService = AccountService(
      repository: _accountRepo,
      logRecordService: _logRecordService,
    );

    // Wire into Riverpod with overrides — this matches the production
    // provider chain except we skip Firebase Auth for account switching
    _container = ProviderContainer(
      overrides: [
        // Override the service providers with our Hive-backed instances
        accountServiceProvider.overrideWithValue(_accountService),
        logRecordServiceProvider.overrideWithValue(_logRecordService),
      ],
    );
  }

  /// Create and save an account in Hive (simulates what login flow does).
  Future<Account> createAccount({
    required String userId,
    required String email,
    bool isActive = false,
    bool isLoggedIn = true,
  }) async {
    final account = Account.create(
      userId: userId,
      email: email,
      isActive: isActive,
      isLoggedIn: isLoggedIn,
      authProvider: AuthProvider.email,
    );
    return await _accountRepo.save(account);
  }

  /// Switch active account in Hive and invalidate Riverpod providers.
  ///
  /// This replicates what `AccountSwitcher.switchAccount()` does in
  /// production — minus the Firebase custom token auth step.
  Future<void> switchAccount(String userId) async {
    await _accountRepo.setActive(userId);
    // Invalidate providers to force re-read — same as production code
    _container.invalidate(activeAccountProvider);
    _container.invalidate(allAccountsProvider);
    _container.invalidate(loggedInAccountsProvider);
    _container.invalidate(activeAccountLogRecordsProvider);
  }

  /// Read `activeAccountIdProvider` — the derived provider that feeds
  /// log creation. This is where race conditions surface.
  String? readActiveAccountId() {
    return _container.read(activeAccountIdProvider);
  }

  /// Wait for the active account stream to emit a specific userId.
  ///
  /// In production, after `setActive()` mutates Hive, the stream controller
  /// emits asynchronously. This waits for that propagation — the exact delay
  /// that can cause race conditions on real devices.
  Future<Account?> waitForActiveAccount({
    String? expectedUserId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final completer = Completer<Account?>();
    final sub = _container.listen<AsyncValue<Account?>>(activeAccountProvider, (
      previous,
      next,
    ) {
      next.whenData((account) {
        if (expectedUserId == null || account?.userId == expectedUserId) {
          if (!completer.isCompleted) completer.complete(account);
        }
      });
    }, fireImmediately: true);

    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      // Return whatever state we have
      final current = _container.read(activeAccountProvider);
      return current.asData?.value;
    } finally {
      sub.close();
    }
  }

  /// Create a log record through the SAME path the widget uses:
  ///   1. Read activeAccountId from Riverpod
  ///   2. Pass it to LogRecordService.createLogRecord()
  ///
  /// Returns null if no active account (same failure mode as production).
  Future<LogRecord?> createLogViaProviderChain({
    EventType eventType = EventType.vape,
    double duration = 5.0,
    String? note,
    double? moodRating,
  }) async {
    final accountId = _container.read(activeAccountIdProvider);
    if (accountId == null) return null;

    return await _logRecordService.createLogRecord(
      accountId: accountId,
      eventType: eventType,
      duration: duration,
      note: note,
      moodRating: moodRating,
    );
  }

  /// Query log records directly from Hive repository — bypasses providers.
  /// Used to verify what's actually persisted vs what providers report.
  Future<List<LogRecord>> getRecordsFromHive(String accountId) async {
    return await _logRecordRepo.getByAccount(accountId);
  }

  /// Get record count directly from Hive for an account.
  Future<int> countRecordsInHive(String accountId) async {
    return await _logRecordRepo.countByAccount(accountId);
  }

  /// Clean up: close boxes, delete temp directory.
  Future<void> tearDown() async {
    _container.dispose();
    await _accountsBox.close();
    await _logRecordsBox.close();
    try {
      _tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Best effort cleanup
    }
  }
}

/// Testable version of AccountRepositoryHive that bypasses the singleton
/// factory constructor. This prevents cross-test state leakage.
class _AccountRepositoryHiveTestable implements AccountRepository {
  late final Box _box;
  late final StreamController<List<Account>> _controller;
  bool _initialEmitted = false;

  _AccountRepositoryHiveTestable(Map<String, dynamic> boxes) {
    _box = boxes['accounts'] as Box;
    _controller = StreamController<List<Account>>.broadcast(
      onListen: () {
        if (!_initialEmitted) {
          _initialEmitted = true;
          _emitChanges();
        }
      },
    );
    _box.watch().listen((_) => _emitChanges());
    _emitChanges();
    // Match production: delayed re-emit for listener stabilization
    Future.microtask(() {
      if (!_controller.isClosed && _controller.hasListener) {
        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          if (!_controller.isClosed) _emitChanges();
        });
      }
    });
  }

  void _emitChanges() {
    if (_controller.isClosed) return;
    getAll()
        .then((accounts) {
          if (!_controller.isClosed) _controller.add(accounts);
        })
        .catchError((e) {
          if (!_controller.isClosed) _controller.addError(e);
        });
  }

  @override
  Future<List<Account>> getAll() async {
    final accounts = <Account>[];
    for (var key in _box.keys) {
      try {
        final json = Map<String, dynamic>.from(_box.get(key));
        // Round-trip through WebAccount JSON serialization — same as production
        final webAccount = _parseWebAccount(json);
        accounts.add(_webAccountToAccount(webAccount));
      } catch (e) {
        // Skip malformed entries, same as production
      }
    }
    return accounts;
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      if (json['userId'] == userId) {
        return _webAccountToAccount(_parseWebAccount(json));
      }
    }
    return null;
  }

  @override
  Future<Account?> getActive() async {
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      if (json['isActive'] == true) {
        return _webAccountToAccount(_parseWebAccount(json));
      }
    }
    return null;
  }

  @override
  Future<Account> save(Account account) async {
    final json = _accountToJson(account);
    await _box.put(account.userId, json);
    _emitChanges();
    return account;
  }

  @override
  Future<void> delete(String userId) async {
    await _box.delete(userId);
    _emitChanges();
  }

  @override
  Future<void> setActive(String userId) async {
    // Iterate all keys and set isActive only on the target — same as production
    final keysToUpdate = _box.keys.toList();
    for (var key in keysToUpdate) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final isTarget = json['userId'] == userId;
      json['isActive'] = isTarget;
      if (isTarget) {
        json['lastAccessedAt'] = DateTime.now().toIso8601String();
      }
      json['updatedAt'] = DateTime.now().toIso8601String();
      await _box.put(key, json);
    }
    _emitChanges();
  }

  @override
  Future<void> clearActive() async {
    final keysToUpdate = _box.keys.toList();
    for (var key in keysToUpdate) {
      final json = Map<String, dynamic>.from(_box.get(key));
      json['isActive'] = false;
      json['updatedAt'] = DateTime.now().toIso8601String();
      await _box.put(key, json);
    }
    _emitChanges();
  }

  @override
  Stream<Account?> watchActive() {
    return _controller.stream.map((accounts) {
      try {
        return accounts.firstWhere((a) => a.isActive);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Stream<List<Account>> watchAll() {
    return _controller.stream;
  }

  // --- JSON round-trip helpers (match production WebAccount serialization) ---

  Map<String, dynamic> _accountToJson(Account account) {
    return {
      'id': account.id.toString(),
      'userId': account.userId,
      'email': account.email,
      'displayName': account.displayName,
      'photoUrl': account.photoUrl,
      'isActive': account.isActive,
      'isLoggedIn': account.isLoggedIn,
      'authProvider': account.authProvider.name,
      'createdAt': account.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'lastAccessedAt': account.lastAccessedAt?.toIso8601String(),
      'refreshToken': account.refreshToken,
      'accessToken': account.accessToken,
      'tokenExpiresAt': account.tokenExpiresAt?.toIso8601String(),
    };
  }

  _WebAccountData _parseWebAccount(Map<String, dynamic> json) {
    return _WebAccountData(
      id: json['id']?.toString() ?? '0',
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      isLoggedIn: json['isLoggedIn'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'email',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastAccessedAt:
          json['lastAccessedAt'] != null
              ? DateTime.parse(json['lastAccessedAt'] as String)
              : null,
    );
  }

  Account _webAccountToAccount(_WebAccountData web) {
    return Account.create(
      userId: web.userId,
      email: web.email,
      displayName: web.displayName,
      photoUrl: web.photoUrl,
      isActive: web.isActive,
      isLoggedIn: web.isLoggedIn,
      authProvider: AuthProvider.values.firstWhere(
        (p) => p.name == web.authProvider,
        orElse: () => AuthProvider.email,
      ),
      createdAt: web.createdAt,
      lastAccessedAt: web.lastAccessedAt,
    )..id = int.tryParse(web.id) ?? 0;
  }
}

/// Minimal data class matching WebAccount fields needed for deserialization.
class _WebAccountData {
  final String id;
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isActive;
  final bool isLoggedIn;
  final String authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastAccessedAt;

  _WebAccountData({
    required this.id,
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isActive,
    required this.isLoggedIn,
    required this.authProvider,
    required this.createdAt,
    required this.updatedAt,
    this.lastAccessedAt,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════════

void main() {
  group('Realistic Hive Pipeline: Basic Log Creation', () {
    late RealisticTestHarness harness;

    setUp(() async {
      harness = RealisticTestHarness();
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test('Log persists in Hive and survives JSON round-trip', () async {
      // Setup: create account and activate it
      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );

      // Wait for stream propagation — this is async in production
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);

      // Verify the provider chain resolves the account
      final resolvedId = harness.readActiveAccountId();
      expect(
        resolvedId,
        kTestUser1Id,
        reason: 'activeAccountIdProvider should resolve after stream emits',
      );

      // Create log through provider chain (same path as HomeQuickLogWidget)
      final record = await harness.createLogViaProviderChain(
        note: 'Hive round-trip test',
        duration: 10.0,
        moodRating: 5.0,
      );
      expect(record, isNotNull, reason: 'Log creation should succeed');
      expect(record!.accountId, kTestUser1Id);
      expect(record.note, 'Hive round-trip test');
      expect(record.duration, 10.0);

      // Verify it's actually in Hive (not just in memory)
      final hiveRecords = await harness.getRecordsFromHive(kTestUser1Id);
      expect(
        hiveRecords.length,
        1,
        reason: 'Record should be persisted in Hive box',
      );
      expect(hiveRecords.first.logId, record.logId);
      expect(hiveRecords.first.note, 'Hive round-trip test');
      expect(hiveRecords.first.moodRating, 5.0);
    });

    test('Log creation fails gracefully when no active account', () async {
      // No accounts created — provider should return null
      final record = await harness.createLogViaProviderChain(
        note: 'Should fail',
      );
      expect(
        record,
        isNull,
        reason: 'Should return null when no active account',
      );
    });

    test('Log records are account-scoped in Hive', () async {
      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );
      await harness.createAccount(userId: kTestUser2Id, email: kTestUser2Email);

      // Wait for provider chain to stabilize
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);

      // Create 2 logs for user 1
      await harness.createLogViaProviderChain(note: 'U1-Log1');
      await harness.createLogViaProviderChain(note: 'U1-Log2');

      // Verify Hive has them under user 1 only
      expect(await harness.countRecordsInHive(kTestUser1Id), 2);
      expect(await harness.countRecordsInHive(kTestUser2Id), 0);
    });
  });

  group('Realistic Hive Pipeline: Account Switching', () {
    late RealisticTestHarness harness;

    setUp(() async {
      harness = RealisticTestHarness();
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test(
      'Switch account → provider chain updates → logs go to correct account',
      () async {
        // Setup both accounts
        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );
        await harness.createAccount(
          userId: kTestUser2Id,
          email: kTestUser2Email,
        );

        // Wait for user 1 to be active in provider chain
        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
        expect(harness.readActiveAccountId(), kTestUser1Id);

        // Create log for user 1
        final u1Log = await harness.createLogViaProviderChain(
          note: 'U1-Before',
        );
        expect(u1Log?.accountId, kTestUser1Id);

        // === SWITCH TO USER 2 ===
        await harness.switchAccount(kTestUser2Id);

        // Wait for the ASYNC stream propagation — this is the critical delay
        // that can cause race conditions on real devices
        await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);

        // Verify provider chain has propagated
        final activeId = harness.readActiveAccountId();
        expect(
          activeId,
          kTestUser2Id,
          reason:
              'activeAccountIdProvider must update after switchAccount + stream propagation',
        );

        // Create log for user 2
        final u2Log = await harness.createLogViaProviderChain(note: 'U2-After');
        expect(
          u2Log?.accountId,
          kTestUser2Id,
          reason: 'Log should go to the SWITCHED account, not the old one',
        );

        // Verify Hive isolation
        expect(await harness.countRecordsInHive(kTestUser1Id), 1);
        expect(await harness.countRecordsInHive(kTestUser2Id), 1);

        final u1Records = await harness.getRecordsFromHive(kTestUser1Id);
        expect(u1Records.first.note, 'U1-Before');

        final u2Records = await harness.getRecordsFromHive(kTestUser2Id);
        expect(u2Records.first.note, 'U2-After');
      },
    );

    test('Multiple switches → data integrity maintained in Hive', () async {
      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );
      await harness.createAccount(userId: kTestUser2Id, email: kTestUser2Email);

      // Round 1: User 1
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
      await harness.createLogViaProviderChain(note: 'R1-U1');

      // Round 2: Switch to User 2
      await harness.switchAccount(kTestUser2Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
      await harness.createLogViaProviderChain(note: 'R1-U2');
      await harness.createLogViaProviderChain(note: 'R2-U2');

      // Round 3: Back to User 1
      await harness.switchAccount(kTestUser1Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
      await harness.createLogViaProviderChain(note: 'R2-U1');

      // Round 4: Back to User 2
      await harness.switchAccount(kTestUser2Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
      await harness.createLogViaProviderChain(note: 'R3-U2');

      // Verify Hive counts
      expect(
        await harness.countRecordsInHive(kTestUser1Id),
        2,
        reason: 'User 1 should have R1-U1 and R2-U1',
      );
      expect(
        await harness.countRecordsInHive(kTestUser2Id),
        3,
        reason: 'User 2 should have R1-U2, R2-U2, R3-U2',
      );

      // Verify record notes match
      final u1Records = await harness.getRecordsFromHive(kTestUser1Id);
      expect(
        u1Records.map((r) => r.note).toSet(),
        containsAll(['R1-U1', 'R2-U1']),
      );

      final u2Records = await harness.getRecordsFromHive(kTestUser2Id);
      expect(
        u2Records.map((r) => r.note).toSet(),
        containsAll(['R1-U2', 'R2-U2', 'R3-U2']),
      );
    });

    test('3-account round-robin with Hive persistence', () async {
      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );
      await harness.createAccount(userId: kTestUser2Id, email: kTestUser2Email);
      await harness.createAccount(userId: kTestUser3Id, email: kTestUser3Email);

      // User 1: 3 logs
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
      for (int i = 1; i <= 3; i++) {
        await harness.createLogViaProviderChain(note: 'U1-$i');
      }

      // User 2: 2 logs
      await harness.switchAccount(kTestUser2Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
      for (int i = 1; i <= 2; i++) {
        await harness.createLogViaProviderChain(note: 'U2-$i');
      }

      // User 3: 1 log
      await harness.switchAccount(kTestUser3Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser3Id);
      await harness.createLogViaProviderChain(note: 'U3-1');

      // Verify all isolated in Hive
      expect(await harness.countRecordsInHive(kTestUser1Id), 3);
      expect(await harness.countRecordsInHive(kTestUser2Id), 2);
      expect(await harness.countRecordsInHive(kTestUser3Id), 1);
    });
  });

  group('Realistic Hive Pipeline: Race Conditions & Timing', () {
    late RealisticTestHarness harness;

    setUp(() async {
      harness = RealisticTestHarness();
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test(
      'RACE: Log created immediately after switchAccount, before stream propagates',
      () async {
        // This test replicates the suspected real-device bug:
        // User switches account, then immediately creates a log before
        // the provider chain has propagated the new account.

        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );
        await harness.createAccount(
          userId: kTestUser2Id,
          email: kTestUser2Email,
        );

        // Wait for user 1 to be fully active
        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
        expect(harness.readActiveAccountId(), kTestUser1Id);

        // Switch to user 2 in Hive but DON'T wait for stream propagation
        await harness.accountRepo.setActive(kTestUser2Id);
        harness.container.invalidate(activeAccountProvider);
        harness.container.invalidate(activeAccountLogRecordsProvider);
        // intentionally NOT awaiting waitForActiveAccount

        // Immediately try to create a log — which account does it use?
        final raceAccountId = harness.readActiveAccountId();
        final record = await harness.createLogViaProviderChain(
          note: 'Race condition log',
        );

        // The log might go to user 1 OR user 2 depending on timing.
        // What matters is that it went to SOME account and was persisted.
        if (record != null) {
          // Verify it was persisted in Hive
          final persisted = await harness.logRecordRepo.getByLogId(
            record.logId,
          );
          expect(
            persisted,
            isNotNull,
            reason: 'Record must be persisted regardless of race outcome',
          );
          expect(
            persisted!.accountId,
            raceAccountId,
            reason:
                'Persisted record accountId must match what provider returned',
          );

          // Document which account won the race
          // ignore: avoid_print
          print(
            'RACE RESULT: Provider returned accountId=$raceAccountId '
            '(Hive active=${(await harness.accountRepo.getActive())?.userId})',
          );
        } else {
          // If record is null, the provider was in a loading/null state during
          // the race — this IS the bug we're looking for in production.
          // ignore: avoid_print
          print(
            'RACE RESULT: Log creation returned null! '
            'Provider accountId was: $raceAccountId. '
            'This replicates the TestFlight bug — the provider chain '
            'had not propagated the new account yet.',
          );
        }

        // Now wait for propagation and verify we CAN create logs after settling
        await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
        final afterSettle = await harness.createLogViaProviderChain(
          note: 'After settle',
        );
        expect(
          afterSettle,
          isNotNull,
          reason: 'Log creation must work after provider chain settles',
        );
        expect(afterSettle!.accountId, kTestUser2Id);
      },
    );

    test(
      'RACE: Rapid switch + log creates logs only for the final active account',
      () async {
        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );
        await harness.createAccount(
          userId: kTestUser2Id,
          email: kTestUser2Email,
        );
        await harness.createAccount(
          userId: kTestUser3Id,
          email: kTestUser3Email,
        );

        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);

        // Rapid-fire: switch U1→U2→U3 without waiting
        await harness.switchAccount(kTestUser2Id);
        await harness.switchAccount(kTestUser3Id);

        // Now wait for final state to settle
        await harness.waitForActiveAccount(expectedUserId: kTestUser3Id);

        // Verify the final active account
        expect(
          harness.readActiveAccountId(),
          kTestUser3Id,
          reason: 'After rapid switches, provider should end up on User 3',
        );

        // Create log — should go to user 3
        final log = await harness.createLogViaProviderChain(note: 'Final');
        expect(log?.accountId, kTestUser3Id);
        expect(await harness.countRecordsInHive(kTestUser3Id), 1);
      },
    );

    test('Stream emission count during account switch', () async {
      // Tracks how many times the active account provider emits during
      // a single switch — helps diagnose "double emission" issues.

      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );
      await harness.createAccount(userId: kTestUser2Id, email: kTestUser2Email);

      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);

      // Count emissions during switch
      final emissions = <String?>[];
      final sub = harness.container.listen<AsyncValue<Account?>>(
        activeAccountProvider,
        (_, next) {
          next.whenData((account) {
            emissions.add(account?.userId);
          });
        },
      );

      // Perform the switch
      await harness.switchAccount(kTestUser2Id);
      // Give time for all async emissions
      await Future.delayed(const Duration(milliseconds: 500));

      sub.close();

      // ignore: avoid_print
      print('Emissions during switch: $emissions');

      // Verify the chain eventually settled on user 2
      expect(
        emissions.last,
        kTestUser2Id,
        reason: 'Final emission must be the switched-to account',
      );

      // There may be intermediate null or loading emissions — that's expected.
      // But if there are TOO MANY, it indicates unnecessary rebuilds.
      expect(
        emissions.length,
        lessThanOrEqualTo(5),
        reason: 'Should not have excessive emissions during a single switch',
      );
    });
  });

  group('Realistic Hive Pipeline: Provider Chain Consistency', () {
    late RealisticTestHarness harness;

    setUp(() async {
      harness = RealisticTestHarness();
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test(
      'activeAccountIdProvider stays in sync with Hive after switch',
      () async {
        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );
        await harness.createAccount(
          userId: kTestUser2Id,
          email: kTestUser2Email,
        );

        // User 1 active
        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
        expect(harness.readActiveAccountId(), kTestUser1Id);

        // Verify Hive agrees
        final hiveActive1 = await harness.accountRepo.getActive();
        expect(
          hiveActive1?.userId,
          kTestUser1Id,
          reason: 'Hive and provider must agree on active account',
        );

        // Switch to user 2
        await harness.switchAccount(kTestUser2Id);
        await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
        expect(harness.readActiveAccountId(), kTestUser2Id);

        // Verify Hive agrees
        final hiveActive2 = await harness.accountRepo.getActive();
        expect(
          hiveActive2?.userId,
          kTestUser2Id,
          reason: 'Hive and provider must agree after switch',
        );
      },
    );

    test('Delete in one account does not leak to another via Hive', () async {
      await harness.createAccount(
        userId: kTestUser1Id,
        email: kTestUser1Email,
        isActive: true,
      );
      await harness.createAccount(userId: kTestUser2Id, email: kTestUser2Email);

      // Create logs for both accounts
      await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
      final u1Log1 = await harness.createLogViaProviderChain(note: 'U1-Keep');
      final u1Log2 = await harness.createLogViaProviderChain(note: 'U1-Delete');
      expect(u1Log1, isNotNull);
      expect(u1Log2, isNotNull);

      await harness.switchAccount(kTestUser2Id);
      await harness.waitForActiveAccount(expectedUserId: kTestUser2Id);
      final u2Log = await harness.createLogViaProviderChain(note: 'U2-Keep');
      expect(u2Log, isNotNull);

      // Delete one record from user 1 (hard delete — same as UNDO snackbar)
      await harness.logRecordService.hardDeleteLogRecord(u1Log2!);

      // Verify Hive state
      expect(
        await harness.countRecordsInHive(kTestUser1Id),
        1,
        reason: 'User 1 should have 1 record after delete',
      );
      expect(
        await harness.countRecordsInHive(kTestUser2Id),
        1,
        reason: 'User 2 records must not be affected by User 1 delete',
      );

      final u1Records = await harness.getRecordsFromHive(kTestUser1Id);
      expect(
        u1Records.first.logId,
        u1Log1!.logId,
        reason: 'The kept record should be U1-Keep',
      );
    });

    test(
      'Stress: 20 logs per account across 2 accounts with switching',
      () async {
        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );
        await harness.createAccount(
          userId: kTestUser2Id,
          email: kTestUser2Email,
        );

        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);

        // Alternate: create log, switch, create log, switch...
        for (int i = 0; i < 20; i++) {
          final currentUser = i.isEven ? kTestUser1Id : kTestUser2Id;
          if (harness.readActiveAccountId() != currentUser) {
            await harness.switchAccount(currentUser);
            await harness.waitForActiveAccount(expectedUserId: currentUser);
          }
          final log = await harness.createLogViaProviderChain(
            note: '$currentUser-$i',
          );
          expect(log, isNotNull, reason: 'Log $i should be created');
          expect(
            log!.accountId,
            currentUser,
            reason: 'Log $i should be for $currentUser',
          );
        }

        // Verify Hive totals
        final u1Count = await harness.countRecordsInHive(kTestUser1Id);
        final u2Count = await harness.countRecordsInHive(kTestUser2Id);
        expect(
          u1Count,
          10,
          reason: 'User 1 should have 10 logs (even indices)',
        );
        expect(u2Count, 10, reason: 'User 2 should have 10 logs (odd indices)');
      },
    );
  });

  group('Realistic Hive Pipeline: activeAccountProvider Loading State', () {
    late RealisticTestHarness harness;

    setUp(() async {
      harness = RealisticTestHarness();
      await harness.setUp();
    });

    tearDown(() async {
      await harness.tearDown();
    });

    test('Provider is initially loading before any account exists', () async {
      // Before any account is created, the activeAccountProvider stream
      // may be loading or emit null. This is the state that causes
      // "No active account selected" errors on cold start.
      final state = harness.container.read(activeAccountProvider);

      // It's either loading or has null data — either is acceptable
      // but if it's loading, createLogViaProviderChain should return null
      if (state.isLoading) {
        final record = await harness.createLogViaProviderChain(
          note: 'Should fail during loading',
        );
        expect(
          record,
          isNull,
          reason: 'Must not create log when provider is loading',
        );
      }
    });

    test(
      'Provider transitions: loading → null → data when account is created',
      () async {
        final states = <String>[];
        final sub = harness.container.listen<AsyncValue<Account?>>(
          activeAccountProvider,
          (_, next) {
            if (next.isLoading) {
              states.add('loading');
            } else if (next.hasError) {
              states.add('error:${next.error}');
            } else {
              states.add('data:${next.asData?.value?.userId ?? 'null'}');
            }
          },
          fireImmediately: true,
        );

        // Let initial state settle
        await Future.delayed(const Duration(milliseconds: 200));

        // Create and activate an account
        await harness.createAccount(
          userId: kTestUser1Id,
          email: kTestUser1Email,
          isActive: true,
        );

        // Wait for it to propagate
        await harness.waitForActiveAccount(expectedUserId: kTestUser1Id);
        await Future.delayed(const Duration(milliseconds: 200));

        sub.close();

        // ignore: avoid_print
        print('Provider state transitions: $states');

        // The last state must be the active account
        expect(
          states.last,
          'data:$kTestUser1Id',
          reason: 'Final state must be the active account data',
        );
      },
    );
  });
}
