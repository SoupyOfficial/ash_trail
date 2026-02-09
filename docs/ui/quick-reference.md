# Quick Reference

Scannable tables summarizing everything in the documentation. Use this page when you need to look something up fast.

← [Back to Index](README.md)

---

## All 27 Widgets

| # | Widget | Category | Default Size | Default? | Doc Link |
|---|--------|----------|-------------|----------|----------|
| 1 | Time Since Last Hit | Time | large | ✅ | [time-based](widgets/time-based.md#time-since-last) |
| 2 | Average Gap Today | Time | medium | | [time-based](widgets/time-based.md#average-gap) |
| 3 | Longest Gap | Time | medium | | [time-based](widgets/time-based.md#longest-gap-today) |
| 4 | First Hit Today | Time | small | | [time-based](widgets/time-based.md#first-hit-today) |
| 5 | Last Hit Today | Time | small | | [time-based](widgets/time-based.md#last-hit-time) |
| 6 | Peak Hour | Time | small | | [time-based](widgets/time-based.md#peak-hour) |
| 7 | Active Hours Today | Time | small | | [time-based](widgets/time-based.md#active-hours) |
| 8 | Total Duration Today | Duration | medium | ✅ | [duration-based](widgets/duration-based.md#total-today) |
| 9 | Average Duration | Duration | medium | | [duration-based](widgets/duration-based.md#avg-per-hit) |
| 10 | Longest Hit | Duration | small | | [duration-based](widgets/duration-based.md#longest-hit) |
| 11 | Shortest Hit | Duration | small | | [duration-based](widgets/duration-based.md#shortest-hit) |
| 12 | Total Duration Chart | Duration | chart | | [duration-based](widgets/duration-based.md#total-this-week) |
| 13 | Duration Trend | Duration | chart | | [duration-based](widgets/duration-based.md#duration-trend) |
| 14 | Hits Today | Count | medium | ✅ | [count-based](widgets/count-based.md#hits-today) |
| 15 | Daily Average | Count | medium | | [count-based](widgets/count-based.md#daily-average) |
| 16 | Hits Per Active Hour | Count | small | | [count-based](widgets/count-based.md#hitsactive-hour) |
| 17 | Hit Count Chart | Count | chart | | [count-based](widgets/count-based.md#hits-this-week) |
| 18 | Today vs Yesterday | Comparison | medium | | [comparison](widgets/comparison.md#today-vs-yesterday) |
| 19 | Period Comparison | Comparison | large | | [comparison](widgets/comparison.md#today-vs-week-avg) |
| 20 | Weekday vs Weekend | Comparison | medium | | [comparison](widgets/comparison.md#weekday-vs-weekend) |
| 21 | Hourly Pattern | Pattern | chart | | [pattern](widgets/pattern.md#weekday-heatmap) |
| 22 | Weekly Pattern | Pattern | chart | | [pattern](widgets/pattern.md#weekly-pattern) |
| 23 | Event Type Distribution | Pattern | chart | | [pattern](widgets/pattern.md#weekend-heatmap) |
| 24 | Mood/Physical Average | Secondary | medium | ✅ | [secondary-data](widgets/secondary-data.md#moodphysical-avg) |
| 25 | Top Reasons | Secondary | medium | | [secondary-data](widgets/secondary-data.md#top-reasons) |
| 26 | Quick Log | Action | large | ✅ | [action](widgets/action.md#quick-log) |
| 27 | Recent Entries | Action | large | ✅ | [action](widgets/action.md#recent-entries) |

**Default widgets** (shown on first launch): Time Since Last Hit, Quick Log, Hits Today, Total Duration Today, Mood/Physical Average, Recent Entries.

---

## All Screens

| Screen | Tab / Access | Purpose | Doc Link |
|--------|-------------|---------|----------|
| Home | Tab 1 | Customizable widget dashboard | [screens](screens.md#4-homescreen) |
| Analytics | Tab 2 | Charts and trend analysis | [screens](screens.md#5-analyticsscreen) |
| History | Tab 3 | Scrollable log list with search/filter | [screens](screens.md#6-historyscreen) |
| Logging | FAB / Quick Log | Create new entries (Detailed + Backdate) | [logging](logging.md) |
| Login | Auth flow | Email/password + Google + Apple sign-in | [screens](screens.md#2-loginscreen) |
| Signup | Auth flow | Account creation | [screens](screens.md#3-signupscreen) |
| Accounts | Profile | Switch/manage multiple accounts | [screens](screens.md#7-accountsscreen) |
| Profile | Accounts | User profile and settings | [screens](screens.md#8-profilescreen) |
| Export | Accounts | CSV/JSON export and import | [data-sync](data-sync.md#export-formats) |
| Settings | Profile | App settings and preferences | [screens](screens.md#10-loggingscreen) |

---

## Entry Fields

All fields available when logging an entry. See [Logging](logging.md) for full details.

| Field | Type | Required? | Notes |
|-------|------|-----------|-------|
| Event Type | `EventType` enum | Yes | Default: `vape`. 9 options. |
| Date/Time | `DateTime` | Yes | Default: now. Backdate tab for past entries. |
| Duration | `int` + `Unit` | No | Press-and-hold timer or manual entry |
| Reason(s) | `List<LogReason>` | No | Multi-select chips. 8 options. |
| Mood Rating | `double` (1–5) | No | Slider with emoji labels |
| Physical Rating | `double` (1–5) | No | Slider with emoji labels |
| Notes | `String` | No | Free text |
| Location | `double` (lat/lng) | No | Auto-captured via GPS if permitted |

---

## Enums

| Enum | Values |
|------|--------|
| `EventType` | vape, inhale, sessionStart, sessionEnd, note, purchase, tolerance, symptomRelief, custom |
| `SyncState` | pending, syncing, synced, error, conflict |
| `Unit` | seconds, minutes, hours, puffs, ml, mg, hits, custom |
| `LogReason` | craving, stress, social, boredom, habit, afterMeal, withCoffee, other |
| `Source` | manual, timer, import, migration |
| `TimeConfidence` | exact, approximate, estimated |
| `RangeType` | today, week, month, custom |
| `GroupBy` | day, week, month |

---

## Trend Colors & Arrows

See [Trends & Indicators](trends.md) for full explanation.

| Arrow | Color | Meaning (default) | Meaning (inverted) |
|-------|-------|-------------------|-------------------|
| ↑ | Green | Metric increased — good | Metric increased — bad |
| ↓ | Red | Metric decreased — bad | Metric decreased — good |
| → | Grey | No significant change | No significant change |

**Inverted widgets** (↑ = bad): Hits Today, Daily Average, Hits Per Active Hour, Total Duration Today.

---

## Sync States

| State | What it means |
|-------|--------------|
| Pending | Saved locally, awaiting upload |
| Syncing | Upload in progress |
| Synced | Confirmed on server |
| Error | Upload failed — will retry next cycle |
| Conflict | Server has newer version |

See [Data & Sync](data-sync.md) for state machine diagram and full explanation.

---

## Architecture Layers

| Layer | Location | Responsibility |
|-------|----------|---------------|
| UI | `lib/screens/`, `lib/widgets/` | Visual presentation, user interaction |
| State | `lib/providers/` | Riverpod state management, reactive updates |
| Business | `lib/services/` | Calculations, validation, sync logic |
| Data | `lib/repositories/` | Hive local storage, Firestore cloud |

See [Architecture](architecture.md) for full diagrams.

---

## Day Boundary

The app day runs **6:00 AM → 5:59 AM**. "Today" means the current day boundary window.

Defined in `lib/utils/day_boundary.dart` as `dayStartHour = 6`.

See [Glossary](glossary.md#day-boundary) for rationale and diagram.

---

← [Back to Index](README.md)
