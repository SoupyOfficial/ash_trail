# AshTrail Logging System - Quick Start Guide

## 🚀 Quick Integration

### 1. Basic Setup (Already Done!)

All models, services, and providers are ready to use. The Isar schemas have been generated.

### 2. Initialize in Main App

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/isar_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar
  await IsarService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Add Quick Log Button to Home Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/log_entry_widgets.dart';
import '../widgets/sync_status_widget.dart';
import '../models/enums.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AshTrail'),
        actions: const [
          SyncStatusIndicator(), // Shows sync status
        ],
      ),
      body: Column(
        children: [
          // Sync status card
          const SyncStatusWidget(),
          
          // Quick log buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                QuickLogButton(
                  eventType: EventType.inhale,
                  label: 'Log Hit',
                  icon: Icons.air,
                  defaultUnit: Unit.hits,
                  defaultValue: 1.0,
                ),
                QuickLogButton(
                  eventType: EventType.sessionStart,
                  label: 'Start Session',
                  icon: Icons.play_circle,
                ),
                QuickLogButton(
                  eventType: EventType.note,
                  label: 'Add Note',
                  icon: Icons.note,
                ),
              ],
            ),
          ),
          
          // Recent logs list
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
            builder: (context) => const CreateLogEntryDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 4. Set Active Account

```dart
// In your account selection logic
ref.read(activeAccountIdProvider.notifier).state = selectedAccountId;
```

### 5. Display Analytics

```dart
import '../providers/analytics_provider.dart';
import '../models/range_query_spec.dart';

class AnalyticsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = ref.watch(activeAccountIdProvider);
    
    if (accountId == null) {
      return const Center(child: Text('No active account'));
    }
    
    // Set range to last 7 days
    ref.read(rangeQuerySpecProvider.notifier).state = 
      RangeQuerySpec.week(groupBy: GroupBy.day);
    
    final timeSeriesAsync = ref.watch(timeSeriesProvider(accountId));
    
    return timeSeriesAsync.when(
      data: (timeSeries) {
        // Use your charting library here (fl_chart)
        return Column(
          children: [
            Text('Total Events: ${timeSeries.fold(0, (sum, point) => sum + point.count)}'),
            Text('Total Value: ${timeSeries.fold(0.0, (sum, point) => sum + point.value)}'),
            // Add your chart widget here
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 📖 Common Operations

### Create a Log Entry

```dart
// Manual creation
final service = LogRecordService();
await service.createLogRecord(
  accountId: accountId,
  eventType: EventType.inhale,
  value: 1.0,
  unit: Unit.hits,
  note: 'Feeling good',
  tags: ['morning', 'sativa'],
);

// Or use the dialog
showDialog(
  context: context,
  builder: (context) => const CreateLogEntryDialog(),
);
```

### Query Log Records

```dart
// Watch in real-time
final params = LogRecordsParams(
  accountId: accountId,
  startDate: DateTime.now().subtract(Duration(days: 7)),
);
final recordsStream = ref.watch(logRecordsProvider(params));

// One-time fetch
final service = LogRecordService();
final records = await service.getLogRecords(
  accountId: accountId,
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

### Force Sync

```dart
final syncService = ref.read(syncServiceProvider);
final result = await syncService.forceSyncNow();
print('Synced: ${result.success}, Failed: ${result.failed}');
```

### Get Analytics

```dart
final service = AnalyticsService();

// Time series for charts
final spec = RangeQuerySpec.week(groupBy: GroupBy.day);
final timeSeries = await service.getTimeSeries(
  accountId: accountId,
  spec: spec,
);

// Event type breakdown
final breakdown = await service.getEventTypeBreakdown(
  accountId: accountId,
  startDate: startDate,
  endDate: endDate,
);

// Summary stats
final summary = await service.getPeriodSummary(
  accountId: accountId,
  startDate: startDate,
  endDate: endDate,
);
print('Average: ${summary.averageValue}');
print('Total: ${summary.totalValue}');
```

### Update a Log Record

```dart
final service = LogRecordService();
await service.updateLogRecord(
  record,
  note: 'Updated note',
  value: 2.0,
  tags: ['updated', 'tag'],
);
```

### Delete a Log Record (Soft Delete)

```dart
final service = LogRecordService();
await service.deleteLogRecord(record);
// Record is marked isDeleted=true but not removed
```

## 🎨 Available Widgets

### `CreateLogEntryDialog`
Full-featured dialog for creating new log entries with all fields.

### `QuickLogButton`
Preset button for fast logging with predefined values.

### `LogRecordList`
Displays a list of log records with real-time updates.

### `SyncStatusWidget`
Full card showing sync status with manual sync button.

### `SyncStatusIndicator`
Compact indicator for app bars showing current sync state.

## 🔧 Available Providers

### Account Management
- `activeAccountIdProvider` - Current active account ID
- `activeProfileIdProvider` - Current active profile ID

### Log Records
- `logRecordsProvider(params)` - Stream of log records
- `getLogRecordsProvider(params)` - One-time fetch
- `logRecordByIdProvider(logId)` - Get specific record
- `logRecordStatsProvider(params)` - Statistics

### Sync
- `syncStatusProvider(accountId)` - Current sync status
- `isOnlineProvider` - Check if device is online
- `triggerSyncProvider` - Manual sync trigger

### Analytics
- `rangeQuerySpecProvider` - Current query range
- `aggregatedDataProvider(accountId)` - Aggregated data
- `timeSeriesProvider(accountId)` - Time series for charts
- `eventTypeBreakdownProvider(params)` - Event type stats
- `periodSummaryProvider(params)` - Period summary
- `dailyRollupProvider(params)` - Daily rollup cache

### UI State
- `selectedRangeTypeProvider` - Selected range type
- `selectedGroupByProvider` - Selected grouping
- `customDateRangeProvider` - Custom date range
- `eventTypeFilterProvider` - Event type filter

## 📊 Event Types

- `EventType.inhale` - Single inhale/hit
- `EventType.sessionStart` - Start of session
- `EventType.sessionEnd` - End of session
- `EventType.note` - General note
- `EventType.purchase` - Purchase tracking
- `EventType.tolerance` - Tolerance note
- `EventType.symptomRelief` - Symptom tracking
- `EventType.custom` - Custom event

## 📏 Units

- `Unit.hits` - Number of hits
- `Unit.seconds` - Duration in seconds
- `Unit.minutes` - Duration in minutes
- `Unit.mg` - Milligrams
- `Unit.grams` - Grams
- `Unit.ml` - Milliliters
- `Unit.count` - Generic count
- `Unit.none` - No unit

## 🎯 Range Types

- `RangeType.today` - Today only
- `RangeType.yesterday` - Yesterday
- `RangeType.week` - Last 7 days
- `RangeType.month` - This month
- `RangeType.year` - This year
- `RangeType.ytd` - Year to date
- `RangeType.custom` - Custom range
- `RangeType.all` - All time

## 🔍 Troubleshooting

### No records showing up
1. Check if active account is set: `ref.read(activeAccountIdProvider)`
2. Verify records exist in database
3. Check date range filters

### Sync not working
1. Check internet connection
2. Verify Firestore configuration
3. Check sync status: `ref.watch(syncStatusProvider(accountId))`
4. Look at sync errors in record details

### Analytics showing wrong data
1. Verify date range
2. Check filters applied
3. Invalidate rollup cache if needed
4. Verify account ID is correct

## 📚 More Information

- See [LOGGING_SYSTEM.md](LOGGING_SYSTEM.md) for complete technical documentation
- See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for implementation details
- Check inline code documentation in service files

## 🎉 That's It!

The logging system is ready to use. Start by:
1. Setting an active account
2. Adding the `CreateLogEntryDialog` to your UI
3. Using `LogRecordList` to display logs
4. Adding `SyncStatusWidget` for sync visibility

Happy logging! 🚀
