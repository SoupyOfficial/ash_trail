import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../logging/app_logger.dart';
import '../models/log_record.dart';
import 'app_analytics_service.dart';
import '../models/account.dart';
import '../models/enums.dart';
import 'log_record_service.dart';
import 'legacy_data_adapter.dart';
import 'account_session_manager.dart';
import 'token_service.dart';
import 'error_reporting_service.dart';

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
  static final _log = AppLogger.logger('SyncService');
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
    _pullTimer = Timer.periodic(pullInterval, (_) => pullAllLoggedInAccounts());
    AppAnalyticsService.instance.setSyncStatus('enabled');
  }

  /// Stop automatic background sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _pullTimer?.cancel();
    _syncTimer = null;
    _pullTimer = null;
    AppAnalyticsService.instance.setSyncStatus('disabled');
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
      _log.w('No authenticated user, skipping sync');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'No authenticated user',
      );
    }

    final authenticatedUid = firebaseUser.uid;
    _log.i('Syncing records for authenticated user: $authenticatedUid');

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
        accountId: authenticatedUid, // Only sync records for this user
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

      _log.i(
        'Found ${pendingRecords.length} pending records for $authenticatedUid',
      );

      int successCount = 0;
      int failedCount = 0;
      int skippedCount = 0;

      for (final record in pendingRecords) {
        // Double-check record belongs to authenticated user (safety net)
        if (record.accountId != authenticatedUid) {
          _log.w('Skipping record ${record.logId} - account mismatch');
          skippedCount++;
          continue;
        }

        try {
          // Re-fetch the record to check if it's been modified since we fetched the list
          final currentRecord = await _logRecordService.getLogRecordByLogId(
            record.logId,
          );

          if (currentRecord == null) {
            _log.w('Record ${record.logId} no longer exists, skipping');
            skippedCount++;
            continue;
          }

          // Check if record is still in a syncable state (pending or error)
          // If it's been synced or modified (revision changed), skip it
          if (currentRecord.syncState != SyncState.pending &&
              currentRecord.syncState != SyncState.error) {
            _log.i(
              'Record ${record.logId} is no longer syncable (state: ${currentRecord.syncState}), skipping',
            );
            skippedCount++;
            continue;
          }

          // Check if record has been modified since we fetched it (revision or updatedAt changed)
          if (currentRecord.revision != record.revision ||
              currentRecord.updatedAt != record.updatedAt) {
            _log.i(
              'Record ${record.logId} was modified during sync (revision: ${record.revision} -> ${currentRecord.revision}), skipping to preserve changes',
            );
            skippedCount++;
            continue;
          }

          // Record is still in syncable state and hasn't been modified, proceed with upload
          try {
            await _uploadRecord(currentRecord);
            successCount++;
          } catch (e, st) {
            // Check if this is a "modified during upload" error - these should be skipped, not failed
            if (e.toString().contains('modified during upload') ||
                e.toString().contains('not in syncable state')) {
              _log.i(
                'Record ${record.logId} was modified during upload, skipping',
              );
              skippedCount++;
            } else {
              // Real error - mark as failed
              _log.e(
                'Failed to upload record ${record.logId}',
                error: e,
                stackTrace: st,
              );
              ErrorReportingService.instance.reportException(
                e,
                stackTrace: st,
                context: 'SyncService.syncPendingRecords',
              );
              failedCount++;
              await _logRecordService.markSyncError(record, e.toString());
            }
          }
        } catch (e, st) {
          // Catch any errors from re-fetching or validation
          _log.e('Error processing record ${record.logId}', error: e);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.syncPendingRecords',
          );
          failedCount++;
          await _logRecordService.markSyncError(record, e.toString());
        }
      }

      return SyncResult(
        success: successCount,
        failed: failedCount,
        skipped: skippedCount,
        message:
            'Synced $successCount records, $failedCount failed, $skippedCount skipped (modified during sync)',
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
    if (record.syncState != SyncState.pending &&
        record.syncState != SyncState.error) {
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
    final freshRecord = await _logRecordService.getLogRecordByLogId(
      record.logId,
    );
    if (freshRecord == null) {
      throw Exception('Record ${record.logId} was deleted during upload');
    }

    // If record was modified (revision or updatedAt changed), don't mark as synced
    // This preserves the user's changes which will be synced in the next cycle
    if (freshRecord.revision != record.revision ||
        freshRecord.updatedAt != record.updatedAt) {
      _log.w(
        'Record ${record.logId} was modified during upload. '
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
        } catch (e, st) {
          _log.e('Failed to process record', error: e, stackTrace: st);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.pullRecordsForAccount',
          );
          failedCount++;
        }
      }

      return SyncResult(
        success: successCount,
        failed: failedCount,
        skipped: 0,
        message: 'Pulled $successCount records',
      );
    } catch (e, st) {
      _log.e('Error pulling records for account', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService.pullRecordsForAccount',
      );
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
        } catch (e, st) {
          _log.e('Failed to process record', error: e, stackTrace: st);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.pullRecordsForAccountIncludingLegacy',
          );
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
    } catch (e, st) {
      _log.e(
        'Error pulling records including legacy',
        error: e,
        stackTrace: st,
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService.pullRecordsForAccountIncludingLegacy',
      );
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
    } catch (e, st) {
      _log.e('Error pulling current records', error: e);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService._pullCurrentRecords',
      );
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
    } catch (e, st) {
      _log.e('Error pulling legacy records', error: e);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService._pullLegacyRecords',
      );
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
        } catch (e, st) {
          _log.e('Error importing legacy record ${record.logId}', error: e);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.importLegacyDataForAccount',
          );
        }
      }

      return importedCount;
    } catch (e, st) {
      _log.e('Error importing legacy data', error: e);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService.importLegacyDataForAccount',
      );
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
              } catch (e, st) {
                _log.e(
                  'Failed to parse record in watch stream',
                  error: e,
                  stackTrace: st,
                );
                ErrorReportingService.instance.reportException(
                  e,
                  stackTrace: st,
                  context: 'SyncService.watchAccountLogsIncludingLegacy',
                );
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
      _log.d('[MULTI_SYNC] Already in progress, skipping');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    final stopwatch = Stopwatch()..start();

    try {
      if (!await isOnline()) {
        _log.d('[MULTI_SYNC] Device offline, skipping sync');
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'Device is offline',
        );
      }

      final loggedInAccounts = await _sessionManager.getLoggedInAccounts();

      if (loggedInAccounts.isEmpty) {
        _log.i('[MULTI_SYNC] No logged-in accounts to sync');
        return SyncResult(
          success: 0,
          failed: 0,
          skipped: 0,
          message: 'No logged-in accounts',
        );
      }

      _log.w(
        '[MULTI_SYNC_START] Syncing ${loggedInAccounts.length} accounts: '
        '${loggedInAccounts.map((a) => "${a.email}(${a.userId.substring(0, 8)}...)").join(", ")}',
      );

      final auth = FirebaseAuth.instance;
      final originalUser = auth.currentUser;
      _log.d(
        '[MULTI_SYNC] Original Firebase user: uid=${originalUser?.uid}, email=${originalUser?.email}',
      );
      int totalSuccess = 0;
      int totalFailed = 0;

      for (final account in loggedInAccounts) {
        try {
          // Temporarily switch Firebase auth to this account
          _log.d(
            '[MULTI_SYNC] Switching to account: ${account.email} (${account.userId})',
          );
          await _switchToAccount(account);

          // Sync pending records for this account (skip lock check since we're managing it here)
          final result = await syncPendingRecords(skipLockCheck: true);
          _log.d(
            '[MULTI_SYNC] Account ${account.email}: '
            'success=${result.success}, failed=${result.failed}, skipped=${result.skipped}',
          );
          totalSuccess += result.success;
          totalFailed += result.failed;
        } catch (e, st) {
          _log.e(
            '[MULTI_SYNC] Failed to sync account ${account.email} (${account.userId})',
            error: e,
          );
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.syncAllLoggedInAccounts',
          );
          totalFailed++;
        }
      }

      // Restore original Firebase auth state
      if (originalUser != null && auth.currentUser?.uid != originalUser.uid) {
        _log.d('[MULTI_SYNC] Restoring original auth: uid=${originalUser.uid}');
        try {
          final originalToken = await _sessionManager.getValidCustomToken(
            originalUser.uid,
          );
          if (originalToken != null) {
            await auth.signInWithCustomToken(originalToken);
            _log.d('[MULTI_SYNC] Original auth restored successfully');
          } else {
            _log.w(
              '[MULTI_SYNC] No valid token to restore original auth for ${originalUser.uid}',
            );
          }
        } catch (e, st) {
          _log.w(
            '[MULTI_SYNC] Could not restore original auth state',
            error: e,
          );
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.syncAllLoggedInAccounts',
          );
        }
      }

      stopwatch.stop();
      _log.w(
        '[MULTI_SYNC_END] ${loggedInAccounts.length} accounts synced in ${stopwatch.elapsedMilliseconds}ms: '
        '$totalSuccess success, $totalFailed failed',
      );
      AppAnalyticsService.instance.logSyncCompleted(
        pushed: totalSuccess,
        failed: totalFailed,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return SyncResult(
        success: totalSuccess,
        failed: totalFailed,
        skipped: 0,
        message:
            'Synced ${loggedInAccounts.length} accounts: $totalSuccess success, $totalFailed failed',
      );
    } catch (e, st) {
      stopwatch.stop();
      _log.e(
        '[MULTI_SYNC_FAIL] Error after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService.syncAllLoggedInAccounts',
      );
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
      _log.d('[MULTI_PULL] Device offline, skipping pull');
      return SyncResult(
        success: 0,
        failed: 0,
        skipped: 0,
        message: 'Device is offline',
      );
    }

    final stopwatch = Stopwatch()..start();
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

      _log.w(
        '[MULTI_PULL_START] Pulling records for ${loggedInAccounts.length} accounts: '
        '${loggedInAccounts.map((a) => "${a.email}(${a.userId.substring(0, 8)}...)").join(", ")}',
      );

      final auth = FirebaseAuth.instance;
      final originalUser = auth.currentUser;
      int totalSuccess = 0;
      int totalFailed = 0;

      for (final account in loggedInAccounts) {
        try {
          // Temporarily switch Firebase auth to this account
          _log.d(
            '[MULTI_PULL] Switching to account: ${account.email} (${account.userId})',
          );
          await _switchToAccount(account);

          // Pull records for this account
          final result = await pullRecordsForAccountIncludingLegacy(
            accountId: account.userId,
          );
          _log.d(
            '[MULTI_PULL] Account ${account.email}: '
            'success=${result.success}, failed=${result.failed}',
          );
          totalSuccess += result.success;
          totalFailed += result.failed;
        } catch (e, st) {
          _log.e(
            '[MULTI_PULL] Failed to pull for account ${account.email} (${account.userId})',
            error: e,
          );
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.pullAllLoggedInAccounts',
          );
          totalFailed++;
        }
      }

      // Restore original Firebase auth state
      if (originalUser != null && auth.currentUser?.uid != originalUser.uid) {
        _log.d('[MULTI_PULL] Restoring original auth: uid=${originalUser.uid}');
        try {
          final originalToken = await _sessionManager.getValidCustomToken(
            originalUser.uid,
          );
          if (originalToken != null) {
            await auth.signInWithCustomToken(originalToken);
            _log.d('[MULTI_PULL] Original auth restored');
          } else {
            _log.w(
              '[MULTI_PULL] No valid token to restore original auth for ${originalUser.uid}',
            );
          }
        } catch (e, st) {
          _log.w(
            '[MULTI_PULL] Could not restore original auth state',
            error: e,
          );
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'SyncService.pullAllLoggedInAccounts',
          );
        }
      }

      stopwatch.stop();
      _log.w(
        '[MULTI_PULL_END] ${loggedInAccounts.length} accounts pulled in ${stopwatch.elapsedMilliseconds}ms: '
        '$totalSuccess success, $totalFailed failed',
      );
      AppAnalyticsService.instance.logSyncCompleted(
        pulled: totalSuccess,
        failed: totalFailed,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      return SyncResult(
        success: totalSuccess,
        failed: totalFailed,
        skipped: 0,
        message:
            'Pulled records for ${loggedInAccounts.length} accounts: $totalSuccess success, $totalFailed failed',
      );
    } catch (e, st) {
      stopwatch.stop();
      _log.e(
        '[MULTI_PULL_FAIL] Error after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService.pullAllLoggedInAccounts',
      );
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
      _log.d(
        '[SWITCH_AUTH] Already authenticated as ${account.email}, no switch needed',
      );
      return;
    }

    _log.d(
      '[SWITCH_AUTH] Need to switch from ${auth.currentUser?.uid ?? "null"} to ${account.userId}',
    );

    // Get or generate custom token
    String? customToken = await _sessionManager.getValidCustomToken(
      account.userId,
    );

    if (customToken == null) {
      // Try to generate a new token
      _log.d(
        '[SWITCH_AUTH] No cached token for ${account.email}, generating new one...',
      );
      try {
        final tokenData = await _tokenService.generateCustomToken(
          account.userId,
        );
        customToken = tokenData['customToken'] as String;
        await _sessionManager.storeCustomToken(account.userId, customToken);
        _log.d('[SWITCH_AUTH] New token generated for ${account.email}');
      } catch (e, st) {
        _log.e(
          '[SWITCH_AUTH] Token generation FAILED for ${account.email}',
          error: e,
        );
        ErrorReportingService.instance.reportException(
          e,
          stackTrace: st,
          context: 'SyncService._switchToAccount',
        );
        throw Exception(
          'Could not get custom token for account ${account.userId}',
        );
      }
    } else {
      _log.d(
        '[SWITCH_AUTH] Using cached token for ${account.email} (${customToken.length} chars)',
      );
    }

    // Sign in with custom token
    try {
      await auth.signInWithCustomToken(customToken);
      _log.w(
        '[SWITCH_AUTH] Switched to ${account.email} (${account.userId}) — '
        'Firebase uid now: ${auth.currentUser?.uid}',
      );
    } catch (e, st) {
      _log.w(
        '[SWITCH_AUTH] First attempt FAILED for ${account.email}, refreshing token...',
        error: e,
      );
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'SyncService._switchToAccount',
      );
      // Token might be invalid, try to regenerate
      try {
        final tokenData = await _tokenService.generateCustomToken(
          account.userId,
        );
        customToken = tokenData['customToken'] as String;
        await _sessionManager.storeCustomToken(account.userId, customToken);
        await auth.signInWithCustomToken(customToken);
        _log.w('[SWITCH_AUTH] Retry SUCCESS for ${account.email}');
      } catch (retryError) {
        _log.e(
          '[SWITCH_AUTH] Retry FAILED for ${account.email}',
          error: retryError,
        );
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
