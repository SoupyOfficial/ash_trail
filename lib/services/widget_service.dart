import 'dart:async';
import 'dart:io';
import 'package:home_widget/home_widget.dart';
import '../logging/app_logger.dart';
import 'log_record_service.dart';
import 'home_metrics_service.dart';

/// Bridges Flutter analytics data to iOS Home Screen & Lock Screen widgets
/// via the `home_widget` package. Writes metrics to shared UserDefaults
/// (App Group: group.com.soup.smokeLog) so the WidgetKit extension can read them.
///
/// Follows the same service pattern as [WatchConnectivityService]:
/// constructor-injected dependencies, AppLogger, initialize/dispose lifecycle.
class WidgetService {
  static final _log = AppLogger.logger('WidgetService');
  static const _appGroupId = 'group.com.soup.smokeLog';

  final LogRecordService _logRecordService;
  final HomeMetricsService _homeMetricsService;

  /// Current active account ID — set by the provider when the active account changes
  String? activeAccountId;

  WidgetService({
    required LogRecordService logRecordService,
    required HomeMetricsService homeMetricsService,
  }) : _logRecordService = logRecordService,
       _homeMetricsService = homeMetricsService;

  /// Initialize the widget service and set the App Group ID for iOS
  Future<void> initialize() async {
    if (!Platform.isIOS) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      _log.i('WidgetService initialized with group: $_appGroupId');
      // Push initial data
      await updateWidgetData();
    } catch (e, st) {
      _log.e('Failed to initialize WidgetService', error: e, stackTrace: st);
    }
  }

  /// Dispose — no persistent resources to clean up
  void dispose() {
    _log.i('WidgetService disposed');
  }

  /// Compute current analytics and push to iOS widget UserDefaults.
  /// Call after every log mutation so widgets stay current.
  Future<void> updateWidgetData() async {
    if (!Platform.isIOS) return;

    final accountId = activeAccountId;
    if (accountId == null) {
      _log.d('Cannot update widget data: no active account');
      return;
    }

    try {
      final records = await _logRecordService.getLogRecords(
        accountId: accountId,
        includeDeleted: false,
      );

      // Compute metrics using the same HomeMetricsService calls as WatchConnectivityService
      final hitsToday = _homeMetricsService.getHitCountToday(records);
      final totalDuration = _homeMetricsService.getTotalDurationToday(records);
      final timeSince = _homeMetricsService.getTimeSinceLastHit(records);
      final avgGap = _homeMetricsService.getAverageGapToday(records);
      final avgDuration = _homeMetricsService.getAverageDurationToday(records);
      final longestGap = _homeMetricsService.getLongestGap(records);
      final dailyAvg = _homeMetricsService.getDailyAverageHits(records);

      // Write each metric to shared UserDefaults via home_widget
      await Future.wait([
        HomeWidget.saveWidgetData<int>('widget_hitsToday', hitsToday),
        HomeWidget.saveWidgetData<double>(
          'widget_totalDurationToday',
          totalDuration,
        ),
        HomeWidget.saveWidgetData<double>(
          'widget_lastHitTimestamp',
          timeSince != null
              ? DateTime.now().subtract(timeSince).millisecondsSinceEpoch /
                    1000.0
              : 0,
        ),
        HomeWidget.saveWidgetData<double>(
          'widget_averageGapSeconds',
          avgGap?.inSeconds.toDouble() ?? 0,
        ),
        HomeWidget.saveWidgetData<double>(
          'widget_averageDurationSeconds',
          avgDuration ?? 0,
        ),
        HomeWidget.saveWidgetData<double>(
          'widget_longestGapSeconds',
          longestGap?.gap.inSeconds.toDouble() ?? 0,
        ),
        HomeWidget.saveWidgetData<double>('widget_dailyAverageHits', dailyAvg),
        HomeWidget.saveWidgetData<double>(
          'widget_lastUpdated',
          DateTime.now().millisecondsSinceEpoch / 1000.0,
        ),
      ]);

      // Trigger WidgetKit to reload all timelines
      // Each widget kind is reloaded so they all pick up the new data
      await HomeWidget.updateWidget(iOSName: 'HitsTodayWidget');
      await HomeWidget.updateWidget(iOSName: 'TimeSinceLastHitWidget');
      await HomeWidget.updateWidget(iOSName: 'DailySummaryWidget');
      await HomeWidget.updateWidget(iOSName: 'QuickStatsWidget');
      await HomeWidget.updateWidget(iOSName: 'AppLaunchWidget');

      _log.d(
        'Widget data updated: $hitsToday hits, ${totalDuration}s duration',
      );
    } catch (e, st) {
      _log.e('Failed to update widget data', error: e, stackTrace: st);
    }
  }
}
