# time_range_picker

> **Source:** `lib/widgets/charts/time_range_picker.dart`

## Purpose
Custom dialog for selecting time ranges in analytics. Offers preset quick-select options (Today, Yesterday, Last 7/14/30/90 Days, This Week, This/Last Month, All Time) and manual start/end date pickers. Uses 6am day boundaries via `DayBoundary` for more natural grouping of late-night activity. Includes a convenience `showTimeRangePicker()` function.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:intl/intl.dart` — DateFormat
- `../../utils/day_boundary.dart` — DayBoundary (getTodayStart, getYesterdayStart, getDayStartDaysAgo, getThisWeekStart, getTodayEnd, dayStartHour)

## Pseudo-Code

### Enum: TimeRangePreset
```
today("Today"), yesterday("Yesterday"), last7Days("Last 7 Days"),
last14Days("Last 14 Days"), last30Days("Last 30 Days"),
last90Days("Last 90 Days"), thisWeek("This Week"),
thisMonth("This Month"), lastMonth("Last Month"), allTime("All Time")
```

### Class: TimeRangePicker (StatefulWidget)

**Constructor Parameters:**
- `initialStart: DateTime?`
- `initialEnd: DateTime?`
- `onRangeSelected: ValueChanged<DateTimeRange>` — callback with result

#### State: _TimeRangePickerState

**State Variables:**
- `_startDate: DateTime`
- `_endDate: DateTime`
- `_selectedPreset: TimeRangePreset?`

#### Method: initState()
```
_endDate = initialEnd ?? DateTime.now()
_startDate = initialStart ?? (endDate - 7 days)
```

#### Method: build(context) → Widget
```
RETURN Dialog → ConstrainedBox(maxW: 400, maxH: 500) → Padding(24) → Column:
  ├─ Header Row: "Select Time Range" + close IconButton
  │
  ├─ Expanded → SingleChildScrollView → Column:
  │   ├─ "Quick Select" label
  │   ├─ Wrap of ChoiceChips for each TimeRangePreset
  │   │   onSelected → _applyPreset(preset)
  │   │
  │   ├─ "Custom Range" label
  │   ├─ Row:
  │   │   ├─ _DatePickerField("Start", _startDate, onTap → _selectDate(isStart: true))
  │   │   ├─ Arrow icon
  │   │   └─ _DatePickerField("End", _endDate, onTap → _selectDate(isStart: false))
  │   └─ _buildRangeSummary: "{N} day(s) selected"
  │
  └─ Actions Row:
      ├─ TextButton("Cancel") → pop
      └─ FilledButton("Apply") → _applySelection
```

#### Method: _applyPreset(TimeRangePreset preset)
```
SET _selectedPreset = preset
SET _endDate = DayBoundary.getTodayEnd()

SWITCH preset:
  today      → start = TodayStart(6am)
  yesterday  → start = YesterdayStart(6am), end = TodayStart - 1sec
  last7Days  → start = 6 days ago (6am)
  last14Days → start = 13 days ago
  last30Days → start = 29 days ago
  last90Days → start = 89 days ago
  thisWeek   → start = ThisWeekStart
  thisMonth  → start = 1st of month at 6am
  lastMonth  → start = 1st of prev month, end = 1st of this month - 1sec
  allTime    → start = Jan 1, 2020 at 6am
```

#### Method: _selectDate({isStart}) → Future<void>
```
SHOW DatePicker (2020 to now)
IF selected:
  CLEAR _selectedPreset (manual override)
  SET start or end date
  ENFORCE start ≤ end constraint
```

#### Method: _applySelection()
```
CALL onRangeSelected(DateTimeRange(start, end))
POP dialog
```

---

### Class: _DatePickerField (StatelessWidget)
```
InkWell → Container(border, rounded):
  ├─ label (bodySmall, muted)
  └─ date formatted "MMM d, yyyy" (bodyLarge)
```

---

### Function: showTimeRangePicker({context, initialStart, initialEnd}) → Future<DateTimeRange?>
```
SHOW dialog with TimeRangePicker
CAPTURE result via onRangeSelected callback
RETURN result (or null if cancelled)
```
