# Legacy Data Support - Quick Reference

## Account Mappings

```
Email                  Account ID    Collection
──────────────────────────────────────────────
soupsterx@gmail.com    → "jacob"   → JacobLogs
ashley_g25@gmail.com   → "ashley"  → AshleyLogs
```

## Quick Start

### Check for Legacy Data
```dart
final syncService = SyncService();

// For soupsterx@gmail.com (accountId: 'jacob')
if (await syncService.hasLegacyData('jacob')) {
  final count = await syncService.getLegacyRecordCount('jacob');
  print('Found $count legacy records from JacobLogs');
}

// For ashley_g25@gmail.com (accountId: 'ashley')
if (await syncService.hasLegacyData('ashley')) {
  final count = await syncService.getLegacyRecordCount('ashley');
  print('Found $count legacy records from AshleyLogs');
}
```

### Migrate Legacy Data
```dart
// Import all legacy records for an account
final imported = await syncService.importLegacyDataForAccount(
  accountId: accountId, // 'jacob' or 'ashley'
);
print('Imported $imported records');
```

### Pull Records with Legacy Support
```dart
final result = await syncService.pullRecordsForAccountIncludingLegacy(
  accountId: accountId,
  since: DateTime.now().subtract(Duration(days: 30)),
);
```

### Watch Real-Time Updates
```dart
syncService.watchAccountLogsIncludingLegacy(accountId).listen((record) {
  print('Record updated: ${record.logId}');
});
```

## Supported Legacy Collections

| Collection | Account Email | Account ID |
|-----------|---------------|-----------|
| `JacobLogs` | soupsterx@gmail.com | `jacob` |
| `AshleyLogs` | ashley_g25@gmail.com | `ashley` |

To add more: Update `legacyCollections` list in `LegacyDataAdapter`

## Key Methods

### SyncService
- `pullRecordsForAccountIncludingLegacy()` - Sync from both current and legacy
- `hasLegacyData()` - Check if legacy data exists
- `getLegacyRecordCount()` - Get legacy record count
- `importLegacyDataForAccount()` - Bulk import legacy records
- `watchAccountLogsIncludingLegacy()` - Real-time stream

### LegacyDataAdapter
- `queryLegacyCollection()` - Query single legacy collection
- `queryAllLegacyCollections()` - Query all legacy collections
- `hasLegacyData()` - Check existence
- `getLegacyRecordCount()` - Count records
- `watchLegacyCollections()` - Real-time watch

### LogRecordService
- `importLegacyRecordsBatch()` - Batch import
- `getLegacyMigrationStatus()` - Check status

## Field Mapping Reference

```
Legacy Field          → Current Field      Default
─────────────────────────────────────────────────
logId / id           → logId              docId
accountId            → accountId          Extracted
eventAt              → eventAt            now
createdAt            → createdAt          now
updatedAt            → updatedAt          now
eventType            → eventType          activity
duration             → duration           0
unit                 → unit               minutes
note                 → note               null
reasons              → reasons            null
moodRating           → moodRating         null
physicalRating       → physicalRating     null
latitude             → latitude           null
longitude            → longitude          null
deviceId             → deviceId           null
appVersion           → appVersion         null
```

## Common Patterns

### UI: Migration Dialog
```dart
if (await syncService.hasLegacyData(accountId)) {
  // Show migration prompt to user
  final imported = await syncService.importLegacyDataForAccount(
    accountId: accountId,
  );
  // Show success message
}
```

### Background Sync
```dart
// Pull from both current and legacy tables
final result = await syncService.pullRecordsForAccountIncludingLegacy(
  accountId: accountId,
);
print('Status: ${result.message}');
```

### Provider Pattern
```dart
class LogsProvider extends ChangeNotifier {
  Future<void> syncLogs(String accountId) async {
    final result = await _syncService
        .pullRecordsForAccountIncludingLegacy(
          accountId: accountId,
        );
    notifyListeners();
  }
}
```

## Error Handling

```dart
try {
  await syncService.importLegacyDataForAccount(
    accountId: accountId,
  );
} on SocketException {
  print('Network error - offline?');
} catch (e) {
  print('Migration failed: $e');
}
```

## Performance Tips

1. **Batch Operations**: Import large datasets in batches
2. **Query Limits**: Use `limit` parameter to control size
3. **Date Filtering**: Use `since` parameter for incremental syncs
4. **Streaming**: Use `watch()` for real-time instead of polling

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No legacy data found | Verify collection names in Firestore |
| Slow queries | Add `limit` and `since` parameters |
| Missing fields | Check legacy field names match expected |
| Duplicate records | Deduplication works automatically by logId |
| Permission errors | Verify Firestore rules allow access |

## Files Modified

- `lib/services/legacy_data_adapter.dart` - NEW
- `lib/services/sync_service.dart` - UPDATED
- `lib/services/log_record_service.dart` - UPDATED
- `LEGACY_DATA_SUPPORT.md` - NEW (comprehensive guide)

## See Also

- [Full Documentation](./LEGACY_DATA_SUPPORT.md)
- [LogRecord Model](./lib/models/log_record.dart)
- [SyncService](./lib/services/sync_service.dart)
