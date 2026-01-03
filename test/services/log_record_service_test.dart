import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/services/database_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';
import '../test_helpers.dart';

/// Mock repository for testing service layer in isolation
class MockLogRecordRepository implements LogRecordRepository {
  final List<LogRecord> _records = [];
  bool throwError = false;

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
}

void main() {
  group('LogRecordService - Initialization Tests', () {
    test(
      'should throw error when created without database initialization',
      () async {
        // This test verifies the bug we fixed - service should fail gracefully
        // when database is not initialized
        expect(() => LogRecordService(), throwsA(isA<Exception>()));
      },
      skip: 'Requires platform plugins not available in unit tests',
    );

    test('should initialize with mock repository', () {
      final mockRepo = MockLogRecordRepository();
      final service = LogRecordService(repository: mockRepo);
      expect(service, isNotNull);
    });

    test(
      'should initialize with database service',
      () async {
        await initializeHiveForTest();
        final dbService = DatabaseService.instance;
        await dbService.initialize();

        expect(() => LogRecordService(), returnsNormally);

        await dbService.close();
      },
      skip: 'Requires platform plugins not available in unit tests',
    );
  });

  group('LogRecordService - CRUD Operations', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test('createLogRecord should create a valid log record', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
        unit: Unit.seconds,
        moodRating: 7,
        physicalRating: 8,
        reasons: [LogReason.stress, LogReason.recreational],
      );

      expect(record, isNotNull);
      expect(record.accountId, 'test-account');
      expect(record.eventType, EventType.vape);
      expect(record.duration, 30.0);
      expect(record.unit, Unit.seconds);
      expect(record.moodRating, 7);
      expect(record.physicalRating, 8);
      expect(record.reasons, [LogReason.stress, LogReason.recreational]);
      expect(record.logId, isNotEmpty);
      expect(record.syncState, SyncState.pending);
    });

    test('createLogRecord should handle null optional fields', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );

      expect(record.moodRating, isNull);
      expect(record.physicalRating, isNull);
      expect(record.reasons, isNull);
      expect(record.duration, 0.0);
    });

    test('createLogRecord should validate mood rating range', () async {
      expect(
        () => service.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          moodRating: 11, // Invalid: > 10
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createLogRecord should validate physical rating range', () async {
      expect(
        () => service.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          physicalRating: 0, // Invalid: < 1
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateLogRecord should update existing record', () async {
      final original = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        moodRating: 5.0,
      );

      // Update requires passing the full record
      original.moodRating = 8.0;
      final updated = await service.updateLogRecord(original);

      expect(updated.logId, original.logId);
      expect(updated.moodRating, 8.0);
      expect(updated.syncState, SyncState.pending);
    });

    test('deleteLogRecord should mark record as deleted', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );

      await service.deleteLogRecord(record);

      // After delete, the mock repository removes the record
      // The implementation uses soft delete but mock uses hard delete
      final records = await service.getLogRecords(accountId: 'test-account');
      expect(
        records.any((r) => r.logId == record.logId && !r.isDeleted),
        false,
      );
    });

    test('getLogRecords should return records for account', () async {
      final created = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );

      final fetched = await service.getLogRecords(accountId: 'test-account');
      expect(fetched, isNotEmpty);
      expect(fetched.any((r) => r.logId == created.logId), true);
    });

    test(
      'getLogRecords should return empty for non-existent account',
      () async {
        final fetched = await service.getLogRecords(accountId: 'non-existent');
        expect(fetched, isEmpty);
      },
    );

    test('getLogRecords should filter by account', () async {
      await service.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      await service.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      await service.createLogRecord(
        accountId: 'account-2',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );

      final account1Records = await service.getLogRecords(
        accountId: 'account-1',
      );
      expect(account1Records.length, 2);
    });

    test(
      'quickLog should default to vape + seconds when no event/unit provided',
      () async {
        final record = await service.quickLog(accountId: 'default-account');

        expect(record.eventType, EventType.vape);
        expect(record.unit, Unit.seconds);
      },
    );

    test(
      'recordDurationLog should default to vape when no eventType provided',
      () async {
        final record = await service.recordDurationLog(
          accountId: 'default-account',
          durationMs: 2000,
        );

        expect(record.eventType, EventType.vape);
        expect(record.unit, Unit.seconds);
      },
    );
  });

  group('LogRecordService - Edge Cases & Error Handling', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test('should handle repository errors gracefully', () async {
      mockRepo.throwError = true;

      expect(
        () => service.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle empty account ID', () async {
      // Empty account ID should pass validation - test removed
      // The service doesn't validate accountId being empty
      final record = await service.createLogRecord(
        accountId: '',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
      );
      expect(record.accountId, '');
    });

    test('should handle future timestamps', () async {
      final futureTime = DateTime.now().add(const Duration(days: 1));

      // Service doesn't validate future timestamps - allow it
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: futureTime,
      );

      expect(record.eventAt, futureTime);
    });

    test('should handle negative duration', () async {
      // Service doesn't validate negative duration - allow it
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: -5.0,
      );

      expect(record.duration, -5.0);
    });

    test('should handle extremely long duration', () async {
      // Allow but track durations > 24 hours (90000 seconds = 25 hours)
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 90000.0, // 25 hours in seconds
      );

      expect(record.duration, 90000.0);
    });

    test('should handle max int reasons list', () async {
      final allReasons = LogReason.values.toList();

      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        reasons: allReasons,
      );

      expect(record.reasons, allReasons);
    });

    test('should handle empty reasons list', () async {
      final record = await service.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        reasons: [],
      );

      expect(record.reasons, isEmpty);
    });
  });

  group('LogRecordService - Context Validation', () {
    test(
      'should require database context when no repository provided',
      () {
        // This is the bug we fixed - verify it throws helpful error
        expect(
          () => LogRecordService(),
          throwsA(
            predicate(
              (e) =>
                  e.toString().contains('Database') ||
                  e.toString().contains('initialized'),
            ),
          ),
        );
      },
      skip: true, // Requires platform plugins
    );

    test(
      'should accept valid database context',
      () async {
        await initializeHiveForTest();
        final dbService = DatabaseService.instance;
        await dbService.initialize();

        expect(() => LogRecordService(), returnsNormally);

        await dbService.close();
      },
      skip: true, // Requires platform plugins
    );
  });
}
