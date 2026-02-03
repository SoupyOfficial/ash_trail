import 'package:cloud_firestore/cloud_firestore.dart';
import '../logging/app_logger.dart';
import '../models/log_record.dart';
import '../models/enums.dart' as enums;

/// LegacyDataAdapter handles querying and converting legacy Firestore tables
/// Supports backward compatibility for:
/// - JacobLogs (legacy personal logs)
/// - AshleyLogs (legacy personal logs)
/// - Any other legacy log tables that need to be migrated to current schema
class LegacyDataAdapter {
  static final _log = AppLogger.logger('LegacyDataAdapter');
  final FirebaseFirestore _firestore;

  LegacyDataAdapter({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// List of legacy collection names to query
  /// Add more as needed for additional legacy tables
  static const List<String> legacyCollections = ['JacobLogs', 'AshleyLogs'];

  /// Query a legacy collection and convert to current LogRecord format
  /// Returns records from the specified legacy collection
  Future<List<LogRecord>> queryLegacyCollection({
    required String collectionName,
    DateTime? since,
    int limit = 100,
  }) async {
    try {
      var query = _firestore
          .collection(collectionName)
          .orderBy('eventAt', descending: true);

      // Filter by date if provided
      if (since != null) {
        query = query.where('eventAt', isGreaterThan: since.toIso8601String());
      }

      final querySnapshot = await query.limit(limit).get();
      final records = <LogRecord>[];

      for (final doc in querySnapshot.docs) {
        try {
          final record = _convertLegacyToLogRecord(
            doc.data(),
            collectionName,
            doc.id,
          );
          records.add(record);
        } catch (e) {
          _log.e(
            'Error converting legacy record from $collectionName/${doc.id}',
            error: e,
          );
        }
      }

      return records;
    } catch (e) {
      _log.e('Error querying legacy collection $collectionName', error: e);
      return [];
    }
  }

  /// Query all legacy collections and merge results
  /// Deduplicates records by logId
  Future<List<LogRecord>> queryAllLegacyCollections({
    DateTime? since,
    int limit = 100,
  }) async {
    final allRecords = <String, LogRecord>{}; // Key: logId, Value: LogRecord

    for (final collectionName in legacyCollections) {
      final records = await queryLegacyCollection(
        collectionName: collectionName,
        since: since,
        limit: limit,
      );

      for (final record in records) {
        // Store by logId, newer records (by updatedAt) override older ones
        if (!allRecords.containsKey(record.logId) ||
            record.updatedAt.isAfter(allRecords[record.logId]!.updatedAt)) {
          allRecords[record.logId] = record;
        }
      }
    }

    // Convert to list and sort by eventAt descending
    final result = allRecords.values.toList();
    result.sort((a, b) => b.eventAt.compareTo(a.eventAt));
    return result;
  }

  /// Convert legacy Firestore document to current LogRecord format
  /// Handles various legacy field names and structures
  LogRecord _convertLegacyToLogRecord(
    Map<String, dynamic> data,
    String legacyCollection,
    String docId,
  ) {
    final record = LogRecord();

    // Identity
    record.logId = data['logId'] ?? data['id'] ?? docId;
    record.accountId =
        data['accountId'] ?? _extractAccountIdFromCollection(legacyCollection);

    // Time - handle various date formats
    record.eventAt = _parseDateTime(data['eventAt']) ?? DateTime.now();
    record.createdAt = _parseDateTime(data['createdAt']) ?? DateTime.now();
    record.updatedAt = _parseDateTime(data['updatedAt']) ?? DateTime.now();

    // Event Type - default to VAPE if not specified
    record.eventType = _parseEventType(data['eventType'] ?? 'vape');

    // Duration and Unit
    record.duration = (data['duration'] ?? 0).toDouble();
    record.unit = _parseUnit(data['unit'] ?? 'minutes');

    // Optional fields
    record.note = data['note'];
    record.moodRating = _parseDouble(data['moodRating']);
    record.physicalRating = _parseDouble(data['physicalRating']);
    record.latitude = _parseDouble(data['latitude']);
    record.longitude = _parseDouble(data['longitude']);

    // Metadata
    record.source = enums.Source.imported;
    record.deviceId = data['deviceId'];
    record.appVersion = data['appVersion'];
    record.timeConfidence = enums.TimeConfidence.high;

    // Parse reasons if present
    if (data['reasons'] != null && data['reasons'] is List) {
      record.reasons =
          (data['reasons'] as List)
              .map((r) => _parseLogReason(r))
              .whereType<enums.LogReason>()
              .toList();
    }

    return record;
  }

  /// Extract account ID from legacy collection name
  /// Examples: JacobLogs -> "jacob", AshleyLogs -> "ashley"
  String _extractAccountIdFromCollection(String collectionName) {
    // Remove "Logs" suffix and convert to lowercase
    if (collectionName.endsWith('Logs')) {
      return collectionName
          .substring(0, collectionName.length - 4)
          .toLowerCase();
    }
    return collectionName.toLowerCase();
  }

  /// Parse DateTime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        _log.w('Could not parse datetime string: $value');
        return null;
      }
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return null;
  }

  /// Parse EventType from string
  enums.EventType _parseEventType(dynamic value) {
    if (value == null) return enums.EventType.vape;

    final stringValue = value.toString().toLowerCase();

    for (final eventType in enums.EventType.values) {
      if (eventType.toString().toLowerCase().contains(stringValue)) {
        return eventType;
      }
    }

    // Default to vape if not found
    return enums.EventType.vape;
  }

  /// Parse Unit from string
  enums.Unit _parseUnit(dynamic value) {
    if (value == null) return enums.Unit.minutes;

    final stringValue = value.toString().toLowerCase();

    for (final unit in enums.Unit.values) {
      if (unit.toString().toLowerCase().contains(stringValue)) {
        return unit;
      }
    }

    // Default to minutes if not found
    return enums.Unit.minutes;
  }

  /// Parse LogReason from string or enum
  enums.LogReason? _parseLogReason(dynamic value) {
    if (value == null) return null;

    if (value is enums.LogReason) {
      return value;
    }

    final stringValue = value.toString().toLowerCase();

    for (final reason in enums.LogReason.values) {
      if (reason.toString().toLowerCase().contains(stringValue)) {
        return reason;
      }
    }

    return null;
  }

  /// Parse double values, handling various input types
  double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Check if legacy data exists for an account
  Future<bool> hasLegacyData(String accountId) async {
    for (final collectionName in legacyCollections) {
      try {
        final snapshot =
            await _firestore
                .collection(collectionName)
                .where('accountId', isEqualTo: accountId)
                .limit(1)
                .get();

        if (snapshot.docs.isNotEmpty) {
          return true;
        }
      } catch (e) {
        // Continue checking other collections
      }
    }

    return false;
  }

  /// Get count of legacy records for an account
  Future<int> getLegacyRecordCount(String accountId) async {
    int totalCount = 0;

    for (final collectionName in legacyCollections) {
      try {
        final snapshot =
            await _firestore
                .collection(collectionName)
                .where('accountId', isEqualTo: accountId)
                .count()
                .get();

        totalCount += snapshot.count ?? 0;
      } catch (e) {
        // Continue counting other collections
      }
    }

    return totalCount;
  }

  /// Stream legacy records for real-time updates
  Stream<LogRecord> watchLegacyCollections({
    required String accountId,
    int limit = 50,
  }) async* {
    for (final collectionName in legacyCollections) {
      yield* _firestore
          .collection(collectionName)
          .where('accountId', isEqualTo: accountId)
          .orderBy('eventAt', descending: true)
          .limit(limit)
          .snapshots()
          .asyncExpand((snapshot) async* {
            for (final change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added ||
                  change.type == DocumentChangeType.modified) {
                try {
                  final record = _convertLegacyToLogRecord(
                    change.doc.data()!,
                    collectionName,
                    change.doc.id,
                  );
                  yield record;
                } catch (e) {
                  _log.e('Error processing legacy record', error: e);
                }
              }
            }
          });
    }
  }
}
