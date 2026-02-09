# Understanding Trend Indicators

This file explains the colored trend arrows that appear on many widgets throughout the app. The color convention in Ash Trail is **intentionally inverted** from what you might expect in a typical dashboard — because in a harm-reduction app, *less* usage is the desired direction.

← [Back to Index](README.md)

---

## Default Convention (Most Widgets)

Most widgets use this convention:

| Appearance | Arrow | Meaning |
|------------|-------|---------|
| 🟢 Green | ↓ (down) | Usage **decreased** compared to the reference period — positive progress toward reduction |
| 🔴 Red | ↑ (up) | Usage **increased** compared to the reference period — concerning trend |
| — | (none) | Not enough data to calculate a trend, or comparison period has no entries |

**Why is this "backwards"?** In typical dashboards (financial, performance), green ↑ means "going up = good." But Ash Trail is a harm-reduction app — the goal is to use *less*. So green ↓ means "going down = good." This applies to hit counts, durations, and other usage metrics.

**Widgets using the default convention:**
- Hits Today (green ↓ = fewer hits than yesterday)
- Total Today (green ↓ = less total duration than yesterday's pace)
- Avg Per Hit (green ↓ = shorter sessions)
- Duration Trend (green ↓ = sessions getting shorter)
- Today vs Yesterday (green ↓ = less than yesterday in both count and duration)
- Today vs Week Avg (green ↓ = below 7-day average)

---

## Inverted Convention (Rating Widgets)

Some widgets where a **higher** value is desirable use the standard (non-inverted) convention:

| Appearance | Arrow | Meaning |
|------------|-------|---------|
| 🟢 Green | ↑ (up) | Rating **improved** (higher mood/physical = good) |
| 🔴 Red | ↓ (down) | Rating **worsened** (lower mood/physical = bad) |
| — | (none) | Not enough data |

**Widgets using the inverted convention:**
- Mood/Physical Avg (green ↑ = mood or physical rating went up = feeling better)

The widget builder sets an `invertTrend` flag when the metric is one where higher = better.

---

## Percentage Calculation

The trend percentage is calculated as:

$$\text{trend} = \frac{\text{current} - \text{reference}}{\text{reference}} \times 100$$

Rounded to the nearest integer.

**Example:** If yesterday you had 10 hits and today you have 8:
- Change = (8 − 10) / 10 × 100 = **−20%**
- Displayed as: 🟢 ↓ 20% (green down arrow — 20% fewer hits)

**Example:** If yesterday your total duration was 5 minutes and today it's 6 minutes:
- Change = (6 − 5) / 5 × 100 = **+20%**
- Displayed as: 🔴 ↑ 20% (red up arrow — 20% more total duration)

---

## Hour-Block Pacing (Duration Trend)

The "Total Today" duration widget doesn't naively compare today's total to yesterday's full-day total — that would always show a decrease until the day is over (since the day isn't finished yet).

Instead, it uses **hour-block pacing**:

1. Determines what fraction of the logical day has elapsed (e.g., at 3 PM, about 37.5% of the 24-hour period since 6 AM)
2. Takes yesterday's full-day total and multiplies by that fraction to get "what yesterday looked like at this point in the day"
3. Compares today's actual total to that pro-rated amount
4. Same approach is used for the 7-day daily average comparison

This gives a fair comparison even at 10 AM. If yesterday's total was 60 minutes and it's now noon (25% through the day), the expected pace is 15 minutes. If today's actual total is 12 minutes, the trend shows 🟢 ↓ 20% (you're 20% below yesterday's pace).

---

## No Trend / Neutral State

When there isn't enough data to calculate a trend, no trend arrow is shown. This happens when:
- There are no entries in the reference period (e.g., no entries yesterday to compare to)
- The reference value is zero (division by zero — no percentage can be computed)
- The widget type doesn't support trends (e.g., First Hit Today, Active Hours, pattern widgets)

Some widgets show a gray dash (—) in place of the trend badge, while others simply omit the trend section entirely.

---

## Quick Reference

| Appearance | Default Meaning | Inverted Meaning |
|------------|----------------|------------------|
| 🟢 ↓ 20% | Usage down 20% (good) | Rating down 20% (bad) |
| 🔴 ↑ 15% | Usage up 15% (concerning) | Rating up 15% (good) |
| — | Not enough data | Not enough data |

---

← [Back to Index](README.md)
