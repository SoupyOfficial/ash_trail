# activity_line_chart

> **Source:** `lib/widgets/charts/activity_line_chart.dart`

## Purpose
Interactive line chart showing daily activity trends with a curved line, gradient fill area, interactive dots, and touch tooltips. Built with `fl_chart`. Adapts axis label intervals based on data density.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:fl_chart/fl_chart.dart` — LineChart, LineChartData, LineChartBarData, FlSpot, FlDotData, etc.
- `../../models/daily_rollup.dart` — DailyRollup model

## Pseudo-Code

### Class: ActivityLineChart (StatefulWidget)

**Constructor Parameters:**
- `rollups: List<DailyRollup>` — daily aggregated data
- `title: String` — default "Daily Activity"
- `lineColor: Color` — default blue
- `showDuration: bool` — default false (count vs duration)

#### State: _ActivityLineChartState

**State Variables:**
- `_touchedIndex: int?` — currently highlighted data point

#### Method: build(context) → Widget
```
IF rollups empty → _buildEmptyState (show_chart icon + "No data available")

COMPUTE spots = _buildSpots()
COMPUTE maxY from spots

RETURN Card → Padding(16) → Column:
  ├─ Row:
  │   ├─ Text(title, titleMedium)
  │   └─ IF _touchedIndex valid → _buildTooltipBadge(rollup)
  │
  └─ SizedBox(height: 200) → LineChart:
      gridData: horizontal lines only
      titlesData: _buildTitlesData (bottom MM/DD, left integers)
      borderData: bottom + left lines
      minX: 0, maxX: length-1
      minY: 0, maxY: maxY×1.1 or 5
      lineTouchData:
        tooltipData:
          color: inverseSurface
          items: "{date}\n{value}s or {count} entries"
        touchCallback:
          ON FlTapUpEvent or FlPanUpdateEvent → UPDATE _touchedIndex
        handleBuiltInTouches: true
      lineBarsData: [LineChartBarData:
        spots: spots
        isCurved: true (smoothness: 0.3)
        color: lineColor, barWidth: 3
        dotData:
          IF highlighted → radius 6, white stroke 2
          ELSE → radius 3, no stroke
        belowBarData: BarAreaData(gradient from 0.3 to 0.05 alpha)
      ]
      duration: 300ms animation
```

#### Method: _buildSpots() → List<FlSpot>
```
MAP rollups indexed:
  x = index
  y = showDuration ? totalValue : eventCount
```

#### Method: _calculateXInterval() → double
```
≤7 → 1  |  ≤14 → 2  |  ≤30 → 5  |  else → ceil(length/6)
```

#### Method: _buildTooltipBadge(rollup) → Container
```
Same as ActivityBarChart: rounded badge with value + date
```
