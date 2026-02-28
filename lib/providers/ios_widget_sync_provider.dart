import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_record.dart';
import '../services/ios_widget_service.dart';
import 'log_record_provider.dart';
import 'dart:io' show Platform;

/// Provider for iOS widget service
final iosWidgetServiceProvider = Provider<IOSWidgetService>((ref) {
  return IOSWidgetService();
});

/// Provider that automatically updates iOS widgets when log records change
final iosWidgetSyncProvider = Provider<IOSWidgetSync>((ref) {
  final widgetService = ref.watch(iosWidgetServiceProvider);
  final logRecordService = ref.watch(logRecordProvider);

  return IOSWidgetSync(
    widgetService: widgetService,
    ref: ref,
  );
});

/// Service that manages automatic widget synchronization
class IOSWidgetSync {
  final IOSWidgetService widgetService;
  final Ref ref;

  IOSWidgetSync({
    required this.widgetService,
    required this.ref,
  }) {
    _init();
  }

  void _init() {
    // Only initialize on iOS
    if (!Platform.isIOS) return;

    // Listen to log record changes and update widget
    ref.listen<AsyncValue<List<LogRecord>>>(
      logRecordProvider,
      (previous, next) {
        next.whenData((records) async {
          await widgetService.updateWidgetData(records);
        });
      },
    );
  }

  /// Manually trigger widget update
  Future<void> updateNow() async {
    if (!Platform.isIOS) return;

    final records = await ref.read(logRecordProvider.future);
    await widgetService.updateWidgetData(records);
  }

  /// Reload all widgets
  Future<void> reload() async {
    if (!Platform.isIOS) return;

    await widgetService.reloadWidgets();
  }
}
