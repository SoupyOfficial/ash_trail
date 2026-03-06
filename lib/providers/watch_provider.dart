import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/watch_connectivity_service.dart';
import '../services/log_record_service.dart';
import '../services/home_metrics_service.dart';
import 'account_provider.dart';

/// Provider for the WatchConnectivityService singleton
final watchConnectivityServiceProvider = Provider<WatchConnectivityService>((
  ref,
) {
  final logRecordService = LogRecordService();
  final homeMetricsService = HomeMetricsService();

  final service = WatchConnectivityService(
    logRecordService: logRecordService,
    homeMetricsService: homeMetricsService,
  );

  // Set the active account ID and keep it updated
  ref.listen(activeAccountProvider, (previous, next) {
    next.whenData((account) {
      service.activeAccountId = account?.userId;
      // Push updated context when account changes
      service.pushUpdatedContext();
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

/// Provider to initialize the watch service (call once at app startup)
final watchServiceInitProvider = Provider<void>((ref) {
  // Simply reading the service provider triggers initialization
  ref.watch(watchConnectivityServiceProvider);
});
