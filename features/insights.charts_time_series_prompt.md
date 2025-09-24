# Charts Time Series Feature Implementation Prompt

## Feature: insights.charts_time_series

### Implementation Summary
Complete implementation of interactive charts with time series data visualization for AshTrail smoke logging app. Provides daily, weekly, and monthly aggregation views with multiple metrics and smoothing options.

### Architecture
- **Domain Layer**: ChartDataPoint, TimeSeriesChart entities with business logic
- **Data Layer**: Local data source with SmokeLog aggregation and caching
- **Presentation Layer**: Interactive UI with fl_chart integration and Riverpod state management

### Key Components
- Time range picker for date selection
- Aggregation toggle (daily/weekly/monthly)
- Metric selection (count, duration, mood, physical scores)
- Smoothing options (none, moving average, cumulative)
- Interactive line chart with tooltips and legends
- Empty state handling for no data scenarios

### Performance Targets
- Chart rendering: <200ms (p95)
- Pan/zoom: ≥55fps maintained
- Smooth aggregation switching without re-navigation

### Testing Coverage
- Domain entities and use cases: 100% coverage
- Widget tests for screen components
- Integration tests for provider interactions

### Business Logic
- Real-time aggregation from SmokeLog data
- Configurable time windows and smoothing
- Multi-account support with proper data isolation
- Offline-first architecture with local caching

### User Experience
- Intuitive controls for chart configuration
- Responsive design for mobile and tablet layouts  
- Accessibility compliance with semantic labels
- Performance optimized for smooth interactions

This feature enables users to visualize their smoking patterns over time with comprehensive analytics and interactive controls, supporting data-driven insights for behavior tracking and goal setting.