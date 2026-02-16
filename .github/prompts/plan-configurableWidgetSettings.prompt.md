## Plan: Configurable Widget Settings System

**TL;DR**: Make every home widget configurable by introducing a shared settings vocabulary (time window, event type filter, metric selector) that flows through the existing `HomeWidgetConfig.settings` map. No new packages, no model migrations, no new persistence layer — just extending the infrastructure already in place.

---

### Phase 1: Shared Settings Infrastructure (foundation — blocks all other phases)

**1.1 Define standardized settings keys and defaults**
- Create a new file `lib/widgets/home_widgets/widget_settings_keys.dart` containing:
  - Constants for setting key names: `kTimeWindowDays`, `kEventTypeFilter`, `kMetricType`, `kComparisonTarget`, etc.
  - A `WidgetSettingsDefaults` class with a static method `defaultsFor(HomeWidgetType type) → Map<String, dynamic>` returning the current hardcoded values (e.g. `hitsToday` → `{'timeWindowDays': 1}`, `hitsThisWeek` → `{'timeWindowDays': 7}`)
  - A `MetricType` enum: `count`, `totalDuration`, `avgDuration`, `mood`, `physical`
  - A `ComparisonTarget` enum: `yesterday`, `weekAvg`, `lastWeek`, `lastMonth`, `custom`

**1.2 Add a shared record filtering helper**
- Add a method to `HomeMetricsService`: `filterRecords(List<LogRecord> records, {int? days, EventType? eventType})` that applies time window + event type filtering in one call. Every builder method will use this instead of duplicating filter logic.

**1.3 Extend `HomeWidgetBuilder` to read settings universally**
- At the top of `HomeWidgetBuilder.build()`, extract common settings from `config`:
  ```
  final days = config.getSetting<int>(kTimeWindowDays);
  final eventTypeFilter = config.getSetting<String>(kEventTypeFilter);
  final filteredRecords = metrics.filterRecords(records, days: days, eventType: ...);
  ```
- Pass `filteredRecords` and `days` to each builder method instead of `records` directly.

**Relevant files:**
- `lib/widgets/home_widgets/widget_settings_keys.dart` — **new file**
- `lib/services/home_metrics_service.dart` — add `filterRecords()`
- `lib/widgets/home_widgets/home_widget_builder.dart` — extract settings at top of `build()`

---

### Phase 2: Universal Time Window Selector (parallel with Phase 3)

**2.1 Update `WidgetSettingsSheet._buildSettingsForType()` with time window controls**
- Add a `_buildTimeWindowSetting()` shared method that renders a `SegmentedButton` or `ChoiceChip` row for: Today (1), 3 Days, 7 Days, 14 Days, 30 Days, All Time.
- Wire it into the switch for every stat widget type that currently hardcodes a time period. This covers ~20 widget types — they all get the same setting control, just different defaults.
- For widgets where "today" semantics matter specially (e.g. `timeSinceLastHit`, `firstHitToday`), exclude from time window or mark as "not applicable."

**2.2 Update each builder method to use the `days` setting**
- Every `_buildX()` method in `HomeWidgetBuilder` switches from e.g. `metrics.getHitCountToday(records)` to `metrics.getHitCount(filteredRecords, days: days)`.
- The subtitle/label changes dynamically: hardcoded "today" → "3 days" / "7 days" / etc. based on `days` value.
- Methods that already accept `{int? days}` in `HomeMetricsService`: `getAverageGap`, `getLongestGap`, `getPeakHour`, `getActiveHoursCount`, `getTotalDuration`, `getAverageDuration`, `getLongestHit`, `getShortestHit`, `getHitCount`, `getDailyAverageHits`, `getHitsPerActiveHour`, `getAverageMood`, `getAveragePhysical`, `getTopReasons` — all ready, no changes needed.
- Methods currently today-only (`getAverageGapToday`, `getFirstHitToday`, `getTotalDurationToday`, `getHitCountToday`) — just call the general version with a `days` param instead.

**2.3 Update subtitle labels**
- Add `WidgetSettingsDefaults.timeWindowLabel(int days)` → returns `"today"`, `"3 days"`, `"7 days"`, etc. for use in widget subtitles.

**Relevant files:**
- `lib/widgets/home_widgets/widget_settings_sheet.dart` — add `_buildTimeWindowSetting()`; extend switch cases
- `lib/widgets/home_widgets/home_widget_builder.dart` — update ~20 builder methods
- `lib/widgets/home_widgets/widget_settings_keys.dart` — `timeWindowLabel()` helper

---

### Phase 3: Event Type Filter per Widget (parallel with Phase 2)

**3.1 Add event type filter setting UI**
- In `WidgetSettingsSheet`, add `_buildEventTypeFilterSetting()`: a multi-select chip row showing all `EventType` values. Default = all (null/empty = no filter). Stored as `List<String>` of enum names in settings map under `kEventTypeFilter`.

**3.2 Apply filter in `HomeMetricsService.filterRecords()`**
- The `filterRecords` method added in Phase 1 already handles this — filter `records.where((r) => eventTypes.contains(r.eventType))`.

**3.3 Show active filter indicator on widget**
- When event type filter is active, show a small chip/badge on the widget title (e.g. icon + "Vape only") so users can see at a glance that a widget is filtered.

**Relevant files:**
- `lib/widgets/home_widgets/widget_settings_sheet.dart` — add `_buildEventTypeFilterSetting()`
- `lib/widgets/home_widgets/home_widget_builder.dart` — pass filter badge info through
- `lib/widgets/home_widgets/stat_card_widget.dart` — optional filter indicator chip

---

### Phase 4: Configurable Metric on Comparison & Trend Widgets (*depends on Phases 1–2*)

**4.1 Metric selector for comparison widgets**
- `todayVsYesterday`, `todayVsWeekAvg`, `weekdayVsWeekend` currently show count + duration side by side. Add a `kMetricType` setting so users can pick which metrics to display (count, duration, avg duration, mood, physical).
- In settings sheet: `_buildMetricTypeSetting()` — a `SegmentedButton<MetricType>` or chip group.

**4.2 Configurable comparison target**
- `todayVsYesterday` becomes "Period A vs Period B" — users pick the comparison target (yesterday, week avg, last month, same day last week).
- Add `kComparisonTarget` setting. The builder reads it and calls `comparePeriods()` with the appropriate day ranges.

**4.3 Update `durationTrend` to actually use its `days` setting**
- Currently the builder hardcodes `currentDays: 3, previousDays: 3` and ignores the setting in the sheet. Fix this so the stored `days` value flows through.

**Relevant files:**
- `lib/widgets/home_widgets/widget_settings_sheet.dart` — `_buildMetricTypeSetting()`, `_buildComparisonTargetSetting()`
- `lib/widgets/home_widgets/home_widget_builder.dart` — update comparison builders to read settings

---

### Phase 5: Heatmap Customization (*depends on Phase 1*)

**5.1 Metric-weighted heatmaps**
- `weekdayHeatmap` and `weekendHeatmap` currently show hit count intensity. Add `kMetricType` setting to switch between: count (default), total duration, avg duration.
- Update `_buildFilteredHeatmap()` to compute intensity from the selected metric.

**5.2 Merge weekday/weekend into a single configurable heatmap**
- Instead of two fixed heatmap types, let the existing heatmap widget have a `kDayFilter` setting: All Days, Weekday, Weekend. Fewer widget types, more flexibility.

**Relevant files:**
- `lib/widgets/home_widgets/home_widget_builder.dart` — update `_buildFilteredHeatmap()`
- `lib/widgets/home_widgets/widget_settings_sheet.dart` — add heatmap settings
- `lib/widgets/home_widgets/widget_catalog.dart` — potentially consolidate heatmap types

---

### Phase 6: Custom Stat Widget Type (future — *depends on Phases 1–4*)

**6.1 Add `HomeWidgetType.customStat` to the catalog**
- A new widget type where all dimensions are user-configured: metric + time window + event type filter + optional comparison baseline.
- `allowMultiple: true` so users can add as many as they want.
- Size: `compact` by default (fits in stat card grid).

**6.2 Custom Stat builder**
- Reads `kMetricType`, `kTimeWindowDays`, `kEventTypeFilter`, `kComparisonTarget` from settings.
- Computes the single metric value → renders in a `StatCardWidget`.
- Comparison target is optional — if set, shows a `TrendIndicator`.

**6.3 Custom Stat settings flow**
- When adding from the picker, immediately open `WidgetSettingsSheet` so user configures it before it appears on the dashboard (don't add an unconfigured blank widget).

**Relevant files:**
- `lib/widgets/home_widgets/widget_catalog.dart` — add `customStat` entry
- `lib/models/home_widget_config.dart` — no changes needed (settings map handles everything)
- `lib/widgets/home_widgets/home_widget_builder.dart` — add `customStat` case
- `lib/widgets/home_widgets/widget_settings_sheet.dart` — compose all shared setting builders for this type
- `lib/widgets/home_widgets/widget_picker_sheet.dart` — auto-open settings on add

---

### Verification

- **Unit tests**: Extend `test/services/home_metrics_service_test.dart` with tests for `filterRecords()` covering: event type filtering, day windowing, combined filters, empty results, null filters (no-op).
- **Widget tests**: Add `test/widgets/widget_settings_sheet_test.dart` — verify each setting type renders, saves to config, and persists the expected keys.
- **Existing tests**: Run `test/models/home_widget_config_test.dart` and `test/providers/home_widget_config_provider_test.dart` to confirm settings merge/persist correctly (no changes expected, existing infra should pass).
- **Manual verification**: Add a widget → open settings → change time window → confirm widget re-renders with correct label and value. Repeat for event type filter. Confirm settings survive app restart (SharedPreferences persistence).
- **Regression check**: Ensure widgets with no settings changes still show their current defaults (fallback values in `WidgetSettingsDefaults.defaultsFor()`).

---

### Decisions

- **No model migrations** — all configuration lives in the existing `Map<String, dynamic>? settings` on `HomeWidgetConfig`, persisted in SharedPreferences. No Isar/Hive schema changes.
- **Backward compatible** — widgets without settings stored continue to work via defaults in `WidgetSettingsDefaults.defaultsFor()`.
- **Settings are per-widget-instance** — two "Hits" widgets can have different time windows.
- **Excluded from scope**: custom date range pickers on individual widgets (the analytics screen handles this already), location-based filtering (data exists but no UX pattern yet), cross-account comparisons.
- **Phase 6 (Custom Stat) is optional** — Phases 1–5 already give every existing widget full configurability. Phase 6 is additive for power users.
