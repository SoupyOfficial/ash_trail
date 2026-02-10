# legacy_data_adapter

> **Source:** `lib/services/legacy_data_adapter.dart`

## Purpose

Handles querying and converting legacy Firestore collections (e.g., `JacobLogs`, `AshleyLogs`) into the current `LogRecord` schema. Provides backward compatibility for migrating personal log tables from earlier app versions to the unified data model. Supports querying, deduplication, counting, and real-time streaming of legacy data.

## Dependencies

- `package:cloud_firestore/cloud_firestore.dart` — Firestore queries, `Timestamp`, `DocumentChangeType`
- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `EventType`, `Unit`, `Source`, `TimeConfidence`, `LogReason` enums

## Pseudo-Code

### Class: LegacyDataAdapter

#### Fields
- `_log` — static logger tagged `'LegacyDataAdapter'`
- `_firestore` — `FirebaseFirestore` instance (injected or default)
- `legacyCollections` — static const `['JacobLogs', 'AshleyLogs']`

#### Constructor

```
LegacyDataAdapter({firestore?}):
  _firestore = firestore ?? FirebaseFirestore.instance
```

---

#### `queryLegacyCollection({collectionName, since?, limit=100}) → Future<List<LogRecord>>`

```
TRY:
  query = _firestore.collection(collectionName)
    .orderBy('eventAt', descending=true)

  IF since != null:
    query = query.where('eventAt', greaterThan: since.toIso8601String())

  querySnapshot = AWAIT query.limit(limit).get()
  records = []

  FOR EACH doc IN querySnapshot.docs:
    TRY:
      record = _convertLegacyToLogRecord(doc.data(), collectionName, doc.id)
      records.add(record)
    CATCH e:
      LOG ERROR 'Error converting legacy record from collectionName/doc.id'

  RETURN records
CATCH e:
  LOG ERROR 'Error querying legacy collection'
  RETURN []
```

---

#### `queryAllLegacyCollections({since?, limit=100}) → Future<List<LogRecord>>`

```
allRecords = {}   // Map<logId, LogRecord>

FOR EACH collectionName IN legacyCollections:
  records = AWAIT queryLegacyCollection(collectionName, since, limit)
  FOR EACH record IN records:
    // Dedup by logId — keep newer (by updatedAt)
    IF logId NOT IN allRecords OR record.updatedAt > existing.updatedAt:
      allRecords[logId] = record

result = allRecords.values.toList()
SORT by eventAt descending
RETURN result
```

---

#### `_convertLegacyToLogRecord(data, legacyCollection, docId) → LogRecord` (private)

```
record = new LogRecord()

// Identity
record.logId     = data['logId'] ?? data['id'] ?? docId
record.accountId = data['accountId'] ?? _extractAccountIdFromCollection(legacyCollection)

// Time — handle DateTime, Timestamp, String, int
record.eventAt   = _parseDateTime(data['eventAt']) ?? NOW
record.createdAt = _parseDateTime(data['createdAt']) ?? NOW
record.updatedAt = _parseDateTime(data['updatedAt']) ?? NOW

// Event Type — default to vape if not specified
record.eventType = _parseEventType(data['eventType'] ?? 'vape')

// Duration and Unit
record.duration = data['duration']?.toDouble() ?? 0
record.unit     = _parseUnit(data['unit'] ?? 'minutes')

// Optional fields
record.note           = data['note']
record.moodRating     = _parseDouble(data['moodRating'])
record.physicalRating = _parseDouble(data['physicalRating'])
record.latitude       = _parseDouble(data['latitude'])
record.longitude      = _parseDouble(data['longitude'])

// Metadata
record.source         = Source.imported
record.deviceId       = data['deviceId']
record.appVersion     = data['appVersion']
record.timeConfidence = TimeConfidence.high

// Reasons
IF data['reasons'] is List:
  record.reasons = map each to _parseLogReason, filter non-null

RETURN record
```

---

#### `_extractAccountIdFromCollection(String collectionName) → String` (private)

```
IF collectionName ends with 'Logs':
  RETURN collectionName WITHOUT last 4 chars, lowercased
    e.g. 'JacobLogs' → 'jacob'
ELSE:
  RETURN collectionName.toLowerCase()
```

---

#### `_parseDateTime(dynamic value) → DateTime?` (private)

```
IF null → null
IF DateTime → return as-is
IF Timestamp → .toDate()
IF String → DateTime.parse (catch → null)
IF int → DateTime.fromMillisecondsSinceEpoch
ELSE → null
```

---

#### `_parseEventType(dynamic value) → EventType` (private)

```
stringValue = value.toString().toLowerCase()
FOR EACH eventType IN EventType.values:
  IF eventType.toString().toLowerCase() CONTAINS stringValue → RETURN it
DEFAULT → EventType.vape
```

---

#### `_parseUnit(dynamic value) → Unit` (private)

```
Same pattern as _parseEventType
DEFAULT → Unit.minutes
```

---

#### `_parseLogReason(dynamic value) → LogReason?` (private)

```
IF LogReason instance → return directly
Match string against LogReason.values
RETURN matched or null
```

---

#### `_parseDouble(dynamic value) → double?` (private)

```
IF null → null
IF double → return
IF int → .toDouble()
IF String → double.parse (catch → null)
ELSE → null
```

---

#### `hasLegacyData(String accountId) → Future<bool>`

```
FOR EACH collectionName IN legacyCollections:
  TRY:
    snapshot = AWAIT collection.where('accountId', eq accountId).limit(1).get()
    IF docs not empty → RETURN true
  CATCH: continue

RETURN false
```

---

#### `getLegacyRecordCount(String accountId) → Future<int>`

```
totalCount = 0
FOR EACH collectionName:
  TRY:
    snapshot = AWAIT collection.where('accountId', eq accountId).count().get()
    totalCount += snapshot.count ?? 0
  CATCH: continue
RETURN totalCount
```

---

#### `watchLegacyCollections({accountId, limit=50}) → Stream<LogRecord>` (async generator)

```
FOR EACH collectionName IN legacyCollections:
  YIELD* _firestore.collection(collectionName)
    .where('accountId', eq accountId)
    .orderBy('eventAt', descending=true)
    .limit(limit)
    .snapshots()
    .asyncExpand((snapshot) →
      FOR EACH change IN snapshot.docChanges:
        IF change.type == added OR modified:
          TRY:
            record = _convertLegacyToLogRecord(change.doc.data(), collection, doc.id)
            YIELD record
          CATCH: LOG ERROR
    )
```
