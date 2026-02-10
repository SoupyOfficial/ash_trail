# backdate_dialog

> **Source:** `lib/widgets/backdate_dialog.dart`

## Purpose
Modal dialog for creating a backdated log entry. Lets users pick a past date/time (with quick-select presets), choose event type, set duration/unit, enter notes, adjust mood/physical ratings, and optionally capture GPS location. Returns the created `LogRecord` on success with undo support.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `package:intl/intl.dart` — DateFormat for display
- `../models/enums.dart` — EventType, Unit enums
- `../services/log_record_service.dart` — LogRecordService for creating records
- `../services/validation_service.dart` — ValidationService.clampValue
- `../services/location_service.dart` — LocationService for GPS capture
- `../providers/account_provider.dart` — activeAccountProvider

## Pseudo-Code

### Class: BackdateDialog (ConsumerStatefulWidget)

**Constructor Parameters (all optional defaults):**
- `defaultEventType: EventType?`
- `defaultDuration: double?`
- `defaultUnit: Unit?`

#### State: _BackdateDialogState

**State Variables:**
- `_selectedDateTime: DateTime` — initialized to `DateTime.now()`
- `_eventType: EventType` — from constructor or defaults to `vape`
- `_duration: double` — from constructor or defaults to `1.0`
- `_unit: Unit` — from constructor or defaults to `seconds`
- `_notesController: TextEditingController`
- `_moodRating: double?` — optional 1–10
- `_physicalRating: double?` — optional 1–10
- `_latitude, _longitude: double?` — GPS coordinates
- `_isFetchingLocation: bool`
- `_locationService: LocationService`

#### Method: initState()
```
APPLY defaults from constructor parameters
```

#### Method: dispose()
```
DISPOSE _notesController
```

#### Method: _selectDateTime() → Future<void>
```
SHOW DatePicker (last 30 days to now)
IF date picked AND mounted:
  SHOW TimePicker
  IF time picked:
    SET _selectedDateTime = combined date+time
```

#### Method: _setQuickTime(Duration offset)
```
SET _selectedDateTime = DateTime.now() + offset
(offset is negative, e.g. -10min, -30min, -1h, etc.)
```

#### Method: _createBackdatedLog() → Future<void>
```
READ activeAccount from provider
IF null → SHOW SnackBar "No active account" → RETURN

VALIDATE duration via ValidationService.clampValue

TRY:
  CREATE record via service.backdateLog(accountId, eventType, duration, unit, eventAt, note, lat, lon)
  POP dialog returning record
  SHOW SnackBar confirmation with UNDO action:
    UNDO → service.deleteLogRecord(record)
CATCH:
  SHOW red SnackBar with error message
```

#### Method: build(context) → Widget
```
COMPUTE time difference from now

RETURN Dialog → SingleChildScrollView → Padding(24) → Column:
  ├─ Text("Backdate Log", headlineSmall)
  │
  ├─ Card(primaryContainer) → InkWell(onTap: _selectDateTime):
  │   ├─ Icon(access_time) + formatted date/time text
  │   └─ Relative time label (e.g. "2 hours ago")
  │
  ├─ Quick time buttons (Wrap of ActionChips):
  │   [10 min ago] [30 min ago] [1 hour ago] [2 hours ago] [6 hours ago] [12 hours ago]
  │
  ├─ DropdownButtonFormField<EventType> — event type selector
  │
  ├─ Row:
  │   ├─ TextField (Duration, numeric) — flex 2
  │   └─ DropdownButtonFormField<Unit> — flex 1
  │
  ├─ TextField (Notes, optional, 3 lines)
  │
  ├─ Mood Rating section:
  │   └─ Row: Slider(1–10) + value label + Clear/Not set button
  │
  ├─ Physical Rating section:
  │   └─ Row: Slider(1–10) + value label + Clear/Not set button
  │
  ├─ Location section:
  │   IF coordinates set → display lat/lon with clear button
  │   ELSE → OutlinedButton "Capture Current Location"
  │          (shows spinner while fetching)
  │
  └─ Actions Row:
      ├─ TextButton("CANCEL") → pop
      └─ FilledButton.icon("CREATE LOG") → _createBackdatedLog
```

#### Method: _captureLocation() → Future<void>
```
SET _isFetchingLocation = true
TRY:
  GET position from _locationService.getCurrentLocation()
  IF position != null → SET lat/lon, SHOW success SnackBar
  ELSE → SHOW permission dialog
    IF user grants → requestLocationPermission() → retry _captureLocation()
CATCH → SHOW error SnackBar
FINALLY → _isFetchingLocation = false
```

#### Method: _formatTimeDifference(Duration) → String
```
days > 0 → "X day(s) ago"
hours > 0 → "X hour(s) ago"
minutes > 0 → "X minute(s) ago"
else → "just now"
```
