import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/log_record.dart';
import 'log_record_service.dart';

/// SyncService handles bidirectional synchronization with Firestore
/// Implements conflict resolution and batch upload strategies
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LogRecordService _logRecordService = LogRecordService();
  final Connectivity _connectivity = Connectivity();

  Timer? _syncTimer;
  bool _isSyncing = false;

  /// Sync batch size
  static const int _batchSize = 50;

  /// Sync interval (in seconds)
  static const int _syncIntervalSeconds = 30;

  /// Start automatic background sync
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(seconds: _syncIntervalSeconds),
      (_) => syncPendingRecords(),
    );
  }

  /// Stop automatic background sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }

  /// Sync pending records to Firestore
  Future<SyncResult> syncPendingRecords() async {
    if (_isSyncing) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Sync already in progress',
      );
    }

    if (!await isOnline()) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Device is offline',
      );
    }

    _isSyncing = true;

    try {
      final pendingRecords = await _logRecordService.getPendingSync(
        limit: _batchSize,
      );

      if (pendingRecords.isEmpty) {
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'No records to sync',
        );
      }

      int successCount = 0;
      int failedCount = 0;

      for (final record in pendingRecords) {
        try {
          await _uploadRecord(record);
          successCount++;
        } catch (e) {
          failedCount++;
          await _logRecordService.markSyncError(record, e.toString());
        }
      }

      return SyncResult(
        success: successCount,
        failed: failedCount,
        skipped: 0,
        message: 'Synced $successCount records, $failedCount failed',
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload a single record to Firestore
  Future<void> _uploadRecord(LogRecord record) async {
    final docRef = _firestore
        .collection('accounts')
        .doc(record.accountId)
        .collection('logs')
        .doc(record.logId);

    // Check if document exists and handle conflicts
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Document exists, check for conflicts
      final remoteData = docSnapshot.data()!;
      final remoteRecord = LogRecord.fromFirestore(remoteData);

      if (await _hasConflict(record, remoteRecord)) {
        // Resolve conflict (latest updatedAt wins)
        if (record.updatedAt.isAfter(remoteRecord.updatedAt)) {
          // Local wins, upload
          await docRef.set(record.toFirestore());
        } else {
          // Remote wins, update local
          await _downloadRecord(record.accountId, record.logId);
          return;
        }
      } else {
        // No conflict, upload
        await docRef.set(record.toFirestore());
      }
    } else {
      // New document, upload
      await docRef.set(record.toFirestore());
    }

    // Mark as synced
    await _logRecordService.markSynced(record, DateTime.now());
  }

  /// Check if there's a conflict between local and remote records
  Future<bool> _hasConflict(LogRecord local, LogRecord remote) async {
    // If remote was updated after local was last synced, there's a potential conflict
    if (local.lastRemoteUpdateAt == null) return false;

    return remote.updatedAt.isAfter(local.lastRemoteUpdateAt!);
  }

  /// Download a single record from Firestore
  Future<void> _downloadRecord(String accountId, String logId) async {
    final docRef = _firestore
        .collection('accounts')
        .doc(accountId)
        .collection('logs')
        .doc(logId);

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception('Record not found in Firestore');
    }

    final remoteRecord = LogRecord.fromFirestore(docSnapshot.data()!);

    // Update local record
    final localRecord = await _logRecordService.getLogRecordByLogId(logId);

    if (localRecord != null) {
      // Update existing local record
      await _logRecordService.updateLogRecord(
        localRecord,
        eventType: remoteRecord.eventType,
        eventAt: remoteRecord.eventAt,
        value: remoteRecord.value,
        unit: remoteRecord.unit,
        note: remoteRecord.note,
        tags: remoteRecord.tags,
        sessionId: remoteRecord.sessionId,
      );

      // Mark as synced
      await _logRecordService.markSynced(localRecord, remoteRecord.updatedAt);
    } else {
      // Insert new record
      // Note: This requires exposing a method to insert with specific IDs
      // For now, we'll skip this case
    }
  }

  /// Sync records for a specific account (pull from Firestore)
  Future<SyncResult> pullRecordsForAccount({
    required String accountId,
    DateTime? since,
  }) async {
    if (!await isOnline()) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Device is offline',
      );
    }

    try {
      var query = _firestore
          .collection('accounts')
          .doc(accountId)
          .collection('logs')
          .orderBy('updatedAt', descending: true);

      if (since != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: since.toIso8601String(),
        );
      }

      final querySnapshot = await query.limit(100).get();

      int successCount = 0;
      int failedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final remoteRecord = LogRecord.fromFirestore(doc.data());
          final localRecord = await _logRecordService.getLogRecordByLogId(
            remoteRecord.logId,
          );

          if (localRecord == null) {
            // New record, would need to insert
            // For now, skip
            failedCount++;
          } else {
            // Update existing
            if (remoteRecord.updatedAt.isAfter(localRecord.updatedAt)) {
              await _logRecordService.updateLogRecord(
                localRecord,
                eventType: remoteRecord.eventType,
                eventAt: remoteRecord.eventAt,
                value: remoteRecord.value,
                unit: remoteRecord.unit,
                note: remoteRecord.note,
                tags: remoteRecord.tags,
                sessionId: remoteRecord.sessionId,
              );

              await _logRecordService.markSynced(
                localRecord,
                remoteRecord.updatedAt,
              );

              successCount++;
            }
          }
        } catch (e) {
          failedCount++;
        }
      }

      return SyncResult(
        success: successCount,
        failed: failedCount,
        skipped: 0,
        message: 'Pulled $successCount records',
      );
    } catch (e) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Error pulling records: $e',
      );
    }
  }

  /// Listen to real-time changes from Firestore for an account
  Stream<LogRecord> watchAccountLogs(String accountId) {
    return _firestore
        .collection('accounts')
        .doc(accountId)
        .collection('logs')
        .snapshots()
        .asyncExpand((snapshot) async* {
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified) {
              try {
                final remoteRecord = LogRecord.fromFirestore(
                  change.doc.data()!,
                );
                yield remoteRecord;
              } catch (e) {
                // Skip invalid records
              }
            }
          }
        });
  }

  /// Get sync status for an account
  Future<SyncStatus> getSyncStatus(String accountId) async {
    final pendingCount = await _logRecordService.countLogRecords(
      accountId: accountId,
      includeDeleted: false,
    );

    final isConnected = await isOnline();

    return SyncStatus(
      pendingCount: pendingCount,
      isOnline: isConnected,
      isSyncing: _isSyncing,
    );
  }

  /// Force sync now (manual trigger)
  Future<SyncResult> forceSyncNow() async {
    return await syncPendingRecords();
  }

  /// Cleanup
  void dispose() {
    stopAutoSync();
  }
}

/// Result of a sync operation
class SyncResult {
  final int success;
  final int failed;
  final int skipped;
  final String message;

  SyncResult({
    required this.success,
    required this.failed,
    required this.skipped,
    required this.message,
  });

  bool get hasErrors => failed > 0;

  @override
  String toString() {
    return 'SyncResult(success: $success, failed: $failed, skipped: $skipped, message: $message)';
  }
}

/// Current sync status
class SyncStatus {
  final int pendingCount;
  final bool isOnline;
  final bool isSyncing;

  SyncStatus({
    required this.pendingCount,
    required this.isOnline,
    required this.isSyncing,
  });

  bool get isFullySynced => pendingCount == 0 && !isSyncing;

  @override
  String toString() {
    return 'SyncStatus(pending: $pendingCount, online: $isOnline, syncing: $isSyncing)';
  }
}
