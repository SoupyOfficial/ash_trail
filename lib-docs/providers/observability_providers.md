# observability_providers

> **Source:** `lib/providers/observability_providers.dart`

## Purpose

Exposes observability service singletons (analytics, performance, error reporting, OpenTelemetry) to the Riverpod dependency graph. These providers can be overridden in tests to inject fakes/mocks.

## Dependencies

- `package:flutter_riverpod/flutter_riverpod.dart` — `Provider`
- `../services/app_analytics_service.dart` — `AppAnalyticsService`
- `../services/app_performance_service.dart` — `AppPerformanceService`
- `../services/error_reporting_service.dart` — `ErrorReportingService`
- `../services/otel_service.dart` — `OTelService`

## Pseudo-Code

### Providers

```
PROVIDER analyticsServiceProvider → AppAnalyticsService
  RETURN AppAnalyticsService.instance

PROVIDER performanceServiceProvider → AppPerformanceService
  RETURN AppPerformanceService.instance

PROVIDER errorReportingServiceProvider → ErrorReportingService
  RETURN ErrorReportingService.instance

PROVIDER otelServiceProvider → OTelService
  RETURN OTelService.instance
```

## Notes

- All four services are singletons — the providers simply expose them to the Riverpod graph.
- Override in tests to inject fakes without touching the singleton.
