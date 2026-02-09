# analytics_screen

> **Source:** `lib/screens/analytics_screen.dart`

## Purpose

Displays analytics and statistics for the active account's log records. Shows summary stat cards (total, synced, pending, total duration), interactive charts via `AnalyticsChartsWidget`, and a scrollable list of the 10 most recent entries with edit/delete actions.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `package:intl/intl.dart` — Date formatting (DateFormat)
- `../providers/log_record_provider.dart` — `logRecordStatsProvider`, `LogRecordsParams`, `activeAccountLogRecordsProvider`, `logRecordNotifierProvider`
- `../providers/account_provider.dart` — `activeAccountProvider`
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `SyncState` enum
- `../widgets/edit_log_record_dialog.dart` — `EditLogRecordDialog` for editing records
- `../widgets/analytics_charts.dart` — `AnalyticsChartsWidget` for chart rendering
- `../utils/design_constants.dart` — Design tokens: `Spacing`, `Paddings`, `BorderRadii`, `ElevationLevel`, `IconSize`, `ResponsiveSize`
- `../utils/responsive_layout.dart` — `ResponsiveGrid`, `ResponsiveSize`

## Pseudo-Code

### Class: AnalyticsScreen (ConsumerStatefulWidget)

Creates `_AnalyticsScreenState`.

### Class: _AnalyticsScreenState (ConsumerState)

#### Method: build(context) -> Widget

```
WATCH logRecordsAsync  = ref.watch(activeAccountLogRecordsProvider)
WATCH statisticsAsync  = ref.watch(logRecordStatsProvider(LogRecordsParams(accountId: null)))

RETURN Scaffold:
  appBar = AppBar(title: "Analytics")
  body = RefreshIndicator:
    onRefresh:
      ref.invalidate(activeAccountLogRecordsProvider)
      ref.invalidate(logRecordStatsProvider)
      AWAIT 500ms delay

    child = logRecordsAsync.when:
      data(records):
        statisticsAsync.when:
          data(stats) -> _buildAnalyticsView(records, stats)
          loading     -> CircularProgressIndicator
          error       -> "Error: $error"
      loading -> CircularProgressIndicator
      error   -> "Error: $error"
```

#### Method: _buildAnalyticsView(context, records, stats) -> Widget

```
IF records.isEmpty -> RETURN _buildEmptyView()

WATCH activeAccountAsync = ref.watch(activeAccountProvider)

RETURN SingleChildScrollView (responsive padding):
  Column:
    [1] _buildSummaryStats(records)
    [2] "Charts" section title
        activeAccountAsync.when:
          data(account):
            IF account == null -> SizedBox.shrink
            ELSE -> SizedBox(height: 600):
              Card containing AnalyticsChartsWidget(records, accountId)
          loading -> CircularProgressIndicator
          error   -> error text

    [3] "Recent Entries" section title
        FOR EACH record IN records.take(10):
          Card with ListTile:
            leading  = CircleAvatar with _getSyncStateIcon(record.syncState)
            title    = formatted date "MMM dd, yyyy HH:mm"
            subtitle = Column:
              IF note exists -> note text (1 line, ellipsis)
              "{eventType} • {syncState}" label
            trailing = IF duration > 0:
              Container badge: "{duration} {unit}"
            onTap -> _showLogRecordActions(record)
```

#### Method: _buildSummaryStats(context, records) -> Widget

```
COMPUTE syncedCount  = records WHERE syncState == synced
COMPUTE pendingCount = records WHERE syncState == pending
COMPUTE totalDuration = SUM of all record.duration

RETURN ResponsiveGrid (2 cols mobile, 4 tablet/desktop):
  [1] _buildStatCard("Total",    count, list_alt icon)
  [2] _buildStatCard("Synced",   count, cloud_done, green)
  [3] _buildStatCard("Pending",  count, cloud_upload, orange)
  [4] _buildStatCard("Total Duration", formatted, timer icon)
```

#### Method: _buildStatCard(context, label, value, icon, [color]) -> Widget

```
RETURN Card:
  Column(center):
    Icon(icon, size md, color)
    Text(value, titleLarge bold)
    Text(label, labelSmall)
```

#### Method: _formatDuration(seconds) -> String

```
CONVERT seconds to Duration
IF hours > 0   -> "{h}h {m}m"
ELSE IF min > 0 -> "{m}m {s}s"
ELSE            -> "{s}s"
```

#### Method: _buildEmptyView(context) -> Widget

```
RETURN Center:
  Column:
    Icon: analytics_outlined (large, faded)
    "No data yet" headline
    "Start logging to see your analytics"
```

#### Method: _getSyncStateIcon(SyncState) -> Widget

```
SWITCH state:
  synced   -> cloud_done (green)
  pending  -> cloud_upload (orange)
  syncing  -> cloud_sync (blue)
  error    -> error (red)
  conflict -> warning (amber)
RETURN Icon
```

#### Method: _showLogRecordActions(context, record) -> void

```
SHOW ModalBottomSheet:
  ListTile "Edit"   -> pop sheet, _showEditDialog(record)
  IF !record.isDeleted:
    ListTile "Delete" (red) -> pop sheet, _confirmDeleteLogRecord(record)
```

#### Method: _showEditDialog(context, record) -> Future<void>

```
SHOW Dialog: EditLogRecordDialog(record)
IF result == true AND mounted:
  ref.read(logRecordNotifierProvider.notifier).reset()
```

#### Method: _confirmDeleteLogRecord(context, record) -> Future<void>

```
SHOW AlertDialog: "Delete Log Entry"
  content = "Are you sure? {eventType} from {date}"
  actions: Cancel, Delete (red)

IF confirmed AND mounted:
  TRY:
    AWAIT ref.read(logRecordNotifierProvider.notifier).deleteLogRecord(record)
    SHOW SnackBar "Entry deleted" with UNDO action:
      onPressed -> restoreLogRecord(record)
  CATCH:
    SHOW SnackBar error
```