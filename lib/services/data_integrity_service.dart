import '../logging/app_logger.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../repositories/log_record_repository.dart';
import 'account_service.dart';
import 'database_service.dart';

/// Results from a data integrity check
class IntegrityCheckResult {
  /// Records with accountIds that don't match any existing account
  final List<LogRecord> orphanedRecords;

  /// Records with duplicate logIds
  final Map<String, List<LogRecord>> duplicateRecords;

  /// Records with invalid timestamps (future or too old)
  final List<LogRecord> invalidTimestampRecords;

  /// Records with invalid ratings (outside 1-10 range)
  final List<LogRecord> invalidRatingRecords;

  /// Records with invalid location (one coordinate but not both)
  final List<LogRecord> invalidLocationRecords;

  /// Total number of issues found
  int get totalIssues =>
      orphanedRecords.length +
      duplicateRecords.values.fold<int>(
        0,
        (sum, list) => sum + list.length - 1,
      ) +
      invalidTimestampRecords.length +
      invalidRatingRecords.length +
      invalidLocationRecords.length;

  /// Whether the data passed integrity checks
  bool get isHealthy => totalIssues == 0;

  const IntegrityCheckResult({
    this.orphanedRecords = const [],
    this.duplicateRecords = const {},
    this.invalidTimestampRecords = const [],
    this.invalidRatingRecords = const [],
    this.invalidLocationRecords = const [],
  });

  @override
  String toString() {
    if (isHealthy) {
      return 'DataIntegrity: ✅ All checks passed';
    }
    return 'DataIntegrity: ❌ Found $totalIssues issues\n'
        '  - Orphaned records: ${orphanedRecords.length}\n'
        '  - Duplicate logIds: ${duplicateRecords.length} groups\n'
        '  - Invalid timestamps: ${invalidTimestampRecords.length}\n'
        '  - Invalid ratings: ${invalidRatingRecords.length}\n'
        '  - Invalid locations: ${invalidLocationRecords.length}';
  }
}

/// Results from a repair operation
class RepairResult {
  /// Number of orphaned records reassigned
  final int orphansReassigned;

  /// Number of duplicate records removed
  final int duplicatesRemoved;

  /// Number of records with fixed ratings
  final int ratingsFixed;

  /// Number of records with cleared invalid locations
  final int locationsCleared;

  /// Errors encountered during repair
  final List<String> errors;

  /// Whether the repair completed successfully
  bool get success => errors.isEmpty;

  const RepairResult({
    this.orphansReassigned = 0,
    this.duplicatesRemoved = 0,
    this.ratingsFixed = 0,
    this.locationsCleared = 0,
    this.errors = const [],
  });

  @override
  String toString() {
    final buffer = StringBuffer('RepairResult:\n');
    buffer.writeln('  - Orphans reassigned: $orphansReassigned');
    buffer.writeln('  - Duplicates removed: $duplicatesRemoved');
    buffer.writeln('  - Ratings fixed: $ratingsFixed');
    buffer.writeln('  - Locations cleared: $locationsCleared');
    if (errors.isNotEmpty) {
      buffer.writeln('  - Errors: ${errors.join(", ")}');
    }
    return buffer.toString();
  }
}

/// Interface for account validation used by DataIntegrityService
/// This allows mocking in tests
abstract class AccountIntegrityValidator {
  Future<bool> accountExists(String userId);
  Future<Set<String>> getAllAccountIds();
}

/// Adapter to make AccountService compatible with AccountIntegrityValidator
class AccountServiceValidator implements AccountIntegrityValidator {
  final AccountService _service;

  AccountServiceValidator(this._service);

  @override
  Future<bool> accountExists(String userId) => _service.accountExists(userId);

  @override
  Future<Set<String>> getAllAccountIds() => _service.getAllAccountIds();
}

/// Service for checking and repairing data integrity issues
///
/// This service helps detect and fix:
/// - Orphaned records (logs with non-existent accountIds)
/// - Duplicate logIds
/// - Invalid timestamps
/// - Invalid ratings
/// - Invalid location data
class DataIntegrityService {
  static final _log = AppLogger.logger('DataIntegrityService');
  final AccountIntegrityValidator _accountValidator;
  final LogRecordRepository _repository;

  /// Create a DataIntegrityService with the given dependencies.
  /// 
  /// Requires [accountValidator] to check account existence.
  /// If [repository] is not provided, creates a default one from DatabaseService.
  DataIntegrityService({
    required AccountIntegrityValidator accountValidator,
    LogRecordRepository? repository,
  }) : _accountValidator = accountValidator,
       _repository = repository ?? _createDefaultRepository();

  static LogRecordRepository _createDefaultRepository() {
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;
    return createLogRecordRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : {},
    );
  }

  /// Run a full integrity check on all log records
  ///
  /// Returns [IntegrityCheckResult] with any issues found.
  /// This is a read-only operation and doesn't modify any data.
  Future<IntegrityCheckResult> runIntegrityCheck() async {
    _log.i('Starting integrity check');
    final validAccountIds = await _accountValidator.getAllAccountIds();
    _log.d('Found ${validAccountIds.length} valid accounts');

    // Get ALL log records from the repository to check for orphans
    final allRecords = await _repository.getAll();

    // Track issues
    final orphanedRecords = <LogRecord>[];
    final duplicateMap = <String, List<LogRecord>>{};
    final invalidTimestamps = <LogRecord>[];
    final invalidRatings = <LogRecord>[];
    final invalidLocations = <LogRecord>[];

    // Track seen logIds for duplicate detection
    final seenLogIds = <String, LogRecord>{};

    for (final record in allRecords) {
      // Check for orphaned records
      if (!validAccountIds.contains(record.accountId)) {
        orphanedRecords.add(record);
        _log.w('Orphaned record: ${record.logId} (accountId: ${record.accountId})');
      }

      // Check for duplicates
      if (seenLogIds.containsKey(record.logId)) {
        duplicateMap.putIfAbsent(
          record.logId,
          () => [seenLogIds[record.logId]!],
        );
        duplicateMap[record.logId]!.add(record);
        _log.w('Duplicate logId: ${record.logId}');
      } else {
        seenLogIds[record.logId] = record;
      }

      // Check for invalid timestamps
      final now = DateTime.now();
      final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
      final oneDayFromNow = now.add(const Duration(days: 1));

      if (record.eventAt.isBefore(tenYearsAgo) ||
          record.eventAt.isAfter(oneDayFromNow)) {
        invalidTimestamps.add(record);
        _log.w('Invalid timestamp: ${record.logId} (eventAt: ${record.eventAt})');
      }

      // Check for invalid ratings
      if ((record.moodRating != null &&
              (record.moodRating! < 1 || record.moodRating! > 10)) ||
          (record.physicalRating != null &&
              (record.physicalRating! < 1 || record.physicalRating! > 10))) {
        invalidRatings.add(record);
        _log.w('Invalid rating: ${record.logId} (mood: ${record.moodRating}, physical: ${record.physicalRating})');
      }

      // Check for invalid location (one coordinate but not both)
      if ((record.latitude != null && record.longitude == null) ||
          (record.latitude == null && record.longitude != null)) {
        invalidLocations.add(record);
        _log.w('Invalid location: ${record.logId} (lat: ${record.latitude}, lon: ${record.longitude})');
      }
    }

    final result = IntegrityCheckResult(
      orphanedRecords: orphanedRecords,
      duplicateRecords: duplicateMap,
      invalidTimestampRecords: invalidTimestamps,
      invalidRatingRecords: invalidRatings,
      invalidLocationRecords: invalidLocations,
    );

    _log.i('Check complete: $result');
    return result;
  }

  /// Check integrity for a specific account
  Future<IntegrityCheckResult> checkAccountIntegrity(String accountId) async {
    _log.d('Checking integrity for account: $accountId');

    final validAccountIds = await _accountValidator.getAllAccountIds();
    final records = await _repository.getByAccount(accountId);

    final orphanedRecords = <LogRecord>[];
    final duplicateMap = <String, List<LogRecord>>{};
    final invalidTimestamps = <LogRecord>[];
    final invalidRatings = <LogRecord>[];
    final invalidLocations = <LogRecord>[];
    final seenLogIds = <String, LogRecord>{};

    for (final record in records) {
      // Check if accountId is valid
      if (!validAccountIds.contains(record.accountId)) {
        orphanedRecords.add(record);
      }

      // Check for duplicates
      if (seenLogIds.containsKey(record.logId)) {
        duplicateMap.putIfAbsent(
          record.logId,
          () => [seenLogIds[record.logId]!],
        );
        duplicateMap[record.logId]!.add(record);
      } else {
        seenLogIds[record.logId] = record;
      }

      // Timestamp validation
      final now = DateTime.now();
      final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
      final oneDayFromNow = now.add(const Duration(days: 1));

      if (record.eventAt.isBefore(tenYearsAgo) ||
          record.eventAt.isAfter(oneDayFromNow)) {
        invalidTimestamps.add(record);
      }

      // Rating validation
      if ((record.moodRating != null &&
              (record.moodRating! < 1 || record.moodRating! > 10)) ||
          (record.physicalRating != null &&
              (record.physicalRating! < 1 || record.physicalRating! > 10))) {
        invalidRatings.add(record);
      }

      // Location validation
      if ((record.latitude != null && record.longitude == null) ||
          (record.latitude == null && record.longitude != null)) {
        invalidLocations.add(record);
      }
    }

    return IntegrityCheckResult(
      orphanedRecords: orphanedRecords,
      duplicateRecords: duplicateMap,
      invalidTimestampRecords: invalidTimestamps,
      invalidRatingRecords: invalidRatings,
      invalidLocationRecords: invalidLocations,
    );
  }

  /// Attempt to repair issues found in integrity check
  ///
  /// [targetAccountId] - Account to reassign orphaned records to (required if orphans exist)
  /// [removeDuplicates] - Whether to remove duplicate records (keeps newest)
  /// [fixRatings] - Whether to clamp invalid ratings to valid range
  /// [clearInvalidLocations] - Whether to clear incomplete location data
  Future<RepairResult> repairIssues({
    required IntegrityCheckResult checkResult,
    String? targetAccountId,
    bool removeDuplicates = true,
    bool fixRatings = true,
    bool clearInvalidLocations = true,
  }) async {
    _log.i('Starting repair');

    final errors = <String>[];
    var orphansReassigned = 0;
    var duplicatesRemoved = 0;
    var ratingsFixed = 0;
    var locationsCleared = 0;

    // Repair orphaned records
    if (checkResult.orphanedRecords.isNotEmpty) {
      if (targetAccountId == null) {
        errors.add(
          'Cannot repair orphaned records: no target account specified',
        );
      } else {
        // Verify target account exists
        final exists = await _accountValidator.accountExists(targetAccountId);
        if (!exists) {
          errors.add('Target account "$targetAccountId" does not exist');
        } else {
          for (final record in checkResult.orphanedRecords) {
            try {
              // Create a new record with the correct accountId
              final fixedRecord = LogRecord.create(
                logId: record.logId,
                accountId: targetAccountId,
                eventType: record.eventType,
                eventAt: record.eventAt,
                createdAt: record.createdAt,
                updatedAt: DateTime.now(),
                duration: record.duration,
                unit: record.unit,
                note: record.note,
                source: record.source,
                deviceId: record.deviceId,
                appVersion: record.appVersion,
                syncState: SyncState.pending,
                moodRating: record.moodRating,
                physicalRating: record.physicalRating,
                reasons: record.reasons,
                latitude: record.latitude,
                longitude: record.longitude,
              );
              await _repository.update(fixedRecord);
              orphansReassigned++;
              _log.i('Reassigned ${record.logId} to $targetAccountId');
            } catch (e) {
              errors.add('Failed to reassign ${record.logId}: $e');
            }
          }
        }
      }
    }

    // Remove duplicates (keep the most recently updated)
    if (removeDuplicates && checkResult.duplicateRecords.isNotEmpty) {
      for (final entry in checkResult.duplicateRecords.entries) {
        final duplicates = entry.value;
        // Sort by updatedAt descending, keep the first (newest)
        duplicates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        // Delete all but the first
        for (var i = 1; i < duplicates.length; i++) {
          try {
            await _repository.delete(duplicates[i].logId);
            duplicatesRemoved++;
            _log.i('Removed duplicate ${duplicates[i].logId}');
          } catch (e) {
            errors.add('Failed to remove duplicate ${duplicates[i].logId}: $e');
          }
        }
      }
    }

    // Fix invalid ratings
    if (fixRatings && checkResult.invalidRatingRecords.isNotEmpty) {
      for (final record in checkResult.invalidRatingRecords) {
        try {
          var needsUpdate = false;
          var newMood = record.moodRating;
          var newPhysical = record.physicalRating;

          if (newMood != null && (newMood < 1 || newMood > 10)) {
            newMood = newMood.clamp(1.0, 10.0);
            needsUpdate = true;
          }
          if (newPhysical != null && (newPhysical < 1 || newPhysical > 10)) {
            newPhysical = newPhysical.clamp(1.0, 10.0);
            needsUpdate = true;
          }

          if (needsUpdate) {
            record.moodRating = newMood;
            record.physicalRating = newPhysical;
            record.markDirty();
            await _repository.update(record);
            ratingsFixed++;
            _log.i('Fixed ratings for ${record.logId}');
          }
        } catch (e) {
          errors.add('Failed to fix ratings for ${record.logId}: $e');
        }
      }
    }

    // Clear invalid locations
    if (clearInvalidLocations &&
        checkResult.invalidLocationRecords.isNotEmpty) {
      for (final record in checkResult.invalidLocationRecords) {
        try {
          record.latitude = null;
          record.longitude = null;
          record.markDirty();
          await _repository.update(record);
          locationsCleared++;
          _log.i('Cleared invalid location for ${record.logId}');
        } catch (e) {
          errors.add('Failed to clear location for ${record.logId}: $e');
        }
      }
    }

    final result = RepairResult(
      orphansReassigned: orphansReassigned,
      duplicatesRemoved: duplicatesRemoved,
      ratingsFixed: ratingsFixed,
      locationsCleared: locationsCleared,
      errors: errors,
    );

    _log.i('Repair complete: $result');
    return result;
  }

  /// Quick health check - returns true if data is healthy
  Future<bool> isDataHealthy() async {
    final result = await runIntegrityCheck();
    return result.isHealthy;
  }

  /// Get a summary of data health for display
  Future<String> getHealthSummary() async {
    final result = await runIntegrityCheck();
    return result.toString();
  }
}
