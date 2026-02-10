# event_type_pie_chart

> **Source:** `lib/widgets/charts/event_type_pie_chart.dart`

## Purpose
Interactive pie chart showing the breakdown of log entries by event type. Built with `fl_chart`. Includes touch-to-expand sections, percentage labels, badge icons on touch, and a color-coded legend.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework
- `package:fl_chart/fl_chart.dart` — PieChart, PieChartData, PieChartSectionData
- `../../models/enums.dart` — EventType enum

## Pseudo-Code

### Class: EventTypePieChart (StatefulWidget)

**Constructor Parameters:**
- `eventTypeCounts: Map<EventType, int>` — count per event type
- `title: String` — default "Event Types"

#### State: _EventTypePieChartState

**State Variables:**
- `_touchedIndex: int` — default `-1`

#### Method: build(context) → Widget
```
IF eventTypeCounts empty → _buildEmptyState (pie_chart_outline + "No event data")

COMPUTE total = sum of all counts

RETURN Card → Padding(16) → Column:
  ├─ Text(title, titleMedium)
  └─ Row:
      ├─ Expanded(flex: 3) → AspectRatio(1:1) → PieChart:
      │   pieTouchData:
      │     touchCallback → UPDATE _touchedIndex (postFrameCallback)
      │   sectionsSpace: 2
      │   centerSpaceRadius: 40
      │   sections: _buildSections(total)
      │
      └─ Expanded(flex: 2) → _buildLegend(context, total)
```

#### Method: _buildSections(total) → List<PieChartSectionData>
```
FOR each eventType entry (indexed):
  isTouched = index == _touchedIndex
  percentage = (value / total) × 100
  color = _getEventTypeColor(type)
  
  RETURN PieChartSectionData:
    color, value
    title: IF touched → "XX.X%" ELSE → ""
    radius: IF touched → 60 ELSE → 50
    titleStyle: bold white with shadow
    badgeWidget: IF touched → _buildBadge (circular icon)
    badgePositionPercentageOffset: 1.3
```

#### Method: _buildBadge(EventType, Color) → Container
```
Circular container with event icon in white, drop shadow
```

#### Method: _buildLegend(context, total) → Column
```
FOR each eventType entry:
  Row: colored circle dot + event name (ellipsis) + count
```

#### Color Mapping (_getEventTypeColor):
```
vape → indigo    | inhale → blue    | sessionStart → green
sessionEnd → red | note → orange    | tolerance → purple
symptomRelief → teal | purchase → amber | custom → grey
```

#### Icon Mapping (_getEventTypeIcon):
```
vape → cloud | inhale → air | sessionStart → play_circle
sessionEnd → stop_circle | note → note | tolerance → trending_up
symptomRelief → healing | purchase → shopping_cart | custom → star
```
