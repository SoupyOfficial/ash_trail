# Comparison Widgets

These 3 widgets show two values side-by-side or as a percentage difference. They help you answer "am I doing better or worse than my baseline?" by comparing today's usage against yesterday, the 7-day average, or weekday-vs-weekend patterns. All comparisons exclude [soft-deleted](../glossary.md#soft-delete) records.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Today vs Yesterday

**ID:** `todayVsYesterday` · **Size:** standard · **Category:** Comparison

**What it shows:** A side-by-side display showing today's count and total [duration](../glossary.md#duration) versus yesterday's count and total duration. Two columns with raw numbers — plus percentage change indicators for both count and duration.

**How it's calculated:** Filters entries to today (since 6 AM, respecting the [day boundary](../glossary.md#day-boundary)). Separately filters entries to yesterday (the 24-hour period before today's 6 AM). For each period: counts non-deleted records and sums their durations. Computes percentage change for both count and duration as `((today − yesterday) / yesterday) × 100`. If yesterday had zero entries and today has more than zero, the change shows as 100%. If both are zero, shows 0%.

**How to interpret it:**
- Lower count/duration today vs yesterday = using less = positive progress
- Higher count/duration today = using more than yesterday
- Trend arrow: green ↓ = less than yesterday. Red ↑ = more than yesterday
- Both count and duration get independent trend arrows

**Data source:** Entry counts and durations (`duration`, `unit`, `eventAt`) from today's and yesterday's non-deleted records.

**Usefulness:** The most intuitive comparison — "am I doing better than yesterday?" Having both count *and* duration side-by-side reveals whether you reduced the number of sessions, the total time, or both.

---

#### Today vs Week Avg

**ID:** `todayVsWeekAvg` · **Size:** standard · **Category:** Comparison

**What it shows:** How today's count and duration compare to the 7-day daily average, expressed as percentage differences (e.g., "+15%" or "-20%"). Uses [trend arrows](../trends.md) to indicate direction.

**How it's calculated:** Gets today's hit count and total duration. Computes the 7-day total count and total duration, then divides each by 7 to get the daily average. For the duration comparison, uses the hour-block pacing approach: pro-rates the weekly average by the fraction of the day elapsed so far (so at 3 PM, it compares to 37.5% of the daily average). Computes percentage change as `((today − average) / average) × 100`.

**How to interpret it:**
- Negative percentage = you're below your weekly average (using less than usual = good)
- Positive percentage = you're above your weekly average (using more than usual = concerning)
- Trend arrow: green ↓ = below average. Red ↑ = above average

**Data source:** Entry counts and durations (`duration`, `unit`, `eventAt`) from today's and the last 7 days' non-deleted records.

**Usefulness:** Provides a more stable baseline than comparing to a single day. Yesterday might have been an outlier — the 7-day average smooths that out. If you're consistently below the weekly average, you're on a downward trend.

---

#### Weekday vs Weekend

**ID:** `weekdayVsWeekend` · **Size:** standard · **Category:** Comparison

**What it shows:** Compares average hits per weekday (Mon–Fri) versus average hits per weekend day (Sat–Sun) over the last 7 days. Shows both averages and the difference.

**How it's calculated:** Takes all non-deleted entries from the last 7 days. Splits them into weekday records (Monday through Friday, where the day-of-week value is 1–5) and weekend records (Saturday and Sunday, where the day-of-week value is 6–7). Counts the number of unique weekday and weekend calendar days in the period. Divides the weekday hit count by the number of weekday days, and the weekend hit count by the number of weekend days. Also computes average duration for each group.

**How to interpret it:**
- If weekday average is higher, you use more during the work week
- If weekend average is higher, you use more on days off
- Helps reveal whether your usage is driven by work stress, boredom on off-days, or other patterns
- No standard trend arrow — this is a pattern comparison, not a directional metric

**Data source:** Entry counts, durations (`duration`, `unit`), and day-of-week values (`eventAt.weekday`) from the last 7 days of non-deleted records.

**Usefulness:** Reveals whether your usage pattern differs on work days vs off days. If weekends are significantly higher, social or boredom triggers might be a factor. If weekdays are higher, stress or routine might be the driver.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
