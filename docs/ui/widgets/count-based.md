# Count-Based Widgets

These 4 widgets simply count [entries](../glossary.md#entry) — they don't use duration or any other field, just the number of non-deleted records. They help you track *how many* times you log per day, per week, and per active hour. All counts exclude [soft-deleted](../glossary.md#soft-delete) records.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Hits Today

**ID:** `hitsToday` · **Size:** compact · **Category:** Count-Based

**What it shows:** The total number of entries since 6 AM today, displayed as a simple number. A trend comparison shows the percentage change versus yesterday's total.

**How it's calculated:** Filters entries to today only (since 6 AM, respecting the [day boundary](../glossary.md#day-boundary)). Counts all non-deleted records. The trend compares today's count to yesterday's full-day count.

**How to interpret it:**
- High value means more entries logged today — more frequent usage
- Low value means fewer entries — less frequent usage
- Trend arrow: green ↓ = fewer hits than yesterday (less usage = positive progress). Red ↑ = more hits than yesterday

**Data source:** Count of non-deleted records filtered by `eventAt` to today.

**Usefulness:** The simplest and most direct metric. At a glance, you know how many times you've used today and whether that's more or less than yesterday.

---

#### Hits This Week

**ID:** `hitsThisWeek` · **Size:** compact · **Category:** Count-Based

**What it shows:** The total number of entries for the last 7 days, displayed as a number. A subtitle shows the average per day.

**How it's calculated:** Filters entries to the last 7 logical days (using the [day boundary](../glossary.md#day-boundary) calculation). Counts all non-deleted records. The daily average is the total divided by 7.

**How to interpret it:**
- High value means heavy usage over the past week
- Low value means lighter usage
- The daily average subtitle provides a useful per-day benchmark
- No trend arrow on this widget

**Data source:** Count of non-deleted records filtered by `eventAt` to the last 7 days.

**Usefulness:** Gives you the weekly view. If you're trying to reduce, watching this number decrease week over week is a meaningful indicator.

---

#### Daily Average

**ID:** `dailyAvgHits` · **Size:** compact · **Category:** Count-Based

**What it shows:** The average number of hits per day over the last 7 days, shown as a number (potentially with one decimal place).

**How it's calculated:** Filters entries to the last 7 days. Counts all non-deleted records. Then counts the number of **unique days with data** — only days that have at least one entry count toward the denominator. Divides the total count by the number of active days (minimum 1). This means days with zero entries **do not** pull the average down. For example, if you had 10 hits across 3 days out of the last 7, your daily average is 10 ÷ 3 = 3.3, not 10 ÷ 7 = 1.4.

**How to interpret it:**
- High value means you're averaging more hits on days you use
- Low value means fewer hits on active days
- No trend arrow on this widget

**Data source:** Count of non-deleted records and their timestamps (`eventAt`) from the last 7 days.

**Usefulness:** A more honest average than dividing by 7 — if you took a few days off, this won't make your average look artificially low. It represents "on days you use, how many times do you typically use?"

---

#### Hits/Active Hour

**ID:** `hitsPerActiveHour` · **Size:** compact · **Category:** Count-Based

**What it shows:** Usage density: today's hit count divided by today's [active hours](../glossary.md#active-hour) count, shown as a number (e.g., "2.5").

**How it's calculated:** Counts today's non-deleted entries (the numerator). Counts the number of distinct clock hours (0–23) that had at least one entry (the denominator). Divides the hit count by the active hours count. For example, if you had 10 hits across 4 different hours, the density is 2.5 hits per active hour.

**How to interpret it:**
- High value means you're cramming more entries into fewer hours — bursty, concentrated usage
- Low value means entries are more spread out — no more than one or two per hour
- No trend arrow on this widget

**Data source:** Count of non-deleted records and their hour-of-day values (`eventAt.hour`) from today.

**Usefulness:** Reveals whether your usage is bursty or spread out. A density of 5 hits/hour means you're chain-using during certain hours, while 1 hit/hour means usage is evenly distributed.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
