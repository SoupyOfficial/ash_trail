# edit_log_record_dialog

> **Source:** `lib/widgets/edit_log_record_dialog.dart`

## Purpose
Full-screen dialog for editing an existing log record. Pre-fills all fields from the record, supports date/time editing, duration, notes, mood/physical ratings, reason chips, and location via a map picker. Also provides delete with undo capability. Returns `true` on success for upstream refresh.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `package:intl/intl.dart` — Date formatting
- `../models/enums.dart` — EventType, Unit, LogReason, SyncState enums
- `../models/log_record.dart` — LogRecord model
- `../providers/log_record_provider.dart` — logRecordNotifierProvider, activeAccountLogRecordsProvider
- `../services/validation_service.dart` — ValidationService for input validation
- `location_map_picker.dart` — LocationMapPicker widget
- `reason_chips_grid.dart` — ReasonChipsGrid widget
- `package:google_maps_flutter/google_maps_flutter.dart` — LatLng type

## Pseudo-Code

### Class: EditLogRecordDialog (ConsumerStatefulWidget)

**Constructor Parameters:**
- `record: LogRecord` — the record to edit

#### State: _EditLogRecordDialogState

**State Variables (all pre-filled from record in initState):**
- `_selectedDateTime`, `_eventType`, `_duration`, `_unit`
- `_notesController`, `_moodRating`, `_physicalRating`
- `_reasons: List<LogReason>`
- `_latitude, _longitude` + coordinate text controllers
- `_isSubmitting: bool`

#### Method: initState()
```
PRE-FILL all fields from widget.record:
  _selectedDateTime = record.eventAt
  _eventType = record.eventType
  _duration = record.duration
  _unit = record.unit
  _notesController = TextEditingController(text: record.note)
  _moodRating = record.moodRating
  _physicalRating = record.physicalRating
  _reasons = copy of record.reasons
  _latitude = record.latitude
  _longitude = record.longitude
```

#### Method: _selectDateTime() → Future<void>
```
SHOW DatePicker (last 365 days to now)
IF date picked → SHOW TimePicker
IF time picked → SET _selectedDateTime
```

#### Method: _confirmDelete() → Future<void>
```
SHOW AlertDialog "Delete Log Entry" with record details
IF confirmed → CALL _deleteLog()
```

#### Method: _deleteLog() → Future<void>
```
SET _isSubmitting = true
TRY:
  AWAIT ref.read(logRecordNotifierProvider.notifier).deleteLogRecord(record)
  POP dialog returning true
  SHOW SnackBar "Entry deleted" with UNDO action:
    UNDO → restoreLogRecord(record) + invalidate providers
CATCH → SHOW red SnackBar
FINALLY → _isSubmitting = false
```

#### Method: _updateLog() → Future<void>
```
IF _isSubmitting → RETURN (prevent double-submit)

VALIDATE location pair (both or neither)
VALIDATE mood rating 1–10
VALIDATE physical rating 1–10

SET _isSubmitting = true
TRY:
  CLAMP duration via ValidationService
  AWAIT ref.read(logRecordNotifierProvider.notifier).updateLogRecord(
    record, eventType, eventAt, duration, unit, note, mood, physical, reasons, lat, lon
  )
  POP dialog returning true
  SHOW SnackBar "Log updated successfully"
CATCH → SHOW red SnackBar
FINALLY → _isSubmitting = false
```

#### Method: build(context) → Widget
```
RETURN Dialog → SingleChildScrollView → Padding(24) → Column:
  ├─ Text("Edit Log", headlineSmall)
  │
  ├─ Date/Time Card (primaryContainer) → InkWell → _selectDateTime
  │   └─ Icon(access_time) + formatted date/time
  │
  ├─ Duration Row:
  │   ├─ TextFormField (duration, numeric) — flex 2
  │   └─ Text(unit name) — flex 1
  │
  ├─ TextField (Notes, 3 lines)
  │
  ├─ Mood Rating: Slider(1–10) + value + Clear button
  │
  ├─ Physical Rating: Slider(1–10) + value + Clear button
  │
  ├─ Reasons: ReasonChipsGrid(selected, onToggle, showIcons)
  │
  ├─ Location section:
  │   IF lat/lon set → container with coords + "Edit on Map" + "Clear" buttons
  │   ELSE → FilledButton "Select Location on Map"
  │
  └─ Action Row:
      ├─ TextButton.icon("Delete", red) → _confirmDelete
      ├─ TextButton("Cancel") → pop
      └─ FilledButton("Update") → _updateLog
          (shows spinner while submitting)
```

#### Method: _openMapPicker() → Future<void>
```
PUSH LocationMapPicker(initialLatitude, initialLongitude)
IF result != null → SET lat/lon, update controllers, SHOW "Location updated"
IF result == null → CLEAR lat/lon, SHOW "Location cleared"
```
