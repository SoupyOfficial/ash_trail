# Secondary Data Widgets

These 2 widgets use the optional fields on each [entry](../glossary.md#entry) — mood rating, physical rating, and reasons — to surface contextual information. Since these fields are nullable (users may not fill them for every entry), the widgets only include entries where the respective field was actually provided. They help you correlate your usage with how you feel and understand *why* you use.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Mood/Physical Avg

**ID:** `moodPhysicalAvg` · **Size:** standard · **Category:** Secondary Data

**What it shows:** Two average ratings displayed side by side: mood (1–10) and physical (1–10), both for today and for the last 7 days. A rating of 1 = worst, 10 = best.

**How it's calculated:** For the mood average: filters entries (to today or last 7 days). Keeps only entries where the mood rating is not null. Sums all mood rating values and divides by the count of entries that had a mood rating. Same approach for physical rating — only entries with a non-null physical rating are included. Entries without ratings are excluded entirely (not counted as zero).

**How to interpret it:**
- Higher averages (closer to 10) mean you generally feel better — both mood and physical
- Lower averages (closer to 1) mean you generally feel worse
- Comparing today to the 7-day average shows whether today is better or worse than usual
- Trend arrow: this widget uses the **inverted convention** — green ↑ = rating improved (higher = good). Red ↓ = rating worsened (lower = bad). This is the opposite of most other widgets.

**Data source:** Mood ratings (`moodRating`) and physical ratings (`physicalRating`) from non-deleted records where those fields are non-null.

**Usefulness:** Helps you see if there's a correlation between usage patterns and how you feel. If your mood average drops on heavy-usage days, that's a signal worth noticing.

---

#### Top Reasons

**ID:** `topReasons` · **Size:** standard · **Category:** Secondary Data

**What it shows:** The top 3 most frequently selected [reasons](../glossary.md#log-reason) from the last 7 days, ranked by count. Each reason shows its icon and how many times it was selected.

**How it's calculated:** Takes all non-deleted entries from the last 7 days. For each entry that has a reasons list, iterates through each reason in the list and increments a frequency counter. Sorts the frequency map by count (highest first). Returns the top 3 reasons. Note that a single entry can have multiple reasons — each one is counted independently.

**How to interpret it:**
- The top reason is your most common trigger or context for using
- If "Stress Relief" is consistently #1, stress management strategies might help
- If "Habit" dominates, the behavior may be more automatic than intentional
- No trend arrow — this is a categorical breakdown, not a directional metric

**Data source:** Reason lists (`reasons`) from the last 7 days of non-deleted records where reasons were provided.

**Usefulness:** Surfaces *why* you use. Knowing your top reasons gives you actionable insight — if "Social" is your top reason, social situations are your biggest trigger. If "Habit" leads, focus on breaking the automatic routine.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
