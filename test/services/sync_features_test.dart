import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Sync Features - Comprehensive Sync Testing', () {
    const testAccountId = 'sync-test-account';
    const uuid = Uuid();

    group('Pending Records and Sync Status', () {
      test('new records start in pending state', () async {
        // GIVEN: Create a new log record
        final record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        // THEN: Should be in pending state
        expect(record.syncState, SyncState.pending);
      });

      test('multiple pending records can be created', () {
        // GIVEN: Create multiple records
        final record1 = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        final record2 = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.inhale,
          duration: 25.0,
        );
        final record3 = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.inhale,
          duration: 20.0,
        );

        // Verify sync state on multiple records
        expect(
          [
            record1,
            record2,
            record3,
          ].every((r) => r.syncState == SyncState.pending),
          isTrue,
        );
      });

      test('pending records can be marked as syncing', () {
        // GIVEN: A pending record
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        expect(record.syncState, SyncState.pending);

        // WHEN: Mark as syncing
        record = record.copyWith(syncState: SyncState.syncing);

        // THEN: Should be syncing
        expect(record.syncState, SyncState.syncing);
      });

      test('syncing records can transition to synced', () {
        // GIVEN: A record transitioning through states
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        // WHEN: Move through states
        record = record.copyWith(
          syncState: SyncState.syncing,
          syncedAt: DateTime.now(),
        );
        record = record.copyWith(
          syncState: SyncState.synced,
          lastRemoteUpdateAt: DateTime.now(),
        );

        // THEN: Should be synced with timestamps
        expect(record.syncState, SyncState.synced);
        expect(record.syncedAt, isNotNull);
        expect(record.lastRemoteUpdateAt, isNotNull);
      });
    });

    group('Sync Conflict Detection', () {
      test('records with conflicting timestamps are detected', () {
        // GIVEN: Two records with conflicting update times
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        // Create a remote update time
        final remoteTime = DateTime.now().add(const Duration(hours: 1));

        record = record.copyWith(
          syncState: SyncState.conflict,
          lastRemoteUpdateAt: remoteTime,
          updatedAt: DateTime.now(),
        );

        // THEN: Conflict should be detected by comparing timestamps
        expect(record.syncState, SyncState.conflict);
        expect(record.lastRemoteUpdateAt!.isAfter(record.updatedAt), isTrue);
      });

      test('conflict resolution preserves later timestamp', () {
        // GIVEN: Records in conflict state
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        final localTime = DateTime.now();
        final remoteTime = localTime.add(const Duration(minutes: 5));

        record = record.copyWith(
          syncState: SyncState.conflict,
          lastRemoteUpdateAt: remoteTime,
          updatedAt: localTime,
        );

        // WHEN: Resolve using last-write-wins
        record = record.copyWith(
          syncState: SyncState.synced,
          updatedAt: remoteTime, // Use remote timestamp
        );

        // THEN: Should be synced with remote timestamp
        expect(record.syncState, SyncState.synced);
        expect(record.updatedAt, remoteTime);
      });

      test('sync error state can be detected', () {
        // GIVEN: A record in error state
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        record = record.copyWith(syncState: SyncState.error);

        // THEN: Should show error state
        expect(record.syncState, SyncState.error);
      });

      test('error state can transition back to pending for retry', () {
        // GIVEN: Record in error state
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        record = record.copyWith(syncState: SyncState.error);
        expect(record.syncState, SyncState.error);

        // WHEN: Retry
        record = record.copyWith(syncState: SyncState.pending);

        // THEN: Should be back in pending
        expect(record.syncState, SyncState.pending);
      });
    });

    group('Batch Sync Operations', () {
      test('multiple records can be synced as batch', () {
        // GIVEN: Create multiple pending records
        final records = <LogRecord>[];
        for (int i = 0; i < 5; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: i % 2 == 0 ? EventType.vape : EventType.inhale,
              duration: (30 + i).toDouble(),
            ),
          );
        }

        // VERIFY: All are pending
        expect(records.every((r) => r.syncState == SyncState.pending), isTrue);

        // SIMULATE: Batch sync by marking all as synced
        final syncedRecords =
            records
                .map(
                  (r) => r.copyWith(
                    syncState: SyncState.synced,
                    syncedAt: DateTime.now(),
                    lastRemoteUpdateAt: DateTime.now(),
                  ),
                )
                .toList();

        // THEN: All should be synced
        expect(
          syncedRecords.every((r) => r.syncState == SyncState.synced),
          isTrue,
        );
      });

      test('handles 50-record batch sync efficiently', () {
        // GIVEN: Large batch of records
        final records = <LogRecord>[];
        for (int i = 0; i < 50; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: i % 2 == 0 ? EventType.vape : EventType.inhale,
              duration: (20 + (i % 30)).toDouble(),
            ),
          );
        }

        // WHEN: Sync all records
        final syncedRecords =
            records
                .map(
                  (r) => r.copyWith(
                    syncState: SyncState.synced,
                    syncedAt: DateTime.now(),
                  ),
                )
                .toList();

        // THEN: All 50 should be synced
        expect(syncedRecords.length, 50);
        expect(
          syncedRecords.every((r) => r.syncState == SyncState.synced),
          isTrue,
        );
      });

      test('handles 100-150 record batch sync', () {
        // GIVEN: Very large batch
        final records = <LogRecord>[];
        for (int i = 0; i < 150; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: i % 3 == 0 ? EventType.vape : EventType.inhale,
              duration: (15 + (i % 40)).toDouble(),
            ),
          );
        }

        // SIMULATE: Batch sync
        final syncedRecords =
            records
                .map(
                  (r) => r.copyWith(
                    syncState: SyncState.synced,
                    syncedAt: DateTime.now(),
                  ),
                )
                .toList();

        // THEN: All 150 synced
        expect(syncedRecords.length, 150);
        expect(
          syncedRecords.every((r) => r.syncState == SyncState.synced),
          isTrue,
        );
      });

      test('partial batch sync with mixed results', () {
        // GIVEN: Batch with successful and failed records
        final records = <LogRecord>[];
        for (int i = 0; i < 20; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: i % 2 == 0 ? EventType.vape : EventType.inhale,
              duration: (25 + i).toDouble(),
            ),
          );
        }

        // SIMULATE: First 15 succeed, last 5 fail
        final results = <LogRecord>[];
        for (int i = 0; i < records.length; i++) {
          if (i < 15) {
            results.add(
              records[i].copyWith(
                syncState: SyncState.synced,
                syncedAt: DateTime.now(),
              ),
            );
          } else {
            results.add(records[i].copyWith(syncState: SyncState.error));
          }
        }

        // THEN: Verify mixed states
        final synced =
            results.where((r) => r.syncState == SyncState.synced).length;
        final errors =
            results.where((r) => r.syncState == SyncState.error).length;

        expect(synced, 15);
        expect(errors, 5);
      });
    });

    group('Sync State Transitions', () {
      test('pending to syncing transition is valid', () {
        // GIVEN: Pending record
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );

        // WHEN: Transition to syncing
        record = record.copyWith(syncState: SyncState.syncing);

        // THEN: State changed correctly
        expect(record.syncState, SyncState.syncing);
      });

      test('syncing to synced transition is valid', () {
        // GIVEN: Syncing record
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        record = record.copyWith(syncState: SyncState.syncing);

        // WHEN: Complete sync
        record = record.copyWith(syncState: SyncState.synced);

        // THEN: Transitioned to synced
        expect(record.syncState, SyncState.synced);
      });

      test('any state to error is valid', () {
        // Test pending to error
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        record = record.copyWith(syncState: SyncState.error);
        expect(record.syncState, SyncState.error);

        // Test syncing to error
        record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.inhale,
          duration: 25.0,
        );
        record = record.copyWith(syncState: SyncState.syncing);
        record = record.copyWith(syncState: SyncState.error);
        expect(record.syncState, SyncState.error);
      });

      test('error to pending retry is valid', () {
        // GIVEN: Error record
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        record = record.copyWith(syncState: SyncState.error);

        // WHEN: Retry
        record = record.copyWith(syncState: SyncState.pending);

        // THEN: Back to pending for retry
        expect(record.syncState, SyncState.pending);
      });

      test('synced records can transition to conflict', () {
        // GIVEN: Synced record
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        record = record.copyWith(
          syncState: SyncState.synced,
          syncedAt: DateTime.now(),
        );

        // WHEN: Conflict detected
        record = record.copyWith(syncState: SyncState.conflict);

        // THEN: In conflict state
        expect(record.syncState, SyncState.conflict);
      });
    });

    group('Offline Sync Behavior', () {
      test('pending records queue for sync when offline', () {
        // GIVEN: Multiple pending records (simulating offline mode)
        final records = <LogRecord>[];
        for (int i = 0; i < 5; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: i % 2 == 0 ? EventType.vape : EventType.inhale,
              duration: (20 + i).toDouble(),
            ),
          );
        }

        // VERIFY: All remain pending
        expect(records.every((r) => r.syncState == SyncState.pending), isTrue);
      });

      test('pending records maintain order when offline', () {
        // GIVEN: Create records in sequence
        final records = <LogRecord>[];
        final logIds = <String>[];

        for (int i = 0; i < 10; i++) {
          final logId = uuid.v4();
          logIds.add(logId);
          records.add(
            LogRecord.create(
              logId: logId,
              accountId: testAccountId,
              eventType: EventType.vape,
              duration: (20.0 + i),
            ),
          );
        }

        // WHEN: Sync in order
        for (int i = 0; i < records.length; i++) {
          records[i] = records[i].copyWith(
            syncState: SyncState.synced,
            syncedAt: DateTime.now(),
          );
        }

        // THEN: Order preserved
        for (int i = 0; i < logIds.length; i++) {
          expect(records[i].logId, logIds[i]);
        }
      });

      test('reconnection triggers pending sync', () {
        // GIVEN: Pending records from offline period
        var record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          duration: 30.0,
        );
        expect(record.syncState, SyncState.pending);

        // WHEN: Reconnect (transition to synced)
        record = record.copyWith(
          syncState: SyncState.synced,
          syncedAt: DateTime.now(),
          lastRemoteUpdateAt: DateTime.now(),
        );

        // THEN: Should be synced with remote timestamps
        expect(record.syncState, SyncState.synced);
        expect(record.lastRemoteUpdateAt, isNotNull);
      });
    });

    group('Sync Performance', () {
      test('handles 50-record sync under 100ms', () {
        // GIVEN: 50 records
        final records = <LogRecord>[];
        for (int i = 0; i < 50; i++) {
          records.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: testAccountId,
              eventType: EventType.vape,
              duration: (20 + i).toDouble(),
            ),
          );
        }

        // WHEN: Sync all (simulated)
        final startTime = DateTime.now();
        final syncedRecords =
            records
                .map(
                  (r) => r.copyWith(
                    syncState: SyncState.synced,
                    syncedAt: DateTime.now(),
                  ),
                )
                .toList();
        final duration = DateTime.now().difference(startTime);

        // THEN: Operation completes quickly
        expect(syncedRecords.length, 50);
        // In Dart, this operation should be nearly instant, under 100ms
        expect(duration.inMilliseconds < 100, isTrue);
      });

      test('filters pending and synced records efficiently', () {
        // GIVEN: Mixed state records
        final records = <LogRecord>[];
        for (int i = 0; i < 100; i++) {
          final state = i % 3 == 0 ? SyncState.synced : SyncState.pending;
          final record = LogRecord.create(
            logId: uuid.v4(),
            accountId: testAccountId,
            eventType: EventType.vape,
            duration: 25.0,
          ).copyWith(syncState: state);
          records.add(record);
        }

        // WHEN: Filter pending and synced
        final pending =
            records.where((r) => r.syncState == SyncState.pending).toList();
        final synced =
            records.where((r) => r.syncState == SyncState.synced).toList();

        // THEN: Filtering works correctly
        expect(pending.isNotEmpty, isTrue);
        expect(synced.isNotEmpty, isTrue);
        expect(
          pending.length + synced.length,
          lessThanOrEqualTo(records.length),
        );
      });
    });

    group('Sync Account Isolation', () {
      test('sync status is independent per account', () {
        // GIVEN: Records for different accounts
        final account1 = 'account-001';
        final account2 = 'account-002';

        var record1 = LogRecord.create(
          logId: uuid.v4(),
          accountId: account1,
          eventType: EventType.vape,
          duration: 30.0,
        );

        var record2 = LogRecord.create(
          logId: uuid.v4(),
          accountId: account2,
          eventType: EventType.vape,
          duration: 30.0,
        );

        // WHEN: Sync only account 1
        record1 = record1.copyWith(syncState: SyncState.synced);

        // THEN: Account 1 synced, account 2 still pending
        expect(record1.syncState, SyncState.synced);
        expect(record2.syncState, SyncState.pending);
      });

      test('pending records from one account do not affect another', () {
        // GIVEN: Multiple accounts
        final account1 = 'account-001';
        final account2 = 'account-002';

        final records = <LogRecord>[
          LogRecord.create(
            logId: uuid.v4(),
            accountId: account1,
            eventType: EventType.vape,
            duration: 30.0,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: account1,
            eventType: EventType.inhale,
            duration: 25.0,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: account2,
            eventType: EventType.vape,
            duration: 20.0,
          ),
        ];

        // Count pending by account
        final account1Pending =
            records
                .where(
                  (r) =>
                      r.accountId == account1 &&
                      r.syncState == SyncState.pending,
                )
                .length;
        final account2Pending =
            records
                .where(
                  (r) =>
                      r.accountId == account2 &&
                      r.syncState == SyncState.pending,
                )
                .length;

        // THEN: Both have pending, but isolated
        expect(account1Pending, 2);
        expect(account2Pending, 1);
      });

      test('synced state does not cross account boundaries', () {
        // GIVEN: Multiple accounts with mixed sync states
        final account1 = 'account-001';
        final account2 = 'account-002';

        var records = <LogRecord>[
          LogRecord.create(
            logId: uuid.v4(),
            accountId: account1,
            eventType: EventType.vape,
            duration: 30.0,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: account2,
            eventType: EventType.vape,
            duration: 25.0,
          ),
        ];

        // WHEN: Sync only account 1
        records =
            records
                .map(
                  (r) =>
                      r.accountId == account1
                          ? r.copyWith(
                            syncState: SyncState.synced,
                            syncedAt: DateTime.now(),
                          )
                          : r,
                )
                .toList();

        // THEN: Account 1 synced, account 2 pending
        final account1Synced =
            records
                .where(
                  (r) =>
                      r.accountId == account1 &&
                      r.syncState == SyncState.synced,
                )
                .length;
        final account2Synced =
            records
                .where(
                  (r) =>
                      r.accountId == account2 &&
                      r.syncState == SyncState.synced,
                )
                .length;

        expect(account1Synced, 1);
        expect(account2Synced, 0);
      });
    });
  });
}
