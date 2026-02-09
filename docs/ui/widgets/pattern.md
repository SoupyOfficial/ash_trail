# Pattern Widgets

These 3 widgets are visual/graphical — they render mini-charts and heatmap grids directly in the widget card, using multi-day data to show recurring patterns. Unlike stat-card widgets that show a single number, these widgets help you *see* patterns in when and how often you use across days and hours. Color intensity in heatmaps is proportional to the entry count in each cell — the cell with the highest count gets the darkest color, and others are proportionally lighter.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Weekly Pattern

**ID:** `weeklyPattern` · **Size:** standard · **Category:** Pattern

**What it shows:** A mini bar chart with 7 bars (Mon–Sun) showing the total number of [entries](../glossary.md#entry) per day of the week over the last 7 days. Bar height is proportional to the day with the most entries.

**How it's calculated:** Takes all non-deleted entries from the last 7 days. Groups them by day of the week. Counts entries per day. Renders each day as a bar whose height is proportional to `dayCount / maxDayCount`.

**How to interpret it:**
- Tall bars indicate days with heavy usage
- Short bars indicate lighter days
- A consistent pattern (e.g., always tall on Fridays) reveals habitual day-of-week triggers
- No trend arrow — this is a visual pattern, not a single metric

**Data source:** Entry timestamps (`eventAt`) and their day-of-week values from the last 7 days of non-deleted records.

**Usefulness:** Instantly shows which days of the week you use the most. Patterns like "always more on Fridays" or "weekends are heavier" become visually obvious.

---

#### Weekday Heatmap

**ID:** `weekdayHeatmap` · **Size:** large · **Category:** Pattern

**What it shows:** A grid with rows for Monday through Friday and columns for 24 hours (0–23). Each cell's color intensity represents how many entries occurred during that hour on that weekday over the last 7 days. Tapping a cell shows the exact count.

**How it's calculated:** Takes all non-deleted entries from the last 7 days that fall on weekdays (Mon–Fri). Groups them by `(dayOfWeek, hourOfDay)` pairs. Counts entries per cell. The cell with the highest count gets the darkest color (full intensity). All other cells are colored proportionally: `cellColor = intensity × (cellCount / maxCount)`. Cells with zero entries have no color fill.

**How to interpret it:**
- Dark cells = heavy activity during that hour on that day
- Light cells = some activity but less intense
- Empty cells = no recorded entries for that time slot
- Clusters of dark cells reveal your most active time windows during the work week
- No trend arrow — this is a heat map visualization

**Data source:** Entry timestamps (`eventAt`) — specifically the day-of-week and hour components — from the last 7 days of non-deleted records (weekdays only).

**Usefulness:** Reveals time-of-day patterns on work days. If you see a dark band at 12 PM every weekday, lunch breaks are a trigger. If mornings are dark, you might be starting each work day with heavy use.

---

#### Weekend Heatmap

**ID:** `weekendHeatmap` · **Size:** large · **Category:** Pattern

**What it shows:** The same grid format as the Weekday Heatmap but filtered to Saturday and Sunday only. Rows represent the two weekend days, columns represent 24 hours (0–23). Same color intensity logic — tap a cell for the exact count.

**How it's calculated:** Identical to the Weekday Heatmap but filters to entries where the day of the week is Saturday (6) or Sunday (7). Groups by `(dayOfWeek, hourOfDay)`, counts per cell, and colors proportionally.

**How to interpret it:**
- Differences from the weekday heatmap reveal how your patterns change on days off
- Dark cells at unusual hours (e.g., late night) might indicate weekend-specific triggers
- No trend arrow — this is a heat map visualization

**Data source:** Entry timestamps (`eventAt`) — specifically the day-of-week and hour components — from the last 7 days of non-deleted records (weekends only).

**Usefulness:** Lets you compare weekend usage patterns against weekday patterns. Combined with the Weekday Heatmap, you get a complete picture of when activity happens throughout the entire week.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
