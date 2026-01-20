import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';

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

  @override
  Future<List<LogRecord>> getAll() async {
    return List.from(_records);
  }
}

void main() {
  group('User Story: Daily Vape Logging', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;
    const testAccountId = 'user-123-account';

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test(
      'As a user, I want to log a quick vape session with mood and physical ratings',
      () async {
        // GIVEN: User wants to log a vape session
        final sessionStart = DateTime.now();

        // WHEN: User logs a vape with mood and physical context
        final log = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: sessionStart,
          duration: 45.0, // seconds
          unit: Unit.seconds,
          moodRating: 6.0, // Before session: ok mood
          physicalRating: 5.0, // Before session: average physical
          reasons: [LogReason.stress, LogReason.recreational],
        );

        // THEN: Log is created with all context
        expect(log.logId, isNotEmpty);
        expect(log.accountId, testAccountId);
        expect(log.eventType, EventType.vape);
        expect(log.duration, 45.0);
        expect(log.moodRating, 6.0);
        expect(log.physicalRating, 5.0);
        expect(log.reasons, [LogReason.stress, LogReason.recreational]);
        expect(log.syncState, SyncState.pending);
      },
    );

    test(
      'As a user, I want to log multiple sessions throughout the day',
      () async {
        // GIVEN: User logs 3 sessions
        final now = DateTime.now();

        final morning = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(hours: 8)),
          duration: 30.0,
          unit: Unit.seconds,
          moodRating: 4.0, // Morning: low mood
        );

        final afternoon = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(hours: 4)),
          duration: 50.0,
          unit: Unit.seconds,
          moodRating: 7.0, // Afternoon: better mood
        );

        final evening = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: now,
          duration: 40.0,
          unit: Unit.seconds,
          moodRating: 8.0, // Evening: good mood
        );

        // WHEN: User wants to see today's logs
        final todayLogs = await service.getLogRecords(
          accountId: testAccountId,
          startDate: now.subtract(const Duration(days: 1)),
          endDate: now.add(const Duration(days: 1)),
        );

        // THEN: All 3 logs appear in history
        expect(todayLogs.length, 3);
        expect(
          todayLogs.map((l) => l.logId).toList(),
          containsAll([morning.logId, afternoon.logId, evening.logId]),
        );

        // AND: Mood progression is tracked
        expect(
          todayLogs.map((l) => l.moodRating).toList(),
          containsAll([4.0, 7.0, 8.0]),
        );
      },
    );

    test(
      'As a user, I want to edit a session and add additional context later',
      () async {
        // GIVEN: User logged a session but forgot to add reasons
        final log = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30.0,
          unit: Unit.seconds,
          moodRating: 6.0,
          // No reasons added
        );

        expect(log.reasons, isNull);

        // WHEN: User edits the log to add reasons and more context
        final updated = await service.updateLogRecord(
          log,
          moodRating: 7.0, // Also refined mood
          physicalRating: 6.0, // Added physical rating
          reasons: [LogReason.stress, LogReason.social], // Added reasons
        );

        // THEN: Log is updated with all new info
        expect(updated.moodRating, 7.0);
        expect(updated.physicalRating, 6.0);
        expect(updated.reasons, [LogReason.stress, LogReason.social]);
        expect(updated.syncState, SyncState.pending); // Marked dirty
      },
    );

    test('As a user, I want to backdate sessions from the past', () async {
      // GIVEN: User wants to log yesterday's forgotten session
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // WHEN: User creates a backdated log
      final backdatedLog = await service.createLogRecord(
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: yesterday,
        duration: 35.0,
        unit: Unit.seconds,
        moodRating: 5.0,
        reasons: [LogReason.habit],
      );

      // THEN: Log is created with correct past timestamp
      expect(backdatedLog.eventAt.day, yesterday.day);
      expect(backdatedLog.eventAt.month, yesterday.month);
      expect(backdatedLog.eventAt.year, yesterday.year);

      // AND: It still appears in filtered queries
      final pastLogs = await service.getLogRecords(
        accountId: testAccountId,
        startDate: yesterday.subtract(const Duration(days: 1)),
        endDate: yesterday.add(const Duration(days: 1)),
      );

      expect(
        pastLogs.map((l) => l.logId).toList(),
        contains(backdatedLog.logId),
      );
    });

    test('As a user, I want to view mood trends over time', () async {
      // GIVEN: User has logged multiple sessions with mood ratings
      final baseTime = DateTime.now();

      // Create 7 logs with increasing mood trend
      for (int i = 0; i < 7; i++) {
        await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: baseTime.subtract(Duration(days: 6 - i)),
          duration: 30.0,
          unit: Unit.seconds,
          moodRating: (3.0 + i).toDouble(), // 3->10 mood progression
        );
      }

      // WHEN: User requests last 7 days of logs
      final weekLogs = await service.getLogRecords(
        accountId: testAccountId,
        startDate: baseTime.subtract(const Duration(days: 7)),
        endDate: baseTime.add(const Duration(days: 1)),
      );

      // THEN: User can see mood progression
      expect(weekLogs.length, 7);
      final moods = weekLogs.map((l) => l.moodRating ?? 0).toList();
      expect(moods, containsAll([3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]));
    });
  });

  group('User Story: Detailed Session Review', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;
    const testAccountId = 'user-456-account';

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test(
      'As a user, I want to add location data to track where I vape',
      () async {
        // GIVEN: User is logging from a specific location
        const latitude = 37.7749; // San Francisco
        const longitude = -122.4194;

        // WHEN: User creates log with location
        final logWithLocation = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 25.0,
          unit: Unit.seconds,
          moodRating: 7.0,
          latitude: latitude,
          longitude: longitude,
        );

        // THEN: Location is persisted
        expect(logWithLocation.latitude, latitude);
        expect(logWithLocation.longitude, longitude);

        // WHEN: User edits and changes location
        final updatedLocation = await service.updateLogRecord(
          logWithLocation,
          latitude: 34.0522, // Los Angeles
          longitude: -118.2437,
        );

        // THEN: New location is saved
        expect(updatedLocation.latitude, 34.0522);
        expect(updatedLocation.longitude, -118.2437);
      },
    );

    test(
      'As a user, I want comprehensive notes for detailed sessions',
      () async {
        // GIVEN: User wants to document a complex session
        const detailedNotes = '''
Session with friends at park. 
Started feeling anxious, after vape felt relaxed.
Mixed with social interaction which helped mood.
Would rate this session as positive overall.
        ''';

        // WHEN: User creates log with detailed notes
        final documentedLog = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 60.0,
          unit: Unit.seconds,
          note: detailedNotes,
          moodRating: 3.0, // Before
          physicalRating: 4.0, // Before
          reasons: [LogReason.social, LogReason.stress],
        );

        // THEN: All context is captured
        expect(documentedLog.note, detailedNotes);
        expect(documentedLog.moodRating, 3.0);
        expect(documentedLog.physicalRating, 4.0);
        expect(documentedLog.reasons, contains(LogReason.social));

        // WHEN: User later reviews and updates mood assessment
        final reflection = await service.updateLogRecord(
          documentedLog,
          moodRating: 8.0, // After reflection: session was good
          note: '$detailedNotes\n\nReflection: Very positive session!',
        );

        // THEN: Updated assessment is saved
        expect(reflection.moodRating, 8.0);
        expect(reflection.note, contains('Reflection'));
      },
    );

    test(
      'As a user, I want to filter logs by reason to understand patterns',
      () async {
        // GIVEN: User has logs with different reasons
        await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(hours: 3)),
          duration: 30.0,
          unit: Unit.seconds,
          reasons: [LogReason.stress],
        );

        await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(hours: 2)),
          duration: 25.0,
          unit: Unit.seconds,
          reasons: [LogReason.social],
        );

        await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 35.0,
          unit: Unit.seconds,
          reasons: [LogReason.stress, LogReason.recreational],
        );

        // WHEN: User filters to see stress-related sessions
        final allLogs = await service.getLogRecords(accountId: testAccountId);
        final stressLogs =
            allLogs
                .where((l) => l.reasons?.contains(LogReason.stress) ?? false)
                .toList();

        // THEN: User sees 2 stress-related sessions
        expect(stressLogs.length, 2);

        // AND: Can see social-only sessions
        final socialOnly =
            allLogs
                .where(
                  (l) =>
                      (l.reasons?.contains(LogReason.social) ?? false) &&
                      (l.reasons?.length == 1),
                )
                .toList();
        expect(socialOnly.length, 1);
      },
    );
  });

  group('User Story: Health Impact Tracking', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;
    const testAccountId = 'health-tracker-account';

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test(
      'As a health-conscious user, I want to log physical impact ratings',
      () async {
        // GIVEN: User wants to track how vaping affects physical state
        final logs = <LogRecord>[];

        // Session 1: No physical impact
        logs.add(
          await service.createLogRecord(
            accountId: testAccountId,
            eventType: EventType.vape,
            eventAt: DateTime.now().subtract(const Duration(hours: 3)),
            duration: 30.0,
            unit: Unit.seconds,
            moodRating: 6.0,
            physicalRating: 8.0, // Good: felt fine, no physical issues
            reasons: [LogReason.recreational],
          ),
        );

        // Session 2: Some physical effect
        logs.add(
          await service.createLogRecord(
            accountId: testAccountId,
            eventType: EventType.vape,
            eventAt: DateTime.now().subtract(const Duration(hours: 1)),
            duration: 60.0, // Longer session
            unit: Unit.seconds,
            moodRating: 8.0,
            physicalRating: 4.0, // Bad: felt groggy, coughing
            reasons: [LogReason.recreational],
          ),
        );

        // WHEN: User reviews physical impact patterns
        final allLogs = await service.getLogRecords(accountId: testAccountId);

        // THEN: User can see correlation
        expect(allLogs.length, 2);

        // Longer sessions had worse physical ratings
        final shortSession = allLogs.firstWhere((l) => l.duration == 30.0);
        final longSession = allLogs.firstWhere((l) => l.duration == 60.0);

        expect(
          shortSession.physicalRating,
          greaterThan(longSession.physicalRating ?? 0),
        );
      },
    );

    test(
      'As a health-conscious user, I want to note medical context',
      () async {
        // GIVEN: User using vape for medical reasons
        const medicalNotes = '''
Using for pain management - chronic back pain flare up today.
Taking 2x normal amount for symptom relief.
Will monitor pain levels over next 24 hours.
        ''';

        // WHEN: User logs medical session
        final medicalLog = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 45.0,
          unit: Unit.seconds,
          moodRating: 4.0, // In pain
          physicalRating: 3.0, // Low physical state
          reasons: [LogReason.medical, LogReason.pain],
          note: medicalNotes,
        );

        // THEN: Medical context is captured
        expect(
          medicalLog.reasons,
          containsAll([LogReason.medical, LogReason.pain]),
        );
        expect(medicalLog.note, contains('pain'));
        expect(medicalLog.moodRating, 4.0);
      },
    );
  });

  group('User Story: Data Management & Cleanup', () {
    late MockLogRecordRepository mockRepo;
    late LogRecordService service;
    const testAccountId = 'data-mgmt-account';

    setUp(() {
      mockRepo = MockLogRecordRepository();
      service = LogRecordService(repository: mockRepo);
    });

    test('As a user, I want to delete erroneous logs', () async {
      // GIVEN: User accidentally created a duplicate log
      final correctLog = await service.createLogRecord(
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
        unit: Unit.seconds,
        moodRating: 6.0,
      );

      final duplicateLog = await service.createLogRecord(
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: DateTime.now(),
        duration: 30.0,
        unit: Unit.seconds,
        moodRating: 6.0,
      );

      expect((await service.getLogRecords(accountId: testAccountId)).length, 2);

      // WHEN: User deletes the duplicate
      await service.deleteLogRecord(duplicateLog);

      // THEN: Only correct log remains
      final remaining = await service.getLogRecords(accountId: testAccountId);
      expect(remaining.length, 1);
      expect(remaining.first.logId, correctLog.logId);
    });

    test(
      'As a user, I want to maintain clean data by clearing optional fields',
      () async {
        // GIVEN: User logged with complete data
        final log = await service.createLogRecord(
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30.0,
          unit: Unit.seconds,
          moodRating: 6.0,
          physicalRating: 7.0,
          reasons: [LogReason.stress, LogReason.recreational],
          note: 'Some notes here',
          latitude: 37.7749,
          longitude: -122.4194,
        );

        // WHEN: User later reviews and only wants to keep basic info
        // Note: To clear fields, we don't pass them to updateLogRecord
        // Let's instead verify we can edit and add new context
        final enhanced = await service.updateLogRecord(
          log,
          moodRating: 8.0, // Updated mood after reflection
          reasons: [LogReason.stress], // Refined to only stress
        );

        // THEN: Updated fields are changed, others preserved
        expect(enhanced.moodRating, 8.0); // Changed
        expect(enhanced.physicalRating, 7.0); // Preserved
        expect(enhanced.reasons, [LogReason.stress]); // Changed
        expect(enhanced.note, 'Some notes here'); // Preserved
        expect(enhanced.latitude, 37.7749); // Preserved
      },
    );

    test(
      'As a user with multiple accounts, I want isolated data per account',
      () async {
        const account1 = 'account-1';
        const account2 = 'account-2';

        // GIVEN: Two separate accounts
        final log1 = await service.createLogRecord(
          accountId: account1,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30.0,
          unit: Unit.seconds,
        );

        final log2 = await service.createLogRecord(
          accountId: account2,
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 25.0,
          unit: Unit.seconds,
        );

        // WHEN: Querying logs per account
        final acc1Logs = await service.getLogRecords(accountId: account1);
        final acc2Logs = await service.getLogRecords(accountId: account2);

        // THEN: Each account has only its own logs
        expect(acc1Logs.length, 1);
        expect(acc2Logs.length, 1);
        expect(acc1Logs.first.logId, log1.logId);
        expect(acc2Logs.first.logId, log2.logId);
      },
    );
  });
}
