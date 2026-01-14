# Feature Plan A: Health-Focused Statistics

## Overview
Emphasizes wellness correlations, user health goals, and daily targets. Focuses on mood, physical state tracking, and helping users set/monitor personal limits.

---

## Features

### 1. Mood & Physical Rating Correlations
**Description**: Show average mood and physical ratings alongside usage patterns to identify correlations between usage and wellbeing.

**Data Requirements**:
- `moodRating` from LogRecord (1-10 scale)
- `physicalRating` from LogRecord (1-10 scale)
- Filter by time period

**User Stories**:
- As a user, I want to see my average mood today vs. my average usage to understand if I'm using more when I'm down
- As a user, I want to compare my physical rating before/after to track physical impact

**Data Flow**:
```
LogRecords (with moodRating, physicalRating) 
  → Filter by period (today, yesterday, week)
  → Calculate avg ratings per period
  → Compare to usage patterns
  → Display insights ("High usage correlated with low mood")
```

**Widget Changes**:
- Add mood/physical stat cards (avg rating displayed with color coding 1-5=red, 6-7=yellow, 8-10=green)
- Show mood/physical trend alongside usage trend
- Optional: "Correlation strength" indicator

**Implementation Complexity**: Low-Medium

---

### 2. Daily Limit/Goal Tracking
**Description**: Users set a daily target (e.g., max 5 hits/day) and widget shows progress toward that goal.

**Data Requirements**:
- New field: `Account.dailyUsageLimit` (optional)
- Today's hit count
- Alert threshold (e.g., 80% of limit)

**User Stories**:
- As a user trying to reduce, I want to set a daily limit and see my progress
- As a user, I want a warning when I'm approaching my daily limit
- As a user, I want to see when I've exceeded my limit for the day

**Data Flow**:
```
Account.dailyUsageLimit (if set)
  ↓
Today's LogRecords
  ↓
Calculate: count / limit = percentage
  ↓
Display progress bar with color coding:
  - Green: 0-60%
  - Yellow: 60-90%
  - Orange: 90-100%
  - Red: >100%
```

**Widget Changes**:
- Add progress bar/ring showing "3/5 hits today"
- Color-coded based on percentage
- Show "X hits remaining" or "Over by X hits"
- Badge icon when exceeded

**Database Changes**:
```dart
// Add to Account model
int? dailyUsageLimit; // null = no limit set
```

**Implementation Complexity**: Low

---

### 3. Reduction Goal Progress
**Description**: Users set a reduction target (e.g., "20% less than last week") and track progress toward it.

**Data Requirements**:
- New field: `Account.weeklyReductionTarget` (percentage)
- This week's hit count
- Last week's hit count
- Month-to-date average

**User Stories**:
- As a user working toward reduction, I want to see if I'm on track to meet my weekly goal
- As a user, I want to visualize my improvement over time
- As a user, I want to see what % reduction I've achieved this week

**Data Flow**:
```
This week count vs. Last week count
  → Calculate: (last_week - this_week) / last_week * 100
  ↓
Compare to user's target reduction %
  ↓
Status: "On track" / "Ahead" / "Behind"
  ↓
Display with visual indicator (thermometer style)
```

**Widget Changes**:
- Comparison card: "Last week: 15 hits | This week: 12 hits | Target: -20% ✓"
- Visual thermometer showing progress toward goal
- Motivational message based on status

**Database Changes**:
```dart
// Add to Account model
int? weeklyReductionTargetPercent; // e.g., 20 for 20% reduction goal
```

**Implementation Complexity**: Medium

---

### 4. Streak Tracking (Reduction Focus)
**Description**: Track consecutive days with usage below daily limit or below average.

**Data Requirements**:
- Daily limit (if set)
- Historical daily counts
- Average daily baseline

**User Stories**:
- As a user, I want to see my streak of days staying under my limit
- As a user reducing, I want to celebrate maintaining low usage for consecutive days
- As a user, I want to see my best streak

**Data Flow**:
```
Get last 30 days of records
  → Group by calendar day
  → Count hits per day
  ↓
Compare each day to: limit OR moving average
  ↓
Calculate consecutive days below threshold
  ↓
Track: Current streak | Best streak this month | Days active
```

**Widget Changes**:
- Streak counter: "🔥 5 days under limit"
- Best streak badge: "Best: 12 days"
- Mini calendar showing streak (today's cell highlighted, broken days marked)

**Implementation Complexity**: Medium

---

### 5. Wellness Summary Card
**Description**: Comprehensive health snapshot combining mood, physical, limits, and goals.

**Data Requirements**:
- All of the above

**User Stories**:
- As a user, I want a wellness dashboard that shows my health in one view
- As a user, I want quick health status at a glance before drilling deeper

**Widget Changes**:
- Card showing:
  - Overall wellness rating (composite of mood + physical + goal progress)
  - Daily limit status
  - Current streak
  - Goal progress
  - Color indicator (healthy/at-risk/concerning)

**Implementation Complexity**: Medium (combines above features)

---

## Data Model Changes

```dart
// Add to Account model
class Account {
  // ... existing fields ...
  
  /// Optional daily usage limit for tracking/reduction
  int? dailyUsageLimit;
  
  /// Weekly reduction target as percentage (e.g., 20 for 20% reduction)
  int? weeklyReductionTargetPercent;
  
  /// Whether health insights feature is enabled
  bool enableHealthInsights = true;
}
```

---

## UI/UX Guidelines

- **Color scheme**: Use warm greens for positive, yellows for caution, reds for concerns
- **Messaging**: Positive reinforcement, supportive tone for users reducing
- **Optional toggles**: Let users enable/disable specific insights
- **Privacy**: All data stays local, no sharing without explicit consent

---

## Implementation Priority

1. **Phase 1** (Low effort): Mood/Physical ratings display + Daily limit tracking
2. **Phase 2** (Medium effort): Reduction goal progress + Basic streak
3. **Phase 3** (Polish): Wellness summary card + Mini calendar view

---

## Dependencies

- LogRecord model already has `moodRating`, `physicalRating`, `reasons`
- Will need Account preferences storage for limits/goals
- No external API dependencies
