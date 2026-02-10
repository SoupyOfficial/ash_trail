# export_service

> **Source:** `lib/services/export_service.dart`

## Purpose

Provides CSV and JSON import/export for log records per design doc §23 (Import/Export). Exports produce flat CSV for spreadsheets or full-fidelity JSON for backups. Imports validate data before mutation, parse records without persisting them (caller handles persistence), and support conflict resolution strategies.

## Dependencies

- `dart:convert` — JSON encoding/decoding
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `EventType`, `Unit`, `Source`, `SyncState`, `LogReason`, `TimeConfidence` enums

## Pseudo-Code

### Class: ExportService

_(No fields, no constructor — stateless service)_

---

#### `exportToCsv(List<LogRecord> records) → Future<String>`

```
buffer = StringBuffer()

// Write CSV header
buffer.writeln('logId,accountId,eventType,eventAt,duration,unit,note,moodRating,physicalRating,latitude,longitude,source,syncState,createdAt,updatedAt')

FOR EACH record IN records:
  buffer.writeln(
    logId, accountId, eventType.name, eventAt ISO, duration, unit.name,
    "escaped_note", moodRating or '', physicalRating or '',
    latitude or '', longitude or '', source.name, syncState.name,
    createdAt ISO, updatedAt ISO
  )

RETURN buffer.toString()
```

---

#### `exportToJson(List<LogRecord> records) → Future<String>`

```
exportData = {
  'version': '1.0.0',
  'exportedAt': NOW ISO,
  'recordCount': records.length,
  'records': records.map(r → _recordToJson(r)).toList()
}

RETURN JsonEncoder.withIndent('  ').convert(exportData)
```

---

#### `importFromCsv(String csvContent) → Future<ImportResult>`

```
errors = [], records = []

TRY:
  lines = csvContent.split('\n').WHERE(not empty)
  IF lines.isEmpty → RETURN ImportResult(success=false, 'CSV file is empty')

  // Parse and validate headers
  headers = _parseCsvLine(lines[0])
  headerMap = {headerName.toLowerCase → index}

  requiredHeaders = ['logid', 'accountid', 'eventtype', 'eventat']
  FOR EACH required IN requiredHeaders:
    IF required NOT IN headerMap:
      RETURN ImportResult(success=false, 'Missing required header: required')

  // Parse data rows
  FOR i = 1 TO lines.length-1:
    TRY:
      values = _parseCsvLine(lines[i])
      IF values.length < 4:
        errors.add('Row {i+1}: Insufficient columns')
        CONTINUE
      record = _parseRecordFromCsv(values, headerMap, rowNum)
      IF record != null → records.add(record)
    CATCH e:
      errors.add('Row {i+1}: e')

  RETURN ImportResult(
    success = errors.isEmpty,
    message = 'Parsed {count} records' (with or without errors),
    importedCount = records.length,
    skippedCount = dataRows - records.length,
    errors, records
  )

CATCH e:
  RETURN ImportResult(success=false, 'Failed to parse CSV: e')
```

---

#### `importFromJson(String jsonContent) → Future<ImportResult>`

```
errors = [], records = []

TRY:
  data = json.decode(jsonContent)
  version = data['version']  // warn if missing
  recordsList = data['records']
  IF null or empty → RETURN ImportResult(success=false, 'No records found')

  FOR i = 0 TO recordsList.length-1:
    TRY:
      recordData = recordsList[i]
      record = _parseRecordFromJson(recordData, i)
      IF record != null → records.add(record)
    CATCH e:
      errors.add('Record i: e')

  RETURN ImportResult(success, message, importedCount, skippedCount, errors, records)

CATCH e:
  RETURN ImportResult(success=false, 'Failed to parse JSON: e')
```

---

#### `_parseCsvLine(String line) → List<String>` (private)

```
Handle quoted fields with escaped double-quotes (""):
  Iterate character-by-character
  Track inQuotes state
  Handle "" as escaped quote
  Split on commas only when not inside quotes
RETURN list of values
```

---

#### `_parseRecordFromCsv(values, headerMap, rowNum) → LogRecord?` (private)

```
Extract fields via headerMap index lookup: logId, accountId, eventType, eventAt (required)
IF any required field empty → THROW FormatException

Parse eventType → enum (fallback EventType.custom)
Parse eventAt → DateTime.parse
Parse duration → double (default 0)
Parse unit → enum (default seconds)
Parse note (unescape \\n → \n)
Parse moodRating, physicalRating → double? (nullable)
Parse latitude, longitude → double? (nullable)
Parse source → enum (default imported)
Parse createdAt, updatedAt → DateTime (default NOW)

RETURN LogRecord.create(... all fields ..., syncState=SyncState.pending)
```

---

#### `_parseRecordFromJson(Map data, int index) → LogRecord?` (private)

```
Extract required: logId, accountId, eventType, eventAt
IF any null → THROW FormatException

Parse all enums from string names (eventType, unit, source, timeConfidence)
Parse reasons list → List<LogReason>
Parse optional doubles: duration, moodRating, physicalRating, latitude, longitude
Parse optional fields: note, deviceId, appVersion, isDeleted, deletedAt, revision

RETURN LogRecord.create(... all fields ..., syncState=SyncState.pending)
```

---

#### `_escapeCsv(String value) → String` (private)

```
RETURN value.replaceAll('"', '""').replaceAll('\n', '\\n')
```

---

#### `_recordToJson(LogRecord record) → Map<String, dynamic>` (private)

```
RETURN {
  logId, accountId, eventType.name, eventAt ISO, createdAt ISO, updatedAt ISO,
  duration, unit.name, note, reasons (list of .name), moodRating, physicalRating,
  latitude, longitude, source.name, deviceId, appVersion,
  timeConfidence.name, isDeleted, deletedAt ISO?, syncState.name, revision
}
```

---

### Class: ImportResult

#### Fields
- `success` — whether all rows parsed without errors
- `message` — human-readable summary
- `importedCount` — number of successfully parsed records
- `skippedCount` — rows that could not be parsed
- `errors` — list of error strings
- `records` — parsed `LogRecord` list (caller persists)

---

### Enum: ConflictResolution

```
skip     // Skip conflicting records
replace  // Replace existing with imported
merge    // Merge fields (keep newer values)
```
