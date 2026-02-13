import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_analytics_service.dart';
import '../services/app_performance_service.dart';
import '../services/error_reporting_service.dart';
import '../services/otel_service.dart';

/// Exposes observability singletons to the Riverpod graph.
/// Override in tests to inject fakes.
final analyticsServiceProvider = Provider<AppAnalyticsService>(
  (ref) => AppAnalyticsService.instance,
);

final performanceServiceProvider = Provider<AppPerformanceService>(
  (ref) => AppPerformanceService.instance,
);

final errorReportingServiceProvider = Provider<ErrorReportingService>(
  (ref) => ErrorReportingService.instance,
);

final otelServiceProvider = Provider<OTelService>(
  (ref) => OTelService.instance,
);
