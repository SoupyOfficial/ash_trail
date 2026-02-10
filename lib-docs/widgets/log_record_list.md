# log_record_list

> **Source:** `lib/widgets/log_record_list.dart`

## Purpose
Displays a scrollable list of log records as Cards with event icons, durations, notes, sync status, and relative timestamps. Supports date filtering, deleted record inclusion, and tapping to view full details in a dialog with delete capability.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `package:intl/intl.dart` — DateFormat
- `../models/log_record.dart` — LogRecord model
- `../models/enums.dart` — EventType, Unit, SyncState
- `../providers/log_record_provider.dart` — activeAccountIdProvider, logRecordsProvider, logRecordServiceProvider, LogRecordsParams

## Pseudo-Code

### Class: LogRecordList (ConsumerWidget)

**Constructor Parameters:**
- `startDate: DateTime?` — optional filter start
- `endDate: DateTime?` — optional filter end
- `includeDeleted: bool` — default `false`

#### Method: build(context, ref) → Widget
```
WATCH activeAccountIdProvider
IF accountId null → Center("No active account")

CREATE LogRecordsParams(accountId, startDate, endDate, includeDeleted)
WATCH logRecordsProvider(params)

RETURN recordsStream.when:
  data(records):
    IF empty → Center("No log entries yet")
    ELSE → ListView.builder:
      FOR each record → LogRecordTile(record)
  loading → Center(CircularProgressIndicator)
  error → Center("Error: $error")
```

---

### Class: LogRecordTile (ConsumerWidget)

**Constructor Parameters:**
- `record: LogRecord`

#### Method: build(context, ref) → Widget
```
RETURN Card(margin: h8 v4) → ListTile:
  leading: _buildEventIcon() — CircleAvatar with type-specific icon/color
  title: Row:
    ├─ Expanded: formatted event type name
    └─ IF hasLocation → small location_on icon
  subtitle: Column:
    ├─ Relative time (e.g. "5m ago", "2d ago")
    ├─ IF duration > 0 → "{value} {unit}" (bold)
    └─ IF note exists → note text (2-line ellipsis)
  trailing: _buildSyncStatusIcon()
  onTap: _showRecordDetails(context, ref)
```

#### Method: _buildEventIcon() → CircleAvatar
```
SWITCH record.eventType:
  inhale      → air icon, blue
  sessionStart → play_circle, green
  sessionEnd  → stop_circle, red
  note        → note, orange
  purchase    → shopping_cart, purple
  tolerance   → trending_up, amber
  symptomRelief → healing, teal
  default     → circle, grey
```

#### Method: _buildSyncStatusIcon() → Icon
```
pending  → sync icon, orange
syncing  → small CircularProgressIndicator
synced   → cloud_done, green
error    → error, red
conflict → warning, amber
```

#### Method: _showRecordDetails(context, ref)
```
SHOW AlertDialog:
  title: formatted event type
  content: detail rows:
    Time, Duration, Note, Mood, Physical, Reasons,
    Location (with "View on Map" button),
    Status (syncState), Created, Updated
  actions:
    ├─ TextButton("Close")
    └─ IF not deleted: TextButton("Delete", red) → delete + SnackBar
```

#### Helpers:
- `_formatEventType` — camelCase to Title Case
- `_formatEventTime` — relative time or full date
- `_formatUnit` — short unit labels (s, min, hits, mg, g, ml)
- `_formatDuration` — decimal for time units, integer for counts
- `_buildDetailRow` — label+value pair
