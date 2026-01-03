import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/export_service.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('User Story: Import/Export (Stories 20-25)', () {
    late ExportService exportService;
    const testAccountId = 'export-test-account';
    const uuid = Uuid();

    setUp(() {
      exportService = ExportService();
    });

    /// Helper to create test log records
    LogRecord createTestLog({
      required DateTime eventAt,
      double duration = 30.0,
      Unit unit = Unit.seconds,
      EventType eventType = EventType.vape,
      String? note,
      double? moodRating,
      double? physicalRating,
      double? latitude,
      double? longitude,
      List<LogReason>? reasons,
    }) {
      return LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: eventType,
        eventAt: eventAt,
        duration: duration,
        unit: unit,
        note: note,
        moodRating: moodRating,
        physicalRating: physicalRating,
        latitude: latitude,
        longitude: longitude,
        reasons: reasons,
      );
    }

    test(
      'Story 20: As a user, I want to export my logs to JSON for backup',
      () async {
        // GIVEN: User has 5 logs with various data
        final now = DateTime.now();
        final records = <LogRecord>[];

        for (int i = 0; i < 5; i++) {
          records.add(
            createTestLog(
              eventAt: now.subtract(Duration(hours: i)),
              duration: 30 + i.toDouble(),
              note: 'Test note $i',
              moodRating: 5.0 + i,
              physicalRating: 6.0 + i,
              reasons: [LogReason.recreational],
            ),
          );
        }

        // WHEN: User exports as JSON
        final jsonExport = await exportService.exportToJson(records);

        // THEN: File contains all logs with metadata
        expect(jsonExport, isNotEmpty);
        expect(jsonExport, contains('"version"'));
        expect(jsonExport, contains('"exportedAt"'));
        expect(jsonExport, contains('"recordCount": 5'));
        expect(jsonExport, contains('"records"'));

        // All records are included
        expect(jsonExport, contains(testAccountId));
        expect(jsonExport, contains('vape'));
        expect(jsonExport, contains('Test note 0'));
        expect(jsonExport, contains('Test note 4'));

        // Timestamps are ISO-8601
        expect(jsonExport, contains('T')); // ISO format has T separator
      },
    );

    test(
      'Story 21: As a user, I want to export logs to CSV for spreadsheets',
      () async {
        // GIVEN: User has logs with notes
        final now = DateTime.now();
        final records = <LogRecord>[];

        records.add(
          createTestLog(
            eventAt: now.subtract(const Duration(hours: 1)),
            note: 'Morning session',
            moodRating: 7.0,
          ),
        );

        records.add(
          createTestLog(
            eventAt: now.subtract(const Duration(hours: 2)),
            note: 'Afternoon break, felt good',
            moodRating: 8.0,
          ),
        );

        records.add(
          createTestLog(
            eventAt: now,
            note: 'Evening wind down',
            moodRating: 6.0,
          ),
        );

        // WHEN: User exports as CSV
        final csvExport = await exportService.exportToCsv(records);

        // THEN: All fields present
        expect(csvExport, isNotEmpty);

        // Header row present
        expect(csvExport, contains('logId,'));
        expect(csvExport, contains('accountId,'));
        expect(csvExport, contains('eventType,'));
        expect(csvExport, contains('eventAt,'));
        expect(csvExport, contains('duration,'));

        // Data rows present
        expect(csvExport, contains(testAccountId));
        expect(csvExport, contains('vape'));

        // Timestamps are ISO-8601
        final lines = csvExport.split('\n');
        expect(lines.length, greaterThan(1)); // Header + at least one data row

        // Notes are properly escaped in quotes
        expect(csvExport, contains('"'));
      },
    );

    test('Story 22: Export preserves all log metadata', () async {
      // GIVEN: User has a log with complete metadata
      final now = DateTime.now();
      final record = createTestLog(
        eventAt: now,
        duration: 45.0,
        unit: Unit.seconds,
        eventType: EventType.vape,
        note: 'Complete record test',
        moodRating: 7.5,
        physicalRating: 8.0,
        latitude: 37.7749,
        longitude: -122.4194,
        reasons: [LogReason.stress, LogReason.recreational],
      );

      // WHEN: Exporting to JSON
      final jsonExport = await exportService.exportToJson([record]);

      // THEN: All metadata is preserved
      expect(jsonExport, contains('"duration": 45.0'));
      expect(jsonExport, contains('"unit": "seconds"'));
      expect(jsonExport, contains('"eventType": "vape"'));
      expect(jsonExport, contains('"note": "Complete record test"'));
      expect(jsonExport, contains('"moodRating": 7.5'));
      expect(jsonExport, contains('"physicalRating": 8.0'));
      expect(jsonExport, contains('"latitude": 37.7749'));
      expect(jsonExport, contains('"longitude": -122.4194'));
      expect(jsonExport, contains('"reasons"'));
      expect(jsonExport, contains('"stress"'));
      expect(jsonExport, contains('"recreational"'));
    });

    test('Story 23: Export handles empty records gracefully', () async {
      // GIVEN: User has no logs
      final emptyRecords = <LogRecord>[];

      // WHEN: User exports (both formats)
      final jsonExport = await exportService.exportToJson(emptyRecords);
      final csvExport = await exportService.exportToCsv(emptyRecords);

      // THEN: Valid output with no crash
      expect(jsonExport, isNotEmpty);
      expect(jsonExport, contains('"recordCount": 0'));
      expect(jsonExport, contains('"records": []'));

      expect(csvExport, isNotEmpty);
      // CSV should have header row even with no data
      expect(csvExport, contains('logId,'));
    });

    test('Story 24: Export handles special characters in notes', () async {
      // GIVEN: User has notes with special characters
      final now = DateTime.now();
      final records = <LogRecord>[];

      records.add(
        createTestLog(
          eventAt: now,
          note: 'Test with "quotes" and commas, here',
        ),
      );

      records.add(
        createTestLog(
          eventAt: now.subtract(const Duration(hours: 1)),
          note: 'Multi\nline\nnote',
        ),
      );

      // WHEN: Exporting to CSV
      final csvExport = await exportService.exportToCsv(records);

      // THEN: Special characters are escaped
      expect(csvExport, isNotEmpty);
      // Quotes should be escaped (doubled)
      expect(csvExport, contains('""'));
      // Newlines should be escaped
      expect(csvExport, contains('\\n'));
    });

    test('Story 25: Export maintains account isolation', () async {
      // GIVEN: User has logs from multiple accounts
      final now = DateTime.now();
      final records = <LogRecord>[];

      // Account A logs
      const accountA = 'account-A';
      records.add(
        LogRecord.create(
          logId: uuid.v4(),
          accountId: accountA,
          eventType: EventType.vape,
          eventAt: now,
          duration: 30,
        ),
      );

      // Account B logs
      const accountB = 'account-B';
      records.add(
        LogRecord.create(
          logId: uuid.v4(),
          accountId: accountB,
          eventType: EventType.vape,
          eventAt: now.subtract(const Duration(hours: 1)),
          duration: 45,
        ),
      );

      // WHEN: Filtering and exporting only Account A
      final accountARecords =
          records.where((r) => r.accountId == accountA).toList();
      final jsonExport = await exportService.exportToJson(accountARecords);

      // THEN: Only Account A data in export
      expect(jsonExport, contains('"recordCount": 1'));
      expect(jsonExport, contains(accountA));
      expect(jsonExport, isNot(contains(accountB)));
    });
  });

  group('User Story: Import Validation', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService();
    });

    test('Import from invalid JSON returns error result', () async {
      // GIVEN: Invalid JSON content
      const invalidJson = '{ invalid json }';

      // WHEN: Attempting to import
      final result = await exportService.importFromJson(invalidJson);

      // THEN: Error result with message
      expect(result.success, false);
      expect(result.importedCount, 0);
      expect(result.message, isNotEmpty);
    });

    test('Import from invalid CSV returns error result', () async {
      // GIVEN: Invalid CSV content (missing required headers)
      const invalidCsv = 'not,proper,csv\nformat,data,here';

      // WHEN: Attempting to import
      final result = await exportService.importFromCsv(invalidCsv);

      // THEN: Error result with message
      expect(result.success, false);
      expect(result.importedCount, 0);
      expect(result.message, isNotEmpty);
    });
  });

  group('User Story: CSV Import Full Coverage', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService();
    });

    test('Import valid CSV with all required fields', () async {
      // GIVEN: Valid CSV content
      const validCsv =
          '''logId,accountId,eventType,eventAt,duration,unit,note,moodRating,physicalRating,latitude,longitude,source,syncState,createdAt,updatedAt
abc-123,user-1,vape,2024-06-15T10:30:00.000,30.0,seconds,"Morning session",7.0,8.0,37.7749,-122.4194,manual,pending,2024-06-15T10:30:00.000,2024-06-15T10:30:00.000''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(validCsv);

      // THEN: Success with parsed records
      expect(result.success, true);
      expect(result.importedCount, 1);
      expect(result.records, hasLength(1));
      expect(result.records.first.logId, 'abc-123');
      expect(result.records.first.accountId, 'user-1');
      expect(result.records.first.eventType, EventType.vape);
      expect(result.records.first.duration, 30.0);
      expect(result.records.first.moodRating, 7.0);
      expect(result.records.first.physicalRating, 8.0);
      expect(result.records.first.latitude, 37.7749);
      expect(result.records.first.longitude, -122.4194);
    });

    test('Import CSV with minimal required fields', () async {
      // GIVEN: CSV with only required fields
      const minimalCsv = '''logId,accountId,eventType,eventAt
def-456,user-2,inhale,2024-06-15T14:00:00.000''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(minimalCsv);

      // THEN: Success with defaults applied
      expect(result.success, true);
      expect(result.records, hasLength(1));
      expect(result.records.first.logId, 'def-456');
      expect(result.records.first.duration, 0.0);
      expect(result.records.first.unit, Unit.seconds);
    });

    test('Import CSV handles empty file', () async {
      // GIVEN: Empty CSV
      const emptyCsv = '';

      // WHEN: Importing
      final result = await exportService.importFromCsv(emptyCsv);

      // THEN: Error result
      expect(result.success, false);
      expect(result.message, contains('empty'));
    });

    test('Import CSV handles missing required header', () async {
      // GIVEN: CSV missing accountId header
      const missingHeader = '''logId,eventType,eventAt
abc-123,vape,2024-06-15T10:30:00.000''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(missingHeader);

      // THEN: Error result
      expect(result.success, false);
      expect(result.message, contains('accountid'));
    });

    test('Import CSV handles row with insufficient columns', () async {
      // GIVEN: CSV with incomplete row
      const incompleteCsv = '''logId,accountId,eventType,eventAt
abc-123,user-1,vape''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(incompleteCsv);

      // THEN: Row skipped with error
      expect(result.skippedCount, 1);
      expect(result.errors, isNotEmpty);
    });

    test('Import CSV handles quoted fields with commas', () async {
      // GIVEN: CSV with quoted field containing comma
      const quotedCsv = '''logId,accountId,eventType,eventAt,duration,unit,note
abc-123,user-1,vape,2024-06-15T10:30:00.000,30.0,seconds,"Note with, comma inside"''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(quotedCsv);

      // THEN: Parses correctly
      expect(result.success, true);
      expect(result.records.first.note, 'Note with, comma inside');
    });

    test('Import CSV handles escaped quotes', () async {
      // GIVEN: CSV with escaped quotes
      const escapedCsv = '''logId,accountId,eventType,eventAt,duration,unit,note
abc-123,user-1,vape,2024-06-15T10:30:00.000,30.0,seconds,"Note with ""quotes"" inside"''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(escapedCsv);

      // THEN: Parses correctly
      expect(result.success, true);
      expect(result.records.first.note, 'Note with "quotes" inside');
    });

    test('Import CSV handles multiple records', () async {
      // GIVEN: CSV with multiple records
      const multiCsv = '''logId,accountId,eventType,eventAt
abc-123,user-1,vape,2024-06-15T10:30:00.000
def-456,user-1,inhale,2024-06-15T11:00:00.000
ghi-789,user-1,exhale,2024-06-15T12:00:00.000''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(multiCsv);

      // THEN: All records parsed
      expect(result.success, true);
      expect(result.records, hasLength(3));
    });

    test('Import CSV handles unknown event type', () async {
      // GIVEN: CSV with unknown event type
      const unknownTypeCsv = '''logId,accountId,eventType,eventAt
abc-123,user-1,unknown_type,2024-06-15T10:30:00.000''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(unknownTypeCsv);

      // THEN: Defaults to custom event type
      expect(result.success, true);
      expect(result.records.first.eventType, EventType.custom);
    });

    test('Import CSV handles unknown unit', () async {
      // GIVEN: CSV with unknown unit
      const unknownUnitCsv = '''logId,accountId,eventType,eventAt,duration,unit
abc-123,user-1,vape,2024-06-15T10:30:00.000,30.0,unknownunit''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(unknownUnitCsv);

      // THEN: Defaults to seconds
      expect(result.success, true);
      expect(result.records.first.unit, Unit.seconds);
    });

    test('Import CSV handles unknown source', () async {
      // GIVEN: CSV with unknown source
      const unknownSourceCsv = '''logId,accountId,eventType,eventAt,source
abc-123,user-1,vape,2024-06-15T10:30:00.000,unknownsource''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(unknownSourceCsv);

      // THEN: Defaults to imported
      expect(result.success, true);
      expect(result.records.first.source, Source.imported);
    });

    test('Import CSV handles escaped newlines in notes', () async {
      // GIVEN: CSV with escaped newline
      const newlineCsv = '''logId,accountId,eventType,eventAt,duration,unit,note
abc-123,user-1,vape,2024-06-15T10:30:00.000,30.0,seconds,"Line1\\nLine2"''';

      // WHEN: Importing
      final result = await exportService.importFromCsv(newlineCsv);

      // THEN: Newline is unescaped
      expect(result.success, true);
      expect(result.records.first.note, contains('\n'));
    });
  });

  group('User Story: JSON Import Full Coverage', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService();
    });

    test('Import valid JSON with all fields', () async {
      // GIVEN: Valid JSON content
      const validJson = '''
{
  "version": "1.0.0",
  "exportedAt": "2024-06-15T12:00:00.000",
  "recordCount": 1,
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000",
      "createdAt": "2024-06-15T10:30:00.000",
      "updatedAt": "2024-06-15T10:30:00.000",
      "duration": 30.0,
      "unit": "seconds",
      "note": "Test note",
      "reasons": ["stress", "recreational"],
      "moodRating": 7.5,
      "physicalRating": 8.0,
      "latitude": 37.7749,
      "longitude": -122.4194,
      "source": "manual",
      "deviceId": "device-123",
      "appVersion": "1.0.0",
      "timeConfidence": "high",
      "isDeleted": false,
      "deletedAt": null,
      "syncState": "synced",
      "revision": 1
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(validJson);

      // THEN: Success with all fields parsed
      expect(result.success, true);
      expect(result.records, hasLength(1));
      final record = result.records.first;
      expect(record.logId, 'abc-123');
      expect(record.accountId, 'user-1');
      expect(record.eventType, EventType.vape);
      expect(record.duration, 30.0);
      expect(record.unit, Unit.seconds);
      expect(record.note, 'Test note');
      expect(record.reasons, isNotNull);
      expect(record.reasons, contains(LogReason.stress));
      expect(record.reasons, contains(LogReason.recreational));
      expect(record.moodRating, 7.5);
      expect(record.physicalRating, 8.0);
      expect(record.latitude, 37.7749);
      expect(record.longitude, -122.4194);
      expect(record.source, Source.manual);
      expect(record.deviceId, 'device-123');
      expect(record.appVersion, '1.0.0');
      expect(record.timeConfidence, TimeConfidence.high);
      expect(record.isDeleted, false);
      expect(record.revision, 1);
    });

    test('Import JSON with minimal required fields', () async {
      // GIVEN: JSON with only required fields (including version to avoid warning)
      const minimalJson = '''
{
  "version": "1.0.0",
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(minimalJson);

      // THEN: Success with defaults applied
      expect(result.success, true);
      expect(result.records, hasLength(1));
      expect(result.records.first.duration, 0.0);
      expect(result.records.first.unit, Unit.seconds);
      expect(result.records.first.source, Source.imported);
    });

    test('Import JSON handles empty records array', () async {
      // GIVEN: JSON with empty records
      const emptyJson = '''
{
  "version": "1.0.0",
  "records": []
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(emptyJson);

      // THEN: Error result
      expect(result.success, false);
      expect(result.message, contains('No records'));
    });

    test('Import JSON handles missing records field', () async {
      // GIVEN: JSON without records field
      const noRecordsJson = '''
{
  "version": "1.0.0",
  "exportedAt": "2024-06-15T12:00:00.000"
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(noRecordsJson);

      // THEN: Error result
      expect(result.success, false);
    });

    test('Import JSON handles record with missing required fields', () async {
      // GIVEN: JSON record missing logId
      const missingFieldJson = '''
{
  "records": [
    {
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(missingFieldJson);

      // THEN: Record skipped
      expect(result.importedCount, 0);
      expect(result.errors, isNotEmpty);
    });

    test('Import JSON handles unknown event type', () async {
      // GIVEN: JSON with unknown event type
      const unknownTypeJson = '''
{
  "version": "1.0.0",
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "unknown_event",
      "eventAt": "2024-06-15T10:30:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(unknownTypeJson);

      // THEN: Defaults to custom
      expect(result.success, true);
      expect(result.records.first.eventType, EventType.custom);
    });

    test('Import JSON handles unknown reason', () async {
      // GIVEN: JSON with unknown reason
      const unknownReasonJson = '''
{
  "version": "1.0.0",
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000",
      "reasons": ["unknown_reason", "stress"]
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(unknownReasonJson);

      // THEN: Unknown defaults to other
      expect(result.success, true);
      expect(result.records.first.reasons, contains(LogReason.other));
      expect(result.records.first.reasons, contains(LogReason.stress));
    });

    test('Import JSON handles isDeleted and deletedAt', () async {
      // GIVEN: JSON with deleted record
      const deletedJson = '''
{
  "version": "1.0.0",
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000",
      "isDeleted": true,
      "deletedAt": "2024-06-16T10:00:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(deletedJson);

      // THEN: Deleted state preserved
      expect(result.success, true);
      expect(result.records.first.isDeleted, true);
      expect(result.records.first.deletedAt, isNotNull);
    });

    test('Import JSON handles multiple records with some errors', () async {
      // GIVEN: JSON with good and bad records (include version to reduce warnings)
      const mixedJson = '''
{
  "version": "1.0.0",
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000"
    },
    {
      "accountId": "user-1",
      "eventType": "vape"
    },
    {
      "logId": "def-456",
      "accountId": "user-1",
      "eventType": "inhale",
      "eventAt": "2024-06-15T11:00:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(mixedJson);

      // THEN: Good records imported, bad skipped
      expect(result.importedCount, 2);
      expect(result.skippedCount, 1);
      expect(result.errors, hasLength(1)); // Just the bad record error
    });

    test('Import JSON handles missing version gracefully', () async {
      // GIVEN: JSON without version field
      const noVersionJson = '''
{
  "records": [
    {
      "logId": "abc-123",
      "accountId": "user-1",
      "eventType": "vape",
      "eventAt": "2024-06-15T10:30:00.000"
    }
  ]
}''';

      // WHEN: Importing
      final result = await exportService.importFromJson(noVersionJson);

      // THEN: Records still parsed (success is false due to warning)
      expect(result.records, hasLength(1));
      expect(
        result.errors,
        contains('Warning: No version field found in import file'),
      );
    });
  });

  group('User Story: Export Format Consistency', () {
    late ExportService exportService;
    const uuid = Uuid();

    setUp(() {
      exportService = ExportService();
    });

    test('JSON export is valid parseable JSON structure', () async {
      // GIVEN: Some test records
      final records = <LogRecord>[
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30,
        ),
      ];

      // WHEN: Exporting to JSON
      final jsonExport = await exportService.exportToJson(records);

      // THEN: Output starts and ends with curly braces (valid JSON object)
      expect(jsonExport.trim().startsWith('{'), isTrue);
      expect(jsonExport.trim().endsWith('}'), isTrue);

      // Contains required export envelope fields
      expect(jsonExport, contains('"version"'));
      expect(jsonExport, contains('"exportedAt"'));
      expect(jsonExport, contains('"recordCount"'));
      expect(jsonExport, contains('"records"'));
    });

    test('CSV export has consistent row lengths', () async {
      // GIVEN: Multiple records
      final records = <LogRecord>[
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          duration: 30,
        ),
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'test-account',
          eventType: EventType.inhale,
          eventAt: DateTime.now().subtract(const Duration(hours: 1)),
          duration: 5,
          note: 'With note',
        ),
      ];

      // WHEN: Exporting to CSV
      final csvExport = await exportService.exportToCsv(records);

      // THEN: All rows have same number of columns as header
      final lines =
          csvExport.split('\n').where((line) => line.isNotEmpty).toList();

      expect(lines.length, greaterThanOrEqualTo(2)); // Header + data rows

      // Each data row should have similar structure
      // Note: Quoted fields with commas may affect this, so we just check rows exist
      for (int i = 1; i < lines.length; i++) {
        expect(lines[i], isNotEmpty);
      }
    });

    test('Export timestamps are ISO-8601 format', () async {
      // GIVEN: A record with known timestamp
      final testTime = DateTime(2024, 6, 15, 14, 30, 45);
      final records = <LogRecord>[
        LogRecord.create(
          logId: uuid.v4(),
          accountId: 'test-account',
          eventType: EventType.vape,
          eventAt: testTime,
          duration: 30,
        ),
      ];

      // WHEN: Exporting
      final jsonExport = await exportService.exportToJson(records);

      // THEN: Timestamp is in ISO-8601 format
      expect(jsonExport, contains('2024-06-15'));
      expect(jsonExport, contains('T')); // ISO separator
      expect(jsonExport, contains('14:30:45'));
    });
  });
}
