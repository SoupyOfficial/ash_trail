import 'package:uuid/uuid.dart';
import '../logging/app_logger.dart';
import '../models/app_error.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../repositories/log_record_repository.dart';
import 'validation_service.dart';
import 'app_analytics_service.dart';
import 'database_service.dart';
import 'account_service.dart';

/// LogRecordService handles all CRUD operations for log records
/// Implements offline-first with sync queue management
class LogRecordService {
  static final _log = AppLogger.logger('LogRecordService');
  late final LogRecordRepository _repository;
  final Uuid _uuid = const Uuid();

  /// Optional AccountService for validating accountId before saving
  /// When null, validation is skipped (useful for tests)
  final AccountService? _accountService;

  /// Whether to validate accountId exists before creating records
  /// Default: true in production, can be disabled for tests
  final bool validateAccountId;

  LogRecordService({
    LogRecordRepository? repository,
    AccountService? accountService,
    this.validateAccountId = true,
  }) : _accountService = accountService {
    if (repository != null) {
      _repository = repository;
    } else {
      // Initialize repository with Hive database
      final dbService = DatabaseService.instance;
      final dbBoxes = dbService.boxes;

      // Pass Hive boxes map to repository
      _repository = createLogRecordRepository(
        dbBoxes is Map<String, dynamic> ? dbBoxes : {},
      );
    }
  }

  /// Get device ID (platform-specific, simplified here)
  String _getDeviceId() {
    // TODO: Implement platform-specific device ID retrieval
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get app version (simplified)
  String _getAppVersion() {
    // TODO: Get from package_info_plus
    return '1.0.0';
  }

  /// Create a new log record
  /// This is the main entry point for logging events
  Future<LogRecord> createLogRecord({
    required String accountId,
    required EventType eventType,
    DateTime? eventAt,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    Source source = Source.manual,
    double? moodRating,
    double? physicalRating,
    List<LogReason>? reasons,
    double? latitude,
    double? longitude,
  }) async {
    _log.w(
      '[CREATE_LOG_START] accountId=$accountId, eventType=${eventType.name}, '
      'duration=$duration, source=${source.name}',
    );
    // Validate accountId exists (if validation enabled and service available)
    if (validateAccountId && _accountService != null) {
      final exists = await _accountService.accountExists(accountId);
      if (!exists) {
        _log.e('Attempted to create log for non-existent account: $accountId');
        throw AppError.validation(
          message:
              'Account not found. Please select a valid account before logging.',
          code: 'VALIDATION_ACCOUNT_NOT_FOUND',
          technicalDetail: 'accountId=$accountId does not exist',
        );
      }
    }

    // Validate location cross-field constraint: both present or both null
    if (!ValidationService.isValidLocationPair(latitude, longitude)) {
      throw const AppError.validation(
        message: 'Location coordinates must both be present or both be null.',
        code: 'VALIDATION_LOCATION_PAIR',
      );
    }

    // Validate ratings are in correct range (1-10, not 0-10)
    // Per design 5.5: Ratings can be null (not set) or 1-10, but zero is not allowed
    if (moodRating != null && (moodRating < 1 || moodRating > 10)) {
      throw const AppError.validation(
        message: 'Mood rating must be between 1 and 10.',
        code: 'VALIDATION_MOOD_RANGE',
      );
    }
    if (physicalRating != null && (physicalRating < 1 || physicalRating > 10)) {
      throw const AppError.validation(
        message: 'Physical rating must be between 1 and 10.',
        code: 'VALIDATION_PHYSICAL_RANGE',
      );
    }

    final logId = _uuid.v4();
    final now = DateTime.now();

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt ?? now,
      createdAt: now,
      updatedAt: now,
      duration: duration,
      unit: unit,
      note: note,
      source: source,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      moodRating: moodRating,
      physicalRating: physicalRating,
      reasons: reasons,
      latitude: latitude,
      longitude: longitude,
    );

    _log.w(
      '[CREATE_LOG] Persisting to repository: logId=$logId, '
      'accountId=$accountId, eventAt=${record.eventAt}',
    );
    final created = await _repository.create(record);
    _log.w(
      '[CREATE_LOG_END] Record persisted: logId=${created.logId}, '
      'accountId=${created.accountId}',
    );
    AppAnalyticsService.instance.logLogCreated(eventType: eventType.name);
    return created;
  }

  /// Import a log record from remote source (e.g., Firestore)
  /// This preserves the remote logId and metadata
  Future<LogRecord> importLogRecord({
    required String logId,
    required String accountId,
    required EventType eventType,
    required DateTime eventAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    List<LogReason>? reasons,
    double? moodRating,
    double? physicalRating,
    double? latitude,
    double? longitude,
    Source source = Source.imported,
    String? deviceId,
    String? appVersion,
    String? transferredFromAccountId,
    DateTime? transferredAt,
    String? transferredFromLogId,
  }) async {
    final record = LogRecord.create(
      logId: logId, // Use provided logId instead of generating new one
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      duration: duration,
      unit: unit,
      note: note,
      reasons: reasons,
      moodRating: moodRating,
      physicalRating: physicalRating,
      latitude: latitude,
      longitude: longitude,
      source: source,
      deviceId: deviceId ?? _getDeviceId(),
      appVersion: appVersion ?? _getAppVersion(),
      syncState: SyncState.synced, // Mark as synced since it came from remote
      transferredFromAccountId: transferredFromAccountId,
      transferredAt: transferredAt,
      transferredFromLogId: transferredFromLogId,
    );

    return await _repository.create(record);
  }

  /// Update an existing log record
  Future<LogRecord> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? duration,
    Unit? unit,
    String? note,
    double? moodRating,
    double? physicalRating,
    List<LogReason>? reasons,
    double? latitude,
    double? longitude,
  }) async {
    if (eventType != null && eventType != record.eventType) {
      record.eventType = eventType;
    }

    if (eventAt != null && eventAt != record.eventAt) {
      record.eventAt = eventAt;
    }

    if (duration != null && duration != record.duration) {
      record.duration = duration;
    }

    if (unit != null && unit != record.unit) {
      record.unit = unit;
    }

    if (note != null && note != record.note) {
      record.note = note;
    }

    // Allow setting mood rating (including null to clear)
    record.moodRating = moodRating ?? record.moodRating;

    // Allow setting physical rating (including null to clear)
    record.physicalRating = physicalRating ?? record.physicalRating;

    // Allow setting reasons (including null to clear)
    if (reasons != null) {
      record.reasons = reasons.isEmpty ? null : reasons;
    }

    // Allow setting location (including null to clear)
    if (latitude != null || longitude != null) {
      record.latitude = latitude;
      record.longitude = longitude;
    }

    // Mark as dirty
    record.markDirty();

    AppAnalyticsService.instance.logLogUpdated();
    return await _repository.update(record);
  }

  /// Soft delete a log record
  Future<void> deleteLogRecord(LogRecord record) async {
    record.softDelete();
    AppAnalyticsService.instance.logLogDeleted();
    await _repository.update(record);
  }

  /// Transfer a log record from the current account to another account.
  ///
  /// Soft-deletes the original record and creates a new copy under the target
  /// account with transfer metadata for audit trail.
  /// Returns the newly created record in the target account.
  Future<LogRecord> transferLogRecord(
    LogRecord record,
    String targetAccountId,
  ) async {
    _log.w(
      '[TRANSFER_START] logId=${record.logId}, '
      'from=${record.accountId}, to=$targetAccountId',
    );

    // Validate target account is different from source
    if (targetAccountId == record.accountId) {
      throw AppError.validation(
        message: 'Cannot transfer a log to the same account.',
        code: 'TRANSFER_SELF',
        technicalDetail: 'targetAccountId=$targetAccountId == record.accountId',
      );
    }

    // Validate target account exists
    if (validateAccountId && _accountService != null) {
      final exists = await _accountService.accountExists(targetAccountId);
      if (!exists) {
        throw AppError.validation(
          message: 'Target account not found.',
          code: 'TRANSFER_TARGET_NOT_FOUND',
          technicalDetail: 'targetAccountId=$targetAccountId does not exist',
        );
      }
    }

    // Validate record is not already deleted
    if (record.isDeleted) {
      throw const AppError.validation(
        message: 'Cannot transfer a deleted log entry.',
        code: 'TRANSFER_DELETED',
      );
    }

    final now = DateTime.now();
    final newLogId = _uuid.v4();

    // 1. Soft-delete the original record
    record.softDelete();
    await _repository.update(record);

    // 2. Create new record under target account with transfer metadata
    final newRecord = LogRecord.create(
      logId: newLogId,
      accountId: targetAccountId,
      eventType: record.eventType,
      eventAt: record.eventAt,
      createdAt: record.createdAt,
      updatedAt: now,
      duration: record.duration,
      unit: record.unit,
      note: record.note,
      reasons: record.reasons,
      moodRating: record.moodRating,
      physicalRating: record.physicalRating,
      latitude: record.latitude,
      longitude: record.longitude,
      source: Source.migration,
      deviceId: record.deviceId,
      appVersion: record.appVersion,
      timeConfidence: record.timeConfidence,
      syncState: SyncState.pending,
      transferredFromAccountId: record.accountId,
      transferredAt: now,
      transferredFromLogId: record.logId,
    );

    final created = await _repository.create(newRecord);

    _log.w(
      '[TRANSFER_END] original=${record.logId} soft-deleted, '
      'new=${created.logId} created for $targetAccountId',
    );

    return created;
  }

  /// Undo a transfer by restoring the original record and deleting the transferred copy.
  ///
  /// Takes the transferred record (the new copy) and reverses the transfer:
  /// - Finds the original record via [transferredFromLogId]
  /// - Restores the original (un-soft-deletes it)
  /// - Soft-deletes the transferred copy
  Future<void> undoTransfer(LogRecord transferredRecord) async {
    _log.w(
      '[UNDO_TRANSFER_START] transferredLogId=${transferredRecord.logId}, '
      'originalLogId=${transferredRecord.transferredFromLogId}',
    );

    if (transferredRecord.transferredFromLogId == null) {
      throw const AppError.validation(
        message: 'This log was not transferred.',
        code: 'UNDO_TRANSFER_NOT_TRANSFERRED',
      );
    }

    // Find the original record
    final original = await _repository.getByLogId(
      transferredRecord.transferredFromLogId!,
    );

    if (original == null) {
      throw const AppError.validation(
        message: 'Original log record not found. Cannot undo transfer.',
        code: 'UNDO_TRANSFER_ORIGINAL_NOT_FOUND',
      );
    }

    // Restore the original record
    original.isDeleted = false;
    original.deletedAt = null;
    original.markDirty();
    await _repository.update(original);

    // Soft-delete the transferred copy
    transferredRecord.softDelete();
    await _repository.update(transferredRecord);

    _log.w(
      '[UNDO_TRANSFER_END] original=${original.logId} restored, '
      'transferred=${transferredRecord.logId} deleted',
    );
  }

  /// Hard delete a log record (use with caution)
  Future<void> hardDeleteLogRecord(LogRecord record) async {
    await _repository.delete(record.logId);
  }

  /// Get a log record by its logId
  Future<LogRecord?> getLogRecordByLogId(String logId) async {
    return await _repository.getByLogId(logId);
  }

  /// Get all log records for an account
  Future<List<LogRecord>> getLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    List<EventType>? eventTypes,
    bool includeDeleted = false,
  }) async {
    // Get base records from repository
    List<LogRecord> records;

    if (startDate != null && endDate != null) {
      records = await _repository.getByDateRange(accountId, startDate, endDate);
    } else {
      records = await _repository.getByAccount(accountId);
    }

    // Apply additional filters in memory
    return records.where((record) {
      if (!includeDeleted && record.isDeleted) return false;
      if (eventTypes != null && !eventTypes.contains(record.eventType)) {
        return false;
      }
      if (startDate != null && record.eventAt.isBefore(startDate)) return false;
      if (endDate != null && record.eventAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Get log records that need syncing.
  ///
  /// If [accountId] is provided, only returns pending records for that account.
  /// This is important for multi-account support to ensure we only sync records
  /// that belong to the currently authenticated Firebase user.
  Future<List<LogRecord>> getPendingSync({
    String? accountId,
    int limit = 100,
  }) async {
    var records = await _repository.getPendingSync();

    // Filter by accountId if provided
    if (accountId != null) {
      records = records.where((r) => r.accountId == accountId).toList();
    }

    return records.take(limit).toList();
  }

  /// Count log records for an account
  Future<int> countLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );
    return records.length;
  }

  /// Watch log records for real-time updates
  Stream<List<LogRecord>> watchLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) {
    // Use repository watch and filter in stream
    Stream<List<LogRecord>> stream;

    if (startDate != null && endDate != null) {
      stream = _repository.watchByDateRange(accountId, startDate, endDate);
    } else {
      stream = _repository.watchByAccount(accountId);
    }

    return stream.map((records) {
      return records.where((record) {
        if (!includeDeleted && record.isDeleted) return false;
        return true;
      }).toList();
    });
  }

  /// Mark a record as synced
  Future<void> markSynced(LogRecord record, DateTime remoteUpdateTime) async {
    record.markSynced(remoteUpdateTime);
    await _repository.update(record);
  }

  /// Mark a record as having a sync error
  Future<void> markSyncError(LogRecord record, String error) async {
    record.markSyncError(error);
    await _repository.update(record);
  }

  /// Apply a remote deletion state to a local record without marking it dirty
  /// Used when pulling from Firestore where the remote version is deleted
  Future<void> applyRemoteDeletion(
    LogRecord record, {
    DateTime? deletedAt,
    required DateTime remoteUpdatedAt,
  }) async {
    record.isDeleted = true;
    record.deletedAt = deletedAt ?? record.deletedAt ?? DateTime.now();
    // Align local updatedAt to remote for consistency
    record.updatedAt = remoteUpdatedAt;
    // Mark as synced with remote update timestamp
    record.markSynced(remoteUpdatedAt);
    await _repository.update(record);
  }

  /// Delete all log records for an account (used when deleting account)
  Future<void> deleteAllByAccount(String accountId) async {
    await _repository.deleteByAccount(accountId);
  }

  /// Clear transfer metadata on records in other accounts that reference the given account.
  ///
  /// Called before account deletion to prevent dangling references in transfer audit trails.
  /// Records that were transferred FROM the deleting account will have their
  /// [transferredFromAccountId] cleared.
  Future<void> clearTransferMetadataForAccount(String accountId) async {
    final allRecords = await _repository.getAll();
    for (final record in allRecords) {
      if (record.transferredFromAccountId == accountId) {
        record.transferredFromAccountId = null;
        record.transferredAt = null;
        record.transferredFromLogId = null;
        record.markDirty();
        await _repository.update(record);
        _log.i(
          'Cleared transfer metadata on ${record.logId} '
          '(source account $accountId being deleted)',
        );
      }
    }
  }

  /// Batch create multiple log records
  Future<List<LogRecord>> batchCreateLogRecords(
    List<Map<String, dynamic>> recordData,
  ) async {
    final records = <LogRecord>[];

    for (final data in recordData) {
      final logId = _uuid.v4();
      final now = DateTime.now();

      final record = LogRecord.create(
        logId: logId,
        accountId: data['accountId'] as String,
        eventType: data['eventType'] as EventType,
        eventAt: data['eventAt'] as DateTime? ?? now,
        createdAt: now,
        updatedAt: now,
        duration: (data['duration'] as num?)?.toDouble() ?? 0,
        unit: data['unit'] as Unit? ?? Unit.seconds,
        note: data['note'] as String?,
        source: data['source'] as Source? ?? Source.manual,
        deviceId: _getDeviceId(),
        appVersion: _getAppVersion(),
        syncState: SyncState.pending,
      );

      records.add(record);
    }

    // Batch create using repository
    for (final record in records) {
      await _repository.create(record);
    }

    return records;
  }

  /// Get statistics for an account
  Future<Map<String, dynamic>> getStatistics({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
    );

    final totalCount = records.length;
    final totalDuration = records.fold<double>(
      0,
      (sum, record) => sum + record.duration,
    );

    final eventTypeCounts = <EventType, int>{};
    for (final record in records) {
      eventTypeCounts[record.eventType] =
          (eventTypeCounts[record.eventType] ?? 0) + 1;
    }

    return {
      'totalCount': totalCount,
      'totalDuration': totalDuration,
      'averageDuration': totalCount > 0 ? totalDuration / totalCount : 0,
      'eventTypeCounts': eventTypeCounts,
      'firstEvent': records.isNotEmpty ? records.first.eventAt : null,
      'lastEvent': records.isNotEmpty ? records.last.eventAt : null,
    };
  }

  // ===== NEW LOGGING OPERATIONS =====

  /// Quick log: One-tap logging with minimal input
  Future<LogRecord> quickLog({
    required String accountId,
    EventType? eventType,
    double? duration,
    Unit? unit,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate and clamp duration
    final clampedDuration =
        duration != null && unit != null
            ? (ValidationService.clampValue(duration, unit) ?? 0)
            : duration ?? 0;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType ?? EventType.vape,
      eventAt: now,
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: unit ?? Unit.seconds,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: TimeConfidence.high,
    );

    AppAnalyticsService.instance.logLogCreated(
      quickLog: true,
      eventType: (eventType ?? EventType.vape).name,
    );
    return await _repository.create(record);
  }

  /// Backdate log: Create a log entry for a past time
  Future<LogRecord> backdateLog({
    required String accountId,
    required DateTime eventAt,
    required EventType eventType,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate backdate time
    if (!ValidationService.isValidBackdateTime(eventAt)) {
      throw const AppError.validation(
        message: 'Backdate time is too far in the past (max 30 days).',
        code: 'VALIDATION_BACKDATE_TOO_OLD',
      );
    }

    // Detect clock skew and set time confidence
    final timeConfidence = ValidationService.detectClockSkew(eventAt);

    // Validate and clamp duration
    final clampedDuration = ValidationService.clampValue(duration, unit) ?? 0;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: unit,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: timeConfidence,
    );

    await _repository.create(record);

    return record;
  }

  /// Duration log: Create a log entry with measured duration from hold-to-record
  /// The duration is captured from press-and-hold interaction
  Future<LogRecord> recordDurationLog({
    required String accountId,
    required int durationMs,
    EventType? eventType,
    String? note,
    double? latitude,
    double? longitude,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Convert milliseconds to seconds with decimal precision
    final durationSeconds = durationMs / 1000.0;

    // Validate minimum threshold (e.g., 1 second minimum)
    if (durationSeconds < 1.0) {
      throw const AppError.validation(
        message: 'Duration too short (minimum 1 second).',
        code: 'VALIDATION_DURATION_SHORT',
      );
    }

    // Clamp duration to reasonable maximum (e.g., 1 hour)
    final clampedDuration =
        ValidationService.clampValue(durationSeconds, Unit.seconds) ??
        durationSeconds;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType ?? EventType.vape,
      eventAt: now, // Release timestamp
      createdAt: now,
      updatedAt: now,
      duration: clampedDuration,
      unit: Unit.seconds,
      note: note,
      latitude: latitude,
      longitude: longitude,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence:
          TimeConfidence.high, // High confidence for measured duration
    );

    return await _repository.create(record);
  }

  /// Restore a soft-deleted record
  Future<void> restoreDeleted(LogRecord record) async {
    record.isDeleted = false;
    record.deletedAt = null;
    record.markDirty();

    AppAnalyticsService.instance.logLogDeleted(restored: true);
    await _repository.update(record);
  }

  /// Find potential duplicates for a given record
  Future<List<LogRecord>> findPotentialDuplicates(
    LogRecord record, {
    Duration timeTolerance = const Duration(minutes: 1),
  }) async {
    // Find records within time tolerance
    final startTime = record.eventAt.subtract(timeTolerance);
    final endTime = record.eventAt.add(timeTolerance);

    // Get all records in date range for the account
    final candidates = await _repository.getByDateRange(
      record.accountId,
      startTime,
      endTime,
    );

    // Filter using duplicate detection logic
    return candidates
        .where(
          (candidate) =>
              candidate.logId != record.logId &&
              candidate.eventType == record.eventType &&
              !candidate.isDeleted &&
              ValidationService.isPotentialDuplicate(
                eventAt1: record.eventAt,
                eventAt2: candidate.eventAt,
                value1: record.duration,
                value2: candidate.duration,
                eventType1: record.eventType.name,
                eventType2: candidate.eventType.name,
                timeTolerance: timeTolerance,
              ),
        )
        .toList();
  }

  /// Update record with context fields (location, ratings)
  Future<LogRecord> updateContext(
    LogRecord record, {
    double? latitude,
    double? longitude,
    double? moodRating,
    double? physicalRating,
  }) async {
    bool changed = false;

    if (latitude != null && longitude != null) {
      record.latitude = latitude;
      record.longitude = longitude;
      changed = true;
    }

    if (moodRating != null) {
      final validatedMood = ValidationService.validateMood(moodRating);
      if (validatedMood != record.moodRating) {
        record.moodRating = validatedMood;
        changed = true;
      }
    }

    if (physicalRating != null) {
      final validatedPhysical = ValidationService.validateCraving(
        physicalRating,
      );
      if (validatedPhysical != record.physicalRating) {
        record.physicalRating = validatedPhysical;
        changed = true;
      }
    }

    if (changed) {
      record.markDirty();
      await _repository.update(record);
    }

    return record;
  }

  /// Import multiple legacy log records in batch
  /// Useful for migrating legacy data from old tables
  /// Returns count of successfully imported records
  Future<int> importLegacyRecordsBatch(List<LogRecord> records) async {
    int importedCount = 0;

    for (final record in records) {
      try {
        // Check if record already exists locally
        final existing = await _repository.getByLogId(record.logId);

        if (existing == null) {
          // New record - import it
          final imported = LogRecord.create(
            logId: record.logId,
            accountId: record.accountId,
            eventType: record.eventType,
            eventAt: record.eventAt,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            duration: record.duration,
            unit: record.unit,
            note: record.note,
            source: Source.imported,
            deviceId: record.deviceId,
            appVersion: record.appVersion,
            syncState: SyncState.synced,
            moodRating: record.moodRating,
            physicalRating: record.physicalRating,
            reasons: record.reasons,
            latitude: record.latitude,
            longitude: record.longitude,
          );
          await _repository.create(imported);
          importedCount++;
        } else if (record.updatedAt.isAfter(existing.updatedAt)) {
          // Update if remote version is newer
          existing.eventType = record.eventType;
          existing.eventAt = record.eventAt;
          existing.duration = record.duration;
          existing.unit = record.unit;
          existing.note = record.note;
          existing.moodRating = record.moodRating;
          existing.physicalRating = record.physicalRating;
          existing.reasons = record.reasons;
          existing.latitude = record.latitude;
          existing.longitude = record.longitude;
          existing.updatedAt = record.updatedAt;
          existing.markDirty();

          await _repository.update(existing);
          importedCount++;
        }
      } catch (e) {
        _log.e('Error importing legacy record ${record.logId}', error: e);
      }
    }

    return importedCount;
  }

  /// Check if there is legacy data to migrate for an account
  /// This requires integration with LegacyDataAdapter
  /// Returns true if legacy data exists
  Future<bool> hasLegacyDataForAccount(String accountId) async {
    // Note: This method requires injecting LegacyDataAdapter
    // For now, it serves as a marker for integration
    // Implementation depends on how the service is initialized
    return false;
  }

  /// Get migration status for legacy data
  /// Returns a map with status information
  Future<Map<String, dynamic>> getLegacyMigrationStatus(
    String accountId,
  ) async {
    return {
      'hasPendingMigration': false,
      'legacyRecordCount': 0,
      'localRecordCount': await countLogRecords(accountId: accountId),
      'lastChecked': DateTime.now(),
    };
  }
}
