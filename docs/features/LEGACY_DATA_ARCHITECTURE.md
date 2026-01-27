# Legacy Data Support - Architecture & Flow

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
│  (UI Screens, Providers, Business Logic)                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    SyncService (Enhanced)                     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ New Methods:                                           │ │
│  │ • pullRecordsForAccountIncludingLegacy()             │ │
│  │ • importLegacyDataForAccount()                       │ │
│  │ • watchAccountLogsIncludingLegacy()                  │ │
│  │ • hasLegacyData()                                    │ │
│  │ • getLegacyRecordCount()                             │ │
│  └────────────────────────────────────────────────────────┘ │
│                   │           │                              │
│         ┌─────────┘           └─────────┐                   │
│         ▼                               ▼                    │
│  ┌──────────────┐              ┌──────────────────┐         │
│  │ _pullCurrent │              │_pullLegacy       │         │
│  │ Records()    │              │Records()         │         │
│  └──────┬───────┘              └────────┬─────────┘         │
│         │                               │                    │
│         └──────────────┬────────────────┘                   │
│                        ▼                                     │
│                  _mergeRecords()                            │
│         (Deduplication by logId)                           │
│                        │                                    │
└────────────────────────┼────────────────────────────────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
         ▼                               ▼
┌──────────────────────────┐    ┌──────────────────────┐
│   LogRecordService       │    │ LegacyDataAdapter    │
│ (Local Database)         │    │ (Firestore Bridge)   │
│                          │    │                      │
│ • create()              │    │ queryLegacy...()    │
│ • update()              │    │ convertLegacy...()  │
│ • importLogRecord()     │    │ hasLegacyData()     │
│ • importLegacy...Batch()│    │ getLegacyCount()    │
│ • getLogRecordByLogId() │    │ watchLegacy...()    │
│ • getLogRecords()       │    │                      │
│ • getPendingSync()      │    │ Supported Sources:  │
│                          │    │ • JacobLogs         │
│                          │    │ • AshleyLogs        │
│                          │    │ • Custom (add more) │
│                          │    │                      │
└───┬────────────────────┬─┘    └──────────┬──────────┘
    │                    │                 │
    │                    │        ┌────────┘
    │                    │        │
    ▼                    │        ▼
┌──────────────┐         │   ┌─────────────────┐
│ Hive Boxes   │         │   │  Firestore      │
│ (Local DB)   │         │   │  • accounts/    │
│              │         │   │    {id}/logs    │
│ • logRecords │         │   │  • JacobLogs    │
│ • accounts   │         │   │  • AshleyLogs   │
│ • metadata   │         │   │                 │
└──────────────┘         │   └─────────────────┘
                         │
                         ▼
                    LogRecord Model
                 (Unified Log Format)
```

## Data Flow Diagram

### 1. Legacy Data Discovery Flow
```
┌─ User Opens App ──────────────────────────────────────┐
│                                                        │
│  ┌──────────────────────────────────────────────────┐ │
│  │ hasLegacyData(accountId)?                        │ │
│  │  ↓                                               │ │
│  │ Query JacobLogs, AshleyLogs for accountId        │ │
│  │  ↓                                               │ │
│  │ Return: true/false                               │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
│  If true:                                             │
│  ┌──────────────────────────────────────────────────┐ │
│  │ Show "Import Legacy Data" Dialog                 │ │
│  │  ├─ Legacy Records Found: X                      │ │
│  │  ├─ [Import] [Cancel] buttons                    │ │
│  │  └─ Preview of 5 most recent records             │ │
│  └──────────────────────────────────────────────────┘ │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 2. Data Import Flow
```
┌─ User Clicks "Import" ────────────────────────────────┐
│                                                       │
│  importLegacyDataForAccount(accountId)               │
│  │                                                   │
│  ├─ Fetch all legacy collections                    │
│  │  ├─ JacobLogs collection query()                 │
│  │  ├─ AshleyLogs collection query()                │
│  │  └─ Other custom collections()                   │
│  │                                                   │
│  ├─ Convert to LogRecord format                     │
│  │  ├─ Field mapping (legacy → current)             │
│  │  ├─ Default missing fields                       │
│  │  ├─ Parse dates, enums, coordinates             │
│  │  └─ Validate data integrity                      │
│  │                                                   │
│  ├─ Deduplicate records                             │
│  │  ├─ Group by logId                               │
│  │  ├─ Keep version with newest updatedAt           │
│  │  └─ Merge metadata                               │
│  │                                                   │
│  ├─ Check for conflicts with existing local data    │
│  │  ├─ Check if logId exists locally                │
│  │  ├─ Compare timestamps                           │
│  │  └─ Keep newer version                           │
│  │                                                   │
│  ├─ Import into local database                      │
│  │  ├─ Batch insert new records                     │
│  │  ├─ Update existing records if newer             │
│  │  └─ Mark all as synced                           │
│  │                                                   │
│  └─ Return: importedCount                           │
│                                                     │
│  Show success: "Imported X records"                 │
│                                                     │
└──────────────────────────────────────────────────────┘
```

### 3. Sync with Legacy Support Flow
```
┌─ Regular Sync Triggered ──────────────────────────────┐
│                                                       │
│  pullRecordsForAccountIncludingLegacy(accountId)    │
│  │                                                   │
│  ├─ PARALLEL: Pull current records                  │
│  │  └─ accounts/{id}/logs collection query()        │
│  │                                                   │
│  ├─ PARALLEL: Pull legacy records                   │
│  │  ├─ JacobLogs collection query()                 │
│  │  ├─ AshleyLogs collection query()                │
│  │  └─ Other custom collections()                   │
│  │                                                   │
│  ├─ Merge results                                   │
│  │  ├─ Combine all records                          │
│  │  ├─ Remove duplicates by logId                   │
│  │  ├─ Keep newer version (by updatedAt)            │
│  │  └─ Sort by eventAt descending                   │
│  │                                                   │
│  ├─ Process merged records                          │
│  │  ├─ For each record:                             │
│  │  │  ├─ Check if exists locally (by logId)        │
│  │  │  ├─ If new: import it                         │
│  │  │  ├─ If exists: update if remote is newer      │
│  │  │  └─ Mark as synced                            │
│  │  │                                               │
│  │  ├─ On error: increment failedCount              │
│  │  └─ Track successCount                           │
│  │                                                   │
│  └─ Return SyncResult with statistics               │
│                                                     │
│  Log: "Pulled X records (Y current, Z legacy)"      │
│                                                     │
└──────────────────────────────────────────────────────┘
```

### 4. Real-Time Watch Flow
```
┌─ App Initializes Listeners ───────────────────────────┐
│                                                       │
│  watchAccountLogsIncludingLegacy(accountId)         │
│  │                                                   │
│  ├─ Stream 1: Current logs updates                  │
│  │  └─ Listen to accounts/{id}/logs changes         │
│  │     ├─ Added documents                           │
│  │     ├─ Modified documents                        │
│  │     └─ Deleted documents                         │
│  │                                                   │
│  ├─ Stream 2: Legacy logs updates                   │
│  │  ├─ Listen to JacobLogs changes                  │
│  │  ├─ Listen to AshleyLogs changes                 │
│  │  └─ Listen to other collections                  │
│  │                                                   │
│  └─ Yield updates as they arrive                    │
│     └─ Convert to LogRecord                         │
│        └─ Emit to listeners                         │
│                                                     │
│  UI updates in real-time as data changes            │
│                                                     │
└──────────────────────────────────────────────────────┘
```

## Field Conversion Flow

```
Legacy Document (Firestore)
│
├─ { logId: "abc", accountId: "jacob", ... }
├─ { id: "def", accountId: "ashley", ... }
│  (various field names and formats)
│
▼
LegacyDataAdapter._convertLegacyToLogRecord()
│
├─ Identity Field Mapping
│  ├─ logId ← "logId" || "id" || docId
│  └─ accountId ← "accountId" || extracted from collection name
│
├─ DateTime Parsing
│  ├─ eventAt ← ISO8601 || Timestamp || epoch || now
│  ├─ createdAt ← ISO8601 || Timestamp || epoch || now
│  └─ updatedAt ← ISO8601 || Timestamp || epoch || now
│
├─ Enum Parsing
│  ├─ eventType ← parsed value || "vape" (default)
│  ├─ unit ← parsed value || "minutes" (default)
│  ├─ reasons ← array of parsed values || null
│  └─ source ← Source.imported
│
├─ Numeric Fields
│  ├─ duration ← double || 0
│  ├─ moodRating ← 1-10 || null
│  ├─ physicalRating ← 1-10 || null
│  ├─ latitude ← float || null
│  └─ longitude ← float || null
│
├─ Optional Fields
│  ├─ note ← string || null
│  ├─ deviceId ← string || null
│  └─ appVersion ← string || null
│
▼
LogRecord (Unified Format)
│
└─ {
    logId: "abc",
    accountId: "jacob",
    eventType: EventType.vape,
    eventAt: DateTime(...),
    createdAt: DateTime(...),
    updatedAt: DateTime(...),
    duration: 5.0,
    unit: Unit.minutes,
    moodRating: 7.0,
    ...
  }
```

## Deduplication Algorithm

```
Input: [Record A, Record B, Record C, ...] from multiple sources
│
├─ Initialize: merged = {}  // Map<logId, LogRecord>
│
├─ Process each record:
│  │
│  ├─ logId = record.logId
│  │
│  ├─ If logId not in merged:
│  │  └─ merged[logId] = record  // First occurrence
│  │
│  └─ Else if record.updatedAt > merged[logId].updatedAt:
│     └─ merged[logId] = record  // Newer version
│
├─ Sort by eventAt descending
│
└─ Return: List<LogRecord>
   │
   └─ Each logId appears exactly once
      └─ Version with latest updatedAt
```

## Conflict Resolution Strategy

```
Scenario: Same record exists in:
┌─────────────────┐
│ Local Database  │  lastUpdated: 2024-01-05 10:00
├─────────────────┤
│  Current Logs   │  lastUpdated: 2024-01-06 15:00
├─────────────────┤
│  Legacy Logs    │  lastUpdated: 2024-01-07 08:00
└─────────────────┘

Resolution Process:
1. Find all versions of this logId
2. Compare updatedAt timestamps
3. Select version with LATEST timestamp
   └─ Legacy Logs version (2024-01-07 08:00) wins
4. Update all sources to have this version
   └─ Local DB gets updated
   └─ Current/Legacy marked as synced
```

## Error Handling Decision Tree

```
Process Legacy Record
│
├─ Missing required field?
│  ├─ YES: Apply sensible default
│  └─ NO: Continue
│
├─ Invalid date format?
│  ├─ YES: Use current time
│  └─ NO: Continue
│
├─ Invalid enum value?
│  ├─ YES: Use safe default (vape, minutes)
│  └─ NO: Continue
│
├─ Latitude without longitude (or vice versa)?
│  ├─ YES: Set both to null
│  └─ NO: Continue
│
├─ Rating outside 1-10?
│  ├─ YES: Set to null
│  └─ NO: Continue
│
├─ logId already exists locally?
│  ├─ YES: Compare timestamps
│  │  ├─ Remote newer: Update local
│  │  └─ Local newer: Skip remote
│  └─ NO: Insert new record
│
└─ Success: Record processed ✓
```

## Performance Characteristics

```
Query Times (approximate):
┌─────────────────────────────────────┐
│ Operation           │ Typical Time   │
├─────────────────────────────────────┤
│ hasLegacyData()     │ 50-100ms       │
│ getLegacyCount()    │ 100-150ms      │
│ Query 100 records   │ 100-200ms      │
│ Query all legacy    │ 200-400ms      │
│ Dedup 500 records   │ 10-20ms        │
│ Import 100 records  │ 500-1000ms     │
│ Watch stream init   │ 50-100ms       │
└─────────────────────────────────────┘

Memory Usage:
┌─────────────────────────────────────┐
│ Task                │ Memory Impact  │
├─────────────────────────────────────┤
│ Query 100 records   │ ~1-2 MB        │
│ In-memory dedup     │ ~2-5 MB        │
│ Streaming (100)     │ ~0.1-0.5 MB    │
│ Batch import        │ ~5-10 MB       │
└─────────────────────────────────────┘
```

## Integration Points

```
Application
│
├─ Logging Screen
│  └─ Can show "Legacy data detected" banner
│     └─ Trigger migration via syncService
│
├─ Account Management
│  └─ Show legacy record count
│     └─ Initiate migration from settings
│
├─ Sync Provider
│  └─ Automatically includes legacy data
│     └─ No changes needed - backward compatible
│
├─ Data Export
│  └─ Can export legacy + current records together
│     └─ Unified format
│
├─ Analytics/Reports
│  └─ Aggregate across all data sources
│     └─ Transparent to UI layer
│
└─ Background Services
   └─ Periodic sync includes legacy
      └─ Seamless data consolidation
```

---

This architecture ensures:
- ✅ Clean separation of concerns
- ✅ Efficient data handling
- ✅ Graceful error recovery
- ✅ Easy to extend and maintain
- ✅ Transparent to application layer
