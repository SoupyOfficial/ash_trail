# Responsive Layout System

The responsive layout system provides consistent, accessible, and adaptive layouts across different screen sizes for the AshTrail app.

## Quick Start

```dart
import 'package:ash_trail/features/responsive/responsive.dart';

// Simple adaptive layout
AdaptiveLayout(
  mobile: MobileView(),
  tablet: TabletView(), 
  desktop: DesktopView(),
)

// Dual-pane layout for wide screens
DualPaneLayout(
  primary: LogList(),
  secondary: LogDetails(),
)

// Responsive button with accessibility
ResponsiveButton(
  onPressed: () => doAction(),
  child: Text('Action'),
)
```

## Core Concepts

### Breakpoints

The system uses three breakpoints:
- **Mobile**: < 600dp (phones in portrait)
- **Tablet**: 600-839dp (phones in landscape, small tablets)
- **Desktop**: ≥ 840dp (large tablets, desktop)

### Layout Configuration

Default configuration enforces:
- 48px minimum tap targets
- Responsive padding (12px mobile, 16px tablet/desktop)
- Content max-width constraints (1200px)
- Consistent spacing values

## Components

### AdaptiveLayout

Renders different layouts based on breakpoint:

```dart
AdaptiveLayout(
  mobile: Column(children: [...]),
  tablet: Row(children: [...]),
  desktop: GridView(...),
)
```

### DualPaneLayout

Master-detail layout for wide screens:

```dart
DualPaneLayout(
  primary: ItemList(),
  secondary: ItemDetail(),
  primaryFlex: 1,
  secondaryFlex: 2,
)
```

### ResponsiveContainer

Constrains content width and applies responsive padding:

```dart
ResponsiveContainer(
  maxWidth: 800,
  child: Content(),
)
```

### Accessibility Components

#### MinTapTarget
Enforces minimum touch target size:

```dart
MinTapTarget(
  minSize: 48.0,
  child: SmallButton(),
)

// Or use extension
SmallButton().withMinTapTarget()
```

#### ResponsiveButton
Button with built-in accessibility:

```dart
ResponsiveButton(
  onPressed: onTap,
  minTapTarget: 48.0,
  child: Text('Action'),
)
```

#### ResponsiveIconButton
Icon button with tap target enforcement:

```dart
ResponsiveIconButton(
  onPressed: onTap,
  icon: Icon(Icons.add),
  tooltip: 'Add Item',
)
```

### Spacing & Padding

#### ResponsivePadding
Applies different padding per breakpoint:

```dart
ResponsivePadding(
  mobile: EdgeInsets.all(12),
  tablet: EdgeInsets.all(16),
  desktop: EdgeInsets.all(20),
  child: Content(),
)
```

#### ResponsiveGap
Creates responsive spacing:

```dart
Column(
  children: [
    Widget1(),
    ResponsiveGap(
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    ),
    Widget2(),
  ],
)
```

#### ResponsiveSpacing
Utility class for spacing values:

```dart
double spacing = ResponsiveSpacing.medium(breakpoint);
double large = ResponsiveSpacing.large(breakpoint);
```

## Context Extensions

Access breakpoint information anywhere:

```dart
Widget build(BuildContext context) {
  if (context.isMobile) {
    return MobileLayout();
  }
  
  if (context.isWideLayout) {
    return DesktopLayout();
  }
  
  return TabletLayout();
}
```

Available properties:
- `context.breakpoint` - Current breakpoint enum
- `context.isMobile` - Is mobile breakpoint
- `context.isTablet` - Is tablet breakpoint  
- `context.isDesktop` - Is desktop breakpoint
- `context.isWideLayout` - Is wide layout (desktop)
- `context.isCompactLayout` - Is compact layout (mobile)

## Providers

### LayoutState Provider

Access comprehensive layout information:

```dart
Consumer(
  builder: (context, ref, child) {
    final layout = ref.watch(layoutStateProvider);
    
    return Container(
      padding: layout.padding,
      constraints: BoxConstraints(
        maxWidth: layout.contentWidth,
      ),
      child: layout.supportsDualPane 
        ? DualPaneContent()
        : SinglePaneContent(),
    );
  },
)
```

## Best Practices

### 1. Mobile-First Design
Always provide mobile layouts first:

```dart
AdaptiveLayout(
  mobile: MobileView(), // Required
  tablet: TabletView(), // Optional, falls back to mobile
  desktop: DesktopView(), // Optional, falls back to tablet or mobile
)
```

### 2. Accessibility
Use responsive components for interactive elements:

```dart
// Good
ResponsiveButton(
  onPressed: onTap,
  child: Text('Action'),
)

// Avoid - may have insufficient tap target
TextButton(
  onPressed: onTap,
  child: Text('Action'),
)
```

### 3. Consistent Spacing
Use responsive spacing utilities:

```dart
// Good
ResponsiveGap(mobile: 16.0, desktop: 24.0)

// Avoid - not responsive
SizedBox(height: 16)
```

### 4. Content Constraints
Wrap wide content in ResponsiveContainer:

```dart
ResponsiveContainer(
  child: VeryWideContent(),
)
```

## Testing

Test responsive layouts at different breakpoints:

```dart
testWidgets('shows mobile layout on narrow screen', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(375, 812)),
        child: ProviderScope(
          child: MyResponsiveWidget(),
        ),
      ),
    ),
  );
  
  expect(find.text('Mobile View'), findsOneWidget);
});
```

## Performance

### MediaQuery Optimization
The system minimizes MediaQuery rebuilds:
- Uses Riverpod providers to cache breakpoint calculations
- BreakpointBuilder provides scoped rebuilds
- Context extensions are lightweight

### Memory Usage
- AutoDispose providers prevent memory leaks
- Minimal widget tree depth
- Efficient breakpoint calculations

## Migration Guide

### From Direct MediaQuery
```dart
// Before
final isWide = MediaQuery.of(context).size.width >= 840;

// After  
final isWide = context.isWideLayout;
```

### From Hardcoded Breakpoints
```dart
// Before
if (MediaQuery.of(context).size.width > 600) {
  return TabletView();
}

// After
AdaptiveLayout(
  mobile: MobileView(),
  tablet: TabletView(),
)
```

### Adding Accessibility
```dart
// Before
IconButton(
  onPressed: onTap,
  icon: Icon(Icons.add),
)

// After
ResponsiveIconButton(
  onPressed: onTap,
  icon: Icon(Icons.add),
  tooltip: 'Add Item',
)
```
