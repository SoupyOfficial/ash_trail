# log_entry_widgets

> **Source:** `lib/widgets/log_entry_widgets.dart`

## Purpose
Contains two widgets: `CreateLogEntryDialog` — a full-featured AlertDialog for creating new log entries with event type, duration, time, notes, reasons, mood/physical ratings; and `QuickLogButton` — a one-tap preset-based log button. Both support location capture.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `../logging/app_logger.dart` — AppLogger
- `../models/enums.dart` — EventType, Unit, LogReason
- `../providers/log_record_provider.dart` — logRecordServiceProvider, activeAccountIdProvider
- `../services/location_service.dart` — LocationService
- `reason_chips_grid.dart` — ReasonChipsGrid widget

## Pseudo-Code

### Class: CreateLogEntryDialog (ConsumerStatefulWidget)

#### State: _CreateLogEntryDialogState

**State Variables:**
- `_formKey: GlobalKey<FormState>`
- `_selectedEventType: EventType` — default `vape`
- `_selectedUnit: Unit` — default `seconds`
- `_duration: double?`, `_note: String?`
- `_eventTime: DateTime` — default `DateTime.now()`
- `_moodRating, _physicalRating: double?`
- `_reasons: List<LogReason>?`
- `_isSubmitting: bool`

#### Method: build(context) → Widget
```
RETURN AlertDialog:
  title: "Log Event"
  content: SingleChildScrollView → Form:
    ├─ DropdownButtonFormField<EventType>
    │   onChanged: auto-select unit (vape→seconds, inhale→hits, etc.)
    │
    ├─ Duration Row:
    │   ├─ TextFormField (numeric with decimal)
    │   └─ DropdownButtonFormField<Unit>
    │
    ├─ Event Time ListTile:
    │   subtitle: formatted date/time
    │   trailing: calendar icon
    │   onTap → DatePicker → TimePicker
    │
    ├─ Notes TextFormField (optional, 3 lines)
    │
    ├─ Reasons section:
    │   ├─ Header row with "Clear" button
    │   └─ ReasonChipsGrid(selected, showIcons, onToggle: add/remove)
    │
    ├─ Mood Rating:
    │   Header + value text
    │   Row: sad icon → Slider(1–10) → happy icon
    │   Clear button if set
    │
    └─ Physical Rating:
        Header + value text
        Row: fitness icon → Slider(1–10) → yoga icon
        Clear button if set

  actions:
    ├─ TextButton("Cancel") → pop
    └─ FilledButton("Log") → _submitLog
        (shows spinner while submitting)
```

#### Method: _submitLog() → Future<void>
```
VALIDATE form
SET _isSubmitting = true

TRY:
  READ logRecordService and activeAccountId from providers
  IF accountId null → throw "No active account"
  CALL service.createLogRecord(all fields)
  POP dialog returning true
  SHOW SnackBar "Event logged successfully"
CATCH → SHOW SnackBar with error
FINALLY → _isSubmitting = false
```

#### Helper: _formatEnumName(String) → String
```
Convert camelCase to "Title Case" with spaces
```

---

### Class: QuickLogButton (ConsumerWidget)

**Constructor Parameters:**
- `eventType: EventType`
- `label: String`
- `icon: IconData`
- `defaultUnit: Unit?`
- `defaultDuration: double?`

#### Method: build(context, ref) → Widget
```
RETURN ElevatedButton.icon:
  icon: Icon(icon)
  label: Text(label)
  onPressed:
    READ logRecordService and activeAccountId
    IF accountId null → SHOW SnackBar "No active account" → RETURN

    TRY:
      CAPTURE location via LocationService
      CREATE log record with defaults + location
      SHOW SnackBar "{label} logged" (with location note if captured)
    CATCH → SHOW SnackBar with error
```
