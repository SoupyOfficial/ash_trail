import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/services/hive_database_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Integration tests for the logging flow
/// Tests UI interactions and data persistence
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Logging Flow', () {
    late HiveDatabaseService dbService;
    late LogRecordService logRecordService;

    setUp(() async {
      // Initialize services
      dbService = HiveDatabaseService();
      await dbService.initialize();
      logRecordService = LogRecordService();
    });

    tearDown(() async {
      // Clean up - close database
      await dbService.close();
    });

    testWidgets('App starts correctly', (tester) async {
      // Start the app
      await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));
      await tester.pumpAndSettle();

      // App should start and show something (auth screen or home)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Create log entry via service', (tester) async {
      // Create a log entry directly
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account-123',
        eventType: EventType.inhale,
        duration: 2.0,
        unit: Unit.hits,
        note: 'Test log entry',
      );

      expect(logRecord.logId, isNotEmpty);
      expect(logRecord.accountId, 'test-account-123');
      expect(logRecord.eventType, EventType.inhale);
      expect(logRecord.duration, 2.0);
      expect(logRecord.unit, Unit.hits);
      expect(logRecord.note, 'Test log entry');
      expect(logRecord.syncState, SyncState.pending);
    });

    testWidgets('Edit log entry via service', (tester) async {
      // Create entry
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account-123',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Original note',
      );

      // Update entry
      final updated = await logRecordService.updateLogRecord(
        logRecord,
        duration: 3.0,
        note: 'Updated note',
      );

      expect(updated.duration, 3.0);
      expect(updated.note, 'Updated note');
      expect(updated.revision, greaterThan(logRecord.revision));
    });

    testWidgets('Delete log entry via service', (tester) async {
      // Create entry
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account-123',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
      );

      // Delete entry (soft delete)
      await logRecordService.deleteLogRecord(logRecord);

      // Verify it's marked as deleted
      expect(logRecord.isDeleted, true);
      expect(logRecord.deletedAt, isNotNull);
    });

    testWidgets('Query log entries by account', (tester) async {
      // Create multiple entries
      await logRecordService.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
      );

      await logRecordService.createLogRecord(
        accountId: 'account-1',
        eventType: EventType.note,
        note: 'A note',
      );

      await logRecordService.createLogRecord(
        accountId: 'account-2',
        eventType: EventType.inhale,
        duration: 2.0,
        unit: Unit.hits,
      );

      // Query for account-1
      final records = await logRecordService.getLogRecords(
        accountId: 'account-1',
      );

      expect(records.length, 2);
      expect(records.every((r) => r.accountId == 'account-1'), true);
    });

    testWidgets('Log entry with mood and physical ratings', (tester) async {
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        moodRating: 7.5,
        physicalRating: 8.0,
      );

      expect(logRecord.moodRating, 7.5);
      expect(logRecord.physicalRating, 8.0);
    });

    testWidgets('Log entry with location', (tester) async {
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(logRecord.latitude, 37.7749);
      expect(logRecord.longitude, -122.4194);
      expect(logRecord.hasLocation, true);
    });

    testWidgets('Log entry with reason', (tester) async {
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        reasons: [LogReason.recreational],
      );

      expect(logRecord.reasons, contains(LogReason.recreational));
    });

    testWidgets('Statistics calculation', (tester) async {
      final now = DateTime.now();

      // Create sample data
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        eventAt: now.subtract(const Duration(days: 1)),
        duration: 2.0,
        unit: Unit.hits,
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        eventAt: now.subtract(const Duration(days: 2)),
        duration: 3.0,
        unit: Unit.hits,
      );

      final stats = await logRecordService.getStatistics(
        accountId: 'test-account',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );

      expect(stats['totalCount'], 2);
      expect(stats['totalDuration'], 5.0);
    });
  });

  group('Data Persistence', () {
    testWidgets('Data persists after service recreation', (tester) async {
      final dbService = HiveDatabaseService();
      await dbService.initialize();

      var logRecordService = LogRecordService();

      // Create entry
      final logRecord = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        duration: 1.0,
        unit: Unit.hits,
        note: 'Persistent entry',
      );

      final logId = logRecord.logId;

      // Recreate service (simulating app restart)
      logRecordService = LogRecordService();

      // Verify entry still exists
      final retrieved = await logRecordService.getLogRecordByLogId(logId);

      expect(retrieved, isNotNull);
      expect(retrieved!.note, 'Persistent entry');

      await dbService.close();
    });
  });
}
