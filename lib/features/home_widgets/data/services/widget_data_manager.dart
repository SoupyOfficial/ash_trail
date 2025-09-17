// Widget data manager for iOS home screen widget integration.
// Handles data synchronization between Flutter app and iOS widget extension.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';

class WidgetDataManager {
  WidgetDataManager._();
  static final WidgetDataManager _instance = WidgetDataManager._();
  static WidgetDataManager get instance => _instance;

  // Shared UserDefaults suite name for app group communication
  static const String _appGroupSuite = 'group.com.ashtrail.shared';

  /// Updates widget data that will be read by iOS widget extension
  Future<void> updateWidgetData({
    required int todayHitCount,
    required int currentStreak,
    bool? showStreak,
    bool? showLastSync,
    String? tapAction,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Core data that widget always needs
    await prefs.setInt('todayHitCount', todayHitCount);
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setDouble(
        'lastSyncTimestamp', DateTime.now().millisecondsSinceEpoch / 1000);

    // Optional configuration
    if (showStreak != null) {
      await prefs.setBool('widgetShowStreak', showStreak);
    }
    if (showLastSync != null) {
      await prefs.setBool('widgetShowLastSync', showLastSync);
    }
    if (tapAction != null) {
      await prefs.setString('widgetTapAction', tapAction);
    }

    // Request widget timeline refresh (iOS 14+)
    await _requestWidgetUpdate();
  }

  /// Updates widget data from a WidgetData entity
  Future<void> updateFromWidgetEntity(WidgetData widget) async {
    await updateWidgetData(
      todayHitCount: widget.todayHitCount,
      currentStreak: widget.currentStreak,
      showStreak: widget.showStreak,
      showLastSync: widget.showLastSync,
      tapAction: widget.tapAction.name,
    );
  }

  /// Syncs all widgets for an account to use the same core data
  Future<void> syncAllWidgets(List<WidgetData> widgets) async {
    if (widgets.isEmpty) return;

    // Use the first widget's data as the source of truth for stats
    final primaryWidget = widgets.first;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('todayHitCount', primaryWidget.todayHitCount);
    await prefs.setInt('currentStreak', primaryWidget.currentStreak);
    await prefs.setDouble(
        'lastSyncTimestamp', DateTime.now().millisecondsSinceEpoch / 1000);

    // For configuration, use the most permissive settings
    final shouldShowStreak = widgets.any((w) => w.showStreak == true);
    final shouldShowLastSync = widgets.any((w) => w.showLastSync == true);

    await prefs.setBool('widgetShowStreak', shouldShowStreak);
    await prefs.setBool('widgetShowLastSync', shouldShowLastSync);

    // Use the most common tap action
    final tapActionCounts = <WidgetTapAction, int>{};
    for (final widget in widgets) {
      tapActionCounts[widget.tapAction] =
          (tapActionCounts[widget.tapAction] ?? 0) + 1;
    }

    final mostCommonAction =
        tapActionCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    await prefs.setString('widgetTapAction', mostCommonAction.name);

    await _requestWidgetUpdate();
  }

  /// Clears widget data when user logs out or removes all widgets
  Future<void> clearWidgetData(String accountId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('todayHitCount');
    await prefs.remove('currentStreak');
    await prefs.remove('lastSyncTimestamp');
    await prefs.remove('widgetShowStreak');
    await prefs.remove('widgetShowLastSync');
    await prefs.remove('widgetTapAction');

    await _requestWidgetUpdate();
  }

  /// Gets current widget data for debugging or verification
  Future<Map<String, dynamic>> getCurrentWidgetData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'todayHitCount': prefs.getInt('todayHitCount') ?? 0,
      'currentStreak': prefs.getInt('currentStreak') ?? 0,
      'lastSyncTimestamp': prefs.getDouble('lastSyncTimestamp'),
      'widgetShowStreak': prefs.getBool('widgetShowStreak') ?? true,
      'widgetShowLastSync': prefs.getBool('widgetShowLastSync') ?? true,
      'widgetTapAction': prefs.getString('widgetTapAction') ?? 'openApp',
    };
  }

  /// Handles deep link from widget tap
  Future<String?> handleWidgetDeepLink(String? link) async {
    if (link == null || !link.startsWith('ashtrail://')) {
      return null;
    }

    final uri = Uri.parse(link);

    // Log widget interaction for analytics
    await _logWidgetInteraction(uri.host ?? 'unknown');

    return link; // Return the processed link for routing
  }

  /// Requests iOS to update widget timeline (iOS specific)
  Future<void> _requestWidgetUpdate() async {
    // This would use platform channels to call WidgetCenter.shared.reloadAllTimelines()
    // For now, it's a no-op but would be implemented with method channels

    // Example implementation:
    // try {
    //   await _methodChannel.invokeMethod('reloadWidgets');
    // } catch (e) {
    //   // Handle error or ignore if not on iOS
    // }
  }

  /// Logs widget interaction for analytics
  Future<void> _logWidgetInteraction(String action) async {
    // This would integrate with your analytics system
    // For now, just update last interaction timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
        'lastWidgetInteraction', DateTime.now().millisecondsSinceEpoch / 1000);
  }

  /// Sets up periodic sync for widget data
  void startPeriodicSync() {
    // This would set up a background task or timer to periodically
    // update widget data, ensuring it stays current

    // Implementation would depend on your app's architecture
    // Could use background tasks, scheduled notifications, or other mechanisms
  }

  /// Helper method to determine if widgets need data refresh
  Future<bool> needsDataRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getDouble('lastSyncTimestamp');

    if (lastSync == null) return true;

    final lastSyncDate =
        DateTime.fromMillisecondsSinceEpoch((lastSync * 1000).toInt());
    final now = DateTime.now();

    // Consider data stale if older than 1 hour
    return now.difference(lastSyncDate).inHours >= 1;
  }
}
