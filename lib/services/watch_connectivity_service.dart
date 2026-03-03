import 'dart:async';
import 'package:flutter/services.dart';
import '../logging/app_logger.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import 'log_record_service.dart';
import 'home_metrics_service.dart';

/// Handles communication between Flutter and the Apple Watch via MethodChannel.
/// Receives requests from the iOS WatchConnectivityManager and responds using
/// existing service layer APIs. Pushes updated context to the watch after changes.
class WatchConnectivityService {
  static final _log = AppLogger.logger('WatchConnectivityService');
  static const _channel = MethodChannel('com.soup.smokeLog/watch');

  final LogRecordService _logRecordService;
  final HomeMetricsService _homeMetricsService;

  /// Current active account ID — set by the provider when the active account changes
  String? activeAccountId;

  WatchConnectivityService({
    required LogRecordService logRecordService,
    required HomeMetricsService homeMetricsService,
  }) : _logRecordService = logRecordService,
       _homeMetricsService = homeMetricsService;

  /// Initialize and start listening for messages from the watch
  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
    _log.i('WatchConnectivityService initialized');
  }

  /// Dispose of the method call handler
  void dispose() {
    _channel.setMethodCallHandler(null);
  }

  /// Handle incoming method calls from the iOS native bridge
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    _log.i('Received watch request: ${call.method}');

    switch (call.method) {
      case 'createLog':
        return await _handleCreateLog(call.arguments as Map<dynamic, dynamic>);
      case 'getRecentEntries':
        return await _handleGetRecentEntries();
      case 'getAnalytics':
        return await _handleGetAnalytics();
      default:
        throw PlatformException(
          code: 'UNIMPLEMENTED',
          message: 'Method ${call.method} not implemented',
        );
    }
  }

  /// Create a log record from a watch request
  Future<Map<String, dynamic>> _handleCreateLog(
    Map<dynamic, dynamic> args,
  ) async {
    final accountId = activeAccountId;
    if (accountId == null) {
      _log.e('Cannot create log: no active account');
      return {'error': 'No active account'};
    }

    try {
      final duration = (args['duration'] as num?)?.toDouble() ?? 0;

      final record = await _logRecordService.createLogRecord(
        accountId: accountId,
        eventType: EventType.vape,
        duration: duration,
        unit: Unit.seconds,
        source: Source.manual,
      );

      _log.i('Watch log created: ${record.logId}, duration: ${duration}s');

      // Push updated context to the watch after successful log creation
      await pushUpdatedContext();

      return {'success': true, 'logId': record.logId};
    } catch (e) {
      _log.e('Failed to create watch log: $e');
      return {'error': e.toString()};
    }
  }

  /// Get recent entries for the watch
  Future<Map<String, dynamic>> _handleGetRecentEntries() async {
    final accountId = activeAccountId;
    if (accountId == null) {
      return {'entries': <Map<String, dynamic>>[]};
    }

    try {
      final records = await _logRecordService.getLogRecords(
        accountId: accountId,
        includeDeleted: false,
      );

      // Sort by eventAt descending & take last 5
      records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
      final recent = records.take(5).toList();

      final entries =
          recent
              .map(
                (r) => {
                  'logId': r.logId,
                  'eventType': r.eventType.name,
                  'eventAt': r.eventAt.millisecondsSinceEpoch / 1000.0,
                  'duration': r.duration,
                  if (r.moodRating != null) 'moodRating': r.moodRating,
                  if (r.physicalRating != null)
                    'physicalRating': r.physicalRating,
                  if (r.note != null) 'note': r.note,
                },
              )
              .toList();

      return {'entries': entries};
    } catch (e) {
      _log.e('Failed to get recent entries for watch: $e');
      return {'entries': <Map<String, dynamic>>[], 'error': e.toString()};
    }
  }

  /// Get analytics for the watch
  Future<Map<String, dynamic>> _handleGetAnalytics() async {
    final accountId = activeAccountId;
    if (accountId == null) {
      return _emptyAnalytics();
    }

    try {
      final records = await _logRecordService.getLogRecords(
        accountId: accountId,
        includeDeleted: false,
      );

      return _computeAnalytics(records);
    } catch (e) {
      _log.e('Failed to get analytics for watch: $e');
      return _emptyAnalytics();
    }
  }

  /// Compute analytics from records using HomeMetricsService
  Map<String, dynamic> _computeAnalytics(List<LogRecord> records) {
    final hitsToday = _homeMetricsService.getHitCountToday(records);
    final totalDuration = _homeMetricsService.getTotalDurationToday(records);
    final timeSince = _homeMetricsService.getTimeSinceLastHit(records);
    final avgGap = _homeMetricsService.getAverageGapToday(records);
    final avgDuration = _homeMetricsService.getAverageDurationToday(records);

    return {
      'analytics': {
        'hitsToday': hitsToday,
        'totalDurationToday': totalDuration,
        if (timeSince != null)
          'timeSinceLastHitSeconds': timeSince.inSeconds.toDouble(),
        if (avgGap != null) 'averageGapSeconds': avgGap.inSeconds.toDouble(),
        if (avgDuration != null) 'averageDurationSeconds': avgDuration,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch / 1000.0,
      },
    };
  }

  Map<String, dynamic> _emptyAnalytics() {
    return {
      'analytics': {
        'hitsToday': 0,
        'totalDurationToday': 0.0,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch / 1000.0,
      },
    };
  }

  /// Push updated analytics and recent entries to the watch as application context.
  /// Called after every log creation so the watch stays up-to-date.
  Future<void> pushUpdatedContext() async {
    final accountId = activeAccountId;
    if (accountId == null) return;

    try {
      final records = await _logRecordService.getLogRecords(
        accountId: accountId,
        includeDeleted: false,
      );

      final analyticsData = _computeAnalytics(records);

      // Get recent entries
      records.sort((a, b) => b.eventAt.compareTo(a.eventAt));
      final recent = records.take(5).toList();
      final entries =
          recent
              .map(
                (r) => {
                  'logId': r.logId,
                  'eventType': r.eventType.name,
                  'eventAt': r.eventAt.millisecondsSinceEpoch / 1000.0,
                  'duration': r.duration,
                  if (r.moodRating != null) 'moodRating': r.moodRating,
                  if (r.physicalRating != null)
                    'physicalRating': r.physicalRating,
                  if (r.note != null) 'note': r.note,
                },
              )
              .toList();

      // Push combined context to the watch
      final context = <String, dynamic>{...analyticsData, 'entries': entries};

      await _channel.invokeMethod('pushContext', context);
      _log.i('Pushed updated context to watch');
    } catch (e) {
      _log.w('Failed to push context to watch: $e');
    }
  }

  /// Check if the watch is currently reachable
  Future<bool> get isWatchReachable async {
    try {
      final result = await _channel.invokeMethod<bool>('isWatchReachable');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if a watch is paired
  Future<bool> get isWatchPaired async {
    try {
      final result = await _channel.invokeMethod<bool>('isWatchPaired');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
