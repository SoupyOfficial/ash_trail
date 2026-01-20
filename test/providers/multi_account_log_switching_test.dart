/// Multi-Account Log Switching Test Suite
///
/// This file tests the critical requirement that logs are properly isolated
/// and displayed when switching between multiple accounts. These tests simulate
/// real-world scenarios where users:
/// 1. Create logs in one account
/// 2. Switch to another account
/// 3. Verify logs remain isolated
/// 4. Switch back and verify original logs are intact
///
/// ## Test Coverage
/// - 2-account switching scenarios (6 tests)
/// - 3-account switching scenarios (3 tests)
/// - 4-account switching scenarios (3 tests)
/// - Rapid switching edge cases
/// - Sequential log creation across accounts
/// - Data integrity verification after multiple switches
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';

// Test account constants
const kAccount1 = 'test-account-001';
const kAccount2 = 'test-account-002';
const kAccount3 = 'test-account-003';
const kAccount4 = 'test-account-004';

/// Mock repository that accurately simulates account-scoped data storage
class MockMultiAccountRepository implements LogRecordRepository {
  final List<LogRecord> _records = [];

  /// Get all records for verification
  List<LogRecord> get allRecords => List.unmodifiable(_records);

  /// Get count of records per account
  Map<String, int> get recordCountsByAccount {
    final counts = <String, int>{};
    for (final record in _records) {
      counts[record.accountId] = (counts[record.accountId] ?? 0) + 1;
    }
    return counts;
  }

  /// Clear all records (for test reset)
  void clear() => _records.clear();

  @override
  Future<LogRecord> create(LogRecord record) async {
    _records.add(record);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index != -1) {
      _records[index] = record;
    }
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    _records.removeWhere((r) => r.logId == logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    try {
      return _records.firstWhere((r) => r.logId == logId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    return _records.where((r) => r.accountId == accountId).toList();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    return _records
        .where(
          (r) =>
              r.accountId == accountId &&
              r.eventAt.isAfter(start) &&
              r.eventAt.isBefore(end),
        )
        .toList();
  }

  @override
  Future<List<LogRecord>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    return _records
        .where((r) => r.accountId == accountId && r.eventType == eventType)
        .toList();
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    return _records.where((r) => r.syncState != SyncState.synced).toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    return _records
        .where((r) => r.accountId == accountId && r.isDeleted)
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _records.where((r) => r.accountId == accountId).length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    _records.removeWhere((r) => r.accountId == accountId);
  }

  @override
  Stream<List<LogRecord>> watchByAccount(String accountId) {
    return Stream.value(
      _records.where((r) => r.accountId == accountId).toList(),
    );
  }

  @override
  Stream<List<LogRecord>> watchByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) {
    return Stream.value(
      _records
          .where(
            (r) =>
                r.accountId == accountId &&
                r.eventAt.isAfter(start) &&
                r.eventAt.isBefore(end),
          )
          .toList(),
    );
  }

  @override
  Future<List<LogRecord>> getAll() async {
    return List.from(_records);
  }
}

/// Helper class to simulate account switching and track "active" account
class AccountSwitchSimulator {
  final MockMultiAccountRepository repository;
  final LogRecordService service;
  String _activeAccountId;

  AccountSwitchSimulator({
    required this.repository,
    required String initialAccount,
  }) : _activeAccountId = initialAccount,
       service = LogRecordService(repository: repository);

  String get activeAccountId => _activeAccountId;

  /// Simulate switching to a different account
  void switchToAccount(String accountId) {
    _activeAccountId = accountId;
  }

  /// Create a log for the currently active account
  Future<LogRecord> createLog({
    EventType eventType = EventType.vape,
    double duration = 30.0,
    String? note,
    double? moodRating,
  }) async {
    return service.createLogRecord(
      accountId: _activeAccountId,
      eventType: eventType,
      eventAt: DateTime.now(),
      duration: duration,
      note: note,
      moodRating: moodRating,
    );
  }

  /// Get logs for the currently active account
  Future<List<LogRecord>> getActiveAccountLogs() async {
    return service.getLogRecords(accountId: _activeAccountId);
  }

  /// Get logs for a specific account
  Future<List<LogRecord>> getLogsForAccount(String accountId) async {
    return service.getLogRecords(accountId: accountId);
  }
}

void main() {
  group('2-Account Switching Scenarios', () {
    late MockMultiAccountRepository mockRepo;
    late AccountSwitchSimulator simulator;

    setUp(() {
      mockRepo = MockMultiAccountRepository();
      simulator = AccountSwitchSimulator(
        repository: mockRepo,
        initialAccount: kAccount1,
      );
    });

    /// Test 1: Basic log creation and account isolation
    test(
      'Scenario 1: Create log in Account1, switch to Account2, verify isolation',
      () async {
        // GIVEN: User is logged into Account 1
        expect(simulator.activeAccountId, kAccount1);

        // WHEN: User creates a log in Account 1
        final account1Log = await simulator.createLog(
          eventType: EventType.vape,
          duration: 30.0,
          note: 'Account 1 log',
        );

        // THEN: Log should be stored with Account 1's ID
        expect(account1Log.accountId, kAccount1);

        // WHEN: User switches to Account 2
        simulator.switchToAccount(kAccount2);

        // THEN: Account 2 should have no logs
        final account2Logs = await simulator.getActiveAccountLogs();
        expect(account2Logs, isEmpty);

        // AND: Account 1's log should still exist
        final account1Logs = await simulator.getLogsForAccount(kAccount1);
        expect(account1Logs.length, 1);
        expect(account1Logs.first.note, 'Account 1 log');
      },
    );

    /// Test 2: Create logs in both accounts, verify separation
    test(
      'Scenario 2: Create logs in both accounts, verify each sees only their own',
      () async {
        // GIVEN: User creates 2 logs in Account 1
        await simulator.createLog(note: 'A1-Log1');
        await simulator.createLog(note: 'A1-Log2');

        // WHEN: User switches to Account 2 and creates 3 logs
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2-Log1');
        await simulator.createLog(note: 'A2-Log2');
        await simulator.createLog(note: 'A2-Log3');

        // THEN: Account 1 should have exactly 2 logs
        final account1Logs = await simulator.getLogsForAccount(kAccount1);
        expect(account1Logs.length, 2);
        expect(
          account1Logs.map((l) => l.note),
          containsAll(['A1-Log1', 'A1-Log2']),
        );

        // AND: Account 2 should have exactly 3 logs
        final account2Logs = await simulator.getLogsForAccount(kAccount2);
        expect(account2Logs.length, 3);
        expect(
          account2Logs.map((l) => l.note),
          containsAll(['A2-Log1', 'A2-Log2', 'A2-Log3']),
        );

        // AND: Total records should be 5
        expect(mockRepo.allRecords.length, 5);
      },
    );

    /// Test 3: Switch back and forth, verify data integrity
    test(
      'Scenario 3: Multiple switches back and forth maintain data integrity',
      () async {
        // Round 1: Account 1 creates log
        await simulator.createLog(note: 'Round1-A1');

        // Switch to Account 2
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'Round1-A2');

        // Round 2: Back to Account 1
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'Round2-A1');

        // Switch to Account 2
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'Round2-A2');

        // Round 3: Back to Account 1
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'Round3-A1');

        // VERIFY: Account 1 has 3 logs (Round1, Round2, Round3)
        final account1Logs = await simulator.getActiveAccountLogs();
        expect(account1Logs.length, 3);
        expect(
          account1Logs.map((l) => l.note),
          containsAll(['Round1-A1', 'Round2-A1', 'Round3-A1']),
        );

        // VERIFY: Account 2 has 2 logs (Round1, Round2)
        final account2Logs = await simulator.getLogsForAccount(kAccount2);
        expect(account2Logs.length, 2);
        expect(
          account2Logs.map((l) => l.note),
          containsAll(['Round1-A2', 'Round2-A2']),
        );
      },
    );

    /// Test 4: Verify event types are isolated per account
    test(
      'Scenario 4: Different event types per account remain isolated',
      () async {
        // Account 1: Only vape events
        await simulator.createLog(eventType: EventType.vape, note: 'A1-Vape1');
        await simulator.createLog(eventType: EventType.vape, note: 'A1-Vape2');

        // Account 2: Only inhale events
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(
          eventType: EventType.inhale,
          note: 'A2-Inhale1',
        );
        await simulator.createLog(
          eventType: EventType.inhale,
          note: 'A2-Inhale2',
        );
        await simulator.createLog(
          eventType: EventType.inhale,
          note: 'A2-Inhale3',
        );

        // VERIFY: Account 1 only has vape events
        final account1Logs = await simulator.getLogsForAccount(kAccount1);
        expect(account1Logs.length, 2);
        expect(
          account1Logs.every((l) => l.eventType == EventType.vape),
          isTrue,
        );

        // VERIFY: Account 2 only has inhale events
        final account2Logs = await simulator.getActiveAccountLogs();
        expect(account2Logs.length, 3);
        expect(
          account2Logs.every((l) => l.eventType == EventType.inhale),
          isTrue,
        );
      },
    );

    /// Test 5: Verify mood ratings are isolated per account
    test('Scenario 5: Mood ratings tracked separately per account', () async {
      // Account 1: Low mood ratings (1-3)
      await simulator.createLog(moodRating: 1.0, note: 'A1-Low1');
      await simulator.createLog(moodRating: 2.0, note: 'A1-Low2');
      await simulator.createLog(moodRating: 3.0, note: 'A1-Low3');

      // Account 2: High mood ratings (8-10)
      simulator.switchToAccount(kAccount2);
      await simulator.createLog(moodRating: 8.0, note: 'A2-High1');
      await simulator.createLog(moodRating: 9.0, note: 'A2-High2');
      await simulator.createLog(moodRating: 10.0, note: 'A2-High3');

      // VERIFY: Account 1 average mood is low
      final account1Logs = await simulator.getLogsForAccount(kAccount1);
      final account1AvgMood =
          account1Logs.map((l) => l.moodRating ?? 0).reduce((a, b) => a + b) /
          account1Logs.length;
      expect(account1AvgMood, closeTo(2.0, 0.01));

      // VERIFY: Account 2 average mood is high
      final account2Logs = await simulator.getActiveAccountLogs();
      final account2AvgMood =
          account2Logs.map((l) => l.moodRating ?? 0).reduce((a, b) => a + b) /
          account2Logs.length;
      expect(account2AvgMood, closeTo(9.0, 0.01));
    });

    /// Test 6: Delete log in one account doesn't affect other
    test(
      'Scenario 6: Deleting log in Account1 does not affect Account2',
      () async {
        // Setup: Create logs in both accounts
        final log1 = await simulator.createLog(note: 'A1-ToDelete');
        final log2 = await simulator.createLog(note: 'A1-Keep');

        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2-Keep1');
        await simulator.createLog(note: 'A2-Keep2');

        // WHEN: Delete a log from Account 1
        await simulator.service.deleteLogRecord(log1);

        // THEN: Account 1 should have 1 log
        final account1Logs = await simulator.getLogsForAccount(kAccount1);
        expect(account1Logs.length, 1);
        expect(account1Logs.first.logId, log2.logId);

        // AND: Account 2 should still have 2 logs
        final account2Logs = await simulator.getActiveAccountLogs();
        expect(account2Logs.length, 2);
      },
    );
  });

  group('3-Account Switching Scenarios', () {
    late MockMultiAccountRepository mockRepo;
    late AccountSwitchSimulator simulator;

    setUp(() {
      mockRepo = MockMultiAccountRepository();
      simulator = AccountSwitchSimulator(
        repository: mockRepo,
        initialAccount: kAccount1,
      );
    });

    /// Test 7: Round-robin switching between 3 accounts
    test(
      'Scenario 7: Round-robin switching A1 -> A2 -> A3 -> A1 maintains isolation',
      () async {
        // Account 1: Create 2 logs
        await simulator.createLog(note: 'A1-Log1');
        await simulator.createLog(note: 'A1-Log2');

        // Account 2: Create 1 log
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2-Log1');

        // Account 3: Create 3 logs
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'A3-Log1');
        await simulator.createLog(note: 'A3-Log2');
        await simulator.createLog(note: 'A3-Log3');

        // Switch back to Account 1
        simulator.switchToAccount(kAccount1);

        // VERIFY: Each account has correct number of logs
        expect((await simulator.getLogsForAccount(kAccount1)).length, 2);
        expect((await simulator.getLogsForAccount(kAccount2)).length, 1);
        expect((await simulator.getLogsForAccount(kAccount3)).length, 3);

        // VERIFY: Total is 6
        expect(mockRepo.allRecords.length, 6);
      },
    );

    /// Test 8: Complex switching pattern with verification at each step
    test(
      'Scenario 8: Complex switching A1 -> A2 -> A1 -> A3 -> A2 -> A3 -> A1',
      () async {
        // Step 1: A1 creates log
        await simulator.createLog(note: 'Step1-A1');
        expect((await simulator.getActiveAccountLogs()).length, 1);

        // Step 2: Switch to A2, create log
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'Step2-A2');
        expect((await simulator.getActiveAccountLogs()).length, 1);

        // Step 3: Back to A1, create another log
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'Step3-A1');
        expect((await simulator.getActiveAccountLogs()).length, 2);

        // Step 4: Switch to A3, create log
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'Step4-A3');
        expect((await simulator.getActiveAccountLogs()).length, 1);

        // Step 5: Switch to A2, create another log
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'Step5-A2');
        expect((await simulator.getActiveAccountLogs()).length, 2);

        // Step 6: Switch to A3, create another log
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'Step6-A3');
        expect((await simulator.getActiveAccountLogs()).length, 2);

        // Step 7: Back to A1, verify all data intact
        simulator.switchToAccount(kAccount1);
        final finalA1Logs = await simulator.getActiveAccountLogs();
        expect(finalA1Logs.length, 2);
        expect(
          finalA1Logs.map((l) => l.note),
          containsAll(['Step1-A1', 'Step3-A1']),
        );

        // Final verification
        expect(mockRepo.recordCountsByAccount, {
          kAccount1: 2,
          kAccount2: 2,
          kAccount3: 2,
        });
      },
    );

    /// Test 9: Verify data isolation with different event types across 3 accounts
    test(
      'Scenario 9: Each account has unique event type distribution',
      () async {
        // Account 1: Only vape events
        for (int i = 0; i < 3; i++) {
          await simulator.createLog(eventType: EventType.vape);
        }

        // Account 2: Only inhale events
        simulator.switchToAccount(kAccount2);
        for (int i = 0; i < 4; i++) {
          await simulator.createLog(eventType: EventType.inhale);
        }

        // Account 3: Only note events
        simulator.switchToAccount(kAccount3);
        for (int i = 0; i < 2; i++) {
          await simulator.createLog(eventType: EventType.note);
        }

        // VERIFY: Each account has only their event type
        final a1Logs = await simulator.getLogsForAccount(kAccount1);
        expect(a1Logs.every((l) => l.eventType == EventType.vape), isTrue);
        expect(a1Logs.length, 3);

        final a2Logs = await simulator.getLogsForAccount(kAccount2);
        expect(a2Logs.every((l) => l.eventType == EventType.inhale), isTrue);
        expect(a2Logs.length, 4);

        final a3Logs = await simulator.getLogsForAccount(kAccount3);
        expect(a3Logs.every((l) => l.eventType == EventType.note), isTrue);
        expect(a3Logs.length, 2);
      },
    );
  });

  group('4-Account Switching Scenarios', () {
    late MockMultiAccountRepository mockRepo;
    late AccountSwitchSimulator simulator;

    setUp(() {
      mockRepo = MockMultiAccountRepository();
      simulator = AccountSwitchSimulator(
        repository: mockRepo,
        initialAccount: kAccount1,
      );
    });

    /// Test 10: Sequential creation across 4 accounts
    test(
      'Scenario 10: Sequential log creation A1 -> A2 -> A3 -> A4 -> verify all',
      () async {
        // Account 1
        await simulator.createLog(note: 'A1');
        await simulator.createLog(note: 'A1-2');

        // Account 2
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2');

        // Account 3
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'A3');
        await simulator.createLog(note: 'A3-2');
        await simulator.createLog(note: 'A3-3');

        // Account 4
        simulator.switchToAccount(kAccount4);
        await simulator.createLog(note: 'A4');
        await simulator.createLog(note: 'A4-2');

        // VERIFY: All accounts have correct counts
        expect((await simulator.getLogsForAccount(kAccount1)).length, 2);
        expect((await simulator.getLogsForAccount(kAccount2)).length, 1);
        expect((await simulator.getLogsForAccount(kAccount3)).length, 3);
        expect((await simulator.getLogsForAccount(kAccount4)).length, 2);

        // VERIFY: Total is 8
        expect(mockRepo.allRecords.length, 8);
      },
    );

    /// Test 11: Random switching pattern across 4 accounts
    test(
      'Scenario 11: Random switching pattern A1->A3->A2->A4->A1->A2->A3->A4->A1',
      () async {
        // A1
        await simulator.createLog(note: 'A1-1');

        // A3
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'A3-1');

        // A2
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2-1');
        await simulator.createLog(note: 'A2-2');

        // A4
        simulator.switchToAccount(kAccount4);
        await simulator.createLog(note: 'A4-1');

        // A1
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'A1-2');

        // A2
        simulator.switchToAccount(kAccount2);
        await simulator.createLog(note: 'A2-3');

        // A3
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'A3-2');

        // A4
        simulator.switchToAccount(kAccount4);
        await simulator.createLog(note: 'A4-2');
        await simulator.createLog(note: 'A4-3');

        // A1
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'A1-3');

        // VERIFY: Correct distribution
        final a1Logs = await simulator.getActiveAccountLogs();
        expect(a1Logs.length, 3);
        expect(
          a1Logs.map((l) => l.note),
          containsAll(['A1-1', 'A1-2', 'A1-3']),
        );

        expect((await simulator.getLogsForAccount(kAccount2)).length, 3);
        expect((await simulator.getLogsForAccount(kAccount3)).length, 2);
        expect((await simulator.getLogsForAccount(kAccount4)).length, 3);
      },
    );

    /// Test 12: Stress test - rapid switching with many logs
    test(
      'Scenario 12: Rapid switching stress test - 40 logs across 4 accounts',
      () async {
        final accounts = [kAccount1, kAccount2, kAccount3, kAccount4];

        // Create 10 logs per account with rapid switching
        for (int round = 0; round < 10; round++) {
          for (final account in accounts) {
            simulator.switchToAccount(account);
            await simulator.createLog(note: '$account-Round$round');
          }
        }

        // VERIFY: Each account has exactly 10 logs
        for (final account in accounts) {
          final logs = await simulator.getLogsForAccount(account);
          expect(
            logs.length,
            10,
            reason: 'Account $account should have 10 logs',
          );
        }

        // VERIFY: Total is 40
        expect(mockRepo.allRecords.length, 40);

        // VERIFY: Log distribution is correct
        expect(mockRepo.recordCountsByAccount, {
          kAccount1: 10,
          kAccount2: 10,
          kAccount3: 10,
          kAccount4: 10,
        });
      },
    );
  });

  group('Edge Cases and Stress Tests', () {
    late MockMultiAccountRepository mockRepo;
    late AccountSwitchSimulator simulator;

    setUp(() {
      mockRepo = MockMultiAccountRepository();
      simulator = AccountSwitchSimulator(
        repository: mockRepo,
        initialAccount: kAccount1,
      );
    });

    /// Test 13: Empty account remains empty after others create logs
    test(
      'Scenario 13: Account with no logs stays empty while others create logs',
      () async {
        // Account 1 creates logs
        await simulator.createLog(note: 'A1-Log');

        // Switch to Account 2 but don't create any logs
        simulator.switchToAccount(kAccount2);

        // Switch to Account 3 and create logs
        simulator.switchToAccount(kAccount3);
        await simulator.createLog(note: 'A3-Log');

        // Back to Account 1, create more
        simulator.switchToAccount(kAccount1);
        await simulator.createLog(note: 'A1-Log2');

        // VERIFY: Account 2 is still empty
        final account2Logs = await simulator.getLogsForAccount(kAccount2);
        expect(account2Logs, isEmpty);

        // VERIFY: Others have their logs
        expect((await simulator.getLogsForAccount(kAccount1)).length, 2);
        expect((await simulator.getLogsForAccount(kAccount3)).length, 1);
      },
    );

    /// Test 14: Switching without creating logs doesn't affect data
    test(
      'Scenario 14: Switch accounts multiple times without creating logs',
      () async {
        // Create initial log in Account 1
        await simulator.createLog(note: 'Initial');

        // Switch around without creating logs
        simulator.switchToAccount(kAccount2);
        simulator.switchToAccount(kAccount3);
        simulator.switchToAccount(kAccount4);
        simulator.switchToAccount(kAccount2);
        simulator.switchToAccount(kAccount1);

        // VERIFY: Only Account 1 has the initial log
        expect((await simulator.getActiveAccountLogs()).length, 1);
        expect((await simulator.getLogsForAccount(kAccount2)).length, 0);
        expect((await simulator.getLogsForAccount(kAccount3)).length, 0);
        expect((await simulator.getLogsForAccount(kAccount4)).length, 0);
        expect(mockRepo.allRecords.length, 1);
      },
    );

    /// Test 15: Update log in one account doesn't create log in another
    test('Scenario 15: Updating log maintains account isolation', () async {
      // Create log in Account 1
      final log = await simulator.createLog(note: 'Original', moodRating: 5.0);

      // Switch to Account 2
      simulator.switchToAccount(kAccount2);

      // Create log in Account 2
      await simulator.createLog(note: 'A2-Log');

      // Update Account 1's log (simulating edit from service)
      await simulator.service.updateLogRecord(log, moodRating: 8.0);

      // VERIFY: Account 1 has 1 log with updated data
      simulator.switchToAccount(kAccount1);
      final account1Logs = await simulator.getActiveAccountLogs();
      expect(account1Logs.length, 1);
      expect(account1Logs.first.moodRating, 8.0);

      // VERIFY: Account 2 still has only 1 log
      final account2Logs = await simulator.getLogsForAccount(kAccount2);
      expect(account2Logs.length, 1);
      expect(account2Logs.first.note, 'A2-Log');

      // VERIFY: Total is still 2
      expect(mockRepo.allRecords.length, 2);
    });

    /// Test 16: Large number of accounts (simulating power users)
    test('Scenario 16: 10 accounts with logs maintain isolation', () async {
      final accounts = List.generate(
        10,
        (i) => 'test-account-${i.toString().padLeft(2, '0')}',
      );

      // Create 2 logs in each account
      for (final account in accounts) {
        simulator.switchToAccount(account);
        await simulator.createLog(note: '$account-Log1');
        await simulator.createLog(note: '$account-Log2');
      }

      // VERIFY: Each account has exactly 2 logs
      for (final account in accounts) {
        final logs = await simulator.getLogsForAccount(account);
        expect(logs.length, 2, reason: 'Account $account should have 2 logs');
        expect(
          logs.every((l) => l.accountId == account),
          isTrue,
          reason: 'All logs should belong to $account',
        );
      }

      // VERIFY: Total is 20
      expect(mockRepo.allRecords.length, 20);
    });
  });
}
