import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/widget_service.dart';
import '../services/log_record_service.dart';
import '../services/home_metrics_service.dart';
import 'account_provider.dart';

/// Provider for the WidgetService singleton.
/// Follows the same pattern as [watchConnectivityServiceProvider]:
/// constructor injection, reactive account listening, initialize/dispose lifecycle.
final widgetServiceProvider = Provider<WidgetService>((ref) {
  final logRecordService = LogRecordService();
  final homeMetricsService = HomeMetricsService();

  final service = WidgetService(
    logRecordService: logRecordService,
    homeMetricsService: homeMetricsService,
  );

  // Set the active account ID and keep it updated
  ref.listen(activeAccountProvider, (previous, next) {
    next.whenData((account) {
      service.activeAccountId = account?.userId;
      // Push updated widget data when account changes
      service.updateWidgetData();
    });
  });

  // Set initial account ID
  final activeAccount = ref.read(activeAccountProvider);
  activeAccount.whenData((account) {
    service.activeAccountId = account?.userId;
  });

  service.initialize();

  ref.onDispose(service.dispose);

  return service;
});
