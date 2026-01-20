/// Data Integrity Service Test Suite
///
/// Tests for the DataIntegrityService which detects and repairs
/// data integrity issues such as:
/// - Orphaned records (invalid accountId)
/// - Duplicate logIds
/// - Invalid timestamps
/// - Invalid ratings
/// - Invalid location data
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/data_integrity_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';
import 'package:ash_trail/repositories/account_repository.dart';

// Test constants
const kAccount1 = 'test-account-001';
const kAccount2 = 'test-account-002';
const kOrphanAccount = 'deleted-account-999';

/// Mock Account Repository
class MockAccountRepository implements AccountRepository {
  final List<Account> _accounts = [];
  String? _activeUserId;

  void addAccount(Account account) {
    _accounts.add(account);
    if (account.isActive) {
      _activeUserId = account.userId;
    }
  }

  @override
  Future<List<Account>> getAll() async => _accounts;

  @override
  Future<Account?> getActive() async {
    if (_activeUserId == null) return null;
    try {
      return _accounts.firstWhere((a) => a.userId == _activeUserId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Account?> getByUserId(String userId) async {
    try {
      return _accounts.firstWhere((a) => a.userId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Account> save(Account account) async {
    final index = _accounts.indexWhere((a) => a.userId == account.userId);
    if (index >= 0) {
      _accounts[index] = account;
    } else {
      _accounts.add(account);
    }
    return account;
  }

  @override
  Future<void> setActive(String userId) async {
    _activeUserId = userId;
  }

  @override
  Future<void> clearActive() async {
    _activeUserId = null;
  }

  @override
  Future<void> delete(String userId) async {
    _accounts.removeWhere((a) => a.userId == userId);
    if (_activeUserId == userId) {
      _activeUserId = null;
    }
  }

  @override
  Stream<Account?> watchActive() => Stream.value(null);

  @override
  Stream<List<Account>> watchAll() => Stream.value(_accounts);
}

/// Mock Log Record Repository
class MockLogRecordRepository implements LogRecordRepository {
  final List<LogRecord> _records = [];

  List<LogRecord> get allRecords => List.unmodifiable(_records);

  void addRecord(LogRecord record) {
    _records.add(record);
  }

  void clear() {
    _records.clear();
  }

  @override
  Future<LogRecord> create(LogRecord record) async {
    _records.add(record);
    return record;
  }

  @override
  Future<LogRecord> update(LogRecord record) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record;
    }
    return record;
  }

  @override
  Future<void> delete(String logId) async {
    // Remove only the first match (simulating deletion by specific record)
    final index = _records.indexWhere((r) => r.logId == logId);
    if (index >= 0) {
      _records.removeAt(index);
    }
  }

  @override
  Future<LogRecord?> getByLogId(String logId) async {
    try {
      return _records.firstWhere((r) => r.logId == logId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LogRecord>> getAll() async {
    return List.from(_records);
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
}

/// Mock AccountService that implements AccountIntegrityValidator
class MockAccountValidator implements AccountIntegrityValidator {
  final MockAccountRepository _mockRepo;

  MockAccountValidator(this._mockRepo);

  void addAccount(Account account) {
    _mockRepo.addAccount(account);
  }

  @override
  Future<bool> accountExists(String userId) async {
    final account = await _mockRepo.getByUserId(userId);
    return account != null;
  }

  @override
  Future<Set<String>> getAllAccountIds() async {
    final accounts = await _mockRepo.getAll();
    return accounts.map((a) => a.userId).toSet();
  }
}

void main() {
  group('DataIntegrityService - Detection Tests', () {
    late MockAccountRepository mockAccountRepo;
    late MockLogRecordRepository mockLogRepo;
    late MockAccountValidator mockAccountValidator;
    late DataIntegrityService integrityService;

    setUp(() {
      mockAccountRepo = MockAccountRepository();
      mockLogRepo = MockLogRecordRepository();
      mockAccountValidator = MockAccountValidator(mockAccountRepo);

      // Add test accounts
      mockAccountValidator.addAccount(
        Account.create(
          userId: kAccount1,
          email: 'test1@example.com',
          displayName: 'Test User 1',
        ),
      );
      mockAccountValidator.addAccount(
        Account.create(
          userId: kAccount2,
          email: 'test2@example.com',
          displayName: 'Test User 2',
        ),
      );

      integrityService = DataIntegrityService(
        accountValidator: mockAccountValidator,
        repository: mockLogRepo,
      );
    });

    test('healthy data passes integrity check', () async {
      // Add valid records
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'log-1',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          moodRating: 5.0,
        ),
      );
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'log-2',
          accountId: kAccount2,
          eventType: EventType.inhale,
          eventAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isTrue);
      expect(result.totalIssues, 0);
    });

    test('detects orphaned records', () async {
      // Add a record with invalid accountId
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan-log',
          accountId: kOrphanAccount, // This account doesn't exist
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      // Also add a valid record
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'valid-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.orphanedRecords.length, 1);
      expect(result.orphanedRecords.first.logId, 'orphan-log');
    });

    test('detects duplicate logIds', () async {
      final now = DateTime.now();

      // Add two records with same logId
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'duplicate-id',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(hours: 2)),
        ),
      );
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'duplicate-id', // Same ID!
          accountId: kAccount1,
          eventType: EventType.inhale,
          eventAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.duplicateRecords.containsKey('duplicate-id'), isTrue);
      expect(result.duplicateRecords['duplicate-id']!.length, 2);
    });

    test('detects invalid timestamps - future date', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'future-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now().add(const Duration(days: 7)), // Future!
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidTimestampRecords.length, 1);
      expect(result.invalidTimestampRecords.first.logId, 'future-log');
    });

    test('detects invalid timestamps - very old date', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'ancient-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime(1990, 1, 1), // Too old!
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidTimestampRecords.length, 1);
    });

    test('detects invalid mood ratings', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'bad-mood-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          moodRating: 15.0, // Invalid: > 10
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidRatingRecords.length, 1);
    });

    test('detects invalid physical ratings', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'bad-physical-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          physicalRating: -5.0, // Invalid: < 1
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidRatingRecords.length, 1);
    });

    test('detects invalid location - latitude only', () async {
      final record = LogRecord.create(
        logId: 'bad-location-log',
        accountId: kAccount1,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      record.latitude = 45.0;
      record.longitude = null; // Missing!
      mockLogRepo.addRecord(record);

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidLocationRecords.length, 1);
    });

    test('detects invalid location - longitude only', () async {
      final record = LogRecord.create(
        logId: 'bad-location-log-2',
        accountId: kAccount1,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      record.latitude = null; // Missing!
      record.longitude = -120.0;
      mockLogRepo.addRecord(record);

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.invalidLocationRecords.length, 1);
    });

    test('detects multiple issues simultaneously', () async {
      // Orphaned record
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan',
          accountId: kOrphanAccount,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      // Invalid rating
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'bad-rating',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          moodRating: 999.0,
        ),
      );

      // Future timestamp
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'future',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      final result = await integrityService.runIntegrityCheck();

      expect(result.isHealthy, isFalse);
      expect(result.totalIssues, greaterThanOrEqualTo(3));
    });
  });

  group('DataIntegrityService - Repair Tests', () {
    late MockAccountRepository mockAccountRepo;
    late MockLogRecordRepository mockLogRepo;
    late MockAccountValidator mockAccountValidator;
    late DataIntegrityService integrityService;

    setUp(() {
      mockAccountRepo = MockAccountRepository();
      mockLogRepo = MockLogRecordRepository();
      mockAccountValidator = MockAccountValidator(mockAccountRepo);

      mockAccountValidator.addAccount(
        Account.create(
          userId: kAccount1,
          email: 'test1@example.com',
          displayName: 'Test User 1',
        ),
      );
      mockAccountValidator.addAccount(
        Account.create(
          userId: kAccount2,
          email: 'test2@example.com',
          displayName: 'Test User 2',
        ),
      );

      integrityService = DataIntegrityService(
        accountValidator: mockAccountValidator,
        repository: mockLogRepo,
      );
    });

    test('repairs invalid ratings by clamping', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'high-rating',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          moodRating: 15.0,
          physicalRating: -3.0,
        ),
      );

      final checkResult = await integrityService.runIntegrityCheck();
      expect(checkResult.invalidRatingRecords.length, 1);

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        fixRatings: true,
      );

      expect(repairResult.success, isTrue);
      expect(repairResult.ratingsFixed, 1);

      // Verify the record was fixed
      final fixedRecord = await mockLogRepo.getByLogId('high-rating');
      expect(fixedRecord?.moodRating, 10.0); // Clamped to max
      expect(fixedRecord?.physicalRating, 1.0); // Clamped to min
    });

    test('repairs invalid locations by clearing', () async {
      final record = LogRecord.create(
        logId: 'partial-location',
        accountId: kAccount1,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      record.latitude = 45.0;
      record.longitude = null;
      mockLogRepo.addRecord(record);

      final checkResult = await integrityService.runIntegrityCheck();
      expect(checkResult.invalidLocationRecords.length, 1);

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        clearInvalidLocations: true,
      );

      expect(repairResult.success, isTrue);
      expect(repairResult.locationsCleared, 1);

      // Verify location was cleared
      final fixedRecord = await mockLogRepo.getByLogId('partial-location');
      expect(fixedRecord?.latitude, isNull);
      expect(fixedRecord?.longitude, isNull);
    });

    test('removes duplicate records keeping newest', () async {
      final now = DateTime.now();

      // Older duplicate
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'dup-id',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(hours: 5)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
      );

      // Newer duplicate (should be kept)
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'dup-id',
          accountId: kAccount1,
          eventType: EventType.inhale,
          eventAt: now.subtract(const Duration(hours: 1)),
          updatedAt: now.subtract(const Duration(hours: 1)),
        ),
      );

      expect(mockLogRepo.allRecords.length, 2);

      final checkResult = await integrityService.runIntegrityCheck();
      expect(checkResult.duplicateRecords.length, 1);

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        removeDuplicates: true,
      );

      expect(repairResult.success, isTrue);
      expect(repairResult.duplicatesRemoved, 1);
      expect(mockLogRepo.allRecords.length, 1);

      // Verify the newer one was kept
      final remaining = await mockLogRepo.getByLogId('dup-id');
      expect(remaining?.eventType, EventType.inhale);
    });

    test('reassigns orphaned records to target account', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan-log',
          accountId: kOrphanAccount,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final checkResult = await integrityService.runIntegrityCheck();
      expect(checkResult.orphanedRecords.length, 1);

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        targetAccountId: kAccount1,
      );

      expect(repairResult.success, isTrue);
      expect(repairResult.orphansReassigned, 1);

      // Verify record was reassigned
      final records = await mockLogRepo.getByAccount(kAccount1);
      expect(records.length, 1);
      expect(records.first.logId, 'orphan-log');
    });

    test('fails to repair orphans without target account', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan-log',
          accountId: kOrphanAccount,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final checkResult = await integrityService.runIntegrityCheck();

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        targetAccountId: null, // No target!
      );

      expect(repairResult.success, isFalse);
      expect(repairResult.errors.length, 1);
      expect(repairResult.orphansReassigned, 0);
    });

    test('fails to repair orphans with invalid target account', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan-log',
          accountId: kOrphanAccount,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final checkResult = await integrityService.runIntegrityCheck();

      final repairResult = await integrityService.repairIssues(
        checkResult: checkResult,
        targetAccountId: 'non-existent-account',
      );

      expect(repairResult.success, isFalse);
      expect(repairResult.errors.length, 1);
    });
  });

  group('DataIntegrityService - Utility Methods', () {
    late MockAccountRepository mockAccountRepo;
    late MockLogRecordRepository mockLogRepo;
    late MockAccountValidator mockAccountValidator;
    late DataIntegrityService integrityService;

    setUp(() {
      mockAccountRepo = MockAccountRepository();
      mockLogRepo = MockLogRecordRepository();
      mockAccountValidator = MockAccountValidator(mockAccountRepo);

      mockAccountValidator.addAccount(
        Account.create(
          userId: kAccount1,
          email: 'test1@example.com',
          displayName: 'Test User 1',
        ),
      );

      integrityService = DataIntegrityService(
        accountValidator: mockAccountValidator,
        repository: mockLogRepo,
      );
    });

    test('isDataHealthy returns true for healthy data', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'valid-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final isHealthy = await integrityService.isDataHealthy();
      expect(isHealthy, isTrue);
    });

    test('isDataHealthy returns false for unhealthy data', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan',
          accountId: kOrphanAccount,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final isHealthy = await integrityService.isDataHealthy();
      expect(isHealthy, isFalse);
    });

    test('getHealthSummary returns readable string', () async {
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'valid-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      final summary = await integrityService.getHealthSummary();
      expect(summary, contains('✅'));
    });

    test('checkAccountIntegrity checks specific account only', () async {
      // Add valid record to account 1
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'a1-log',
          accountId: kAccount1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          moodRating: 5.0,
        ),
      );

      // Add invalid record to account 2 (orphan since account 2 not added)
      mockLogRepo.addRecord(
        LogRecord.create(
          logId: 'orphan-log',
          accountId: 'non-existent',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
      );

      // Check only account 1 - should be healthy
      final result = await integrityService.checkAccountIntegrity(kAccount1);
      expect(result.isHealthy, isTrue);
    });
  });
}
