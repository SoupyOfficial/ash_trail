import 'dart:convert';
import '../logging/app_logger.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import 'app_analytics_service.dart';
import 'app_performance_service.dart';
import 'error_reporting_service.dart';

/// Export service per design doc 23. Import - Export
/// Provides CSV and JSON export functionality for log records
class ExportService {
  static final _log = AppLogger.logger('ExportService');

  /// Export log records to CSV format per design doc 23.4.1
  /// Returns CSV string with headers and data rows
  Future<String> exportToCsv(List<LogRecord> records) async {
    return AppPerformanceService.instance.traceExport(() async {
      // Per design doc 23.4.1: Flat format for spreadsheets
      // Fields: id, accountId, eventType, eventAt, duration, note, etc.

      final buffer = StringBuffer();

      // CSV Header - includes logId as the stable identifier
      buffer.writeln(
        'logId,accountId,eventType,eventAt,duration,unit,note,moodRating,physicalRating,latitude,longitude,source,syncState,createdAt,updatedAt,transferredFromAccountId,transferredAt,transferredFromLogId',
      );

      // Data rows
      for (final record in records) {
        buffer.writeln(
          '${record.logId},'
          '${record.accountId},'
          '${record.eventType.name},'
          '${record.eventAt.toIso8601String()},'
          '${record.duration},'
          '${record.unit.name},'
          '"${_escapeCsv(record.note ?? '')}",'
          '${record.moodRating ?? ''},'
          '${record.physicalRating ?? ''},'
          '${record.latitude ?? ''},'
          '${record.longitude ?? ''},'
          '${record.source.name},'
          '${record.syncState.name},'
          '${record.createdAt.toIso8601String()},'
          '${record.updatedAt.toIso8601String()},'
          '${record.transferredFromAccountId ?? ''},'
          '${record.transferredAt?.toIso8601String() ?? ''},'
          '${record.transferredFromLogId ?? ''}',
        );
      }

      AppAnalyticsService.instance.logExport(
        format: 'csv',
        recordCount: records.length,
      );
      return buffer.toString();
    }, attributes: {'format': 'csv'});
  }

  /// Export log records to JSON format per design doc 23.4.2
  /// Returns JSON string with full-fidelity backup
  Future<String> exportToJson(List<LogRecord> records) async {
    return AppPerformanceService.instance.traceExport(() async {
      // Per design doc 23.4.2: Full-fidelity backup format

      final exportData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'recordCount': records.length,
        'records': records.map((r) => _recordToJson(r)).toList(),
      };

      // Use dart:convert for proper JSON encoding with escaping
      AppAnalyticsService.instance.logExport(
        format: 'json',
        recordCount: records.length,
      );
      return const JsonEncoder.withIndent('  ').convert(exportData);
    }, attributes: {'format': 'json'});
  }

  /// Import log records from CSV per design doc 23.6.1
  /// Validates data before mutation
  /// Returns parsed records without persisting - caller should handle persistence
  Future<ImportResult> importFromCsv(String csvContent) async {
    // Per design doc 23.6.1: Validate before mutation
    // Per design doc 23.6.2: Handle conflicts (skip/replace)

    final errors = <String>[];
    final records = <LogRecord>[];

    try {
      final lines =
          csvContent.split('\n').where((l) => l.trim().isNotEmpty).toList();

      if (lines.isEmpty) {
        return ImportResult(
          success: false,
          message: 'CSV file is empty',
          importedCount: 0,
          skippedCount: 0,
          errors: ['No data found in CSV'],
        );
      }

      // Parse header row
      final headers = _parseCsvLine(lines[0]);
      final headerMap = <String, int>{};
      for (var i = 0; i < headers.length; i++) {
        headerMap[headers[i].trim().toLowerCase()] = i;
      }

      // Validate required headers
      final requiredHeaders = ['logid', 'accountid', 'eventtype', 'eventat'];
      for (final required in requiredHeaders) {
        if (!headerMap.containsKey(required)) {
          return ImportResult(
            success: false,
            message: 'Missing required header: $required',
            importedCount: 0,
            skippedCount: 0,
            errors: ['CSV must contain header: $required'],
          );
        }
      }

      // Parse data rows
      for (var i = 1; i < lines.length; i++) {
        try {
          final values = _parseCsvLine(lines[i]);
          if (values.length < 4) {
            errors.add('Row ${i + 1}: Insufficient columns');
            continue;
          }

          final record = _parseRecordFromCsv(values, headerMap, i + 1);
          if (record != null) {
            records.add(record);
          }
        } catch (e, st) {
          _log.e('Error parsing CSV row ${i + 1}', error: e);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'ExportService.importFromCsv',
          );
          errors.add('Row ${i + 1}: $e');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message:
            errors.isEmpty
                ? 'Successfully parsed ${records.length} records'
                : 'Parsed ${records.length} records with ${errors.length} errors',
        importedCount: records.length,
        skippedCount: lines.length - 1 - records.length,
        errors: errors,
        records: records,
      );
    } catch (e, st) {
      _log.e('Failed to parse CSV', error: e);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'ExportService.importFromCsv',
      );
      return ImportResult(
        success: false,
        message: 'Failed to parse CSV: $e',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Import log records from JSON per design doc 23.6.1
  /// Validates data before mutation
  /// Returns parsed records without persisting - caller should handle persistence
  Future<ImportResult> importFromJson(String jsonContent) async {
    // Per design doc 23.6.1: Validate before mutation
    // Per design doc 23.6.2: Handle conflicts (skip/replace)

    final errors = <String>[];
    final records = <LogRecord>[];

    try {
      final data = json.decode(jsonContent) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as String?;
      if (version == null) {
        errors.add('Warning: No version field found in import file');
      }

      final recordsList = data['records'] as List<dynamic>?;
      if (recordsList == null || recordsList.isEmpty) {
        return ImportResult(
          success: false,
          message: 'No records found in JSON file',
          importedCount: 0,
          skippedCount: 0,
          errors: ['JSON must contain a "records" array'],
        );
      }

      for (var i = 0; i < recordsList.length; i++) {
        try {
          final recordData = recordsList[i] as Map<String, dynamic>;
          final record = _parseRecordFromJson(recordData, i);
          if (record != null) {
            records.add(record);
          }
        } catch (e, st) {
          _log.e('Error parsing JSON record $i', error: e);
          ErrorReportingService.instance.reportException(
            e,
            stackTrace: st,
            context: 'ExportService.importFromJson',
          );
          errors.add('Record $i: $e');
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        message:
            errors.isEmpty
                ? 'Successfully parsed ${records.length} records'
                : 'Parsed ${records.length} records with ${errors.length} errors',
        importedCount: records.length,
        skippedCount: recordsList.length - records.length,
        errors: errors,
        records: records,
      );
    } catch (e, st) {
      _log.e('Failed to parse JSON', error: e);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'ExportService.importFromJson',
      );
      return ImportResult(
        success: false,
        message: 'Failed to parse JSON: $e',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Parse a CSV line handling quoted fields
  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          current.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    values.add(current.toString());

    return values;
  }

  /// Parse a LogRecord from CSV values
  LogRecord? _parseRecordFromCsv(
    List<String> values,
    Map<String, int> headerMap,
    int rowNum,
  ) {
    String getValue(String header) {
      final index = headerMap[header.toLowerCase()];
      if (index == null || index >= values.length) return '';
      return values[index].trim();
    }

    final logId = getValue('logid');
    final accountId = getValue('accountid');
    final eventTypeStr = getValue('eventtype');
    final eventAtStr = getValue('eventat');

    if (logId.isEmpty ||
        accountId.isEmpty ||
        eventTypeStr.isEmpty ||
        eventAtStr.isEmpty) {
      throw FormatException('Missing required fields');
    }

    final eventType = EventType.values.firstWhere(
      (e) => e.name.toLowerCase() == eventTypeStr.toLowerCase(),
      orElse: () => EventType.custom,
    );

    final eventAt = DateTime.parse(eventAtStr);

    final durationStr = getValue('duration');
    final duration =
        durationStr.isEmpty ? 0.0 : double.tryParse(durationStr) ?? 0.0;

    final unitStr = getValue('unit');
    final unit =
        unitStr.isEmpty
            ? Unit.seconds
            : Unit.values.firstWhere(
              (u) => u.name.toLowerCase() == unitStr.toLowerCase(),
              orElse: () => Unit.seconds,
            );

    final note = getValue('note');

    final moodStr = getValue('moodrating');
    final moodRating = moodStr.isEmpty ? null : double.tryParse(moodStr);

    final physicalStr = getValue('physicalrating');
    final physicalRating =
        physicalStr.isEmpty ? null : double.tryParse(physicalStr);

    final latStr = getValue('latitude');
    final latitude = latStr.isEmpty ? null : double.tryParse(latStr);

    final lonStr = getValue('longitude');
    final longitude = lonStr.isEmpty ? null : double.tryParse(lonStr);

    final sourceStr = getValue('source');
    final source =
        sourceStr.isEmpty
            ? Source.imported
            : Source.values.firstWhere(
              (s) => s.name.toLowerCase() == sourceStr.toLowerCase(),
              orElse: () => Source.imported,
            );

    final createdAtStr = getValue('createdat');
    final createdAt =
        createdAtStr.isEmpty ? DateTime.now() : DateTime.parse(createdAtStr);

    final updatedAtStr = getValue('updatedat');
    final updatedAt =
        updatedAtStr.isEmpty ? DateTime.now() : DateTime.parse(updatedAtStr);

    return LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      duration: duration,
      unit: unit,
      note: note.isEmpty ? null : note.replaceAll('\\n', '\n'),
      moodRating: moodRating,
      physicalRating: physicalRating,
      latitude: latitude,
      longitude: longitude,
      source: source,
      syncState: SyncState.pending, // Mark as pending sync
      transferredFromAccountId:
          getValue('transferredfromaccountid').isEmpty
              ? null
              : getValue('transferredfromaccountid'),
      transferredAt:
          getValue('transferredat').isEmpty
              ? null
              : DateTime.tryParse(getValue('transferredat')),
      transferredFromLogId:
          getValue('transferredfromlogid').isEmpty
              ? null
              : getValue('transferredfromlogid'),
    );
  }

  /// Parse a LogRecord from JSON map
  LogRecord? _parseRecordFromJson(Map<String, dynamic> data, int index) {
    final logId = data['logId'] as String?;
    final accountId = data['accountId'] as String?;
    final eventTypeStr = data['eventType'] as String?;
    final eventAtStr = data['eventAt'] as String?;

    if (logId == null ||
        accountId == null ||
        eventTypeStr == null ||
        eventAtStr == null) {
      throw FormatException(
        'Missing required fields: logId, accountId, eventType, or eventAt',
      );
    }

    final eventType = EventType.values.firstWhere(
      (e) => e.name == eventTypeStr,
      orElse: () => EventType.custom,
    );

    final eventAt = DateTime.parse(eventAtStr);

    final createdAtStr = data['createdAt'] as String?;
    final createdAt =
        createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();

    final updatedAtStr = data['updatedAt'] as String?;
    final updatedAt =
        updatedAtStr != null ? DateTime.parse(updatedAtStr) : DateTime.now();

    final duration = (data['duration'] as num?)?.toDouble() ?? 0.0;

    final unitStr = data['unit'] as String?;
    final unit =
        unitStr != null
            ? Unit.values.firstWhere(
              (u) => u.name == unitStr,
              orElse: () => Unit.seconds,
            )
            : Unit.seconds;

    final note = data['note'] as String?;

    final reasonsList = data['reasons'] as List<dynamic>?;
    final reasons =
        reasonsList
            ?.map(
              (r) => LogReason.values.firstWhere(
                (reason) => reason.name == r,
                orElse: () => LogReason.other,
              ),
            )
            .toList();

    final moodRating = (data['moodRating'] as num?)?.toDouble();
    final physicalRating = (data['physicalRating'] as num?)?.toDouble();
    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();

    final sourceStr = data['source'] as String?;
    final source =
        sourceStr != null
            ? Source.values.firstWhere(
              (s) => s.name == sourceStr,
              orElse: () => Source.imported,
            )
            : Source.imported;

    final deviceId = data['deviceId'] as String?;
    final appVersion = data['appVersion'] as String?;

    final timeConfidenceStr = data['timeConfidence'] as String?;
    final timeConfidence =
        timeConfidenceStr != null
            ? TimeConfidence.values.firstWhere(
              (tc) => tc.name == timeConfidenceStr,
              orElse: () => TimeConfidence.high,
            )
            : TimeConfidence.high;

    final isDeleted = data['isDeleted'] as bool? ?? false;
    final deletedAtStr = data['deletedAt'] as String?;
    final deletedAt =
        deletedAtStr != null ? DateTime.parse(deletedAtStr) : null;

    final revision = data['revision'] as int? ?? 0;

    final transferredFromAccountId =
        data['transferredFromAccountId'] as String?;
    final transferredAtStr = data['transferredAt'] as String?;
    final transferredAt =
        transferredAtStr != null ? DateTime.parse(transferredAtStr) : null;
    final transferredFromLogId = data['transferredFromLogId'] as String?;

    return LogRecord.create(
      logId: logId,
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
      deviceId: deviceId,
      appVersion: appVersion,
      timeConfidence: timeConfidence,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      syncState: SyncState.pending, // Mark as pending sync
      revision: revision,
      transferredFromAccountId: transferredFromAccountId,
      transferredAt: transferredAt,
      transferredFromLogId: transferredFromLogId,
    );
  }

  /// Escape special characters for CSV
  String _escapeCsv(String value) {
    return value.replaceAll('"', '""').replaceAll('\n', '\\n');
  }

  /// Convert LogRecord to JSON map for full-fidelity backup
  Map<String, dynamic> _recordToJson(LogRecord record) {
    return {
      'logId': record.logId,
      'accountId': record.accountId,
      'eventType': record.eventType.name,
      'eventAt': record.eventAt.toIso8601String(),
      'createdAt': record.createdAt.toIso8601String(),
      'updatedAt': record.updatedAt.toIso8601String(),
      'duration': record.duration,
      'unit': record.unit.name,
      'note': record.note,
      'reasons': record.reasons?.map((r) => r.name).toList(),
      'moodRating': record.moodRating,
      'physicalRating': record.physicalRating,
      'latitude': record.latitude,
      'longitude': record.longitude,
      'source': record.source.name,
      'deviceId': record.deviceId,
      'appVersion': record.appVersion,
      'timeConfidence': record.timeConfidence.name,
      'isDeleted': record.isDeleted,
      'deletedAt': record.deletedAt?.toIso8601String(),
      'syncState': record.syncState.name,
      'revision': record.revision,
      'transferredFromAccountId': record.transferredFromAccountId,
      'transferredAt': record.transferredAt?.toIso8601String(),
      'transferredFromLogId': record.transferredFromLogId,
    };
  }
}

/// Result of an import operation
class ImportResult {
  final bool success;
  final String message;
  final int importedCount;
  final int skippedCount;
  final List<String> errors;
  final List<LogRecord> records;

  ImportResult({
    required this.success,
    required this.message,
    required this.importedCount,
    required this.skippedCount,
    required this.errors,
    this.records = const [],
  });
}

/// Conflict resolution strategy for imports per design doc 23.6.2
enum ConflictResolution {
  skip, // Skip conflicting records
  replace, // Replace existing with imported
  merge, // Merge fields (keep newer values)
}
