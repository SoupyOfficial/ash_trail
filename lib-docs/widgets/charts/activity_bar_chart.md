# activity_bar_chart

> **Source:** `lib/widgets/charts/activity_bar_chart.dart`

## Purpose
Interactive bar chart displaying daily activity (entry count or total duration). Built with `fl_chart`, supports touch interactions with tooltips and a highlighted tooltip badge in the header. Adapts bar width and label intervals based on data density.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:fl_chart/fl_chart.dart` — BarChart, BarChartData, BarChartGroupData, BarChartRodData, FlTitlesData, etc.
- `../../models/daily_rollup.dart` — DailyRollup model (date, eventCount, totalValue)

## Pseudo-Code

### Class: ActivityBarChart (StatefulWidget)

**Constructor Parameters:**
- `rollups: List<DailyRollup>` — daily aggregated data
- `title: String` — default "Daily Activity"
- `barColor: Color` — default blue
- `showDuration: bool` — default false (shows count; true → total seconds)

#### State: _ActivityBarChartState

**State Variables:**
- `_touchedIndex: int` — default `-1` (no selection)

#### Method: build(context) → Widget
```
IF rollups empty → _buildEmptyState (bar_chart icon + "No data available")

COMPUTE maxY = _getMaxValue()

RETURN Card → Padding(16) → Column:
  ├─ Row:
  │   ├─ Text(title, titleMedium)
  │   └─ IF touched index valid → _buildTooltipBadge(rollup)
  │
  └─ SizedBox(height: 200) → BarChart:
      alignment: spaceAround
      maxY: maxY × 1.1
      barTouchData:
        enabled: true
        tooltipData:
          color: inverseSurface
          getTooltipItem: "{date}\n{value}s or {count} entries"
        touchCallback:
          ON interaction → UPDATE _touchedIndex (deferred via postFrameCallback)
      titlesData: _buildTitlesData (bottom MM/DD labels, left integer axis)
      borderData: bottom + left lines
      gridData: horizontal lines only
      barGroups: _buildBarGroups
      duration: 300ms animation
```

#### Method: _getMaxValue() → double
```
MAP rollups to values (duration or count)
RETURN max or 5 if empty
```

#### Method: _buildBarGroups() → List<BarChartGroupData>
```
FOR each rollup:
  value = showDuration ? totalValue : eventCount
  isTouched = index == _touchedIndex
  RETURN BarChartGroupData:
    barRods: [BarChartRodData(
      toY: value
      color: barColor (full if touched, 0.7 alpha otherwise)
      width: _calculateBarWidth() (20/12/8/4 based on count)
      borderRadius: top corners only
      backDrawRodData: faint background bar
    )]
    showingTooltipIndicators: [0] if touched
```

#### Method: _calculateBarWidth() → double
```
≤7 bars → 20  |  ≤14 → 12  |  ≤30 → 8  |  >30 → 4
```

#### Method: _calculateLabelInterval() → int
```
≤7 → 1  |  ≤14 → 2  |  ≤30 → 5  |  >30 → 7
```

#### Method: _buildTooltipBadge(rollup) → Container
```
Rounded container with light barColor background:
  "{value}s on {date}" or "{count} on {date}"
```
