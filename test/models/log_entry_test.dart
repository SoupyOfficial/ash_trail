import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_entry.dart';

void main() {
  group('LogEntry Model Tests', () {
    test('LogEntry.create() should create entry with required fields', () {
      final entry = LogEntry.create(entryId: 'entry_123', userId: 'user_456');

      expect(entry.entryId, 'entry_123');
      expect(entry.userId, 'user_456');
      expect(entry.syncState, SyncState.pending);
      expect(entry.timestamp, isNotNull);
      expect(entry.createdAt, isNotNull);
    });

    test('LogEntry.create() should accept optional notes and amount', () {
      final entry = LogEntry.create(
        entryId: 'entry_123',
        userId: 'user_456',
        notes: 'Test note',
        amount: 2.5,
      );

      expect(entry.notes, 'Test note');
      expect(entry.amount, 2.5);
    });

    test('LogEntry.create() should accept custom timestamp', () {
      final customTime = DateTime(2025, 1, 1, 12, 0);
      final entry = LogEntry.create(
        entryId: 'entry_123',
        userId: 'user_456',
        timestamp: customTime,
      );

      expect(entry.timestamp, customTime);
    });

    test('LogEntry.create() should support session grouping', () {
      final entry = LogEntry.create(
        entryId: 'entry_123',
        userId: 'user_456',
        sessionId: 'session_789',
      );

      expect(entry.sessionId, 'session_789');
    });

    test('LogEntry should support all sync states', () {
      expect(SyncState.pending, isNotNull);
      expect(SyncState.synced, isNotNull);
      expect(SyncState.conflict, isNotNull);
      expect(SyncState.error, isNotNull);
    });

    test('LogEntry.create() should track Firestore doc reference', () {
      final entry = LogEntry.create(
        entryId: 'entry_123',
        userId: 'user_456',
        firestoreDocId: 'firestore_doc_123',
      );

      expect(entry.firestoreDocId, 'firestore_doc_123');
    });

    test('LogEntry() default constructor should create empty entry', () {
      final entry = LogEntry();

      expect(entry.id, isNotNull);
    });
  });

  group('SyncState Tests', () {
    test('SyncState enum should have correct values', () {
      expect(SyncState.values.length, 4);
      expect(SyncState.pending.name, 'pending');
      expect(SyncState.synced.name, 'synced');
      expect(SyncState.conflict.name, 'conflict');
      expect(SyncState.error.name, 'error');
    });
  });
}
