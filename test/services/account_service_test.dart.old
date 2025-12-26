import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ash_trail/services/isar_service.dart';
import 'package:ash_trail/services/account_service.dart';
import 'package:ash_trail/models/account.dart';
import 'dart:io';

void main() {
  late Isar isar;
  late AccountService accountService;

  setUpAll(() async {
    // Initialize Isar for testing
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    // Create a new in-memory Isar instance for each test
    final dir = Directory.systemTemp.createTempSync();
    isar = await Isar.open(
      [AccountSchema, LogEntrySchema, SyncMetadataSchema],
      directory: dir.path,
      name: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Initialize IsarService with test instance
    IsarService.initialize = () async => isar;
    accountService = AccountService();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('AccountService Tests', () {
    test('saveAccount should create new account', () async {
      final account = Account.create(
        userId: 'test_user_1',
        email: 'test1@example.com',
        displayName: 'Test User 1',
      );

      final saved = await accountService.saveAccount(account);
      expect(saved.id, isNotNull);
      expect(saved.userId, 'test_user_1');
    });

    test('getAllAccounts should return all accounts', () async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
      );

      await accountService.saveAccount(account1);
      await accountService.saveAccount(account2);

      final accounts = await accountService.getAllAccounts();
      expect(accounts.length, 2);
    });

    test('getAccountByUserId should find account', () async {
      final account = Account.create(
        userId: 'unique_user',
        email: 'unique@example.com',
      );

      await accountService.saveAccount(account);
      final found = await accountService.getAccountByUserId('unique_user');

      expect(found, isNotNull);
      expect(found!.userId, 'unique_user');
    });

    test('setActiveAccount should activate one account', () async {
      final account1 = Account.create(
        userId: 'user1',
        email: 'user1@example.com',
      );
      final account2 = Account.create(
        userId: 'user2',
        email: 'user2@example.com',
      );

      await accountService.saveAccount(account1);
      await accountService.saveAccount(account2);

      await accountService.setActiveAccount('user1');

      final active = await accountService.getActiveAccount();
      expect(active, isNotNull);
      expect(active!.userId, 'user1');

      final accounts = await accountService.getAllAccounts();
      final user2 = accounts.firstWhere((a) => a.userId == 'user2');
      expect(user2.isActive, false);
    });

    test(
      'getActiveAccount should return null when no active account',
      () async {
        final active = await accountService.getActiveAccount();
        expect(active, isNull);
      },
    );

    test('deleteAccount should remove account', () async {
      final account = Account.create(
        userId: 'to_delete',
        email: 'delete@example.com',
      );

      await accountService.saveAccount(account);
      await accountService.deleteAccount('to_delete');

      final found = await accountService.getAccountByUserId('to_delete');
      expect(found, isNull);
    });

    test('watchActiveAccount should emit changes', () async {
      final account = Account.create(
        userId: 'watch_user',
        email: 'watch@example.com',
      );

      await accountService.saveAccount(account);
      await accountService.setActiveAccount('watch_user');

      final stream = accountService.watchActiveAccount();

      expectLater(
        stream,
        emitsInOrder([predicate<Account?>((a) => a?.userId == 'watch_user')]),
      );
    });
  });
}
