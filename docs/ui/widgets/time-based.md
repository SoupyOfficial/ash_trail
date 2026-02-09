# Time-Based Widgets

These 7 widgets use the timestamp of each [entry](../glossary.md#entry) as their primary data source. They compute time differences between entries, identify the first and last entry of the day, and find patterns in when entries occur. All time calculations respect the 6 AM [day boundary](../glossary.md#day-boundary) — meaning "today" starts at 6 AM, not midnight. If you want to understand *when* you use and how your timing patterns look, these are your widgets.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Time Since Last

**ID:** `timeSinceLastHit` · **Size:** standard · **Category:** Time-Based

**What it shows:** A live ticking clock displaying the elapsed time since your most recent entry. The display updates every second and shows the duration in h:mm:ss format (e.g., "1:23:45" means 1 hour, 23 minutes, 45 seconds since your last hit).

**How it's calculated:** Looks at all your entries across all time (not just today). Finds the most recent non-deleted entry by sorting all records newest-first. Computes the difference between right now and that entry's timestamp. The clock ticks up in real-time.

**How to interpret it:**
- High value means you've gone a long time without using — you're extending the gap between sessions
- Low value means you recently logged an entry
- No [trend arrow](../trends.md) on this widget — it's a live clock, not a comparison metric

**Data source:** Entry timestamps (`eventAt`) from all non-deleted records.

**Usefulness:** Lets you see at a glance how long it's been since your last session. If you're trying to space out usage, watching this clock tick higher can be motivating.

---

#### Average Gap

**ID:** `avgTimeBetween` · **Size:** compact · **Category:** Time-Based

**What it shows:** The average time between consecutive hits today, displayed as h:mm or mm:ss. A subtitle shows the 7-day average for comparison.

**How it's calculated:** Filters your entries to today only (since 6 AM, respecting the [day boundary](../glossary.md#day-boundary)). Sorts them by time. Finds the first hit (earliest) and last hit (most recent). Computes the total time span between them. Divides that span by the number of gaps (which is one less than the number of entries). For example, if you had 5 hits between 8 AM and 4 PM, the total span is 8 hours with 4 gaps, giving an average gap of 2 hours. The 7-day average uses a similar approach but averages individual consecutive pair gaps across 7 days of data.

**How to interpret it:**
- High value means you're going longer between sessions — spacing them out more
- Low value means you're using more frequently — shorter intervals between sessions
- Trend arrow: green ↓ on usage count comparisons; this widget shows two values (today vs 7-day) rather than a trend arrow

**Data source:** Entry timestamps (`eventAt`) from today's and last 7 days' non-deleted records.

**Usefulness:** Helps you see whether you're spacing sessions out more or less than usual. If your average gap today is larger than the 7-day average, you're doing better than your baseline.

---

#### Longest Gap Today

**ID:** `longestGapToday` · **Size:** compact · **Category:** Time-Based

**What it shows:** The maximum time between any two consecutive entries today, displayed as h:mm or mm:ss.

**How it's calculated:** Filters entries to today (since 6 AM). Sorts them by time. Iterates through each consecutive pair and computes the time between them. Tracks the longest one found. Also records when the gap started and ended.

**How to interpret it:**
- High value means you had a long uninterrupted stretch without using — your best break of the day
- Low value means your longest break was still short — usage was fairly evenly distributed
- No trend arrow on this widget

**Data source:** Entry timestamps (`eventAt`) from today's non-deleted records.

**Usefulness:** Useful for seeing your longest break of the day. If you're trying to extend the time between sessions, watching this number grow over days is encouraging.

---

#### First Hit Today

**ID:** `firstHitToday` · **Size:** compact · **Category:** Time-Based

**What it shows:** The time of your earliest entry today, shown in 12-hour format (e.g., "8:23 AM"). If no entries exist today, it shows a placeholder.

**How it's calculated:** Filters entries to today (since 6 AM, respecting the [day boundary](../glossary.md#day-boundary)). Sorts them by time. Returns the timestamp of the oldest entry (the very first one of the day).

**How to interpret it:**
- A later time means you delayed your first session — you waited longer after waking up to start
- An earlier time means you started sooner in the day
- No trend arrow on this widget

**Data source:** Entry timestamps (`eventAt`) from today's non-deleted records.

**Usefulness:** Helps track if you're pushing your first session later in the day. If you started at 7 AM last week and now start at 9 AM, that's progress in delaying the first use.

---

#### Last Hit Time

**ID:** `lastHitTime` · **Size:** compact · **Category:** Time-Based

**What it shows:** When your most recent entry was logged, shown as both the actual time (e.g., "2:15 PM") and relative time (e.g., "2h ago").

**How it's calculated:** Filters entries to today (since 6 AM). Sorts them newest-first. Returns the timestamp of the first entry in the sorted list (the most recent one). The relative time is computed as the difference between now and that timestamp.

**How to interpret it:**
- Shows you when your last session was at a glance
- The relative time ("2h ago") gives quick context without reading the clock
- No trend arrow on this widget

**Data source:** Entry timestamps (`eventAt`) from today's non-deleted records.

**Usefulness:** Quick reference for when you last logged. If you see "4h ago," you know it's been a while since your last session.

---

#### Peak Hour

**ID:** `peakHour` · **Size:** compact · **Category:** Time-Based

**What it shows:** The hour of day when you log the most entries, based on the last 7 days of data. Shows the hour (e.g., "2 PM") and what percentage of total hits occurred during that hour (e.g., "18%").

**How it's calculated:** Takes all non-deleted entries from the last 7 days. Groups them by the hour of their timestamp (0–23). Counts how many entries fall in each hour. Finds the hour with the highest count. Computes the percentage as that hour's count divided by the total number of entries, multiplied by 100.

**How to interpret it:**
- Identifies your most active hour — this is when you tend to use the most
- A high percentage means your usage is concentrated in that one hour
- A low percentage means usage is spread more evenly across the day
- No trend arrow on this widget

**Data source:** Entry timestamps (`eventAt`) — specifically the hour component — from the last 7 days of non-deleted records.

**Usefulness:** Reveals your peak usage time. If you learn you always use most at 3 PM, you can plan alternative activities for that hour.

---

#### Active Hours

**ID:** `activeHoursToday` · **Size:** compact · **Category:** Time-Based

**What it shows:** The count of distinct clock hours (e.g., 8 AM, 9 AM, 2 PM) in which at least one entry was recorded today. Displayed as a simple number.

**How it's calculated:** Filters entries to today (since 6 AM). Collects the hour component (0–23) of each entry's timestamp into a set (which automatically removes duplicates). Returns the size of that set. For example, if you logged at 8:05 AM, 8:30 AM, and 10:15 AM, you'd have 2 [active hours](../glossary.md#active-hour) (8 AM and 10 AM — the two 8 AM entries count as the same hour).

**How to interpret it:**
- A lower number means your activity is concentrated in fewer hours — you're not using throughout the entire day
- A higher number means usage is spread across many hours of the day
- No trend arrow on this widget

**Data source:** Entry timestamps (`eventAt`) — specifically the hour component — from today's non-deleted records.

**Usefulness:** Helps you see how many hours of your day involve usage. If you used during 12 different hours yesterday but only 8 today, you're confining activity to a narrower window.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
