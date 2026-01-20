/// Account Data Isolation Test Suite
///
/// This file tests the critical requirement that each account's data
/// is completely isolated from other accounts. When a user switches
/// accounts, they should:
/// 1. Only see logs associated with the active account
/// 2. Not be able to access/modify logs from other accounts
/// 3. Have their data persist independently of other accounts
/// 4. Maintain offline-first model - local data is authoritative
/// 5. Only sync records updated/created on another device when swapping
///
/// ## User Story
/// As a user with multiple accounts, I want my logs to be isolated
/// so that when I switch accounts, I only see logs from the active
/// account and can't accidentally mix data between accounts.
///
/// ## Offline-First Requirements
/// - Users can stay signed in for up to a week of inactivity
/// - All logs go to local DB with account ID
/// - When swapping accounts, records stay in local DB under original account ID
/// - New account gets its own isolated collection
/// - Swapping back shows original logs without interference
/// - Only pull records from remote that were updated/created on another device
///
/// ## Scenarios Tested
/// - Creating logs under Account A stores them with A's accountId
/// - Switching to Account B should not show Account A's logs
/// - Creating logs under Account B stores them with B's accountId
/// - Switching back to Account A shows only A's original logs
/// - Long-term persistence: data survives "session" changes
/// - Offline-first: local data is available immediately on account switch
/// - Sync on switch: only fetch updated/new remote records
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';

/// Second test account constants for multi-account testing
const kSecondTestAccountId = 'dev-test-account-002';
const kSecondTestAccountEmail = 'test2@ashtrail.dev';
const kSecondTestAccountName = 'Test User 2';

/// Helper extension to get log by ID from service
extension LogRecordServiceExtension on LogRecordService {
  Future<LogRecord?> getLogRecord(String logId) async {
    return await getLogRecordByLogId(logId);
  }
}

/// Mock repository that accurately simulates account-scoped data storage
class MockMultiAccountLogRecordRepository implements LogRecordRepository {
  final List<LogRecord> _records = [];
  bool throwError = false;

  /// Get all records (for debugging/verification)
  List<LogRecord> get allRecords => List.unmodifiable(_records);

  /// Get count of records per account (for verification)
  Map<String, int> get recordCountsByAccount {
    final counts = <String, int>{};
    for (final record in _records) {
      counts[record.accountId] = (counts[record.accountId] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<LogRecord> create(LogRecord record) async {
    if (throwError) throw Exception('Mock error');
    _records.add(record);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    if (throwError) throw Exception('Mock error');
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index != -1) {
      _records[index] = record;
    }
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    if (throwError) throw Exception('Mock error');
    _records.removeWhere((r) => r.logId == logId);
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    if (throwError) throw Exception('Mock error');
    try {
      return _records.firstWhere((r) => r.logId == logId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<LogRecord>> getByAccount(String accountId) async {
    if (throwError) throw Exception('Mock error');
    return _records.where((r) => r.accountId == accountId).toList();
  }

  @override
  Future<List<LogRecord>> getByDateRange(
    String accountId,
    DateTime start,
    DateTime end,
  ) async {
    if (throwError) throw Exception('Mock error');
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
    if (throwError) throw Exception('Mock error');
    return _records
        .where((r) => r.accountId == accountId && r.eventType == eventType)
        .toList();
  }

  @override
  Future<List<LogRecord>> getPendingSync() async {
    if (throwError) throw Exception('Mock error');
    return _records.where((r) => r.syncState != SyncState.synced).toList();
  }

  @override
  Future<List<LogRecord>> getDeleted(String accountId) async {
    if (throwError) throw Exception('Mock error');
    return _records
        .where((r) => r.accountId == accountId && r.isDeleted)
        .toList();
  }

  @override
  Future<int> countByAccount(String accountId) async {
    if (throwError) throw Exception('Mock error');
    return _records.where((r) => r.accountId == accountId).length;
  }

  @override
  Future<void> deleteByAccount(String accountId) async {
    if (throwError) throw Exception('Mock error');
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

void main() {
  group('Account Data Isolation - Core Requirements', () {
    late MockMultiAccountLogRecordRepository mockRepo;
    late LogRecordService service;

    /// Primary test account ID (matches accounts_screen.dart)
    const accountA = 'dev-test-account-001';
    const accountB = kSecondTestAccountId;

    setUp(() {
      mockRepo = MockMultiAccountLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    /// **Purpose:** Verify logs are stored with the correct account ID.
    ///
    /// **User Story:** As a user, when I create a log while signed into
    /// Account A, that log should be stored with Account A's ID.
    ///
    /// **What it does:** Creates a log record specifying accountA,
    /// then verifies the record's accountId matches accountA.
    test('logs are stored with the creating account\'s ID', () async {
      // GIVEN: User is logged into Account A
      // WHEN: They create a log entry
      final record = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );

      // THEN: The log should be stored with Account A's ID
      expect(record.accountId, accountA);
      expect(mockRepo.allRecords.length, 1);
      expect(mockRepo.allRecords.first.accountId, accountA);
    });

    /// **Purpose:** Verify Account B cannot see Account A's logs.
    ///
    /// **User Story:** As a user who switches from Account A to Account B,
    /// I should not see any of Account A's logs when viewing Account B's data.
    ///
    /// **What it does:** Creates logs for Account A, then queries for
    /// Account B's logs and verifies the result is empty.
    test('Account B cannot see Account A\'s logs', () async {
      // GIVEN: Account A has logs
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 15.0,
      );

      // WHEN: Querying for Account B's logs
      final accountBLogs = await service.getLogRecords(accountId: accountB);

      // THEN: Account B should have no logs
      expect(accountBLogs, isEmpty);
    });

    /// **Purpose:** Verify Account A cannot see Account B's logs.
    ///
    /// **User Story:** Symmetric test - Account A should not see B's data.
    ///
    /// **What it does:** Creates logs for Account B, then queries for
    /// Account A's logs and verifies the result is empty.
    test('Account A cannot see Account B\'s logs', () async {
      // GIVEN: Account B has logs
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 45.0,
      );

      // WHEN: Querying for Account A's logs
      final accountALogs = await service.getLogRecords(accountId: accountA);

      // THEN: Account A should have no logs
      expect(accountALogs, isEmpty);
    });

    /// **Purpose:** Full multi-account workflow test.
    ///
    /// **User Story:** As a user with two accounts, I want to:
    /// 1. Log into Account A and create logs
    /// 2. Switch to Account B and create different logs
    /// 3. Switch back to Account A and see ONLY my original logs
    ///
    /// **What it does:** Simulates the complete user workflow of
    /// creating data in multiple accounts and verifying isolation.
    test('complete multi-account workflow maintains data isolation', () async {
      // GIVEN: User starts with Account A
      // WHEN: They create 3 logs in Account A
      final accountALog1 = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now().subtract(const Duration(hours: 3)),
        duration: 30.0,
        moodRating: 5,
      );
      final accountALog2 = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.inhale,
        eventAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: 15.0,
        moodRating: 4,
      );
      final accountALog3 = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: 45.0,
        moodRating: 6,
      );

      // AND: User switches to Account B and creates 2 logs
      final accountBLog1 = await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now().subtract(const Duration(minutes: 45)),
        duration: 20.0,
        moodRating: 7,
      );
      final accountBLog2 = await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.vape,
        eventAt: DateTime.now().subtract(const Duration(minutes: 15)),
        duration: 60.0,
        moodRating: 8,
      );

      // THEN: Repository should have 5 total records
      expect(mockRepo.allRecords.length, 5);

      // AND: Account A should have exactly 3 logs
      final accountALogs = await service.getLogRecords(accountId: accountA);
      expect(accountALogs.length, 3);
      expect(accountALogs.map((l) => l.logId).toSet(), {
        accountALog1.logId,
        accountALog2.logId,
        accountALog3.logId,
      });

      // AND: Account B should have exactly 2 logs
      final accountBLogs = await service.getLogRecords(accountId: accountB);
      expect(accountBLogs.length, 2);
      expect(accountBLogs.map((l) => l.logId).toSet(), {
        accountBLog1.logId,
        accountBLog2.logId,
      });

      // AND: The logs should maintain their original data
      final retrievedA1 = await service.getLogRecord(accountALog1.logId);
      expect(retrievedA1?.moodRating, 5);
      expect(retrievedA1?.accountId, accountA);

      final retrievedB2 = await service.getLogRecord(accountBLog2.logId);
      expect(retrievedB2?.moodRating, 8);
      expect(retrievedB2?.accountId, accountB);
    });
  });

  group('Account Data Isolation - Persistence Across Sessions', () {
    /// **Purpose:** Verify data persists after simulated session changes.
    ///
    /// **User Story:** As a user, when I close the app and reopen it,
    /// my account's data should still be there and isolated.
    ///
    /// **What it does:** Creates data, then creates a new service instance
    /// (simulating app restart) and verifies data is still accessible
    /// and properly isolated by account.
    test('data persists independently per account across sessions', () async {
      // Note: This test uses mock repo, so persistence is in-memory.
      // Real persistence is tested in integration tests.
      final mockRepo = MockMultiAccountLogRecordRepository();
      final service1 = LogRecordService(repository: mockRepo);

      const accountA = 'dev-test-account-001';
      const accountB = kSecondTestAccountId;

      // GIVEN: Account A creates logs in "session 1"
      await service1.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );

      // AND: Account B creates logs in "session 1"
      await service1.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: "Session 2" starts (new service, same repo = simulated persistence)
      final service2 = LogRecordService(repository: mockRepo);

      // THEN: Account A still has their log
      final accountALogs = await service2.getLogRecords(accountId: accountA);
      expect(accountALogs.length, 1);
      expect(accountALogs.first.eventType, EventType.vape);

      // AND: Account B still has their log
      final accountBLogs = await service2.getLogRecords(accountId: accountB);
      expect(accountBLogs.length, 1);
      expect(accountBLogs.first.eventType, EventType.inhale);
    });

    /// **Purpose:** Verify week-long inactivity doesn't cause data loss.
    ///
    /// **User Story:** As a user, I should be able to stay signed in for
    /// up to a week of inactivity and still have access to my logs.
    ///
    /// **What it does:** Creates logs with timestamps spread over a week,
    /// simulating a user who logs occasionally over a week period.
    test('logs persist over simulated week of activity', () async {
      final mockRepo = MockMultiAccountLogRecordRepository();
      final service = LogRecordService(repository: mockRepo);

      const accountA = 'dev-test-account-001';
      final now = DateTime.now();

      // GIVEN: User creates logs over a 7-day period
      for (int day = 0; day < 7; day++) {
        await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: now.subtract(Duration(days: day)),
          duration: 30.0,
          note: 'Day $day log',
        );
      }

      // WHEN: Checking logs after "a week"
      final allLogs = await service.getLogRecords(accountId: accountA);

      // THEN: All 7 logs should still exist
      expect(allLogs.length, 7);

      // AND: They should span the full week
      final oldestLog = allLogs.reduce(
        (a, b) => a.eventAt.isBefore(b.eventAt) ? a : b,
      );
      final newestLog = allLogs.reduce(
        (a, b) => a.eventAt.isAfter(b.eventAt) ? a : b,
      );
      final daySpan = newestLog.eventAt.difference(oldestLog.eventAt).inDays;
      expect(daySpan, 6); // 7 days = 6 day span from first to last
    });
  });

  group('Account Data Isolation - Edge Cases', () {
    late MockMultiAccountLogRecordRepository mockRepo;
    late LogRecordService service;

    const accountA = 'dev-test-account-001';
    const accountB = kSecondTestAccountId;

    setUp(() {
      mockRepo = MockMultiAccountLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    /// **Purpose:** Verify rapid account switching doesn't mix data.
    ///
    /// **User Story:** As a user who rapidly switches between accounts,
    /// I should never see the wrong account's data.
    test('rapid account switching maintains data isolation', () async {
      // GIVEN: Both accounts have data
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: Rapidly switching and checking (simulated by alternating queries)
      for (int i = 0; i < 10; i++) {
        final currentAccount = i % 2 == 0 ? accountA : accountB;
        final expectedType = i % 2 == 0 ? EventType.vape : EventType.inhale;

        final logs = await service.getLogRecords(accountId: currentAccount);

        // THEN: Each query should return only that account's data
        expect(logs.length, 1);
        expect(logs.first.eventType, expectedType);
      }
    });

    /// **Purpose:** Verify deleting an account's log doesn't affect others.
    ///
    /// **User Story:** As a user, when I delete a log from my account,
    /// it should not affect any other account's data.
    test('deleting logs in one account doesn\'t affect another', () async {
      // GIVEN: Both accounts have logs
      final accountALog = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      final accountBLog = await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: Account A deletes their log
      await service.deleteLogRecord(accountALog);

      // THEN: Account A should have no logs
      final accountALogs = await service.getLogRecords(accountId: accountA);
      expect(accountALogs, isEmpty);

      // AND: Account B's log should be unaffected
      final accountBLogs = await service.getLogRecords(accountId: accountB);
      expect(accountBLogs.length, 1);
      expect(accountBLogs.first.logId, accountBLog.logId);
    });

    /// **Purpose:** Verify count queries are account-scoped.
    ///
    /// **User Story:** As a user viewing my statistics, the counts
    /// should only reflect my account's data.
    test('count queries are correctly scoped to account', () async {
      // GIVEN: Account A has 5 logs, Account B has 2 logs
      for (int i = 0; i < 5; i++) {
        await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30.0,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.createLogRecord(
          accountId: accountB,
          eventType: EventType.inhale,
          eventAt: DateTime.now(),
          duration: 20.0,
        );
      }

      // WHEN: Counting logs per account
      final accountACount = await mockRepo.countByAccount(accountA);
      final accountBCount = await mockRepo.countByAccount(accountB);

      // THEN: Counts should be correct for each account
      expect(accountACount, 5);
      expect(accountBCount, 2);
    });

    /// **Purpose:** Verify date range queries are account-scoped.
    ///
    /// **User Story:** As a user viewing logs for a specific date range,
    /// I should only see my account's logs from that range.
    test('date range queries are correctly scoped to account', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      // GIVEN: Account A has logs from yesterday and today
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: yesterday.add(const Duration(hours: 1)),
        duration: 30.0,
      );
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: now.subtract(const Duration(hours: 1)),
        duration: 30.0,
      );

      // AND: Account B has a log from yesterday
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: yesterday.add(const Duration(hours: 2)),
        duration: 20.0,
      );

      // WHEN: Querying Account A's logs from yesterday to today
      final accountARange = await mockRepo.getByDateRange(
        accountA,
        twoDaysAgo,
        now.add(const Duration(hours: 1)),
      );

      // THEN: Should only return Account A's 2 logs
      expect(accountARange.length, 2);
      expect(accountARange.every((l) => l.accountId == accountA), isTrue);
    });

    /// **Purpose:** Verify event type queries are account-scoped.
    ///
    /// **User Story:** As a user filtering by event type, I should
    /// only see my account's logs of that type.
    test('event type queries are correctly scoped to account', () async {
      // GIVEN: Account A has 2 vape logs, Account B has 1 vape log
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 45.0,
      );
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: Querying Account A's vape logs
      final accountAVapeLogs = await mockRepo.getByEventType(
        accountA,
        EventType.vape,
      );

      // THEN: Should return only Account A's 2 vape logs
      expect(accountAVapeLogs.length, 2);
      expect(accountAVapeLogs.every((l) => l.accountId == accountA), isTrue);
    });
  });

  group('Account Data Isolation - Stream/Watch Queries', () {
    late MockMultiAccountLogRecordRepository mockRepo;
    late LogRecordService service;

    const accountA = 'dev-test-account-001';
    const accountB = kSecondTestAccountId;

    setUp(() {
      mockRepo = MockMultiAccountLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    /// **Purpose:** Verify watch streams are account-scoped.
    ///
    /// **User Story:** As a user with real-time updates enabled,
    /// I should only receive updates for my account's data.
    test('watchByAccount stream returns only that account\'s logs', () async {
      // GIVEN: Both accounts have logs
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: Listening to Account A's watch stream
      final accountAStream = mockRepo.watchByAccount(accountA);
      final accountALogs = await accountAStream.first;

      // THEN: Should only contain Account A's log
      expect(accountALogs.length, 1);
      expect(accountALogs.first.accountId, accountA);
      expect(accountALogs.first.eventType, EventType.vape);
    });
  });

  // NOTE: Database integration tests have been moved to integration_test/database_integration_test.dart
  // This includes the 'real database maintains account isolation' test which requires
  // actual database initialization with platform plugins.
  //
  // To run database integration tests:
  //   flutter test integration_test/database_integration_test.dart

  group('Account Data Isolation - Offline-First Account Switching', () {
    late MockMultiAccountLogRecordRepository mockRepo;
    late LogRecordService service;

    const accountA = 'dev-test-account-001';
    const accountB = kSecondTestAccountId;

    setUp(() {
      mockRepo = MockMultiAccountLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    /// **Purpose:** Verify local data is immediately available on account switch.
    ///
    /// **User Story:** As a user switching accounts, I should immediately
    /// see my local data without waiting for any network requests.
    ///
    /// **What it does:** Creates local logs for both accounts, then simulates
    /// account switching and verifies data is available instantly from local DB.
    test('local data is immediately available on account switch', () async {
      // GIVEN: Both accounts have local data created over time
      final accountALog = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: 30.0,
      );
      final accountBLog = await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now().subtract(const Duration(hours: 12)),
        duration: 45.0,
      );

      // WHEN: User switches from Account A to Account B (simulated by querying B)
      final accountBLogs = await service.getLogRecords(accountId: accountB);

      // THEN: Account B's local data should be immediately available
      expect(accountBLogs.length, 1);
      expect(accountBLogs.first.logId, accountBLog.logId);

      // AND: Account A's data should still be in local DB (not deleted)
      final accountALogs = await service.getLogRecords(accountId: accountA);
      expect(accountALogs.length, 1);
      expect(accountALogs.first.logId, accountALog.logId);
    });

    /// **Purpose:** Verify sync state is preserved per account.
    ///
    /// **User Story:** As a user, when I switch accounts, each account's
    /// sync state should be independent - pending syncs for one account
    /// don't affect the other.
    ///
    /// **What it does:** Creates logs with different sync states per account,
    /// then verifies sync queries return only relevant account's records.
    test('sync state is preserved independently per account', () async {
      // GIVEN: Account A has a synced log
      final accountALog = await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );
      // Simulate it was synced
      await service.markSynced(accountALog, DateTime.now());

      // AND: Account B has a pending sync log
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 45.0,
      );
      // This one stays pending (default)

      // WHEN: Checking pending sync records
      final pendingRecords = await mockRepo.getPendingSync();

      // THEN: Only Account B's record should be pending
      // Note: Account A's record was marked synced, so should not be pending
      final pendingAccountIds = pendingRecords.map((r) => r.accountId).toSet();
      expect(pendingAccountIds.contains(accountB), isTrue);
    });

    /// **Purpose:** Verify account switch preserves all local data.
    ///
    /// **User Story:** As a user who creates logs on Account A, switches
    /// to Account B for a while, then switches back to A, all my original
    /// Account A logs should still be there unchanged.
    ///
    /// **What it does:** Creates data, switches accounts multiple times,
    /// and verifies original data remains intact.
    test(
      'switching accounts multiple times preserves all local data',
      () async {
        // GIVEN: User creates logs in Account A
        final accountALog1 = await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(days: 5)),
          duration: 30.0,
          moodRating: 5,
        );
        final accountALog2 = await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.inhale,
          eventAt: DateTime.now().subtract(const Duration(days: 4)),
          duration: 15.0,
          moodRating: 6,
        );

        // WHEN: User switches to Account B and creates logs
        final accountBLog1 = await service.createLogRecord(
          accountId: accountB,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(days: 3)),
          duration: 45.0,
          moodRating: 7,
        );

        // AND: User switches back to Account A
        final accountALogsAfterSwitch = await service.getLogRecords(
          accountId: accountA,
        );

        // THEN: Account A should have exactly the same 2 logs
        expect(accountALogsAfterSwitch.length, 2);
        expect(accountALogsAfterSwitch.map((l) => l.logId).toSet(), {
          accountALog1.logId,
          accountALog2.logId,
        });

        // AND: Original data should be unchanged
        final retrievedLog1 = accountALogsAfterSwitch.firstWhere(
          (l) => l.logId == accountALog1.logId,
        );
        expect(retrievedLog1.moodRating, 5);
        expect(retrievedLog1.duration, 30.0);

        // AND: Account B's log should be separate and unaffected
        final accountBLogs = await service.getLogRecords(accountId: accountB);
        expect(accountBLogs.length, 1);
        expect(accountBLogs.first.logId, accountBLog1.logId);
      },
    );

    /// **Purpose:** Verify week-long session persistence with account switching.
    ///
    /// **User Story:** As a user, I should be able to stay signed in for
    /// up to a week, create logs throughout the week, switch accounts,
    /// and when I switch back, see all my original logs.
    test(
      'week-long session with account switches maintains data integrity',
      () async {
        final now = DateTime.now();

        // GIVEN: Account A creates logs throughout a week
        final accountALogs = <LogRecord>[];
        for (int day = 0; day < 7; day++) {
          final log = await service.createLogRecord(
            accountId: accountA,
            eventType: day % 2 == 0 ? EventType.vape : EventType.inhale,
            eventAt: now.subtract(Duration(days: day)),
            duration: 20.0 + (day * 5), // Varying durations
          );
          accountALogs.add(log);
        }

        // AND: User switches to Account B on day 3 and creates some logs
        for (int day = 3; day < 5; day++) {
          await service.createLogRecord(
            accountId: accountB,
            eventType: EventType.vape,
            eventAt: now.subtract(Duration(days: day)),
            duration: 60.0,
          );
        }

        // AND: User switches back to Account A on day 5 and creates more logs
        final laterLog = await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(days: 1)),
          duration: 35.0,
        );

        // WHEN: Checking Account A's complete history
        final allAccountALogs = await service.getLogRecords(
          accountId: accountA,
        );

        // THEN: Should have all 8 logs (7 original + 1 later)
        expect(allAccountALogs.length, 8);
        expect(allAccountALogs.map((l) => l.logId).toSet(), {
          ...accountALogs.map((l) => l.logId),
          laterLog.logId,
        });

        // AND: Account B should have only its 2 logs
        final allAccountBLogs = await service.getLogRecords(
          accountId: accountB,
        );
        expect(allAccountBLogs.length, 2);
      },
    );

    /// **Purpose:** Verify records created on another device can be pulled on switch.
    ///
    /// **User Story:** As a user, when I switch accounts, the app should
    /// check for and pull only records that were created/updated on another
    /// device since the last sync for that account.
    ///
    /// **What it does:** Simulates the scenario where remote records exist
    /// by creating "imported" records that would come from sync.
    test('can import records from another device on account switch', () async {
      // GIVEN: Account A has local logs
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now().subtract(const Duration(days: 2)),
        duration: 30.0,
      );

      // AND: Account A has records that came from another device (imported)
      final importedLog = await service.importLogRecord(
        logId: 'remote-log-from-device-2',
        accountId: accountA,
        eventType: EventType.inhale,
        eventAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        duration: 45.0,
        source: Source.imported,
      );

      // WHEN: Querying Account A's logs
      final allAccountALogs = await service.getLogRecords(accountId: accountA);

      // THEN: Should see both local and imported logs
      expect(allAccountALogs.length, 2);
      expect(allAccountALogs.any((l) => l.logId == importedLog.logId), isTrue);

      // AND: Imported log should be marked as synced
      final retrievedImported = allAccountALogs.firstWhere(
        (l) => l.logId == importedLog.logId,
      );
      expect(retrievedImported.syncState, SyncState.synced);
    });

    /// **Purpose:** Verify incremental sync uses lastSyncAt timestamp.
    ///
    /// **User Story:** When switching accounts, the sync should only fetch
    /// records updated after the account's lastSyncAt timestamp, not the
    /// entire history.
    test(
      'sync timestamps are tracked per account for incremental sync',
      () async {
        // GIVEN: Account A has logs with different sync states
        final accountALog1 = await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(hours: 3)),
          duration: 30.0,
        );
        await service.markSynced(accountALog1, DateTime.now());

        final accountALog2 = await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.inhale,
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 45.0,
        );
        await service.markSynced(accountALog2, DateTime.now());

        // AND: Account B has a log synced at different time
        await service.createLogRecord(
          accountId: accountB,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(minutes: 30)),
          duration: 60.0,
        );
        // Leave Account B's log pending (not synced yet)

        // WHEN: Checking the sync states
        final accountALogs = await service.getLogRecords(accountId: accountA);
        final accountBLogs = await service.getLogRecords(accountId: accountB);

        // THEN: Each account's logs should have their own sync states
        expect(accountALogs.length, 2);
        expect(accountBLogs.length, 1);

        // AND: Account A's logs should be synced (have syncedAt set)
        final accountASyncedLogs =
            accountALogs
                .where(
                  (l) => l.syncedAt != null && l.syncState == SyncState.synced,
                )
                .toList();
        expect(accountASyncedLogs.length, 2);

        // AND: Account B's log should still be pending
        expect(accountBLogs.first.syncState, SyncState.pending);
        expect(accountBLogs.first.syncedAt, isNull);

        // Key assertion: Each account tracks sync state independently
        // Account A being fully synced doesn't affect Account B's pending state
        final pendingRecords = await mockRepo.getPendingSync();
        expect(pendingRecords.length, 1);
        expect(pendingRecords.first.accountId, accountB);
      },
    );
  });

  group('Account Data Isolation - Offline Scenarios', () {
    late MockMultiAccountLogRecordRepository mockRepo;
    late LogRecordService service;

    const accountA = 'dev-test-account-001';
    const accountB = kSecondTestAccountId;

    setUp(() {
      mockRepo = MockMultiAccountLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    /// **Purpose:** Verify app works fully offline with multiple accounts.
    ///
    /// **User Story:** As a user without network access, I should still
    /// be able to create logs, switch accounts, and see all my local data.
    test('full functionality works offline with multiple accounts', () async {
      // GIVEN: User creates logs while "offline" (all local)
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );

      // AND: User switches accounts and creates more logs
      await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 45.0,
      );

      // AND: User switches back
      await service.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 20.0,
      );

      // WHEN: Checking all data (still offline)
      final accountALogs = await service.getLogRecords(accountId: accountA);
      final accountBLogs = await service.getLogRecords(accountId: accountB);

      // THEN: All data should be accessible locally
      expect(accountALogs.length, 2);
      expect(accountBLogs.length, 1);

      // AND: All should be marked as pending sync
      final allPending = await mockRepo.getPendingSync();
      expect(allPending.length, 3);
    });

    /// **Purpose:** Verify pending syncs don't block account switching.
    ///
    /// **User Story:** As a user with unsynced changes, I should still
    /// be able to switch accounts freely without losing any data.
    test('pending syncs do not block account switching', () async {
      // GIVEN: Account A has multiple pending logs
      for (int i = 0; i < 5; i++) {
        await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(Duration(hours: i)),
          duration: 30.0 + i,
        );
      }

      // WHEN: User switches to Account B (with pending syncs on A)
      final accountBLog = await service.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 45.0,
      );

      // THEN: Account B operations work normally
      final accountBLogs = await service.getLogRecords(accountId: accountB);
      expect(accountBLogs.length, 1);
      expect(accountBLogs.first.logId, accountBLog.logId);

      // AND: Account A's pending logs are still there
      final accountALogs = await service.getLogRecords(accountId: accountA);
      expect(accountALogs.length, 5);

      // AND: All 6 records are pending sync
      final allPending = await mockRepo.getPendingSync();
      expect(allPending.length, 6);
    });

    /// **Purpose:** Verify data integrity during concurrent offline edits.
    ///
    /// **User Story:** If logs are created for multiple accounts while
    /// offline, all data should be preserved and properly isolated when
    /// connectivity returns.
    test('data integrity maintained with concurrent offline edits', () async {
      // GIVEN: Multiple accounts have interleaved offline edits
      final logs = <LogRecord>[];

      // Simulate interleaved creation (as might happen with background sync queue)
      logs.add(
        await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(minutes: 10)),
          duration: 30.0,
        ),
      );
      logs.add(
        await service.createLogRecord(
          accountId: accountB,
          eventType: EventType.inhale,
          eventAt: DateTime.now().subtract(const Duration(minutes: 9)),
          duration: 45.0,
        ),
      );
      logs.add(
        await service.createLogRecord(
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(minutes: 8)),
          duration: 20.0,
        ),
      );
      logs.add(
        await service.createLogRecord(
          accountId: accountB,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(minutes: 7)),
          duration: 60.0,
        ),
      );

      // WHEN: Checking data for each account
      final accountALogs = await service.getLogRecords(accountId: accountA);
      final accountBLogs = await service.getLogRecords(accountId: accountB);

      // THEN: Each account should have exactly their logs
      expect(accountALogs.length, 2);
      expect(accountBLogs.length, 2);

      // AND: Log IDs should be properly distributed
      expect(accountALogs.map((l) => l.logId).toSet(), {
        logs[0].logId,
        logs[2].logId,
      });
      expect(accountBLogs.map((l) => l.logId).toSet(), {
        logs[1].logId,
        logs[3].logId,
      });
    });
  });
}
