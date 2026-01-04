import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/services/hive_database_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/enums.dart';

/// Integration tests for database operations
/// Tests real database initialization, CRUD operations, and data isolation
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LogRecordService - Database Integration', () {
    late HiveDatabaseService dbService;
    late LogRecordService logRecordService;

    setUp(() async {
      // Initialize real Hive database service
      dbService = HiveDatabaseService();
      await dbService.initialize();
      logRecordService = LogRecordService();
    });

    tearDown(() async {
      // Clean up - close database
      await dbService.close();
    });

    test('should initialize with database service', () async {
      // Verify database is properly initialized
      expect(dbService.isInitialized, true);
      expect(dbService.boxes, isNotNull);
    });

    test('should accept valid database context', () async {
      // Verify service can be created and uses the initialized database
      final service = LogRecordService();
      expect(service, isNotNull);
    });

    test('should create and retrieve log records', () async {
      // GIVEN: Create a log record
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account-001',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
      );

      expect(record.logId, isNotEmpty);
      expect(record.accountId, 'test-account-001');

      // WHEN: Retrieve the record
      final records = await logRecordService.getLogRecords(
        accountId: 'test-account-001',
      );

      // THEN: Record should be found
      expect(records.length, greaterThan(0));
      expect(records.first.logId, record.logId);
    });

    test('should update existing log records', () async {
      // GIVEN: Create a record
      var record = await logRecordService.createLogRecord(
        accountId: 'test-account-002',
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
        note: 'Original note',
      );

      // WHEN: Update the record
      record.note = 'Updated note';
      await logRecordService.updateLogRecord(record);

      // THEN: Changes should be persisted
      final updated = await logRecordService.getLogRecord(record.logId);
      expect(updated.note, 'Updated note');
    });

    test('should delete log records', () async {
      // GIVEN: Create a record
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account-003',
        eventType: EventType.tolerance,
        eventAt: DateTime.now(),
        duration: 40.0,
      );

      final initialRecords = await logRecordService.getLogRecords(
        accountId: 'test-account-003',
      );
      final initialCount = initialRecords.length;

      // WHEN: Delete the record
      await logRecordService.deleteLogRecord(record.logId);

      // THEN: Record should be removed
      final finalRecords = await logRecordService.getLogRecords(
        accountId: 'test-account-003',
      );
      expect(finalRecords.length, lessThan(initialCount));
      expect(finalRecords.any((r) => r.logId == record.logId), false);
    });
  });

  group('Account Data Isolation - Database Integration', () {
    late HiveDatabaseService dbService;
    late LogRecordService logRecordService;

    setUp(() async {
      dbService = HiveDatabaseService();
      await dbService.initialize();
      logRecordService = LogRecordService();
    });

    tearDown(() async {
      await dbService.close();
    });

    test('real database maintains account isolation', () async {
      // GIVEN: Two accounts create log entries
      const accountA = 'isolation-test-account-a';
      const accountB = 'isolation-test-account-b';

      final accountALog = await logRecordService.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
        note: 'Account A entry',
      );

      final accountBLog = await logRecordService.createLogRecord(
        accountId: accountB,
        eventType: EventType.inhale,
        eventAt: DateTime.now(),
        duration: 20.0,
        note: 'Account B entry',
      );

      // WHEN: Query each account's logs
      final accountALogs = await logRecordService.getLogRecords(
        accountId: accountA,
      );
      final accountBLogs = await logRecordService.getLogRecords(
        accountId: accountB,
      );

      // THEN: Each account should only see their own logs
      expect(
        accountALogs.any((r) => r.logId == accountALog.logId),
        true,
        reason: 'Account A should see their own log',
      );
      expect(
        accountALogs.any((r) => r.logId == accountBLog.logId),
        false,
        reason: 'Account A should NOT see account B logs',
      );

      expect(
        accountBLogs.any((r) => r.logId == accountBLog.logId),
        true,
        reason: 'Account B should see their own log',
      );
      expect(
        accountBLogs.any((r) => r.logId == accountALog.logId),
        false,
        reason: 'Account B should NOT see account A logs',
      );
    });

    test('accounts cannot access other account data through service', () async {
      // GIVEN: Create logs in two accounts
      const accountA = 'access-test-account-a';
      const accountB = 'access-test-account-b';

      final logA = await logRecordService.createLogRecord(
        accountId: accountA,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 25.0,
      );

      // WHEN: Try to access account A's log from account B's context
      final accountBLogs = await logRecordService.getLogRecords(
        accountId: accountB,
      );

      // THEN: Account B should NOT see account A's logs
      expect(
        accountBLogs.any((r) => r.logId == logA.logId),
        false,
        reason: 'Account B should never see Account A logs',
      );
    });
  });

  group('Database Error Handling', () {
    late HiveDatabaseService dbService;

    setUp(() async {
      dbService = HiveDatabaseService();
      await dbService.initialize();
    });

    tearDown(() async {
      await dbService.close();
    });

    test('should handle concurrent writes gracefully', () async {
      // GIVEN: Prepare multiple write operations
      const accountId = 'concurrent-test';
      final futures = <Future<dynamic>>[];

      // WHEN: Create multiple records concurrently
      for (int i = 0; i < 5; i++) {
        futures.add(
          LogRecordService().createLogRecord(
            accountId: accountId,
            eventType: EventType.vape,
            eventAt: DateTime.now(),
            duration: 10.0 + i,
          ),
        );
      }

      // THEN: All operations should complete successfully
      final results = await Future.wait(futures);
      expect(results.length, 5);
      expect(results.every((r) => r.logId != null && r.logId.isNotEmpty), true);
    });

    test('should persist data across service instances', () async {
      // GIVEN: Create a record with one service instance
      const accountId = 'persistence-test';
      final service1 = LogRecordService();
      final record = await service1.createLogRecord(
        accountId: accountId,
        eventType: EventType.tolerance,
        eventAt: DateTime.now(),
        duration: 45.0,
        note: 'Persistence test',
      );

      // WHEN: Query with a different service instance
      final service2 = LogRecordService();
      final records = await service2.getLogRecords(accountId: accountId);

      // THEN: New instance should see the previously created record
      expect(
        records.any((r) => r.logId == record.logId),
        true,
        reason: 'Data should persist across service instances',
      );
      expect(
        records.firstWhere((r) => r.logId == record.logId).note,
        'Persistence test',
      );
    });
  });
}
