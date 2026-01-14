# Feature Plan D: Gamification & Achievements

## Overview
Adds motivation through streaks, badges, milestones, and progress toward goals. Encourages sustained engagement with celebration and recognition of achievements.

---

## Features

### 1. Streak System
**Description**: Track consecutive days meeting a condition (below limit, clean days, logging consistency).

**Data Requirements**:
- Daily hit counts (last 90 days)
- User's chosen condition (below limit | clean days | daily logging)
- Calendar dates

**User Stories**:
- As a user reducing, I want to celebrate consecutive days below my limit
- As a user, I want visual motivation from maintaining a streak
- As a user, I want my best streaks recorded for lifetime achievement
- As a user, I want a daily reminder when a streak is at risk

**Data Flow**:
```
Condition selection: User chooses one of:
  1. Days below daily limit
  2. Clean days (0 hits)
  3. Consistent logging (at least 1 hit/day)
  
Calculate streaks:
  → Look at last 90 days
  → For each day, check if meets condition
  → Count consecutive days meeting condition
  → Track: Current streak | Best streak | Days until broken
  
Display:
  - 🔥 Current streak: 7 days
  - 🏆 Best streak: 21 days (Jan 1-21)
  - ⚠️ Risk if no action in 12 hours
```

**Widget Changes**:
- Streak badge with emoji and counter (🔥 7)
- Sub-text: "days [condition]"
- Tap to see streak history/calendar
- Best streak badge (🏆 21 days)
- Animated notification when streak breaks/continues

**Database Changes**:
```dart
class StreakData {
  int currentStreak = 0;
  DateTime currentStreakStart = DateTime.now();
  int bestStreak = 0;
  DateTime bestStreakStart = DateTime.now();
  String streakCondition; // 'below_limit' | 'clean' | 'consistent'
  DateTime lastCheckedDate = DateTime.now();
}

// Add to Account model
StreakData? streakData;
```

**Implementation Complexity**: Medium

---

### 2. Achievement Badges/Milestones
**Description**: Unlock badges for reaching specific goals (100 days, 30-day reduction, etc.).

**Data Requirements**:
- Account creation date
- Cumulative stats
- Streak data
- Reduction metrics

**User Stories**:
- As a user, I want to unlock badges for hitting milestones
- As a user, I want visual recognition of my achievements
- As a user, I want to compare my badges with friends (future social feature)
- As a user, I want to share achievements

**Potential Badges**:

| Badge | Condition | Rarity | Emoji |
|-------|-----------|--------|-------|
| First Log | Log first entry | Common | 🎬 |
| Week Warrior | 7 consecutive logging days | Common | ⚔️ |
| Month Champion | 30 days logged | Uncommon | 🏆 |
| Century | 100 total log entries | Uncommon | 💯 |
| Iron Will | 14-day clean streak | Rare | 💪 |
| Reduction Master | 50% usage reduction vs baseline | Rare | 📉 |
| Perfect Week | No days over limit (7 days) | Uncommon | ⭐ |
| Mood Keeper | Logged mood 20+ times | Common | 😊 |
| Analyst | Viewed analytics 50+ times | Common | 📊 |
| Consistent | Streak of 30+ days | Rare | 🔥 |
| Marathon | 90 days of activity | Epic | 🏃 |
| Transformation | 75%+ reduction sustained | Epic | 🦋 |

**Data Flow**:
```
Daily calculation:
  → Check if new milestones unlocked
  → Compare current stats to badge conditions
  → Mark badges as unlocked
  → Show celebration popup if new badge
  
Display: Badges grid with:
  - Locked vs. Unlocked visual
  - Progress bar (e.g., "12/14 days for Iron Will")
  - Unlock date (if earned)
```

**Widget Changes**:
- Badge collection view (scrollable grid)
- Locked badges shown with progress
- Unlocked badges highlighted with glow effect
- Tap for badge details (description, unlock date, how it helps)
- Share button for each badge

**Database Changes**:
```dart
class BadgeData {
  String badgeId; // 'first_log', 'week_warrior', etc.
  DateTime? unlockedAt;
  bool isUnlocked = false;
  int progress = 0; // For tracking progress to unlock
}

// Add to Account model
List<BadgeData> badges = [];
```

**Implementation Complexity**: Medium-High

---

### 3. Level/XP System
**Description**: Gain XP for activities (logging, streak days, goal achievement) to level up.

**Data Requirements**:
- Log entries
- Streak continuation
- Goal achievement
- Consistent action

**User Stories**:
- As a user, I want a sense of progression through levels
- As a user, I want XP rewards for positive behaviors
- As a user, I want a visual level-up celebration

**XP Award Structure**:
- Log entry: 10 XP base (+ 5 if mood/physical added, + 5 if reason added)
- Daily streak continuation: 20 XP
- Weekly goal met: 50 XP
- Below daily limit: 15 XP
- Clean day: 30 XP
- Achieving new personal record: 100 XP

**Data Flow**:
```
User action (log, streak day, goal met)
  → Calculate XP earned
  → Add to Account.totalXP
  → Check if level threshold reached
  → If level up: Show celebration, unlock new features
  
Level progression:
  Lvl 1: 0 XP
  Lvl 2: 100 XP
  Lvl 3: 250 XP
  Lvl 4: 450 XP
  ... (quadratic or exponential curve)
  Lvl 20: 5000 XP
```

**Widget Changes**:
- Level badge: "Level 5" with progress bar
- Current XP/Next level XP: "340/450"
- Tap for XP breakdown (what earned today)
- Level-up notification with confetti animation

**Database Changes**:
```dart
// Add to Account model
int totalXP = 0;
int currentLevel = 1;

// Recent XP log for transparency
List<XPEvent> recentXP = []; // timestamp, amount, reason
```

**Implementation Complexity**: Medium

---

### 4. Daily Challenge/Quest System
**Description**: Optional daily missions that reward XP when completed (e.g., "Log 5 hits today", "Stay under limit").

**Data Requirements**:
- Today's count
- Daily limit
- Logging activity
- Streak status

**User Stories**:
- As a user, I want daily challenges to keep me engaged
- As a user, I want to earn bonus XP for completing challenges
- As a user, I want variety in the challenges presented

**Example Daily Challenges**:
- "Log your activity" (1 XP)
- "Add mood rating to 3 logs" (25 XP)
- "Stay under daily limit" (50 XP)
- "Maintain your streak" (20 XP)
- "Log with a reason" (15 XP)
- "Complete 5 logs today" (40 XP)
- "Write a note with your log" (20 XP)

**Data Flow**:
```
Daily reset at midnight:
  → Generate 3-5 random challenges
  → Assign XP rewards
  → Show notification
  
Throughout day:
  → Monitor challenge progress
  → Update UI with completion % 
  → Award XP when completed
  → Show celebration
```

**Widget Changes**:
- Challenges card on home screen
- Progress bars for each challenge
- "2/5 logs" style progress display
- Checkmark when completed
- Bonus XP badge when done

**Database Changes**:
```dart
class DailyChallenge {
  String challengeId; // 'log_activity', 'stay_under_limit', etc.
  String title;
  String description;
  int targetProgress;
  int currentProgress = 0;
  int xpReward;
  bool isCompleted = false;
  DateTime createdAt = DateTime.now();
}

// Add to Account model
List<DailyChallenge> dailyChallenges = [];
DateTime lastChallengeReset = DateTime.now();
```

**Implementation Complexity**: Medium-High

---

### 5. Leaderboards (Future Social Feature)
**Description**: Compare streaks, levels, and achievements with friends or community (optional, privacy-respecting).

**Data Requirements**:
- Streak length
- Current level
- Total XP
- Badges unlocked

**User Stories**:
- As a user, I want friendly competition to motivate me
- As a user, I want to share my achievements
- As a user, I want privacy control over visibility
- As a user, I want to see how I compare globally (anonymous)

**Types of Leaderboards**:
1. Friend leaderboards (weekly/all-time streaks)
2. Anonymous global (weekly level gains, reduction %)
3. Achievement showcase (who unlocked what first)

**Privacy Model**:
- All leaderboards opt-in
- Users choose what data is shared
- Anonymous global leaderboard uses aggregate data
- Friend lists are explicit (not social media import)

**Implementation Complexity**: High (requires backend, requires social features)

**Status**: Defer to Phase 2 after core gamification works

---

### 6. Reward/Milestone Notifications
**Description**: Celebrate achievements with engaging notifications and in-app popups.

**User Stories**:
- As a user, I want to feel celebrated when I achieve goals
- As a user, I want timely notifications before streaks break
- As a user, I want customizable notification frequency

**Notification Types**:
- Badge unlocked: Popup with badge graphics + confetti
- Streak milestone: "🔥 7-day streak! Keep it up!"
- Level up: "Congratulations! You're now Level 5! 🎉"
- New challenge available: "Daily challenges refreshed"
- Streak at risk: "Streak at risk in 2 hours - time to log!"
- Goal achieved: "You stayed under your limit today! ⭐"

**Implementation Complexity**: Medium

---

## Data Model Changes

```dart
// New classes
class StreakData {
  int currentStreak = 0;
  DateTime currentStreakStart = DateTime.now();
  int bestStreak = 0;
  DateTime bestStreakStart = DateTime.now();
  String streakCondition; // 'below_limit' | 'clean' | 'consistent'
  DateTime lastCheckedDate = DateTime.now();
}

class BadgeData {
  String badgeId;
  DateTime? unlockedAt;
  bool isUnlocked = false;
  int progress = 0;
}

class DailyChallenge {
  String challengeId;
  String title;
  String description;
  int targetProgress;
  int currentProgress = 0;
  int xpReward;
  bool isCompleted = false;
  DateTime createdAt = DateTime.now();
}

class XPEvent {
  int amount;
  String reason; // 'log_entry', 'streak_day', 'goal_met', etc.
  DateTime earnedAt = DateTime.now();
}

// Update Account model
class Account {
  // ... existing fields ...
  
  // Gamification
  int totalXP = 0;
  int currentLevel = 1;
  StreakData? streakData;
  List<BadgeData> badges = [];
  List<DailyChallenge> dailyChallenges = [];
  List<XPEvent> recentXP = [];
  DateTime lastChallengeReset = DateTime.now();
  
  // Settings
  bool enableGamification = true;
  bool enableNotifications = true;
  bool shareAchievements = false;
}
```

---

## UI/UX Guidelines

- **Celebration**: Use confetti, animations, satisfying sounds (if enabled)
- **Colors**: Use gold for achievements, vibrant colors for progression
- **Accessibility**: Provide text descriptions of visual achievements
- **Subtlety**: Gamification should enhance, not distract
- **Opt-in**: All features toggleable in settings

---

## Implementation Priority

1. **Phase 1** (Medium effort): Basic streaks + Milestone notifications
2. **Phase 2** (Medium-High effort): Achievement badges + Level/XP system
3. **Phase 3** (High effort): Daily challenges + Challenge rewards
4. **Phase 4** (Defer): Leaderboards + Social features

---

## Psychological Principles

This gamification system leverages:
- **Progress**: Visible level advancement
- **Achievement**: Unlockable badges
- **Mastery**: Streak maintenance
- **Autonomy**: Choose streak condition, opt-in features
- **Social**: Optional comparison (future phase)
- **Purpose**: XP ties to habit formation goals

---

## Potential Issues & Mitigations

| Issue | Mitigation |
|-------|-----------|
| Over-gamification | Make all features optional, use subtle UX |
| Negative reinforcement from broken streaks | Reframe as "new opportunity", allow reset |
| Data privacy with leaderboards | Strict opt-in, anonymous aggregates |
| Screen bloat from notifications | Consolidate notifications, daily digest option |
| Game mechanics vs. wellness goals conflict | Ensure challenges support harm reduction |
