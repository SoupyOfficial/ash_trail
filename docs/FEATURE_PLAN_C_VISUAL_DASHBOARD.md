# Feature Plan C: Visual Dashboard & Charts

## Overview
Focuses on rich visualizations that provide intuitive, at-a-glance understanding of usage patterns. Emphasizes micro-charts and animated progress indicators.

---

## Features

### 1. 7-Day Sparkline Chart
**Description**: Inline sparkline showing 7-day trend (hit count per day) to quickly visualize weekly trajectory.

**Data Requirements**:
- Daily hit counts for last 7 days
- Reference line (average, target, or previous week)

**User Stories**:
- As a user, I want to see my 7-day trend at a glance without navigating to analytics
- As a user reducing, I want visual confirmation of improvement
- As a user, I want to see if usage is trending up or down

**Data Flow**:
```
LogRecords (last 7 days)
  → Group by calendar day
  → Count hits per day
  → Normalize to screen width (7 points)
  ↓
Optional: Calculate baseline (week average)
  ↓
Render:
  - Line connecting points
  - Fill below line with gradient
  - Hover/tap shows day + count
```

**Widget Changes**:
- Small inline sparkline (width: 100%, height: 60px) in statistics area
- Colors: Green trend (improving) | Red trend (increasing) | Gray (stable)
- Points as circles with count labels on hover
- Smooth animation on data update

**Implementation Details**:
```
Example output:
  Mon  Tue  Wed  Thu  Fri  Sat  Sun
   3    5    4    2    1    2    1   ← counts
   
   ╱╲          Visual representation:
  ╱  ╲____╱╲___  (upward = green, downward = red)
 ╱          ╲
```

**Implementation Complexity**: Low-Medium

---

### 2. Daily Activity Heat Map
**Description**: 7x4 (or 7x5) calendar grid showing activity intensity for each day of the last 4-5 weeks. Similar to GitHub contribution graph.

**Data Requirements**:
- Daily hit counts for last 30-35 days
- Min/max for color scaling
- Day of week labels

**User Stories**:
- As a user, I want to visualize my usage patterns across a month
- As a user reducing, I want to see which days I succeeded
- As a user, I want to identify "clean" vs. "heavy" days at a glance

**Data Flow**:
```
LogRecords (last 35 days)
  → Group by calendar day
  → Count hits per day
  ↓
Normalize color scale:
  0 hits → light gray
  1-2 hits → light green
  3-5 hits → medium green
  6-10 hits → darker green
  10+ hits → darkest (red if above target)
  ↓
Arrange: 7 columns (Mon-Sun) × 5 rows (weeks)
  ↓
Add tooltips: "Wednesday, 5 hits"
```

**Widget Changes**:
- Heat map grid (responsive size)
- Color legend (0 | 1-2 | 3-5 | 6-10 | 10+)
- Day-of-week headers (Mo, Tu, We, Th, Fr, Sa, Su)
- Week numbers on left
- Tap cell to see details (hits by hour, reasons)

**Example Visual**:
```
Week 1:  🟩 🟩 🟨 🟩 🟩 🟥 🟥   (Legend: light=low, red=high)
Week 2:  🟩 🟨 🟨 🟩 🟩 🟩 🟨
Week 3:  🟩 🟩 🟩 🟨 🟩 🟨 🟩
Week 4:  🟩 🟩 🟨 🟨 🟨 🟩 🟩
Week 5:  🟩 🟩 🟩 🟨 🟥 (current)
```

**Implementation Complexity**: Medium

---

### 3. Hourly Distribution Mini Chart
**Description**: Bar chart (horizontal or vertical) showing distribution of hits across 24 hours.

**Data Requirements**:
- Hour-of-day for each hit (last 7 days or last 30 days)
- Aggregated count per hour

**User Stories**:
- As a user, I want to see which hours I'm most active
- As a user, I want to identify high-risk times
- As a user reducing, I want to know when to be extra vigilant

**Data Flow**:
```
LogRecords (period: this week or this month)
  → Extract hour from eventAt (0-23)
  → Count occurrences per hour
  → Calculate percentage of total
  ↓
Find peak hour (max count)
  ↓
Render: 24-bar chart or grouped (6am-noon, noon-6pm, etc.)
```

**Widget Changes**:
- Compact bar chart (vertical bars, 24 columns or 4 groups)
- Color: Intensity based on count (light to dark)
- Peak hour highlighted/labeled
- Interaction: Tap bar to see exact count + percentage

**Example Visual** (grouped):
```
Morning (6am-12pm):  ████░░░ 15 hits (22%)
Afternoon (12-6pm):  ██████░ 22 hits (31%)
Evening (6pm-12am):  █████░░ 19 hits (27%)
Night (12am-6am):    ██░░░░░ 14 hits (20%)
                     Peak: 3 PM (8 hits, 12%)
```

**Implementation Complexity**: Low-Medium

---

### 4. Mood/Physical Rating Distribution
**Description**: Visual representation of mood and physical ratings from logs (histogram or gauge).

**Data Requirements**:
- `moodRating` and `physicalRating` from LogRecords
- Period filtering (today, week, month)

**User Stories**:
- As a user, I want to see if my mood improves/worsens with usage
- As a user, I want visual feedback on my physical state trends
- As a user, I want to correlate ratings with usage patterns

**Data Flow**:
```
LogRecords (period)
  → Extract moodRating + physicalRating
  → Group into buckets: 1-3 (low) | 4-6 (med) | 7-10 (high)
  → Count per bucket
  ↓
Calculate: average, min, max, trend
  ↓
Display: 
  - Gauge (0-10 scale)
  - Histogram bars
  - Trend arrow
```

**Widget Changes**:
- Side-by-side gauges (Mood | Physical) showing:
  - Current average (needle/indicator)
  - Trend (↑ improving | ↓ declining | → stable)
  - Distribution histogram below gauge
- Color zones: Red (1-3) | Yellow (4-6) | Green (7-10)

**Example Visual**:
```
Mood Today         Physical Today
  Average: 6.2       Average: 5.8
  ↓ Down 0.3 pts     → Stable
  
  🟢 ← needle @ 6     🟡 ← needle @ 5
  ▓▓ High (7-10)     ▓ High (7-10)
  ▓▓▓ Med (4-6)       ▓▓▓ Med (4-6)
  ▓ Low (1-3)        ▓▓ Low (1-3)
```

**Implementation Complexity**: Medium

---

### 5. Progress Rings
**Description**: Circular progress indicators for daily limits, weekly goals, and streak targets.

**Data Requirements**:
- Daily limit (if set)
- Today's hit count
- Weekly goal/target
- This week's count
- Streak counter

**User Stories**:
- As a user, I want animated progress rings showing goal achievement
- As a user, I want visual motivation from seeing progress
- As a user, I want quick status check

**Data Flow**:
```
For Daily Limit:
  current_hits / limit → percentage (0-100%)
  → Animate ring fill
  → Color: Green (0-60%) | Yellow (60-90%) | Orange (90-100%) | Red (>100%)
  
For Weekly Goal:
  this_week_hits / goal_hits → percentage
  → Same color scheme
  
For Streak:
  current_streak / best_streak → percentage
  → Color: Gold/purple for achievement
```

**Widget Changes**:
- Three concentric progress rings:
  1. Outer ring: Daily limit progress
  2. Middle ring: Weekly goal progress
  3. Inner ring: Streak achievement
- Center text shows current focus metric
- Ring animation on data update (smooth spin/fill)
- Tap to cycle through metrics

**Example Visual**:
```
       Daily Limit
        (3/5 hits)
        
      ╭─────────╮
     ╱  5 Limit  ╲
    │  ⭕ 60% ⭕   │
     ╲  Goal Met  ╱
      ╰─────────╯
      
Color progression as fills:
  0% empty gray
  50% green ring
  100% full gold ring
```

**Implementation Complexity**: Medium-High

---

### 6. Trend Comparison Dashboard
**Description**: Side-by-side comparison charts showing multiple time periods.

**Data Requirements**:
- This week vs. last week hit counts
- This week vs. month average
- Peak hours comparison

**User Stories**:
- As a user, I want to quickly compare my performance across periods
- As a user reducing, I want proof of improvement
- As a user, I want to identify new patterns

**Data Flow**:
```
Fetch data for:
  - This week (7 days)
  - Last week (7 days)
  - Monthly average
  
Create side-by-side visualizations:
  - Bar charts: This week vs. Last week
  - Trend lines: Month progression
  - Metric comparison: Peak hours, avg duration
```

**Widget Changes**:
- Tabbed view or carousel:
  1. Week-over-week comparison
  2. Daily average over last month
  3. Peak times comparison
- Each tab shows visual + key metrics + % change

**Implementation Complexity**: Medium

---

## Technical Implementation

### Chart Library Options
1. **`fl_chart`** (Flutter Pub) - Easy, customizable, lightweight
2. **`syncfusion_flutter_charts`** - Professional, feature-rich
3. **Custom Canvas** - Full control, more code

**Recommendation**: Start with `fl_chart` for quick implementation, migrate to custom Canvas if performance needed.

---

## Data Model Changes

No new database fields needed. All visualizations derive from existing LogRecord data:
- `eventAt` (timestamp)
- `duration`
- `moodRating`, `physicalRating`
- `reasons`

---

## UI/UX Guidelines

- **Responsive**: Charts adapt to screen width
- **Color consistency**: Use app color scheme
  - Primary (current): `colorScheme.primary`
  - Success (improving): Green
  - Warning (increasing): Orange/Yellow
  - Alert (concerning): Red
- **Animation**: Smooth transitions when data updates (500-1000ms)
- **Interactivity**: Tap/long-press for details, pinch-to-zoom for heat map
- **Accessibility**: Provide numeric values alongside visuals

---

## Implementation Priority

1. **Phase 1** (Low effort): 7-day sparkline + Hourly distribution chart
2. **Phase 2** (Medium effort): Heat map calendar + Mood/physical gauges
3. **Phase 3** (Medium effort): Progress rings + Trend comparison
4. **Phase 4** (Polish): Animations, responsive sizing, interactions

---

## Performance Considerations

- Memoize chart data calculations to avoid rebuilds
- Limit history to last 90 days for heat map
- Lazy load charts below fold
- Use `RepaintBoundary` for expensive widgets
