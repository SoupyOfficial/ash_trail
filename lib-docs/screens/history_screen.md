# history_screen

> **Source:** `lib/screens/history_screen.dart`

## Purpose

Displays the full history of log records for the active account with filtering (event type, date range, text search), grouping (none, day, week, month, event type), and inline edit/delete actions. Implements design doc 9.2.2 for the History View.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `package:intl/intl.dart` — Date formatting
- `../models/log_record.dart` — `LogRecord` model
- `../models/enums.dart` — `EventType`, `SyncState` enums
- `../providers/log_record_provider.dart` — `activeAccountLogRecordsProvider`, `logRecordNotifierProvider`
- `../widgets/edit_log_record_dialog.dart` — `EditLogRecordDialog`
- `../utils/design_constants.dart` — Design tokens: `Spacing`, `Paddings`, `BorderRadii`, `ElevationLevel`, `IconSize`, `ResponsiveSize`
- `../utils/day_boundary.dart` — `DayBoundary` for 6am-based week start grouping

## Pseudo-Code

### Class: HistoryScreen (ConsumerStatefulWidget)

Creates `_HistoryScreenState`.

### Class: _HistoryScreenState (ConsumerState)

#### State

```
_selectedEventType: EventType?    = null
_dateRange:         DateTimeRange? = null
_searchQuery:       String         = ''
_grouping:          HistoryGrouping = HistoryGrouping.day
```

#### Getter: _hasActiveFilters -> bool

```
RETURN _selectedEventType != null || _dateRange != null || _searchQuery.isNotEmpty
```

#### Method: build(context) -> Widget

```
WATCH logRecordsAsync = ref.watch(activeAccountLogRecordsProvider)

RETURN Scaffold:
  appBar = AppBar(title: "History"):
    actions:
      [1] IconButton (filter_list) -> _showFilterDialog()
      [2] PopupMenuButton<HistoryGrouping> (view_agenda):
          items: none, day, week, month, eventType
          onSelected -> SET _grouping

  body = Column:
    [1] Padding: TextField "Search entries..."
        prefixIcon = search
        onChanged -> SET _searchQuery

    [2] IF _hasActiveFilters -> _buildActiveFilters()

    [3] Expanded: RefreshIndicator:
        onRefresh -> invalidate provider, delay 500ms
        child = logRecordsAsync.when:
          data(records):
            filtered = _applyFilters(records)
            IF filtered.isEmpty -> _buildEmptyState()
            ELSE -> _buildGroupedList(filtered)
          loading -> CircularProgressIndicator
          error   -> "Error: $error"
```

#### Method: _applyFilters(records) -> List<LogRecord>

```
START with all records
IF _selectedEventType != null:
  FILTER by eventType == _selectedEventType
IF _dateRange != null:
  FILTER by eventAt within [start, end+1day)
IF _searchQuery.isNotEmpty:
  query = _searchQuery.toLowerCase()
  FILTER by note.contains(query) OR eventType.name.contains(query)
RETURN filtered list
```

#### Method: _buildActiveFilters() -> Widget

```
Wrap of Chips:
  IF _selectedEventType -> Chip with name, onDeleted clears it
  IF _dateRange         -> Chip with formatted range, onDeleted clears it
  IF _searchQuery       -> Chip with quoted query, onDeleted clears it
```

#### Method: _buildEmptyState(context) -> Widget

```
Center Column:
  Icon: history (large, faded)
  Text: "No matching entries" or "No entries yet"
  IF _hasActiveFilters:
    "Try adjusting your filters"
    FilledButton.icon "Clear filters" -> _clearFilters()
```

#### Method: _buildGroupedList(context, records) -> Widget

```
SWITCH _grouping:
  none      -> _buildFlatList(records)
  day       -> _buildDayGroupedList(records)
  week      -> _buildWeekGroupedList(records)
  month     -> _buildMonthGroupedList(records)
  eventType -> _buildEventTypeGroupedList(records)
```

#### Method: _buildFlatList(records) -> Widget

```
ListView.builder (padding 16):
  FOR EACH record -> _buildRecordTile(record)
```

#### Methods: _buildDayGroupedList / _buildWeekGroupedList / _buildMonthGroupedList / _buildEventTypeGroupedList

```
GROUP records by respective key (day/week/month/eventType)
SORT groups descending by key (newest first)

ListView.builder (responsive padding):
  FOR EACH group:
    _buildGroupHeader(formatted title)
    FOR EACH record IN group:
      _buildRecordTile(record) with bottom spacing
    inter-group spacing if not last
```

#### Method: _buildGroupHeader(title) -> Widget

```
Text(title, titleMedium bold, primary color, with vertical padding)
```

#### Method: _buildRecordTile(context, record) -> Widget

```
Card (margin bottom 8):
  ListTile:
    leading  = _getEventIcon(record.eventType)
    title    = eventType.name.toUpperCase() (bold)
    subtitle = Column:
      formatted date (yMMMd + jm)
      IF note exists -> note (1 line, ellipsis)
    trailing = Row:
      _buildSyncIndicator(record.syncState)
      IconButton edit   -> _showEditDialog(record)
      IconButton delete (red) -> _confirmDeleteLogRecord(record)
    isThreeLine = true if note exists
    onTap -> _showEditDialog(record)
```

#### Method: _getEventIcon(EventType) -> Widget

```
SWITCH type:
  vape          -> cloud (indigo)
  inhale        -> air (blue)
  sessionStart  -> play_circle (green)
  sessionEnd    -> stop_circle (red)
  note          -> note (orange)
  tolerance     -> trending_up (purple)
  symptomRelief -> healing (teal)
  purchase      -> shopping_cart (amber)
  custom        -> star (grey)
RETURN CircleAvatar with colored background + icon
```

#### Method: _buildSyncIndicator(SyncState) -> Widget

```
SWITCH state:
  synced   -> cloud_done (green)
  pending  -> cloud_upload (orange)
  syncing  -> sync (blue)
  error    -> cloud_off (red)
  conflict -> warning (amber)
RETURN Icon (small)
```

#### Grouping Helpers

```
_groupByDay(records):   GROUP by DateTime(year, month, day), SORT descending
_groupByWeek(records):  GROUP by DayBoundary.getWeekStart(eventAt), SORT descending
_groupByMonth(records): GROUP by DateTime(year, month), SORT descending
_groupByEventType(records): GROUP by eventType
```

#### Method: _clearFilters() -> void

```
SET _selectedEventType = null, _dateRange = null, _searchQuery = ''
```

#### Method: _showFilterDialog() -> void

```
SHOW ModalBottomSheet: _FilterBottomSheet(
  selectedEventType, dateRange,
  onEventTypeChanged, onDateRangeChanged, onClear
)
```

#### Method: _showEditDialog(context, record) -> void

```
SHOW Dialog: EditLogRecordDialog(record)
THEN -> ref.invalidate(activeAccountLogRecordsProvider)
```

#### Method: _confirmDeleteLogRecord(context, record) -> Future<void>

```
SHOW AlertDialog: "Delete Log Entry"
  content: "Are you sure? {eventType} from {date}"
  actions: Cancel, Delete (red)
IF confirmed AND mounted -> _deleteLogRecord(record)
```

#### Method: _deleteLogRecord(record) -> Future<void>

```
TRY:
  AWAIT ref.read(logRecordNotifierProvider.notifier).deleteLogRecord(record)
  ref.invalidate(activeAccountLogRecordsProvider)
  SHOW SnackBar "Entry deleted" with UNDO action:
    onPressed -> restoreLogRecord(record), invalidate
CATCH:
  SHOW SnackBar error (red)
```

### Enum: HistoryGrouping

```
none, day, week, month, eventType
```

### Class: _FilterBottomSheet (StatelessWidget)

```
CONSTRUCTOR(selectedEventType, dateRange, onEventTypeChanged, onDateRangeChanged, onClear)

build(context):
  Container (padding 16):
    Column:
      Title: "Filter History"

      "Event Type" label
      Wrap of FilterChips for each EventType:
        selected = (selectedEventType == type)
        onSelected -> onEventTypeChanged(type or null)

      "Date Range" label
      OutlinedButton.icon -> showDateRangePicker(2020..now)
        onResult -> onDateRangeChanged(range)

      Row:
        OutlinedButton "Clear All" -> onClear()
        FilledButton "Done" -> pop
```
