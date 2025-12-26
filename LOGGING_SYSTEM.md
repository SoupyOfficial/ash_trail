# AshTrail Logging System Documentation

## Overview

The AshTrail logging system implements a comprehensive, offline-first event logging solution with bidirectional Firestore sync, conflict resolution, and advanced analytics capabilities.

## Architecture

### Core Components

1. **Data Models** (`lib/models/`)
   - `enums.dart` - All enumeration types
   - `user_account.dart` - User account entity
   - `profile.dart` - User profiles/personas
   - `log_record.dart` - Main logging entity
   - `daily_rollup.dart` - Cached aggregations
   - `range_query_spec.dart` - Analytics query parameters

2. **Services** (`lib/services/`)
   - `log_record_service.dart` - CRUD operations for log records
   - `sync_service.dart` - Firestore synchronization
   - `analytics_service.dart` - Aggregations and analytics
   - `isar_service.dart` - Local database management

3. **Providers** (`lib/providers/`)
   - `log_record_provider.dart` - State management for logging
   - `sync_provider.dart` - Sync status and operations
   - `analytics_provider.dart` - Analytics queries and state

4. **Widgets** (`lib/widgets/`)
   - `log_entry_widgets.dart` - Create log entry dialog
   - `log_record_list.dart` - Display log records
   - `sync_status_widget.dart` - Sync status indicators

## Logging Flow (End-to-End)

### 1. Select Active Identity

```dart
// Set active account
ref.read(activeAccountIdProvider.notifier).state = accountId;

// Optionally set active profile
ref.read(activeProfileIdProvider.notifier).state = profileId;
```

### 2. Create Log Event Locally

```dart
final service = LogRecordService();
final record = await service.createLogRecord(
  accountId: accountId,
  eventType: EventType.inhale,
  eventAt: DateTime.now(),
  value: 1.0,
  unit: Unit.hits,
  note: 'Morning session',
  tags: ['morning', 'sativa'],
);
```

The system automatically:
- Generates a unique `logId` (UUID)
- Sets `createdAt`, `eventAt`, `deviceId`, `appVersion`
- Writes to **Isar** immediately (source of truth)
- Marks `syncState=PENDING`

### 3. Update UI-Derived Views

UI components automatically react to changes via Riverpod providers:

```dart
// Watch log records in real-time
final recordsStream = ref.watch(logRecordsProvider(params));

// Get aggregated analytics
final aggregated = ref.watch(aggregatedDataProvider(accountId));
```

### 4. Sync Queue

Background `SyncService` automatically:
- Runs every 30 seconds (configurable)
- Batches uploads (50 records at a time)
- Checks online status before syncing
- Updates `syncState` appropriately

```dart
// Manual sync trigger
final syncService = ref.read(syncServiceProvider);
await syncService.forceSyncNow();
```

### 5. Firestore Upsert

- **Idempotent writes** using `logId` as document ID
- Path: `accounts/{accountId}/logs/{logId}`
- On success: `syncState=SYNCED`, stores `syncedAt` and remote update time

### 6. Conflict Handling

- Uses "latest `updatedAt` wins" strategy
- Compares local vs remote timestamps
- Updates local record if remote is newer
- Tracks conflicts via `revision` counter

### 7. Deletes/Edits

- **Soft-delete** preferred: `isDeleted=true`, `deletedAt` timestamp
- Edits update `updatedAt` + `dirtyFields`
- Changes automatically marked `syncState=PENDING`

## Core Entities

### UserAccount

```dart
@collection
class UserAccount {
  Id id; // Local Isar ID
  String accountId; // UUID (stable across devices)
  String displayName;
  String? email;
  AuthProvider authProvider; // gmail, apple, email, devStatic, anonymous
  DateTime createdAt;
  DateTime? updatedAt;
  String? activeProfileId; // Currently active profile
  bool isActive; // Currently selected account
  DateTime? lastSyncedAt;
  // ... session tokens
}
```

### Profile (Optional Multi-Tracker)

```dart
@collection
class Profile {
  Id id;
  String profileId; // UUID
  String accountId; // Parent account
  String name; // Display name
  String? description;
  DateTime createdAt;
  DateTime? updatedAt;
  String? settingsJson; // Units, defaults, chart prefs
  bool isActive;
  bool isDeleted;
  DateTime? deletedAt;
}
```

### LogRecord (Main Event Entity)

```dart
@collection
class LogRecord {
  Id id;
  
  // IDENTITY
  String logId; // UUID (stable across local + Firestore)
  String accountId;
  String? profileId;
  
  // TIME
  DateTime eventAt; // When it happened (for charts)
  DateTime createdAt; // When recorded
  DateTime updatedAt; // Last modified
  
  // EVENT PAYLOAD
  EventType eventType; // inhale, sessionStart, note, etc.
  double? value; // Duration, hits, amount
  Unit unit; // seconds, hits, mg, etc.
  String? note;
  String? tagsString; // Comma-separated tags
  
  // METADATA
  Source source; // manual, imported, automation
  String? deviceId;
  String? appVersion;
  
  // LIFECYCLE
  bool isDeleted;
  DateTime? deletedAt;
  
  // SYNC
  SyncState syncState; // pending, syncing, synced, error
  String? syncError;
  DateTime? syncedAt;
  DateTime? lastRemoteUpdateAt;
  
  // EXTRAS
  String? sessionId; // Group related logs
  String? dirtyFields; // Changed fields tracking
  int revision; // Conflict resolution counter
}
```

### DailyRollup (Performance Cache)

```dart
@collection
class DailyRollup {
  Id id;
  String accountId;
  String? profileId;
  String date; // YYYY-MM-DD
  double totalValue;
  int eventCount;
  DateTime? firstEventAt;
  DateTime? lastEventAt;
  DateTime updatedAt;
  String? sourceRangeHash; // Cache validation
  String? eventTypeBreakdownJson;
}
```

### RangeQuerySpec (Analytics Query)

```dart
class RangeQuerySpec {
  RangeType rangeType; // today, week, month, year, ytd, custom, all
  DateTime startAt;
  DateTime endAt;
  GroupBy groupBy; // hour, day, week, month, quarter, year
  List<EventType>? eventTypes; // Filter
  List<String>? tags; // Filter
  double? minValue; // Filter
  double? maxValue; // Filter
  String? profileId; // Filter
  bool includeDeleted;
}
```

## Firestore Layout

```
accounts/
  {accountId}/
    logs/
      {logId} → LogRecord
    profiles/
      {profileId} → Profile
    rollupsDaily/
      {date} → DailyRollup (optional)
```

**Key rule**: Document ID = `logId` for idempotent uploads

## Local (Isar) Collections

### Registered Schemas

```dart
[
  AccountSchema, // Legacy
  LogEntrySchema, // Legacy
  SyncMetadataSchema, // Legacy
  UserAccountSchema, // New
  ProfileSchema, // New
  LogRecordSchema, // New
  DailyRollupSchema, // New
]
```

### Important Indexes

```dart
// LogRecord indexes
@Index(unique: true, composite: [CompositeIndex('accountId')])
String logId;

@Index()
String accountId;

@Index()
DateTime eventAt;

@Index()
SyncState syncState;

@Index()
bool isDeleted;
```

## Usage Examples

### Creating a Log Entry

```dart
// Using the service directly
final service = LogRecordService();
final record = await service.createLogRecord(
  accountId: 'user-123',
  eventType: EventType.inhale,
  eventAt: DateTime.now(),
  value: 1.0,
  unit: Unit.hits,
  note: 'Feeling good',
  tags: ['morning', 'sativa'],
);

// Using the dialog widget
showDialog(
  context: context,
  builder: (context) => const CreateLogEntryDialog(),
);

// Quick log button
QuickLogButton(
  eventType: EventType.inhale,
  label: 'Log Hit',
  icon: Icons.air,
  defaultUnit: Unit.hits,
  defaultValue: 1.0,
)
```

### Querying Log Records

```dart
// Watch records in real-time
final params = LogRecordsParams(
  accountId: accountId,
  startDate: DateTime.now().subtract(Duration(days: 7)),
  endDate: DateTime.now(),
);

final recordsStream = ref.watch(logRecordsProvider(params));

// One-time fetch
final records = await service.getLogRecords(
  accountId: accountId,
  startDate: startDate,
  endDate: endDate,
  eventTypes: [EventType.inhale, EventType.note],
);
```

### Analytics Queries

```dart
// Get time series for charting
final service = AnalyticsService();
final spec = RangeQuerySpec.week(groupBy: GroupBy.day);
final timeSeries = await service.getTimeSeries(
  accountId: accountId,
  spec: spec,
);

// Get event type breakdown
final breakdown = await service.getEventTypeBreakdown(
  accountId: accountId,
  startDate: startDate,
  endDate: endDate,
);

// Get period summary
final summary = await service.getPeriodSummary(
  accountId: accountId,
  startDate: startDate,
  endDate: endDate,
);
```

### Sync Operations

```dart
// Check sync status
final service = SyncService();
final status = await service.getSyncStatus(accountId);
print('Pending: ${status.pendingCount}');
print('Online: ${status.isOnline}');
print('Syncing: ${status.isSyncing}');

// Force sync
final result = await service.forceSyncNow();
print('Success: ${result.success}, Failed: ${result.failed}');

// Pull records from Firestore
final pullResult = await service.pullRecordsForAccount(
  accountId: accountId,
  since: lastSyncTime,
);

// Start auto-sync
service.startAutoSync(); // Runs every 30 seconds
```

## UI Integration

### Home Screen with Quick Actions

```dart
Scaffold(
  appBar: AppBar(
    title: Text('AshTrail'),
    actions: [
      SyncStatusIndicator(), // Shows sync status
    ],
  ),
  body: Column(
    children: [
      SyncStatusWidget(), // Detailed sync status card
      Row(
        children: [
          QuickLogButton(
            eventType: EventType.inhale,
            label: 'Hit',
            icon: Icons.air,
            defaultUnit: Unit.hits,
            defaultValue: 1.0,
          ),
          QuickLogButton(
            eventType: EventType.sessionStart,
            label: 'Start',
            icon: Icons.play_circle,
          ),
        ],
      ),
      Expanded(
        child: LogRecordList(
          startDate: DateTime.now().subtract(Duration(days: 7)),
        ),
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) => CreateLogEntryDialog(),
      );
    },
    child: Icon(Icons.add),
  ),
)
```

### Analytics Screen

```dart
Consumer(
  builder: (context, ref, child) {
    final accountId = ref.watch(activeAccountIdProvider);
    final timeSeriesAsync = ref.watch(timeSeriesProvider(accountId!));
    
    return timeSeriesAsync.when(
      data: (timeSeries) => LineChart(
        // Use fl_chart with timeSeries data
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  },
)
```

## Best Practices

1. **Always use soft-delete** to avoid sync issues
2. **Check active account** before operations
3. **Use providers** for reactive UI updates
4. **Batch operations** when possible
5. **Handle offline scenarios** gracefully
6. **Validate inputs** before creating records
7. **Monitor sync status** and show user feedback
8. **Use indexes** for efficient queries
9. **Cache aggregations** with DailyRollup
10. **Test conflict resolution** scenarios

## Migration from Legacy Models

The new system coexists with legacy `Account` and `LogEntry` models. To migrate:

1. Keep both schemas registered initially
2. Create migration service to copy data
3. Test thoroughly before removing old models
4. Update all references to use new models

## Performance Considerations

- **Indexes**: All frequently queried fields are indexed
- **Rollups**: Daily aggregations cached for performance
- **Batch sync**: Uploads limited to 50 records per batch
- **Lazy loading**: Use pagination for large datasets
- **Stream queries**: Use `watch()` only when needed

## Security Notes

- LogRecord document ID = logId (prevents overwrites)
- Firestore rules should check `accountId` ownership
- Never expose internal Isar IDs in Firestore
- Validate all inputs before writing
- Use authentication for all Firestore access

## Future Enhancements

- [ ] Session auto-tracking (start/end)
- [ ] Export to CSV/JSON
- [ ] Import from other formats
- [ ] Advanced conflict resolution UI
- [ ] Offline queue management UI
- [ ] Push notifications for sync errors
- [ ] Multi-device sync indicators
- [ ] Bulk operations
- [ ] Search and filtering UI
- [ ] Tag management
- [ ] Profile switching UI

## Troubleshooting

### Records not syncing

1. Check `syncState` field
2. Verify internet connection
3. Check Firestore rules
4. Look at `syncError` field
5. Manually trigger sync

### Conflicts not resolving

1. Check `lastRemoteUpdateAt` timestamp
2. Verify `revision` counter
3. Check for clock skew
4. Review conflict resolution logic

### Aggregations showing wrong data

1. Invalidate rollup cache
2. Force recompute
3. Check date range
4. Verify filters applied correctly

## Support

For issues or questions, refer to:
- Code documentation in source files
- This comprehensive guide
- Firestore documentation
- Isar documentation
