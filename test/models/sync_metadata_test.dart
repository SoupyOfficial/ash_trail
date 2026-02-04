import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/sync_metadata.dart';

void main() {
  group('SyncMetadata', () {
    group('default values', () {
      test('id defaults to 0', () {
        final metadata = SyncMetadata();
        expect(metadata.id, 0);
      });

      test('pendingCount defaults to 0', () {
        final metadata = SyncMetadata();
        expect(metadata.pendingCount, 0);
      });

      test('errorCount defaults to 0', () {
        final metadata = SyncMetadata();
        expect(metadata.errorCount, 0);
      });

      test('isSyncing defaults to false', () {
        final metadata = SyncMetadata();
        expect(metadata.isSyncing, false);
      });

      test('optional fields default to null', () {
        final metadata = SyncMetadata();
        expect(metadata.lastFullSync, isNull);
        expect(metadata.lastSuccessfulSync, isNull);
        expect(metadata.lastError, isNull);
        expect(metadata.lastErrorAt, isNull);
      });
    });

    group('setting values', () {
      test('can set userId', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        expect(metadata.userId, 'user-123');
      });

      test('can set id', () {
        final metadata = SyncMetadata();
        metadata.id = 42;
        expect(metadata.id, 42);
      });

      test('can set lastFullSync', () {
        final metadata = SyncMetadata();
        final timestamp = DateTime.now();
        metadata.lastFullSync = timestamp;
        expect(metadata.lastFullSync, timestamp);
      });

      test('can set lastSuccessfulSync', () {
        final metadata = SyncMetadata();
        final timestamp = DateTime.now();
        metadata.lastSuccessfulSync = timestamp;
        expect(metadata.lastSuccessfulSync, timestamp);
      });

      test('can set pendingCount', () {
        final metadata = SyncMetadata();
        metadata.pendingCount = 5;
        expect(metadata.pendingCount, 5);
      });

      test('can set errorCount', () {
        final metadata = SyncMetadata();
        metadata.errorCount = 3;
        expect(metadata.errorCount, 3);
      });

      test('can set lastError', () {
        final metadata = SyncMetadata();
        metadata.lastError = 'Network timeout';
        expect(metadata.lastError, 'Network timeout');
      });

      test('can set lastErrorAt', () {
        final metadata = SyncMetadata();
        final timestamp = DateTime.now();
        metadata.lastErrorAt = timestamp;
        expect(metadata.lastErrorAt, timestamp);
      });

      test('can set isSyncing', () {
        final metadata = SyncMetadata();
        metadata.isSyncing = true;
        expect(metadata.isSyncing, true);
      });
    });

    group('typical usage scenarios', () {
      test('tracks sync in progress', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        metadata.isSyncing = true;
        metadata.pendingCount = 10;

        expect(metadata.isSyncing, true);
        expect(metadata.pendingCount, 10);
      });

      test('tracks successful sync', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        final syncTime = DateTime.now();
        
        metadata.lastSuccessfulSync = syncTime;
        metadata.lastFullSync = syncTime;
        metadata.pendingCount = 0;
        metadata.isSyncing = false;

        expect(metadata.lastSuccessfulSync, syncTime);
        expect(metadata.lastFullSync, syncTime);
        expect(metadata.pendingCount, 0);
        expect(metadata.isSyncing, false);
      });

      test('tracks sync error', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        final errorTime = DateTime.now();
        
        metadata.lastError = 'Connection refused';
        metadata.lastErrorAt = errorTime;
        metadata.errorCount = 1;
        metadata.isSyncing = false;

        expect(metadata.lastError, 'Connection refused');
        expect(metadata.lastErrorAt, errorTime);
        expect(metadata.errorCount, 1);
        expect(metadata.isSyncing, false);
      });

      test('accumulates error count', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        
        metadata.errorCount = 0;
        metadata.errorCount = metadata.errorCount + 1;
        expect(metadata.errorCount, 1);
        
        metadata.errorCount = metadata.errorCount + 1;
        expect(metadata.errorCount, 2);
        
        metadata.errorCount = metadata.errorCount + 1;
        expect(metadata.errorCount, 3);
      });

      test('can reset error state', () {
        final metadata = SyncMetadata();
        metadata.userId = 'user-123';
        metadata.lastError = 'Some error';
        metadata.lastErrorAt = DateTime.now();
        metadata.errorCount = 5;
        
        // Reset error state
        metadata.lastError = null;
        metadata.lastErrorAt = null;
        metadata.errorCount = 0;

        expect(metadata.lastError, isNull);
        expect(metadata.lastErrorAt, isNull);
        expect(metadata.errorCount, 0);
      });
    });

    group('multiple instances', () {
      test('instances are independent', () {
        final metadata1 = SyncMetadata();
        metadata1.userId = 'user-1';
        metadata1.pendingCount = 5;

        final metadata2 = SyncMetadata();
        metadata2.userId = 'user-2';
        metadata2.pendingCount = 10;

        expect(metadata1.userId, 'user-1');
        expect(metadata1.pendingCount, 5);
        expect(metadata2.userId, 'user-2');
        expect(metadata2.pendingCount, 10);
      });
    });
  });
}
