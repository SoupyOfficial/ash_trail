# ADR-0005: Responsive & Adaptive Layout System

**Status**: Accepted  
**Date**: 2025-09-05  
**Context**: ui.responsive feature implementation  

## Context

AshTrail needs a responsive layout system that adapts to different screen sizes while maintaining excellent usability across iPhone, iPad, and desktop platforms. The app must follow iOS design conventions while being extensible to other platforms.

Current requirements include:
- Phone-first design (portrait & landscape)
- Dual-pane layouts on tablets/desktop (≥840dp)
- Minimum 48px tap targets for accessibility
- Chart legend adaptations for wide screens
- Large title collapsing headers for iOS conventions

## Decision

We will implement a comprehensive responsive layout system with the following components:

### Core Architecture
- **Breakpoint System**: Mobile (<600dp), Tablet (600-839dp), Desktop (≥840dp)
- **Clean Architecture**: Domain entities, presentation widgets, Riverpod providers
- **Feature-first Organization**: All responsive utilities in `features/responsive/`

### Key Components

1. **Breakpoint Entity** (`domain/entities/breakpoint.dart`)
   - Enum-based breakpoint classification
   - Helper methods for layout decisions
   - Context extensions for easy access

2. **Layout Configuration** (`domain/entities/layout_config.dart`)
   - Centralized responsive behavior settings
   - Minimum tap target enforcement (48px default)
   - Consistent spacing and padding rules

3. **Presentation Widgets**:
   - `AdaptiveLayout`: Simple breakpoint-based widget switching
   - `DualPaneLayout`: Master-detail layouts for wide screens
   - `ResponsiveContainer`: Content width constraints and padding
   - `BreakpointBuilder`: Context-aware responsive rebuilding
   - `MinTapTarget`: Accessibility-focused tap target enforcement
   - `ResponsivePadding/Spacing`: Consistent spacing across breakpoints

4. **Provider Integration**:
   - `layoutStateProvider`: Combined breakpoint + configuration state
   - Automatic MediaQuery integration
   - Riverpod autoDispose for performance

### Design Principles

- **Progressive Enhancement**: Mobile-first, with tablet/desktop as enhancements
- **Accessibility-First**: 48px minimum tap targets, semantic labels, contrast support
- **Performance-Conscious**: Minimal rebuilds, efficient MediaQuery usage
- **iOS Conventions**: Large titles, safe areas, navigation patterns
- **Testability**: Comprehensive widget and unit tests

## Options Considered

### Option 1: Flutter's built-in responsive utilities
**Pros**: Minimal code, standard approach
**Cons**: Limited customization, no accessibility enforcement, no Clean Architecture alignment

### Option 2: Third-party package (e.g., responsive_framework)
**Pros**: Battle-tested, feature-rich
**Cons**: External dependency, may not align with Clean Architecture, less control

### Option 3: Custom implementation (chosen)
**Pros**: Full control, testable, aligns with project architecture, accessibility-focused
**Cons**: More initial development time, need to maintain

## Implementation Details

### Breakpoint Strategy
```dart
enum Breakpoint {
  mobile,   // < 600dp
  tablet,   // 600-839dp  
  desktop;  // ≥ 840dp
}
```

### Usage Patterns
```dart
// Simple adaptive layouts
AdaptiveLayout(
  mobile: MobileView(),
  tablet: TabletView(),
  desktop: DesktopView(),
)

// Dual-pane for wide screens
DualPaneLayout(
  primary: LogList(),
  secondary: LogDetails(),
)

// Accessibility-enforced buttons
ResponsiveButton(
  onPressed: onTap,
  child: Text('Action'),
)
```

### Integration Points
- App Shell: Enhanced FAB tap targets
- Logs Screen: Demonstrates all responsive patterns
- Future Charts: Legend layout adaptations ready
- Theme System: Responsive padding integration

## Consequences

### Positive
- **Unified System**: Consistent responsive behavior across features
- **Accessibility**: Built-in tap target enforcement and semantic support
- **Maintainability**: Clean separation of concerns, comprehensive tests
- **Extensibility**: Easy to add new breakpoints or layout patterns
- **Performance**: Efficient MediaQuery usage with Riverpod optimization
- **iOS Fidelity**: Follows platform conventions for navigation and layouts

### Negative
- **Complexity**: More abstractions than simple MediaQuery checks
- **Learning Curve**: Team needs to understand new responsive utilities
- **Bundle Size**: Additional code for comprehensive responsive system

### Neutral
- **Testing Coverage**: Requires comprehensive widget and unit tests
- **Documentation**: Need to maintain responsive design guidelines

## Follow-up Actions

1. **Integration Tasks**:
   - Update remaining screens to use responsive utilities
   - Implement chart legend adaptations when charts feature is ready
   - Add large title collapsing headers to list screens

2. **Performance Monitoring**:
   - Track MediaQuery rebuild frequency
   - Monitor tap target accessibility compliance
   - Validate responsive layout performance on target devices

3. **Documentation**:
   - Create responsive design guidelines for developers
   - Document breakpoint decision rationale
   - Provide usage examples for common patterns

4. **Future Enhancements**:
   - Platform-specific breakpoint customization
   - Dynamic breakpoint adjustment based on content
   - Advanced layout patterns (grid, masonry)

## References

- [Material Design 3 Layout](https://m3.material.io/foundations/layout)
- [iOS Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Flutter Responsive Design Best Practices](https://docs.flutter.dev/ui/layout/responsive)
- [WCAG 2.1 Touch Target Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/target-size.html)
- AshTrail instruction prompt (responsive requirements)
