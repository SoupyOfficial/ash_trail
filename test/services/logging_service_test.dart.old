import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:ash_trail/services/isar_service.dart';
import 'package:ash_trail/services/logging_service.dart';
import 'package:ash_trail/models/log_entry.dart';
import 'dart:io';

void main() {
  late Isar isar;
  late LoggingService loggingService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync();
    isar = await Isar.open(
      [AccountSchema, LogEntrySchema, SyncMetadataSchema],
      directory: dir.path,
      name: 'test_${DateTime.now().millisecondsSinceEpoch}',
    );

    IsarService.initialize = () async => isar;
    loggingService = LoggingService();
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('LoggingService Tests', () {
    test(
      'createLogEntry should create entry with auto-generated UUID',
      () async {
        final entry = await loggingService.createLogEntry(
          userId: 'user_123',
          notes: 'Test entry',
          amount: 1.5,
        );

        expect(entry.entryId, isNotEmpty);
        expect(entry.userId, 'user_123');
        expect(entry.notes, 'Test entry');
        expect(entry.amount, 1.5);
        expect(entry.syncState, SyncState.pending);
      },
    );

    test('quickLog should create entry quickly', () async {
      final entry = await loggingService.quickLog(
        userId: 'user_123',
        amount: 2.0,
      );

      expect(entry.userId, 'user_123');
      expect(entry.amount, 2.0);
      expect(entry.syncState, SyncState.pending);
    });

    test('getLogEntries should filter by date range', () async {
      final userId = 'user_date_test';

      // Create entries across different dates
      await loggingService.createLogEntry(
        userId: userId,
        timestamp: DateTime(2025, 1, 1),
      );
      await loggingService.createLogEntry(
        userId: userId,
        timestamp: DateTime(2025, 1, 15),
      );
      await loggingService.createLogEntry(
        userId: userId,
        timestamp: DateTime(2025, 1, 31),
      );

      final entries = await loggingService.getLogEntries(
        userId: userId,
        startDate: DateTime(2025, 1, 10),
        endDate: DateTime(2025, 1, 20),
      );

      expect(entries.length, 1);
      expect(entries.first.timestamp.day, 15);
    });

    test('getAllEntriesForUser should return all user entries', () async {
      final userId = 'user_all_test';

      await loggingService.createLogEntry(userId: userId);
      await loggingService.createLogEntry(userId: userId);
      await loggingService.createLogEntry(userId: userId);

      final entries = await loggingService.getAllEntriesForUser(userId);
      expect(entries.length, 3);
    });

    test('getEntriesBySession should group by sessionId', () async {
      final sessionId = 'session_123';

      await loggingService.createLogEntry(
        userId: 'user1',
        sessionId: sessionId,
      );
      await loggingService.createLogEntry(
        userId: 'user1',
        sessionId: sessionId,
      );
      await loggingService.createLogEntry(
        userId: 'user1',
        sessionId: 'other_session',
      );

      final entries = await loggingService.getEntriesBySession(sessionId);
      expect(entries.length, 2);
    });

    test('updateLogEntry should modify existing entry', () async {
      final entry = await loggingService.createLogEntry(
        userId: 'user_update',
        notes: 'Original',
      );

      entry.notes = 'Updated';
      await loggingService.updateLogEntry(entry);

      final allEntries = await loggingService.getAllEntriesForUser(
        'user_update',
      );
      expect(allEntries.first.notes, 'Updated');
      expect(allEntries.first.updatedAt, isNotNull);
    });

    test('deleteLogEntry should remove entry', () async {
      final entry = await loggingService.createLogEntry(userId: 'user_delete');

      await loggingService.deleteLogEntry(entry.id);

      final entries = await loggingService.getAllEntriesForUser('user_delete');
      expect(entries.length, 0);
    });

    test('getPendingSyncEntries should filter by sync state', () async {
      final userId = 'user_sync_test';

      final entry1 = await loggingService.createLogEntry(userId: userId);
      await loggingService.createLogEntry(userId: userId);

      // Mark one as synced
      await loggingService.markAsSynced(entry1, 'firestore_doc_123');

      final pending = await loggingService.getPendingSyncEntries(userId);
      expect(pending.length, 1);
    });

    test('markAsSynced should update sync state', () async {
      final entry = await loggingService.createLogEntry(
        userId: 'user_mark_synced',
      );

      await loggingService.markAsSynced(entry, 'doc_789');

      final entries = await loggingService.getAllEntriesForUser(
        'user_mark_synced',
      );
      expect(entries.first.syncState, SyncState.synced);
      expect(entries.first.firestoreDocId, 'doc_789');
      expect(entries.first.syncError, isNull);
    });

    test('markSyncFailed should set error state', () async {
      final entry = await loggingService.createLogEntry(
        userId: 'user_mark_failed',
      );

      await loggingService.markSyncFailed(entry, 'Network error');

      final entries = await loggingService.getAllEntriesForUser(
        'user_mark_failed',
      );
      expect(entries.first.syncState, SyncState.error);
      expect(entries.first.syncError, 'Network error');
    });

    test('getStatistics should calculate correctly', () async {
      final userId = 'user_stats';

      await loggingService.createLogEntry(userId: userId, amount: 1.0);
      await loggingService.createLogEntry(userId: userId, amount: 2.5);
      await loggingService.createLogEntry(userId: userId, amount: 1.5);

      final stats = await loggingService.getStatistics(userId: userId);

      expect(stats['totalEntries'], 3);
      expect(stats['totalAmount'], 5.0);
      expect(stats['firstEntry'], isNotNull);
      expect(stats['lastEntry'], isNotNull);
    });

    test('watchLogEntries should emit real-time updates', () async {
      final userId = 'user_watch';

      await loggingService.createLogEntry(userId: userId);

      final stream = loggingService.watchLogEntries(userId);

      expectLater(
        stream,
        emitsInOrder([
          predicate<List<LogEntry>>((entries) => entries.length == 1),
        ]),
      );
    });
  });
}
