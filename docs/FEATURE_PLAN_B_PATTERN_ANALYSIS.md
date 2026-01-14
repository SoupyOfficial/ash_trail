# Feature Plan B: Pattern Analysis & Insights

## Overview
Focuses on identifying usage patterns, temporal trends, and behavioral insights. Helps users understand *when* and *why* they use, enabling data-driven decisions.

---

## Features

### 1. Peak Usage Hours
**Description**: Identify which hours of the day have the most activity and show usage distribution across 24 hours.

**Data Requirements**:
- `eventAt` timestamp from LogRecord
- Filter by period (today, this week, last week)

**User Stories**:
- As a user, I want to know my peak usage hours to understand my patterns
- As a user, I want to see if my peak hours change day-to-day or week-to-week
- As a user reducing, I want to identify high-risk hours to prepare

**Data Flow**:
```
LogRecords for period
  → Extract hour from eventAt
  → Count hits per hour (0-23)
  ↓
Identify peak hour(s)
  ↓
Calculate: peak_hour_count / total_count = concentration %
  ↓
Display: "Peak: 4pm (8 hits, 25% of daily usage)"
```

**Widget Changes**:
- Hour gauge showing "Peak hour: 4 PM (25% of usage)"
- Optional: Mini bar chart (horizontal) showing hour distribution
- Compare peak hour this week vs. last week

**Implementation Complexity**: Low

---

### 2. Day-of-Week Patterns
**Description**: Show which days of week have highest usage to identify weekday vs. weekend differences.

**Data Requirements**:
- `eventAt` timestamp
- 4-week rolling history

**User Stories**:
- As a user, I want to see if I use more on weekends vs. weekdays
- As a user, I want to identify my lowest-usage day for goal-setting
- As a user, I want to see if certain days are triggers

**Data Flow**:
```
LogRecords (last 4 weeks)
  → Group by day of week (Mon-Sun)
  → Sum hits per day type
  → Calculate average per day
  ↓
Rank: highest → lowest
  ↓
Display insights:
  - Highest: Monday (avg 6 hits)
  - Lowest: Wednesday (avg 2 hits)
  - Weekday avg: 5 | Weekend avg: 4
```

**Widget Changes**:
- "Weekly Pattern" card showing day distribution
- Bar chart: Mo | Tu | We | Th | Fr | Sa | Su
- Insight: "More active on weekends (+30%)"
- Comparison to last period

**Implementation Complexity**: Low-Medium

---

### 3. Reason Analysis
**Description**: Show what reasons users logged for their usage and track reason trends.

**Data Requirements**:
- `reasons` array from LogRecord (LogReason enum: medical, recreational, social, stress, habit, sleep, pain, other)
- Count and percentage per reason
- Period filtering

**User Stories**:
- As a user, I want to see what's driving my usage (stress, habit, social, etc.)
- As a user, I want to know if stress-related usage is increasing or decreasing
- As a user, I want to avoid my top trigger reason

**Data Flow**:
```
LogRecords for period
  → Extract reasons from each record
  → Flatten reasons (one record can have multiple)
  → Count occurrences per reason
  → Calculate percentage of total
  ↓
Display top 3 reasons with:
  - Reason name + icon
  - Count + percentage
  - Trend arrow (↑ increasing, ↓ decreasing)
```

**Widget Changes**:
- "Top Reasons" section showing:
  ```
  🎯 Habit          8 hits (35%)  ↑ +2 from yesterday
  😰 Stress         6 hits (26%)  ↓ -1 from yesterday
  👥 Social         5 hits (22%)  → Same as yesterday
  ```
- Tap to see daily/weekly breakdown per reason
- "No reason" fallback for unmotivated logs

**Implementation Complexity**: Low-Medium

---

### 4. Streak Tracking (Usage Focus)
**Description**: Track consecutive days *with* usage (active days) and streaks without (clean days).

**Data Requirements**:
- Daily hit counts (last 60 days)
- Calendar dates

**User Stories**:
- As a user, I want to see my longest active streak this month
- As a user reducing, I want to celebrate clean days without usage
- As a user, I want to see if I'm maintaining consistent activity

**Data Flow**:
```
Last 60 days of LogRecords
  → Group by calendar day
  → Mark: Has activity (≥1 hit) or No activity
  ↓
Calculate streaks:
  - Current active streak: consecutive days with hits
  - Current clean streak: consecutive days without
  - Best active streak this period
  - Best clean streak this period
  ↓
Display:
  "🔥 7-day active streak | 📅 Best: 14 days"
  "✨ 2-day clean streak | 📅 Best: 21 days"
```

**Widget Changes**:
- Dual streak display (active + clean)
- Mini calendar (7x7 grid) showing last 49 days with color coding:
  - Light gray: No data
  - Green: Clean day (0 hits)
  - Yellow: Low usage
  - Red: High usage
- Streak counter with emoji

**Implementation Complexity**: Medium

---

### 5. Time-to-Next Usage Prediction
**Description**: Based on patterns, estimate when next usage is likely to occur.

**Data Requirements**:
- Inter-event intervals (time between consecutive hits)
- Hour-based patterns
- Day-of-week baseline

**User Stories**:
- As a user, I want to know approximately when I'll likely use next
- As a user reducing, I want to prepare for predicted peaks
- As a user, I want to be notified before predicted times

**Data Flow**:
```
Historical records (last 30 days)
  ↓
Calculate inter-event intervals (gap between hits)
  → Average gap duration
  → Typical patterns by hour/day
  ↓
From last hit (timestamp)
  → Add average interval
  → Adjust for current day-of-week + hour
  ↓
Display: "Based on patterns, ~2.5h until next usage"
```

**Widget Changes**:
- "Next Usage Estimate" card
- Timer display: "⏱️ ~2.5 hours"
- Confidence level: High/Medium/Low (based on pattern consistency)
- Range: "Likely 1.5-3.5 hours from now"

**Implementation Complexity**: Medium-High

---

### 6. Comparison Insights
**Description**: Compare current patterns to historical averages and detect changes.

**User Stories**:
- As a user, I want to see how this week compares to last week
- As a user, I want alerts when my usage significantly increases
- As a user reducing, I want validation that I'm using less

**Data Flow**:
```
This week data vs. Last week data
  → Calculate: (this_week - last_week) / last_week
  → Percent change
  ↓
This week vs. Month average
  → Deviation from baseline
  ↓
Display status:
  - "↓ 20% less than last week ✓"
  - "↑ 15% more than monthly avg ⚠️"
```

**Widget Changes**:
- Comparison badges with arrows and percentages
- Color coded: Green (improvement) / Red (increase) / Gray (stable)

**Implementation Complexity**: Low

---

## Data Model Changes

No new fields required - all data exists in LogRecord:
- `eventAt` - timestamp
- `reasons` - array of LogReason
- Can compute everything from existing records

---

## UI/UX Guidelines

- **Visualization**: Use icons from LogReason enum
- **Time formatting**: Relative (e.g., "2 days ago"), absolute (e.g., "Monday at 3 PM")
- **Interactivity**: Tap cards to drill into details (hourly, daily breakdown)
- **Trends**: Use arrows (↑ ↓ →) with color (red/green/gray)
- **Data availability**: Show "Not enough data" gracefully for < 7 days

---

## Implementation Priority

1. **Phase 1** (Low effort): Peak hours + Day-of-week patterns + Reason analysis
2. **Phase 2** (Medium effort): Streak tracking (both types) + Comparison insights
3. **Phase 3** (Advanced): Time-to-next prediction with ML-lite algorithm

---

## Advanced Features (Future)

- **Anomaly detection**: Alert when usage significantly deviates from pattern
- **Trigger identification**: "Your usage spikes 2 hours after stress events"
- **Circadian rhythm analysis**: Track if usage time shifts (e.g., progressively later)
- **Autocorrelation**: Identify if today's usage predicts tomorrow's
