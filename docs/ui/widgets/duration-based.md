# Duration-Based Widgets

These 6 widgets use the [duration](../glossary.md#duration) of each [entry](../glossary.md#entry) as their primary data source. They compute sums, averages, minimums, maximums, and trends of session lengths. Duration is stored in seconds internally and converted for display. These widgets help you understand *how long* your sessions are and whether they're getting shorter or longer over time.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Total Today

**ID:** `totalDurationToday` · **Size:** compact · **Category:** Duration-Based

**What it shows:** The sum of all entry durations since 6 AM today, displayed in mm:ss or hh:mm:ss format. A subtitle shows the hour-block trend percentage compared to yesterday and the weekly average.

**How it's calculated:** Filters entries to today (since 6 AM, respecting the [day boundary](../glossary.md#day-boundary)). For each non-deleted entry, converts the duration to seconds (if the unit is minutes, multiplies by 60). Sums all the durations. For the trend comparison, it uses **hour-block pacing**: instead of comparing today's total to yesterday's full-day total (which would always look low until the day is over), it figures out what fraction of the day has passed (e.g., at 3 PM, about 37.5% of the 24-hour logical day). It then takes yesterday's total duration and multiplies by that same fraction to get "what yesterday looked like at this time of day." The percentage difference between today's actual total and that pro-rated amount is the trend. The same approach is used against the 7-day daily average.

**How to interpret it:**
- High value means you've accumulated more total session time today
- Low value means shorter total time — possibly fewer or shorter sessions
- Trend arrow: green ↓ = your total duration so far today is *below* yesterday's pace at this same hour (you're on track for less usage). Red ↑ = above yesterday's pace

**Data source:** Entry durations (`duration`, `unit`) and timestamps (`eventAt`) from today's and yesterday's non-deleted records, plus the last 7 days.

**Usefulness:** The headline metric for "how much time have I spent today." The hour-block trending makes it a fair comparison even at 10 AM, unlike a naive today-vs-yesterday total.

---

#### Avg Per Hit

**ID:** `avgDurationPerHit` · **Size:** compact · **Category:** Duration-Based

**What it shows:** The average duration per entry today, displayed in mm:ss format. The subtitle shows a trend comparison to yesterday's average.

**How it's calculated:** Filters entries to today (since 6 AM). Sums all durations (converted to seconds). Divides by the number of non-deleted entries. For example, if you have 4 entries totaling 120 seconds, the average is 30 seconds per hit.

**How to interpret it:**
- High value means your individual sessions tend to be longer
- Low value means your sessions are shorter on average
- Trend arrow: green ↓ = sessions are shorter than yesterday's average (less time per use). Red ↑ = sessions are getting longer

**Data source:** Entry durations (`duration`, `unit`) from today's non-deleted records.

**Usefulness:** Helps you see if your sessions are getting shorter over time, which may indicate you're reducing intake per session even if the count stays the same.

---

#### Longest Hit

**ID:** `longestHitToday` · **Size:** compact · **Category:** Duration-Based

**What it shows:** The duration of your longest single session today, displayed in mm:ss or hh:mm:ss format.

**How it's calculated:** Filters entries to today (since 6 AM). Converts each entry's duration to seconds. Finds the entry with the maximum duration using a comparison across all non-deleted records.

**How to interpret it:**
- High value means you had at least one long session today
- Low value means even your longest session was short
- No trend arrow on this widget

**Data source:** Entry durations (`duration`, `unit`) from today's non-deleted records.

**Usefulness:** Identifies your longest single session. If you're trying to keep sessions short, seeing this number stay low is a positive sign.

---

#### Shortest Hit

**ID:** `shortestHitToday` · **Size:** compact · **Category:** Duration-Based

**What it shows:** The duration of your shortest single session today, displayed in mm:ss format.

**How it's calculated:** Filters entries to today (since 6 AM). Converts each entry's duration to seconds. Finds the entry with the minimum duration using a comparison across all non-deleted records.

**How to interpret it:**
- High value means even your quickest session was relatively long
- Low value means you had at least one very brief session
- No trend arrow on this widget

**Data source:** Entry durations (`duration`, `unit`) from today's non-deleted records.

**Usefulness:** Gives context to your session lengths. If your shortest hit is getting shorter over time, it might mean you're catching yourself sooner.

---

#### Total This Week

**ID:** `totalDurationWeek` · **Size:** compact · **Category:** Duration-Based

**What it shows:** The cumulative duration for the last 7 days, displayed in hh:mm or h:mm:ss format. A subtitle shows the daily average (total divided by 7).

**How it's calculated:** Filters entries to the last 7 logical days (via the [day boundary](../glossary.md#day-boundary) calculation). Sums all non-deleted entry durations (converted to seconds). The daily average divides the total by 7 (calendar days, not days-with-data).

**How to interpret it:**
- High value means significant total session time over the week
- Low value means less overall time spent in sessions
- The daily average subtitle gives you a per-day benchmark
- No trend arrow on this widget

**Data source:** Entry durations (`duration`, `unit`) from the last 7 days of non-deleted records.

**Usefulness:** The "big picture" duration metric. Comparing week-over-week totals helps you see long-term trends that daily metrics might miss.

---

#### Duration Trend

**ID:** `durationTrend` · **Size:** standard · **Category:** Duration-Based

**What it shows:** A comparison of your average session duration over the last 3 days against the previous 3 days, shown as a percentage change and direction arrow. May include a sparkline visualization.

**How it's calculated:** Takes the last 6 days of data and splits them into two periods: the recent 3 days and the prior 3 days. Computes the average session duration (total duration ÷ number of entries) for each period. Calculates the percentage change as `((recent − prior) / prior) × 100`.

**How to interpret it:**
- Positive percentage = sessions are getting longer recently
- Negative percentage = sessions are getting shorter recently
- Trend arrow: green ↓ = duration decreasing (shorter sessions = positive progress). Red ↑ = duration increasing (longer sessions)

**Data source:** Entry durations (`duration`, `unit`) and timestamps (`eventAt`) from the last 6 days of non-deleted records.

**Usefulness:** Answers the question "are my sessions getting longer or shorter lately?" A 3-day window is short enough to detect recent changes but long enough to smooth out single-day anomalies.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
