import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/log_record.dart';
import 'log_record_service.dart';
import 'legacy_data_adapter.dart';

/// SyncService handles bidirectional synchronization with Firestore
///
/// **Conflict Resolution Strategy:**
/// Current implementation assumes SINGLE-WRITER MODEL per account:
/// - One active writer per account at any time
/// - No concurrent edits across devices
/// - Conflicts are avoided by design, not resolved after the fact
///
/// This simplifies sync logic but limits multi-device concurrent editing.
/// See design doc 5. Logging System section 5.6.1 for assumptions.
///
/// **Future Enhancement:** Multi-device conflict resolution is planned
/// but not implemented in MVP. When implemented, would require:
/// - Vector clocks or CRDT approach
/// - Conflict detection at field/property level
/// - User notification and merge strategy
///
/// **Conflict Detection:**
/// Currently detects conflicts when lastRemoteUpdateAt < remote.updatedAt
/// Uses "last write wins" strategy for resolution.
/// TODO: Implement proper multi-device conflict handling for post-MVP
/// Suggested approach: Use vector clocks or CRDT for conflict resolution.
/// Consider implementing conflict detection at the field/property level.
/// User notification and merge strategy will be required for a smooth user experience.
///
/// Implements conflict resolution and batch upload strategies
class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LogRecordService _logRecordService = LogRecordService();
  final Connectivity _connectivity = Connectivity();
  final LegacyDataAdapter _legacyAdapter = LegacyDataAdapter();

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
      if (remoteRecord.isDeleted) {
        // Apply remote deletion
        await _logRecordService.applyRemoteDeletion(
          localRecord,
          deletedAt: remoteRecord.deletedAt,
          remoteUpdatedAt: remoteRecord.updatedAt,
        );
      } else {
        await _logRecordService.updateLogRecord(
          localRecord,
          eventType: remoteRecord.eventType,
          eventAt: remoteRecord.eventAt,
          duration: remoteRecord.duration,
          unit: remoteRecord.unit,
          note: remoteRecord.note,
        );

        // Mark as synced
        await _logRecordService.markSynced(localRecord, remoteRecord.updatedAt);
      }
    } else {
      // Insert new record from remote
      await _logRecordService.importLogRecord(
        logId: remoteRecord.logId,
        accountId: remoteRecord.accountId,
        eventType: remoteRecord.eventType,
        eventAt: remoteRecord.eventAt,
        createdAt: remoteRecord.createdAt,
        updatedAt: remoteRecord.updatedAt,
        duration: remoteRecord.duration,
        unit: remoteRecord.unit,
        note: remoteRecord.note,
        source: remoteRecord.source,
        deviceId: remoteRecord.deviceId,
        appVersion: remoteRecord.appVersion,
      );
      // If remote is deleted, reflect deletion locally on imported record
      if (remoteRecord.isDeleted) {
        final imported = await _logRecordService.getLogRecordByLogId(
          remoteRecord.logId,
        );
        if (imported != null) {
          await _logRecordService.applyRemoteDeletion(
            imported,
            deletedAt: remoteRecord.deletedAt,
            remoteUpdatedAt: remoteRecord.updatedAt,
          );
        }
      }
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
            // New record from remote - import it
            await _logRecordService.importLogRecord(
              logId: remoteRecord.logId,
              accountId: remoteRecord.accountId,
              eventType: remoteRecord.eventType,
              eventAt: remoteRecord.eventAt,
              createdAt: remoteRecord.createdAt,
              updatedAt: remoteRecord.updatedAt,
              duration: remoteRecord.duration,
              unit: remoteRecord.unit,
              note: remoteRecord.note,
              source: remoteRecord.source,
              deviceId: remoteRecord.deviceId,
              appVersion: remoteRecord.appVersion,
            );
            // If remote is deleted, reflect deletion on imported record
            if (remoteRecord.isDeleted) {
              final imported = await _logRecordService.getLogRecordByLogId(
                remoteRecord.logId,
              );
              if (imported != null) {
                await _logRecordService.applyRemoteDeletion(
                  imported,
                  deletedAt: remoteRecord.deletedAt,
                  remoteUpdatedAt: remoteRecord.updatedAt,
                );
              }
            }
            successCount++;
          } else {
            // Update existing
            if (remoteRecord.updatedAt.isAfter(localRecord.updatedAt)) {
              if (remoteRecord.isDeleted) {
                await _logRecordService.applyRemoteDeletion(
                  localRecord,
                  deletedAt: remoteRecord.deletedAt,
                  remoteUpdatedAt: remoteRecord.updatedAt,
                );
              } else {
                await _logRecordService.updateLogRecord(
                  localRecord,
                  eventType: remoteRecord.eventType,
                  eventAt: remoteRecord.eventAt,
                  duration: remoteRecord.duration,
                  unit: remoteRecord.unit,
                  note: remoteRecord.note,
                );

                await _logRecordService.markSynced(
                  localRecord,
                  remoteRecord.updatedAt,
                );
              }

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

  /// Pull records from current Firestore logs and legacy tables for an account
  /// Merges results from both sources with deduplication
  Future<SyncResult> pullRecordsForAccountIncludingLegacy({
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
      // Pull from current logs collection
      final currentRecords = await _pullCurrentRecords(accountId, since);

      // Pull from legacy collections
      final legacyRecords = await _pullLegacyRecords(accountId, since);

      // Merge and deduplicate
      final mergedRecords = _mergeRecords(currentRecords, legacyRecords);

      int successCount = 0;
      int failedCount = 0;

      for (final remoteRecord in mergedRecords) {
        try {
          final localRecord = await _logRecordService.getLogRecordByLogId(
            remoteRecord.logId,
          );

          if (localRecord == null) {
            // New record from remote - import it
            await _logRecordService.importLogRecord(
              logId: remoteRecord.logId,
              accountId: remoteRecord.accountId,
              eventType: remoteRecord.eventType,
              eventAt: remoteRecord.eventAt,
              createdAt: remoteRecord.createdAt,
              updatedAt: remoteRecord.updatedAt,
              duration: remoteRecord.duration,
              unit: remoteRecord.unit,
              note: remoteRecord.note,
              source: remoteRecord.source,
              deviceId: remoteRecord.deviceId,
              appVersion: remoteRecord.appVersion,
            );
            successCount++;
          } else {
            // Update existing if remote is newer
            if (remoteRecord.updatedAt.isAfter(localRecord.updatedAt)) {
              if (remoteRecord.isDeleted) {
                await _logRecordService.applyRemoteDeletion(
                  localRecord,
                  deletedAt: remoteRecord.deletedAt,
                  remoteUpdatedAt: remoteRecord.updatedAt,
                );
              } else {
                await _logRecordService.updateLogRecord(
                  localRecord,
                  eventType: remoteRecord.eventType,
                  eventAt: remoteRecord.eventAt,
                  duration: remoteRecord.duration,
                  unit: remoteRecord.unit,
                  note: remoteRecord.note,
                );

                await _logRecordService.markSynced(
                  localRecord,
                  remoteRecord.updatedAt,
                );
              }

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
        message:
            'Pulled $successCount records (${currentRecords.length} current, ${legacyRecords.length} legacy)',
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

  /// Helper: Pull records from current Firestore logs collection
  Future<List<LogRecord>> _pullCurrentRecords(
    String accountId,
    DateTime? since,
  ) async {
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
      return querySnapshot.docs
          .map((doc) => LogRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error pulling current records: $e');
      return [];
    }
  }

  /// Helper: Pull records from legacy Firestore collections
  Future<List<LogRecord>> _pullLegacyRecords(
    String accountId,
    DateTime? since,
  ) async {
    try {
      return await _legacyAdapter.queryAllLegacyCollections(
        since: since,
        limit: 100,
      );
    } catch (e) {
      debugPrint('Error pulling legacy records: $e');
      return [];
    }
  }

  /// Helper: Merge and deduplicate records from current and legacy sources
  /// Newer records (by updatedAt) take precedence
  List<LogRecord> _mergeRecords(
    List<LogRecord> currentRecords,
    List<LogRecord> legacyRecords,
  ) {
    final merged = <String, LogRecord>{}; // Key: logId

    // Add current records
    for (final record in currentRecords) {
      merged[record.logId] = record;
    }

    // Add or update with legacy records (only if not already present or if older)
    for (final record in legacyRecords) {
      if (!merged.containsKey(record.logId) ||
          record.updatedAt.isAfter(merged[record.logId]!.updatedAt)) {
        merged[record.logId] = record;
      }
    }

    // Convert to list and sort by eventAt descending
    final result = merged.values.toList();
    result.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return result;
  }

  /// Check if account has legacy data to migrate
  Future<bool> hasLegacyData(String accountId) async {
    return await _legacyAdapter.hasLegacyData(accountId);
  }

  /// Get count of legacy records for an account
  Future<int> getLegacyRecordCount(String accountId) async {
    return await _legacyAdapter.getLegacyRecordCount(accountId);
  }

  /// Import all legacy data for an account into current format
  /// Returns count of records imported
  Future<int> importLegacyDataForAccount({required String accountId}) async {
    if (!await isOnline()) {
      throw Exception('Device is offline');
    }

    try {
      final legacyRecords = await _legacyAdapter.queryAllLegacyCollections(
        limit: 500, // Import in larger batch
      );

      int importedCount = 0;

      for (final record in legacyRecords) {
        try {
          final existing = await _logRecordService.getLogRecordByLogId(
            record.logId,
          );

          if (existing == null) {
            // New record - import it
            await _logRecordService.importLogRecord(
              logId: record.logId,
              accountId: record.accountId,
              eventType: record.eventType,
              eventAt: record.eventAt,
              createdAt: record.createdAt,
              updatedAt: record.updatedAt,
              duration: record.duration,
              unit: record.unit,
              note: record.note,
              source: record.source,
              deviceId: record.deviceId,
              appVersion: record.appVersion,
            );
            importedCount++;
          } else if (record.updatedAt.isAfter(existing.updatedAt)) {
            // Update if remote is newer
            await _logRecordService.updateLogRecord(
              existing,
              eventType: record.eventType,
              eventAt: record.eventAt,
              duration: record.duration,
              unit: record.unit,
              note: record.note,
            );
            importedCount++;
          }
        } catch (e) {
          debugPrint('Error importing legacy record ${record.logId}: $e');
        }
      }

      return importedCount;
    } catch (e) {
      debugPrint('Error importing legacy data: $e');
      rethrow;
    }
  }

  /// Watch both current and legacy logs for an account in real-time
  Stream<LogRecord> watchAccountLogsIncludingLegacy(String accountId) async* {
    // Watch current logs
    yield* _firestore
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

    // Watch legacy logs
    yield* _legacyAdapter.watchLegacyCollections(
      accountId: accountId,
      limit: 50,
    );
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
