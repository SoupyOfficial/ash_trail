# Legacy Data Support Implementation

## Overview

This implementation adds comprehensive support for querying and migrating legacy Firestore data from `JacobLogs` and `AshleyLogs` collections to the current `accounts/{accountId}/logs` structure. The solution maintains backward compatibility while supporting seamless data migration.

## Architecture

### Components

1. **LegacyDataAdapter** (`lib/services/legacy_data_adapter.dart`)
   - Handles querying legacy Firestore collections
   - Converts legacy data formats to current `LogRecord` format
   - Provides deduplication and merging of records
   - Supports real-time watching of legacy collections

2. **SyncService** (`lib/services/sync_service.dart`)
   - Enhanced with multi-table sync capabilities
   - Pulls from both current and legacy tables simultaneously
   - Implements intelligent merging with conflict resolution

3. **LogRecordService** (`lib/services/log_record_service.dart`)
   - Added batch import capabilities for legacy records
   - Provides migration status checking

## Key Features

### 1. Multi-Collection Querying

Query both current and legacy collections simultaneously:

```dart
final syncService = SyncService();

// Pull records from both current and legacy tables
final result = await syncService.pullRecordsForAccountIncludingLegacy(
  accountId: 'user123',
  since: DateTime.now().subtract(Duration(days: 7)),
);

print('Pulled ${result.success} records');
print('${result.message}');
```

### 2. Legacy Data Detection

Check if an account has legacy data to migrate:

```dart
final hasLegacy = await syncService.hasLegacyData('user123');
final legacyCount = await syncService.getLegacyRecordCount('user123');

if (hasLegacy) {
  print('Found $legacyCount legacy records to migrate');
}
```

### 3. Automatic Data Import

Import all legacy data for an account:

```dart
try {
  final imported = await syncService.importLegacyDataForAccount(
    accountId: 'user123',
  );
  print('Successfully imported $imported legacy records');
} catch (e) {
  print('Error importing legacy data: $e');
}
```

### 4. Real-Time Watching

Watch both current and legacy logs in real-time:

```dart
syncService.watchAccountLogsIncludingLegacy('user123').listen((record) {
  print('New/Updated record: ${record.logId}');
});
```

### 5. Deduplication

Records are automatically deduplicated by `logId`. When the same record exists in both current and legacy collections, the version with the later `updatedAt` timestamp is used.

## Data Format Conversion

The `LegacyDataAdapter` handles conversion of various legacy field formats:

### Field Mapping

| Legacy Field | Current Field | Default | Notes |
| ----------- | ------------- | ------- | ----- |
| `logId` or `id` | `logId` | Generated from docId | Stable identifier |
| `accountId` | `accountId` | Extracted from collection name | Required |
| `eventAt` | `eventAt` | Current time | Handles multiple date formats |
| `createdAt` | `createdAt` | Current time | Parsed from various formats |
| `updatedAt` | `updatedAt` | Current time | Parsed from various formats |
| `eventType` | `eventType` | `EventType.activity` | Auto-detected |
| `duration` | `duration` | 0 | Converted to double |
| `unit` | `unit` | `Unit.minutes` | Auto-detected |
| `note` | `note` | null | Optional |
| `reasons` | `reasons` | null | Parsed to enum list |
| `moodRating` | `moodRating` | null | Range 1-10 |
| `physicalRating` | `physicalRating` | null | Range 1-10 |
| `latitude` | `latitude` | null | Optional |
| `longitude` | `longitude` | null | Optional |
| `deviceId` | `deviceId` | null | Optional |
| `appVersion` | `appVersion` | null | Optional |

### Account ID Extraction

Legacy collection names are parsed to extract account IDs:
- `JacobLogs` → `"jacob"`
- `AshleyLogs` → `"ashley"`
- Custom collections follow the pattern: Remove `"Logs"` suffix and convert to lowercase

## Conflict Resolution

When the same record appears in multiple sources:

1. **By logId**: Records with identical `logId` are deduplicated
2. **By updatedAt**: The version with the latest `updatedAt` timestamp wins
3. **Merge Strategy**: Combines metadata from all sources, preferring newer data

## Error Handling

The implementation is robust against various error conditions:

- **Missing fields**: Defaults are applied for required fields
- **Invalid dates**: Falls back to current time
- **Enum parsing**: Defaults to safe values (e.g., `EventType.activity`)
- **Network errors**: Gracefully continues processing other records
- **Malformed data**: Skips invalid records and logs errors

Example error handling:

```dart
try {
  final records = await adapter.queryLegacyCollection(
    collectionName: 'JacobLogs',
  );
  print('Retrieved ${records.length} records');
} catch (e) {
  print('Error querying legacy data: $e');
  // Fall back to current data only
}
```

## Performance Considerations

### Batch Processing

For large data migrations, use batch operations:

```dart
final logRecordService = LogRecordService();

// Get all legacy records
final legacyRecords = await adapter.queryAllLegacyCollections(
  limit: 500, // Larger batch for bulk import
);

// Import in batch
final imported = await logRecordService.importLegacyRecordsBatch(
  legacyRecords,
);
```

### Query Optimization

- **Limit results**: Use the `limit` parameter to control query size
- **Date filtering**: Use `since` parameter to only fetch recent changes
- **Lazy loading**: Use streams for real-time updates instead of bulk queries

## Integration Examples

### User Interface - Migration Dialog

```dart
class LegacyDataMigrationDialog extends StatefulWidget {
  final String accountId;
  
  @override
  State<LegacyDataMigrationDialog> createState() =>
      _LegacyDataMigrationDialogState();
}

class _LegacyDataMigrationDialogState extends State<LegacyDataMigrationDialog> {
  final syncService = SyncService();
  bool _hasLegacyData = false;
  int _legacyCount = 0;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _checkLegacyData();
  }

  Future<void> _checkLegacyData() async {
    final hasLegacy = await syncService.hasLegacyData(widget.accountId);
    final count = await syncService.getLegacyRecordCount(widget.accountId);
    
    setState(() {
      _hasLegacyData = hasLegacy;
      _legacyCount = count;
    });
  }

  Future<void> _importLegacyData() async {
    setState(() => _importing = true);
    
    try {
      await syncService.importLegacyDataForAccount(
        accountId: widget.accountId,
      );
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully migrated $_legacyCount records'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error migrating legacy data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLegacyData) {
      return AlertDialog(
        title: Text('No Legacy Data'),
        content: Text('No legacy data found to migrate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Migrate Legacy Data'),
      content: Text(
        'Found $_legacyCount legacy records. '
        'Would you like to import them now?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _importing ? null : _importLegacyData,
          child: _importing
              ? CircularProgressIndicator()
              : Text('Import'),
        ),
      ],
    );
  }
}
```

### Provider Integration

```dart
class LegacyDataProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  
  bool _hasLegacyData = false;
  int _legacyRecordCount = 0;
  bool _isImporting = false;
  String? _error;

  bool get hasLegacyData => _hasLegacyData;
  int get legacyRecordCount => _legacyRecordCount;
  bool get isImporting => _isImporting;
  String? get error => _error;

  Future<void> checkLegacyData(String accountId) async {
    try {
      _hasLegacyData = await _syncService.hasLegacyData(accountId);
      _legacyRecordCount = 
          await _syncService.getLegacyRecordCount(accountId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> importLegacyData(String accountId) async {
    _isImporting = true;
    notifyListeners();
    
    try {
      await _syncService.importLegacyDataForAccount(
        accountId: accountId,
      );
      _hasLegacyData = false;
      _legacyRecordCount = 0;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }
}
```

## Adding More Legacy Collections

To support additional legacy collections, update the `legacyCollections` list in `LegacyDataAdapter`:

```dart
class LegacyDataAdapter {
  static const List<String> legacyCollections = [
    'JacobLogs',
    'AshleyLogs',
    'OldLogs',           // Add new collection names here
    'LegacyActivityLog',
  ];
  // ... rest of implementation
}
```

## Testing

Example test for legacy data import:

```dart
test('Import legacy records with proper conversion', () async {
  final adapter = LegacyDataAdapter();
  
  // Query legacy collection
  final records = await adapter.queryLegacyCollection(
    collectionName: 'JacobLogs',
    limit: 10,
  );
  
  expect(records, isNotEmpty);
  
  // Verify conversion
  final first = records.first;
  expect(first.accountId, isNotEmpty);
  expect(first.eventAt, isNotNull);
  expect(first.eventType, isNotNull);
});

test('Deduplicate records from multiple sources', () async {
  final adapter = LegacyDataAdapter();
  
  // Get records from all legacy collections
  final allRecords = await adapter.queryAllLegacyCollections();
  
  // Create a set of logIds to check for duplicates
  final logIds = <String>{};
  for (final record in allRecords) {
    expect(
      logIds.add(record.logId),
      isTrue,
      reason: 'Duplicate logId found: ${record.logId}',
    );
  }
});
```

## Troubleshooting

### No Legacy Data Found

- Verify the collection names exist in Firestore
- Check that the account has write permission to those collections
- Ensure the `accountId` is correctly matching the collection structure

### Missing Fields in Converted Records

- Check the legacy document structure matches expected field names
- Review error logs in the console for conversion errors
- Verify default values are appropriate for your use case

### Slow Queries

- Use the `limit` parameter to reduce query size
- Add date filters with the `since` parameter
- Consider implementing pagination for very large datasets

### Conflicts During Merge

- Check the `updatedAt` timestamps are correct
- Verify conflict resolution strategy matches your needs
- Consider implementing custom merge logic if needed

## Future Enhancements

Potential improvements for future versions:

1. **Selective Migration**: Allow users to choose which legacy collections to import
2. **Progress Tracking**: Real-time progress updates during bulk imports
3. **Data Validation**: Comprehensive validation before and after import
4. **Rollback Support**: Ability to rollback failed migrations
5. **Custom Mappings**: Allow applications to define custom field mappings
6. **Archive Support**: Option to archive legacy data after successful migration
7. **Audit Logging**: Track all migration operations for compliance

## See Also

- [SyncService Documentation](./SYNC_SERVICE.md)
- [LogRecord Model](../models/log_record.dart)
- [Firestore Integration Guide](./FIRESTORE_SETUP.md)
