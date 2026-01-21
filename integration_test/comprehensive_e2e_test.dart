import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/services/hive_database_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Comprehensive E2E integration tests for AshTrail app
/// These tests run on iOS simulator to catch issues before TestFlight
///
/// Run locally:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/comprehensive_e2e_test.dart \
///     -d [simulator_id]
///
/// Run all integration tests:
///   flutter test integration_test/
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // SECTION 1: APP STARTUP TESTS
  // ==========================================================================

  group('App Startup', () {
    testWidgets('App launches without crashing', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should display MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App shows either home or auth screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should have either Sign in button or Home content
      final hasAuth =
          find.textContaining('Sign').evaluate().isNotEmpty ||
          find.textContaining('Google').evaluate().isNotEmpty;
      final hasHome =
          find.byType(NavigationBar).evaluate().isNotEmpty ||
          find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
          find.byIcon(Icons.home).evaluate().isNotEmpty;

      expect(
        hasAuth || hasHome,
        isTrue,
        reason: 'App should show auth or home screen',
      );
    });
  });

  // ==========================================================================
  // SECTION 2: SERVICE LAYER TESTS (bypassing UI for reliability)
  // ==========================================================================

  group('Log Record Service', () {
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

    testWidgets('Create inhale log entry', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 2.5,
        unit: Unit.hits,
        note: 'Test inhale',
      );

      expect(record.logId, isNotEmpty);
      expect(record.eventType, EventType.inhale);
      expect(record.duration, 2.5);
      expect(record.unit, Unit.hits);
      expect(record.note, 'Test inhale');
      expect(record.syncState, SyncState.pending);
    });

    testWidgets('Create note log entry', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        note: 'Just a note',
      );

      expect(record.eventType, EventType.note);
      expect(record.note, 'Just a note');
    });

    testWidgets('Create tolerance note log entry', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.tolerance,
        note: 'Tolerance note recorded',
      );

      expect(record.eventType, EventType.tolerance);
    });

    testWidgets('Update log entry', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Original',
      );

      final updated = await logRecordService.updateLogRecord(
        record,
        duration: 5.0,
        note: 'Updated',
      );

      expect(updated.duration, 5.0);
      expect(updated.note, 'Updated');
      expect(updated.revision, greaterThan(record.revision));
    });

    testWidgets('Delete log entry', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
      );

      await logRecordService.deleteLogRecord(record);

      expect(record.isDeleted, isTrue);
      expect(record.deletedAt, isNotNull);
    });

    testWidgets('Log entry with mood and physical ratings', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        moodRating: 7.5,
        physicalRating: 8.0,
      );

      expect(record.moodRating, 7.5);
      expect(record.physicalRating, 8.0);
    });

    testWidgets('Log entry with location', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(record.latitude, 37.7749);
      expect(record.longitude, -122.4194);
      expect(record.hasLocation, isTrue);
    });

    testWidgets('Log entry with reasons', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        reasons: [LogReason.recreational, LogReason.social],
      );

      expect(record.reasons, contains(LogReason.recreational));
      expect(record.reasons, contains(LogReason.social));
    });

    testWidgets('Backdate log entry', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 3));

      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        eventAt: pastDate,
      );

      expect(record.eventAt.day, pastDate.day);
      expect(record.eventAt.month, pastDate.month);
    });
  });

  // ==========================================================================
  // SECTION 3: DATA QUERY TESTS
  // ==========================================================================

  group('Data Queries', () {
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

    testWidgets('Query by account ID', (tester) async {
      // Create entries for different accounts
      await logRecordService.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
      );

      await logRecordService.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.note,
        note: 'Note for account 1',
      );

      await logRecordService.createLogRecord(
        accountId: 'account-2',
        eventType: EventType.inhale,
        duration: 2.0,
        unit: Unit.hits,
      );

      final account1Records = await logRecordService.getLogRecords(
        accountId: 'account-1',
      );

      expect(account1Records.length, greaterThanOrEqualTo(2));
      expect(account1Records.every((r) => r.accountId == 'account-1'), isTrue);
    });

    testWidgets('Query by date range', (tester) async {
      final now = DateTime.now();

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        eventAt: now.subtract(const Duration(days: 1)),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 2.0,
        unit: Unit.hits,
        eventAt: now.subtract(const Duration(days: 3)),
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 3.0,
        unit: Unit.hits,
        eventAt: now.subtract(const Duration(days: 10)),
      );

      final weekRecords = await logRecordService.getLogRecords(
        accountId: 'test-account',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );

      // Should find at least the 2 records within the week
      expect(weekRecords.length, greaterThanOrEqualTo(2));
    });

    testWidgets('Query by event type', (tester) async {
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        note: 'A note',
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.tolerance,
        note: 'A tolerance note',
      );

      final inhaleRecords = await logRecordService.getLogRecords(
        accountId: 'test-account',
        eventTypes: [EventType.inhale],
      );

      expect(
        inhaleRecords.every((r) => r.eventType == EventType.inhale),
        isTrue,
      );
    });
  });

  // ==========================================================================
  // SECTION 4: STATISTICS TESTS
  // ==========================================================================

  group('Statistics', () {
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

    testWidgets('Calculate total count', (tester) async {
      final now = DateTime.now();

      for (int i = 0; i < 5; i++) {
        await logRecordService.createLogRecord(
          accountId: 'stats-account',
          eventType: EventType.inhale,
          duration: 1.0,
          unit: Unit.hits,
          eventAt: now.subtract(Duration(days: i)),
        );
      }

      final stats = await logRecordService.getStatistics(
        accountId: 'stats-account',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );

      expect(stats['totalCount'], greaterThanOrEqualTo(5));
    });

    testWidgets('Calculate total duration', (tester) async {
      final now = DateTime.now();

      await logRecordService.createLogRecord(
        accountId: 'duration-account',
        eventType: EventType.inhale,
        duration: 2.0,
        unit: Unit.hits,
        eventAt: now.subtract(const Duration(days: 1)),
      );

      await logRecordService.createLogRecord(
        accountId: 'duration-account',
        eventType: EventType.inhale,
        duration: 3.0,
        unit: Unit.hits,
        eventAt: now.subtract(const Duration(days: 2)),
      );

      final stats = await logRecordService.getStatistics(
        accountId: 'duration-account',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );

      expect(stats['totalDuration'], greaterThanOrEqualTo(5.0));
    });
  });

  // ==========================================================================
  // SECTION 5: DATA PERSISTENCE TESTS
  // ==========================================================================

  group('Data Persistence', () {
    testWidgets('Data survives service recreation', (tester) async {
      final dbService = HiveDatabaseService();
      await dbService.initialize();

      var logRecordService = LogRecordService();

      final record = await logRecordService.createLogRecord(
        accountId: 'persist-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Persistent entry',
      );

      final logId = record.logId;

      // Recreate service (simulates app restart)
      logRecordService = LogRecordService();

      final retrieved = await logRecordService.getLogRecordByLogId(logId);

      expect(retrieved, isNotNull);
      expect(retrieved!.note, 'Persistent entry');

      await dbService.close();
    });
  });

  // ==========================================================================
  // SECTION 6: EDGE CASE TESTS
  // ==========================================================================

  group('Edge Cases', () {
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

    testWidgets('Handle empty note', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: '',
      );

      expect(record.note, '');
    });

    testWidgets('Handle zero duration', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 0.0,
        unit: Unit.hits,
      );

      expect(record.duration, 0.0);
    });

    testWidgets('Handle large duration', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 999.0,
        unit: Unit.hits,
      );

      expect(record.duration, 999.0);
    });

    testWidgets('Handle minimum mood rating', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        moodRating: 1.0,
      );

      expect(record.moodRating, 1.0);
    });

    testWidgets('Handle maximum mood rating', (tester) async {
      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        moodRating: 10.0,
      );

      expect(record.moodRating, 10.0);
    });

    testWidgets('Handle long note text', (tester) async {
      final longNote = 'A' * 1000;

      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        note: longNote,
      );

      expect(record.note, longNote);
      expect(record.note!.length, 1000);
    });

    testWidgets('Handle special characters in note', (tester) async {
      final specialNote =
          'Test with émojis 🎉 and spëcial chàracters!@#\$%^&*()';

      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        note: specialNote,
      );

      expect(record.note, specialNote);
    });

    testWidgets('Handle all event types', (tester) async {
      for (final eventType in EventType.values) {
        final record = await logRecordService.createLogRecord(
          accountId: 'test-account',
          eventType: eventType,
          duration: 1.0,
          unit: Unit.hits,
          note: 'Test for $eventType',
        );

        expect(record.eventType, eventType);
      }
    });

    testWidgets('Handle all unit types', (tester) async {
      for (final unit in Unit.values) {
        final record = await logRecordService.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.inhale,
          duration: 1.0,
          unit: unit,
        );

        expect(record.unit, unit);
      }
    });

    testWidgets('Handle all reason types', (tester) async {
      for (final reason in LogReason.values) {
        final record = await logRecordService.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.inhale,
          duration: 1.0,
          unit: Unit.hits,
          reasons: [reason],
        );

        expect(record.reasons, contains(reason));
      }
    });

    testWidgets('Handle multiple reasons', (tester) async {
      final allReasons = LogReason.values.toList();

      final record = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        reasons: allReasons,
      );

      expect(record.reasons!.length, allReasons.length);
    });
  });

  // ==========================================================================
  // SECTION 7: CONCURRENT OPERATIONS TESTS
  // ==========================================================================

  group('Concurrent Operations', () {
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

    testWidgets('Create multiple records concurrently', (tester) async {
      final futures = <Future>[];

      for (int i = 0; i < 10; i++) {
        futures.add(
          logRecordService.createLogRecord(
            accountId: 'concurrent-account',
            eventType: EventType.inhale,
            duration: i.toDouble(),
            unit: Unit.hits,
            note: 'Concurrent $i',
          ),
        );
      }

      final results = await Future.wait(futures);

      expect(results.length, 10);

      // Verify all have unique IDs
      final ids = results.map((r) => r.logId).toSet();
      expect(ids.length, 10);
    });
  });
}
