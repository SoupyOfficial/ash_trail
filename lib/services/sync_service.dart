import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/log_record.dart';
import '../models/account.dart';
import '../models/enums.dart';
import 'log_record_service.dart';
import 'legacy_data_adapter.dart';
import 'account_session_manager.dart';
import 'token_service.dart';

/// SyncService handles bidirectional synchronization with Firestore
///
/// **Multi-Account Support:**
/// Sync operations are account-scoped and only process records for the currently
/// authenticated Firebase user. This ensures:
/// - Firestore security rules validate correctly (request.auth.uid must match accountId)
/// - No cross-account data leakage
/// - Seamless account switching via Firebase Custom Tokens
///
/// When switching accounts, the Firebase Auth user changes via signInWithCustomToken(),
/// and sync automatically filters to only process records for that user.
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
  final FirebaseFirestore _firestore;
  final LogRecordService _logRecordService;
  final Connectivity _connectivity;
  final LegacyDataAdapter _legacyAdapter;
  final Future<List<ConnectivityResult>> Function()? _connectivityCheck;
  final AccountSessionManager _sessionManager;
  final TokenService _tokenService;

  SyncService({
    FirebaseFirestore? firestore,
    LogRecordService? logRecordService,
    Connectivity? connectivity,
    LegacyDataAdapter? legacyAdapter,
    Future<List<ConnectivityResult>> Function()? connectivityCheck,
    required AccountSessionManager sessionManager,
    required TokenService tokenService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _logRecordService = logRecordService ?? LogRecordService(),
       _connectivity = connectivity ?? Connectivity(),
       _legacyAdapter = legacyAdapter ?? LegacyDataAdapter(),
       _connectivityCheck = connectivityCheck,
       _sessionManager = sessionManager,
       _tokenService = tokenService;

  Timer? _syncTimer;
  Timer? _pullTimer;
  String? _currentAccountId;
  bool _isSyncing = false;

  /// Sync batch size
  static const int _batchSize = 50;

  /// Start automatic background sync and periodic pulls for all logged-in accounts
  void startAutoSync({
    String? accountId,
    Duration pushInterval = const Duration(seconds: 30),
    Duration pullInterval = const Duration(seconds: 30),
  }) {
    _currentAccountId = accountId ?? _currentAccountId;

    _syncTimer?.cancel();
    _pullTimer?.cancel();

    // Sync all logged-in accounts periodically
    _syncTimer = Timer.periodic(pushInterval, (_) => syncAllLoggedInAccounts());

    // Pull records for all logged-in accounts periodically
    _pullTimer = Timer.periodic(
      pullInterval,
      (_) => pullAllLoggedInAccounts(),
    );
  }

  /// Stop automatic background sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _pullTimer?.cancel();
    _syncTimer = null;
    _pullTimer = null;
  }

  /// Run an immediate pull + push cycle for the current account and schedule periodic syncs
  Future<void> startAccountSync({
    required String accountId,
    Duration interval = const Duration(seconds: 30),
  }) async {
    _currentAccountId = accountId;
    stopAutoSync();

    await _runInitialSync(accountId);

    startAutoSync(
      accountId: accountId,
      pushInterval: interval,
      pullInterval: interval,
    );
  }

  /// Pull fresh data and push pending local changes immediately
  Future<void> _runInitialSync(String accountId) async {
    await pullRecordsForAccountIncludingLegacy(accountId: accountId);
    await syncPendingRecords();
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult =
        _connectivityCheck != null
            ? await _connectivityCheck()
            : await _connectivity.checkConnectivity();

    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }

  /// Sync pending records to Firestore
  ///
  /// IMPORTANT: Only syncs records that belong to the currently authenticated
  /// Firebase user. This ensures:
  /// 1. Firestore security rules won't reject the write (auth.uid must match)
  /// 2. Records for other accounts stay pending until that user authenticates
  ///
  /// With seamless account switching via custom tokens, the authenticated user
  /// should always match the active account.
  ///
  /// [skipLockCheck] - If true, skips the _isSyncing lock check (for internal use when syncing multiple accounts)
  Future<SyncResult> syncPendingRecords({bool skipLockCheck = false}) async {
    if (!skipLockCheck && _isSyncing) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Sync already in progress',
      );
    }

    // Safety check: Only sync records for the authenticated Firebase user
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('⚠️ [SyncService] No authenticated user, skipping sync');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'No authenticated user',
      );
    }

    final authenticatedUid = firebaseUser.uid;
    debugPrint('🔄 [SyncService] Syncing records for authenticated user: $authenticatedUid');

    if (!await isOnline()) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Device is offline',
      );
    }

    if (!skipLockCheck) {
      _isSyncing = true;
    }

    try {
      // Get pending records filtered by authenticated user
      final pendingRecords = await _logRecordService.getPendingSync(
        accountId: authenticatedUid,  // Only sync records for this user
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

      debugPrint('🔄 [SyncService] Found ${pendingRecords.length} pending records for $authenticatedUid');

      int successCount = 0;
      int failedCount = 0;
      int skippedCount = 0;

      for (final record in pendingRecords) {
        // Double-check record belongs to authenticated user (safety net)
        if (record.accountId != authenticatedUid) {
          debugPrint('⚠️ [SyncService] Skipping record ${record.logId} - account mismatch');
          skippedCount++;
          continue;
        }

        try {
          // Re-fetch the record to check if it's been modified since we fetched the list
          final currentRecord = await _logRecordService.getLogRecordByLogId(record.logId);
          
          if (currentRecord == null) {
            debugPrint('⚠️ [SyncService] Record ${record.logId} no longer exists, skipping');
            skippedCount++;
            continue;
          }

          // Check if record is still in a syncable state (pending or error)
          // If it's been synced or modified (revision changed), skip it
          if (currentRecord.syncState != SyncState.pending && 
              currentRecord.syncState != SyncState.error) {
            debugPrint('🔄 [SyncService] Record ${record.logId} is no longer syncable (state: ${currentRecord.syncState}), skipping');
            skippedCount++;
            continue;
          }

          // Check if record has been modified since we fetched it (revision or updatedAt changed)
          if (currentRecord.revision != record.revision || 
              currentRecord.updatedAt != record.updatedAt) {
            debugPrint('🔄 [SyncService] Record ${record.logId} was modified during sync (revision: ${record.revision} -> ${currentRecord.revision}), skipping to preserve changes');
            skippedCount++;
            continue;
          }

          // Record is still in syncable state and hasn't been modified, proceed with upload
          try {
            await _uploadRecord(currentRecord);
            successCount++;
          } catch (e) {
            // Check if this is a "modified during upload" error - these should be skipped, not failed
            if (e.toString().contains('modified during upload') ||
                e.toString().contains('not in syncable state')) {
              debugPrint('🔄 [SyncService] Record ${record.logId} was modified during upload, skipping');
              skippedCount++;
            } else {
              // Real error - mark as failed
              failedCount++;
              await _logRecordService.markSyncError(record, e.toString());
            }
          }
        } catch (e) {
          // Catch any errors from re-fetching or validation
          debugPrint('⚠️ [SyncService] Error processing record ${record.logId}: $e');
          failedCount++;
          await _logRecordService.markSyncError(record, e.toString());
        }
      }

      return SyncResult(
        success: successCount,
        failed: failedCount,
        skipped: skippedCount,
        message: 'Synced $successCount records, $failedCount failed, $skippedCount skipped (modified during sync)',
      );
    } finally {
      if (!skipLockCheck) {
        _isSyncing = false;
      }
    }
  }

  /// Upload a single record to Firestore
  /// 
  /// IMPORTANT: This method assumes the record is still in a syncable state.
  /// The caller should verify the record hasn't been modified before calling this.
  Future<void> _uploadRecord(LogRecord record) async {
    // Final safety check: Verify record is still in syncable state before uploading
    // This prevents race conditions where a record is modified between the check and upload
    if (record.syncState != SyncState.pending && record.syncState != SyncState.error) {
      throw Exception(
        'Cannot upload record ${record.logId}: not in syncable state (current: ${record.syncState})',
      );
    }

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

    // Final check before marking as synced: Re-fetch to ensure record wasn't modified during upload
    final freshRecord = await _logRecordService.getLogRecordByLogId(record.logId);
    if (freshRecord == null) {
      throw Exception('Record ${record.logId} was deleted during upload');
    }

    // If record was modified (revision or updatedAt changed), don't mark as synced
    // This preserves the user's changes which will be synced in the next cycle
    if (freshRecord.revision != record.revision || 
        freshRecord.updatedAt != record.updatedAt) {
      debugPrint(
        '⚠️ [SyncService] Record ${record.logId} was modified during upload. '
        'Skipping markSynced to preserve changes (revision: ${record.revision} -> ${freshRecord.revision})',
      );
      throw Exception('Record was modified during upload - preserving changes');
    }

    // Record is still unchanged, safe to mark as synced
    await _logRecordService.markSynced(freshRecord, DateTime.now());
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
        reasons: remoteRecord.reasons,
        moodRating: remoteRecord.moodRating,
        physicalRating: remoteRecord.physicalRating,
        latitude: remoteRecord.latitude,
        longitude: remoteRecord.longitude,
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
              reasons: remoteRecord.reasons,
              moodRating: remoteRecord.moodRating,
              physicalRating: remoteRecord.physicalRating,
              latitude: remoteRecord.latitude,
              longitude: remoteRecord.longitude,
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
              reasons: remoteRecord.reasons,
              moodRating: remoteRecord.moodRating,
              physicalRating: remoteRecord.physicalRating,
              latitude: remoteRecord.latitude,
              longitude: remoteRecord.longitude,
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
              reasons: record.reasons,
              moodRating: record.moodRating,
              physicalRating: record.physicalRating,
              latitude: record.latitude,
              longitude: record.longitude,
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
    return await syncAllLoggedInAccounts();
  }

  /// Sync all logged-in accounts
  /// Switches Firebase auth to each account temporarily to sync their data
  Future<SyncResult> syncAllLoggedInAccounts() async {
    if (_isSyncing) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;

    try {
      if (!await isOnline()) {
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'Device is offline',
        );
      }

      final loggedInAccounts = await _sessionManager.getLoggedInAccounts();
      
      if (loggedInAccounts.isEmpty) {
        debugPrint('🔄 [SyncService] No logged-in accounts to sync');
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'No logged-in accounts',
        );
      }

      debugPrint('🔄 [SyncService] Syncing ${loggedInAccounts.length} logged-in accounts');

      final auth = FirebaseAuth.instance;
      final originalUser = auth.currentUser;
      int totalSuccess = 0;
      int totalFailed = 0;

      for (final account in loggedInAccounts) {
        try {
          // Temporarily switch Firebase auth to this account
          await _switchToAccount(account);
          
          // Sync pending records for this account (skip lock check since we're managing it here)
          final result = await syncPendingRecords(skipLockCheck: true);
          totalSuccess += result.success;
          totalFailed += result.failed;
        } catch (e) {
          debugPrint('⚠️ [SyncService] Error syncing account ${account.userId}: $e');
          totalFailed++;
        }
      }

      // Restore original Firebase auth state
      if (originalUser != null && auth.currentUser?.uid != originalUser.uid) {
        try {
          final originalToken = await _sessionManager.getValidCustomToken(originalUser.uid);
          if (originalToken != null) {
            await auth.signInWithCustomToken(originalToken);
          }
        } catch (e) {
          debugPrint('⚠️ [SyncService] Could not restore original auth state: $e');
        }
      }

      return SyncResult(
        success: totalSuccess,
        failed: totalFailed,
        skipped: 0,
        message: 'Synced ${loggedInAccounts.length} accounts: $totalSuccess success, $totalFailed failed',
      );
    } catch (e) {
      debugPrint('❌ [SyncService] Error in syncAllLoggedInAccounts: $e');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Error syncing accounts: $e',
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Pull records for all logged-in accounts
  Future<SyncResult> pullAllLoggedInAccounts() async {
    if (!await isOnline()) {
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Device is offline',
      );
    }

    try {
      final loggedInAccounts = await _sessionManager.getLoggedInAccounts();
      
      if (loggedInAccounts.isEmpty) {
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'No logged-in accounts',
        );
      }

      debugPrint('🔄 [SyncService] Pulling records for ${loggedInAccounts.length} logged-in accounts');

      final auth = FirebaseAuth.instance;
      final originalUser = auth.currentUser;
      int totalSuccess = 0;
      int totalFailed = 0;

      for (final account in loggedInAccounts) {
        try {
          // Temporarily switch Firebase auth to this account
          await _switchToAccount(account);
          
          // Pull records for this account
          final result = await pullRecordsForAccountIncludingLegacy(
            accountId: account.userId,
          );
          totalSuccess += result.success;
          totalFailed += result.failed;
        } catch (e) {
          debugPrint('⚠️ [SyncService] Error pulling records for account ${account.userId}: $e');
          totalFailed++;
        }
      }

      // Restore original Firebase auth state
      if (originalUser != null && auth.currentUser?.uid != originalUser.uid) {
        try {
          final originalToken = await _sessionManager.getValidCustomToken(originalUser.uid);
          if (originalToken != null) {
            await auth.signInWithCustomToken(originalToken);
          }
        } catch (e) {
          debugPrint('⚠️ [SyncService] Could not restore original auth state: $e');
        }
      }

      return SyncResult(
        success: totalSuccess,
        failed: totalFailed,
        skipped: 0,
        message: 'Pulled records for ${loggedInAccounts.length} accounts: $totalSuccess success, $totalFailed failed',
      );
    } catch (e) {
      debugPrint('❌ [SyncService] Error in pullAllLoggedInAccounts: $e');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Error pulling accounts: $e',
      );
    }
  }

  /// Temporarily switch Firebase auth to the specified account
  Future<void> _switchToAccount(Account account) async {
    final auth = FirebaseAuth.instance;
    
    // Check if already authenticated as this account
    if (auth.currentUser?.uid == account.userId) {
      return;
    }

    // Get or generate custom token
    String? customToken = await _sessionManager.getValidCustomToken(account.userId);
    
    if (customToken == null) {
      // Try to generate a new token
      try {
        final tokenData = await _tokenService.generateCustomToken(account.userId);
        customToken = tokenData['customToken'] as String;
        await _sessionManager.storeCustomToken(account.userId, customToken);
      } catch (e) {
        debugPrint('⚠️ [SyncService] Could not generate token for ${account.userId}: $e');
        throw Exception('Could not get custom token for account ${account.userId}');
      }
    }

    // Sign in with custom token
    try {
      await auth.signInWithCustomToken(customToken);
      debugPrint('🔄 [SyncService] Switched to account ${account.userId} for sync');
    } catch (e) {
      debugPrint('⚠️ [SyncService] Failed to sign in with custom token for ${account.userId}: $e');
      // Token might be invalid, try to regenerate
      try {
        final tokenData = await _tokenService.generateCustomToken(account.userId);
        customToken = tokenData['customToken'] as String;
        await _sessionManager.storeCustomToken(account.userId, customToken);
        await auth.signInWithCustomToken(customToken);
        debugPrint('🔄 [SyncService] Switched to account ${account.userId} after token refresh');
      } catch (retryError) {
        debugPrint('❌ [SyncService] Failed to switch to account ${account.userId} after retry: $retryError');
        throw Exception('Could not switch to account ${account.userId}');
      }
    }
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
