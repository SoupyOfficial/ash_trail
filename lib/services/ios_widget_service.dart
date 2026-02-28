import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/log_record.dart';
import '../services/home_metrics_service.dart';
import '../utils/day_boundary.dart';

/// Service for managing iOS widget data synchronization
/// Exports computed metrics to the native iOS widget extension via App Groups
class IOSWidgetService {
  static const _channel = MethodChannel('com.soupy.ashtrail/widget');
  final HomeMetricsService _metricsService = HomeMetricsService();

  /// Update widget data based on current log records
  /// This should be called whenever logs change or on app lifecycle events
  Future<void> updateWidgetData(List<LogRecord> records) async {
    try {
      // Filter to non-deleted records
      final activeRecords = records
          .where((r) => r.deletedAt == null && r.deletedBy == null)
          .toList();

      // Sort by event time (newest first)
      activeRecords.sort((a, b) => b.eventAt.compareTo(a.eventAt));

      // Compute metrics
      final hitsToday = _metricsService.getHitCount(activeRecords, days: 1);
      final totalDurationToday =
          _metricsService.getTotalDuration(activeRecords, days: 1);
      final lastRecord = _metricsService.getLastRecord(activeRecords);
      final timeSinceLast = _metricsService.getTimeSinceLastHit(activeRecords);

      // Get weekly hits (last 7 days)
      final weeklyHits = <int>[];
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final dayStart = getDayBoundary(now.subtract(Duration(days: i)));
        final dayEnd = dayStart.add(const Duration(days: 1));
        final dayRecords = activeRecords.where((r) =>
            r.eventAt.isAfter(dayStart) && r.eventAt.isBefore(dayEnd));
        weeklyHits.add(dayRecords.length);
      }

      // Prepare data for iOS
      final widgetData = {
        'hitsToday': hitsToday,
        'totalDurationToday': totalDurationToday?.inSeconds ?? 0,
        'timeSinceLastHit': timeSinceLast?.inSeconds,
        'lastHitTime': lastRecord?.eventAt.toIso8601String(),
        'weeklyHits': weeklyHits,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Send to iOS via method channel
      await _channel.invokeMethod('updateWidgetData', widgetData);
    } catch (e) {
      print('Error updating widget data: $e');
      // Don't throw - widget update failures shouldn't crash the app
    }
  }

  /// Force refresh all widgets
  Future<void> reloadWidgets() async {
    try {
      await _channel.invokeMethod('reloadWidgets');
    } catch (e) {
      print('Error reloading widgets: $e');
    }
  }

  /// Check if widget extension is available (iOS 14+)
  Future<bool> isWidgetAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isWidgetAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
