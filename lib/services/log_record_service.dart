import 'package:uuid/uuid.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../repositories/log_record_repository.dart';
import 'database_service.dart';
import 'validation_service.dart';

/// LogRecordService handles all CRUD operations for log records
/// Implements offline-first with sync queue management
class LogRecordService {
  late final LogRecordRepository _repository;
  final Uuid _uuid = const Uuid();

  LogRecordService() {
    // Initialize repository based on platform
    final dbService = DatabaseService.instance;
    final dbInstance = dbService.instance;

    _repository = createLogRecordRepository(
      dbInstance is Map<String, dynamic> ? dbInstance : null,
    );
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
    String? profileId,
    required EventType eventType,
    DateTime? eventAt,
    double? value,
    Unit unit = Unit.none,
    String? note,
    List<String>? tags,
    String? sessionId,
    Source source = Source.manual,
  }) async {
    final logId = _uuid.v4();
    final now = DateTime.now();

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      profileId: profileId,
      eventType: eventType,
      eventAt: eventAt ?? now,
      createdAt: now,
      updatedAt: now,
      value: value,
      unit: unit,
      note: note,
      tagsString: tags?.join(','),
      sessionId: sessionId,
      source: source,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
    );

    return await _repository.create(record);
  }

  /// Import a log record from remote source (e.g., Firestore)
  /// This preserves the remote logId and metadata
  Future<LogRecord> importLogRecord({
    required String logId,
    required String accountId,
    String? profileId,
    required EventType eventType,
    required DateTime eventAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? value,
    Unit unit = Unit.none,
    String? note,
    List<String>? tags,
    String? sessionId,
    Source source = Source.imported,
    String? deviceId,
    String? appVersion,
  }) async {
    final record = LogRecord.create(
      logId: logId, // Use provided logId instead of generating new one
      accountId: accountId,
      profileId: profileId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      value: value,
      unit: unit,
      note: note,
      tagsString: tags?.join(','),
      sessionId: sessionId,
      source: source,
      deviceId: deviceId ?? _getDeviceId(),
      appVersion: appVersion ?? _getAppVersion(),
      syncState: SyncState.synced, // Mark as synced since it came from remote
    );

    return await _repository.create(record);
  }

  /// Update an existing log record
  Future<LogRecord> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? value,
    Unit? unit,
    String? note,
    List<String>? tags,
    String? sessionId,
  }) async {
    final changedFields = <String>[];

    if (eventType != null && eventType != record.eventType) {
      record.eventType = eventType;
      changedFields.add('eventType');
    }

    if (eventAt != null && eventAt != record.eventAt) {
      record.eventAt = eventAt;
      changedFields.add('eventAt');
    }

    if (value != null && value != record.value) {
      record.value = value;
      changedFields.add('value');
    }

    if (unit != null && unit != record.unit) {
      record.unit = unit;
      changedFields.add('unit');
    }

    if (note != null && note != record.note) {
      record.note = note;
      changedFields.add('note');
    }

    if (tags != null) {
      final newTagsString = tags.join(',');
      if (newTagsString != record.tagsString) {
        record.tagsString = newTagsString;
        changedFields.add('tags');
      }
    }

    if (sessionId != null && sessionId != record.sessionId) {
      record.sessionId = sessionId;
      changedFields.add('sessionId');
    }

    // Mark as dirty with changed fields
    record.markDirty(changedFields);

    return await _repository.update(record);
  }

  /// Soft delete a log record
  Future<void> deleteLogRecord(LogRecord record) async {
    record.softDelete();
    await _repository.update(record);
  }

  /// Hard delete a log record (use with caution)
  Future<void> hardDeleteLogRecord(LogRecord record) async {
    await _repository.delete(record.logId);
  }

  /// Get a log record by its logId
  Future<LogRecord?> getLogRecordByLogId(String logId) async {
    return await _repository.getByLogId(logId);
  }

  /// Get a log record by its internal id (kept for backward compatibility)
  Future<LogRecord?> getLogRecordById(Id id) async {
    // This method is kept for backward compatibility but may require refactoring
    // Web doesn't use internal Isar IDs, so this will return null on web
    final allRecords = await _repository.getByAccount(''); // TODO: Fix this
    return allRecords.where((r) => r.id == id).firstOrNull;
  }

  /// Get all log records for an account
  Future<List<LogRecord>> getLogRecords({
    required String accountId,
    String? profileId,
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
      if (profileId != null && record.profileId != profileId) return false;
      if (eventTypes != null && !eventTypes.contains(record.eventType))
        return false;
      if (startDate != null && record.eventAt.isBefore(startDate)) return false;
      if (endDate != null && record.eventAt.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Get log records that need syncing
  Future<List<LogRecord>> getPendingSync({int limit = 100}) async {
    final records = await _repository.getPendingSync();
    return records.take(limit).toList();
  }

  /// Get log records by session ID
  Future<List<LogRecord>> getLogRecordsBySession(String sessionId) async {
    return await _repository.getBySession(sessionId);
  }

  /// Count log records for an account
  Future<int> countLogRecords({
    required String accountId,
    String? profileId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );
    return records.length;
  }

  /// Watch log records for real-time updates
  Stream<List<LogRecord>> watchLogRecords({
    required String accountId,
    String? profileId,
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
        if (profileId != null && record.profileId != profileId) return false;
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
        profileId: data['profileId'] as String?,
        eventType: data['eventType'] as EventType,
        eventAt: data['eventAt'] as DateTime? ?? now,
        createdAt: now,
        updatedAt: now,
        value: data['value'] as double?,
        unit: data['unit'] as Unit? ?? Unit.none,
        note: data['note'] as String?,
        tagsString: (data['tags'] as List<String>?)?.join(','),
        sessionId: data['sessionId'] as String?,
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

  /// Clear all log records (use with extreme caution)
  Future<void> clearAllLogRecords() async {
    // Not implemented for web safety - would need to delete all records individually
    throw UnimplementedError(
      'clearAllLogRecords not supported via repository pattern',
    );
  }

  /// Get statistics for an account
  Future<Map<String, dynamic>> getStatistics({
    required String accountId,
    String? profileId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = await getLogRecords(
      accountId: accountId,
      profileId: profileId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: false,
    );

    final totalCount = records.length;
    final totalValue = records.fold<double>(
      0,
      (sum, record) => sum + (record.value ?? 0),
    );

    final eventTypeCounts = <EventType, int>{};
    for (final record in records) {
      eventTypeCounts[record.eventType] =
          (eventTypeCounts[record.eventType] ?? 0) + 1;
    }

    return {
      'totalCount': totalCount,
      'totalValue': totalValue,
      'averageValue': totalCount > 0 ? totalValue / totalCount : 0,
      'eventTypeCounts': eventTypeCounts,
      'firstEvent': records.isNotEmpty ? records.first.eventAt : null,
      'lastEvent': records.isNotEmpty ? records.last.eventAt : null,
    };
  }

  // ===== NEW LOGGING OPERATIONS =====

  /// Quick log: One-tap logging with minimal input
  /// Uses profile defaults if available
  Future<LogRecord> quickLog({
    required String accountId,
    String? profileId,
    EventType? eventType,
    double? value,
    Unit? unit,
    List<String>? tags,
    String? note,
    String? location,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate and clamp value
    final clampedValue =
        value != null && unit != null
            ? ValidationService.clampValue(value, unit)
            : value;

    // Clean tags
    final cleanedTags = tags != null ? ValidationService.cleanTags(tags) : null;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      profileId: profileId,
      eventType: eventType ?? EventType.inhale,
      eventAt: now,
      createdAt: now,
      updatedAt: now,
      value: clampedValue,
      unit: unit ?? Unit.none,
      note: note,
      tagsString: cleanedTags?.join(','),
      location: location,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: TimeConfidence.high,
    );

    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });

    return record;
  }

  /// Backdate log: Create a log entry for a past time
  Future<LogRecord> backdateLog({
    required String accountId,
    required DateTime eventAt,
    String? profileId,
    required EventType eventType,
    double? value,
    Unit unit = Unit.none,
    List<String>? tags,
    String? note,
    String? location,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Validate backdate time
    if (!ValidationService.isValidBackdateTime(eventAt)) {
      throw ArgumentError('Backdate time is too far in the past (max 30 days)');
    }

    // Detect clock skew and set time confidence
    final timeConfidence = ValidationService.detectClockSkew(eventAt);

    // Validate and clamp value
    final clampedValue =
        value != null ? ValidationService.clampValue(value, unit) : value;

    // Clean tags
    final cleanedTags = tags != null ? ValidationService.cleanTags(tags) : null;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      profileId: profileId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: now,
      updatedAt: now,
      value: clampedValue,
      unit: unit,
      note: note,
      tagsString: cleanedTags?.join(','),
      location: location,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence: timeConfidence,
    );

    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });

    return record;
  }

  /// Duration log: Create a log entry with measured duration from hold-to-record
  /// The duration is captured from press-and-hold interaction
  Future<LogRecord> recordDurationLog({
    required String accountId,
    required int durationMs,
    String? profileId,
    EventType? eventType,
    List<String>? tags,
    String? note,
    String? location,
  }) async {
    final now = DateTime.now();
    final logId = _uuid.v4();

    // Convert milliseconds to seconds with decimal precision
    final durationSeconds = durationMs / 1000.0;

    // Validate minimum threshold (e.g., 1 second minimum)
    if (durationSeconds < 1.0) {
      throw ArgumentError('Duration too short (minimum 1 second)');
    }

    // Clamp duration to reasonable maximum (e.g., 1 hour)
    final clampedDuration = ValidationService.clampValue(
      durationSeconds,
      Unit.seconds,
    );

    // Clean tags
    final cleanedTags = tags != null ? ValidationService.cleanTags(tags) : null;

    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      profileId: profileId,
      eventType: eventType ?? EventType.inhale,
      eventAt: now, // Release timestamp
      createdAt: now,
      updatedAt: now,
      value: clampedDuration,
      unit: Unit.seconds,
      note: note,
      tagsString: cleanedTags?.join(','),
      location: location,
      source: Source.manual,
      deviceId: _getDeviceId(),
      appVersion: _getAppVersion(),
      syncState: SyncState.pending,
      timeConfidence:
          TimeConfidence.high, // High confidence for measured duration
    );

    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });

    return record;
  }

  /// Batch add: Create multiple log records at once
  Future<List<LogRecord>> batchAdd({
    required String accountId,
    String? profileId,
    required List<Map<String, dynamic>> entries,
  }) async {
    final records = <LogRecord>[];
    final now = DateTime.now();

    for (final entry in entries) {
      final logId = _uuid.v4();
      final eventAt = entry['eventAt'] as DateTime? ?? now;
      final eventType = entry['eventType'] as EventType? ?? EventType.inhale;
      final value = entry['value'] as double?;
      final unit = entry['unit'] as Unit? ?? Unit.none;

      // Validate and clamp value
      final clampedValue =
          value != null ? ValidationService.clampValue(value, unit) : value;

      // Clean tags
      final tags = entry['tags'] as List<String>?;
      final cleanedTags =
          tags != null ? ValidationService.cleanTags(tags) : null;

      // Detect time confidence
      final timeConfidence = ValidationService.detectClockSkew(eventAt);

      final record = LogRecord.create(
        logId: logId,
        accountId: accountId,
        profileId: profileId,
        eventType: eventType,
        eventAt: eventAt,
        createdAt: now,
        updatedAt: now,
        value: clampedValue,
        unit: unit,
        note: entry['note'] as String?,
        tagsString: cleanedTags?.join(','),
        location: entry['location'] as String?,
        mood: entry['mood'] as double?,
        craving: entry['craving'] as double?,
        source: Source.manual,
        deviceId: _getDeviceId(),
        appVersion: _getAppVersion(),
        syncState: SyncState.pending,
        timeConfidence: timeConfidence,
      );

      records.add(record);
    }

    await _isar.writeTxn(() async {
      await _isar.logRecords.putAll(records);
    });

    return records;
  }

  /// Restore a soft-deleted record
  Future<void> restoreDeleted(LogRecord record) async {
    record.isDeleted = false;
    record.deletedAt = null;
    record.markDirty(['isDeleted', 'deletedAt']);

    await _isar.writeTxn(() async {
      await _isar.logRecords.put(record);
    });
  }

  /// Find potential duplicates for a given record
  Future<List<LogRecord>> findPotentialDuplicates(
    LogRecord record, {
    Duration timeTolerance = const Duration(minutes: 1),
  }) async {
    // Find records within time tolerance
    final startTime = record.eventAt.subtract(timeTolerance);
    final endTime = record.eventAt.add(timeTolerance);

    final candidates =
        await _isar.logRecords
            .filter()
            .accountIdEqualTo(record.accountId)
            .and()
            .eventAtBetween(startTime, endTime)
            .and()
            .eventTypeEqualTo(record.eventType)
            .and()
            .isDeletedEqualTo(false)
            .findAll();

    // Filter using duplicate detection logic (exclude self and check for duplicates)
    return candidates
        .where(
          (candidate) =>
              candidate.logId != record.logId &&
              ValidationService.isPotentialDuplicate(
                eventAt1: record.eventAt,
                eventAt2: candidate.eventAt,
                value1: record.value,
                value2: candidate.value,
                eventType1: record.eventType.name,
                eventType2: candidate.eventType.name,
                timeTolerance: timeTolerance,
              ),
        )
        .toList();
  }

  /// Create a log from a template
  Future<LogRecord> createFromTemplate({
    required String accountId,
    String? profileId,
    required EventType eventType,
    double? defaultValue,
    Unit? defaultUnit,
    List<String>? defaultTags,
    String? noteTemplate,
    String? defaultLocation,
  }) async {
    return await quickLog(
      accountId: accountId,
      profileId: profileId,
      eventType: eventType,
      value: defaultValue,
      unit: defaultUnit,
      tags: defaultTags,
      note: noteTemplate,
      location: defaultLocation,
    );
  }

  /// Update record with context fields
  Future<LogRecord> updateContext(
    LogRecord record, {
    String? location,
    double? mood,
    double? craving,
  }) async {
    final changedFields = <String>[];

    if (location != null && location != record.location) {
      record.location = location;
      changedFields.add('location');
    }

    if (mood != null) {
      final validatedMood = ValidationService.validateMood(mood);
      if (validatedMood != record.mood) {
        record.mood = validatedMood;
        changedFields.add('mood');
      }
    }

    if (craving != null) {
      final validatedCraving = ValidationService.validateCraving(craving);
      if (validatedCraving != record.craving) {
        record.craving = validatedCraving;
        changedFields.add('craving');
      }
    }

    if (changedFields.isNotEmpty) {
      record.markDirty(changedFields);

      await _isar.writeTxn(() async {
        await _isar.logRecords.put(record);
      });
    }

    return record;
  }
}
