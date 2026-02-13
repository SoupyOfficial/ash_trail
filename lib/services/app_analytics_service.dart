import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import '../logging/app_logger.dart';
import '../models/app_error.dart';
import 'otel_service.dart';

/// Singleton wrapper around Firebase Analytics.
/// All analytics events should go through this service.
///
/// Active in ALL build modes (debug, profile, release/TestFlight).
/// When Firebase is not initialized (unit tests), all methods are silent no-ops.
class AppAnalyticsService {
  static final _log = AppLogger.logger('Analytics');
  static final AppAnalyticsService _instance = AppAnalyticsService._internal();
  static AppAnalyticsService get instance => _instance;
  factory AppAnalyticsService() => _instance;
  AppAnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  /// Initialize after Firebase.initializeApp. Lightweight — no cold-start impact.
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) return; // test isolation
    _analytics = FirebaseAnalytics.instance;
    // Explicitly enable collection in ALL build modes (always-on)
    await _analytics!.setAnalyticsCollectionEnabled(true);
    _log.i('Analytics initialized — collection explicitly enabled');
  }

  bool get _ready => _analytics != null;

  /// Returns the observer for MaterialApp.navigatorObservers.
  FirebaseAnalyticsObserver? get observer =>
      _ready ? FirebaseAnalyticsObserver(analytics: _analytics!) : null;

  // ────────────────────────────────────────────────────────────────
  // Generic event API
  // ────────────────────────────────────────────────────────────────

  /// Log any named event with optional parameters.
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e) {
      _log.w('logEvent($name) failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Core events — covering all key user journeys
  // ────────────────────────────────────────────────────────────────

  /// Track cold launch. Called once per app start from main.dart.
  Future<void> logAppOpen() async {
    if (!_ready) return;
    try {
      await _analytics!.logAppOpen();
    } catch (e) {
      _log.w('logAppOpen failed', error: e);
    }
  }

  /// Track authentication.
  /// [method] values: 'email_signup', 'email', 'google', 'apple'
  Future<void> logLogin({required String method}) async {
    if (!_ready) return;
    try {
      await _analytics!.logLogin(loginMethod: method);
    } catch (e) {
      _log.w('logLogin failed', error: e);
    }
  }

  /// Track sign-out.
  Future<void> logSignOut({bool allAccounts = false}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'sign_out',
        parameters: {'all_accounts': allAccounts},
      );
    } catch (e) {
      _log.w('logSignOut failed', error: e);
    }
  }

  /// Track log record creation — the app's core user action.
  Future<void> logLogCreated({bool quickLog = false, String? eventType}) async {
    // OTel metric (fire-and-forget, no-op if OTel is disabled)
    OTelService.instance.recordLogCreated(eventType: eventType);

    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'log_created',
        parameters: {
          'quick_log': quickLog,
          if (eventType != null) 'event_type': eventType,
        },
      );
    } catch (e) {
      _log.w('logLogCreated failed', error: e);
    }
  }

  /// Track log record edits.
  Future<void> logLogUpdated() async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'log_updated');
    } catch (e) {
      _log.w('logLogUpdated failed', error: e);
    }
  }

  /// Track log record deletions.
  Future<void> logLogDeleted({bool restored = false}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'log_deleted',
        parameters: {'restored': restored},
      );
    } catch (e) {
      _log.w('logLogDeleted failed', error: e);
    }
  }

  /// Track sync completion with outcome metrics.
  Future<void> logSyncCompleted({
    int pushed = 0,
    int pulled = 0,
    int failed = 0,
    int durationMs = 0,
  }) async {
    // OTel metrics (fire-and-forget, no-op if OTel is disabled)
    OTelService.instance.recordSyncPush(pushed);
    OTelService.instance.recordSyncPull(pulled);
    OTelService.instance.recordSyncDuration(durationMs);

    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'sync_completed',
        parameters: {
          'records_pushed': pushed,
          'records_pulled': pulled,
          'records_failed': failed,
          'duration_ms': durationMs,
        },
      );
    } catch (e) {
      _log.w('logSyncCompleted failed', error: e);
    }
  }

  /// Track data export events.
  Future<void> logExport({required String format, int recordCount = 0}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'data_exported',
        parameters: {'format': format, 'record_count': recordCount},
      );
    } catch (e) {
      _log.w('logExport failed', error: e);
    }
  }

  /// Track error occurrences as analytics events (separate from Crashlytics).
  Future<void> logError(ErrorCategory category, ErrorSeverity severity) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'app_error',
        parameters: {'category': category.name, 'severity': severity.name},
      );
    } catch (e) {
      // Silent — don't log errors about logging errors
    }
  }

  /// Track bottom navigation tab switches.
  Future<void> logTabSwitch({required String tabName}) async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(
        name: 'tab_switch',
        parameters: {'tab_name': tabName},
      );
    } catch (e) {
      _log.w('logTabSwitch failed', error: e);
    }
  }

  /// Track account switch events (multi-account feature).
  Future<void> logAccountSwitch() async {
    if (!_ready) return;
    try {
      await _analytics!.logEvent(name: 'account_switch');
    } catch (e) {
      _log.w('logAccountSwitch failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Screen tracking
  // ────────────────────────────────────────────────────────────────

  /// Log a screen view. Use for IndexedStack tabs (Home, Analytics, History)
  /// which are NOT tracked by FirebaseAnalyticsObserver (no route push).
  Future<void> logScreenView({required String screenName}) async {
    if (!_ready) return;
    try {
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      _log.w('logScreenView failed', error: e);
    }
  }

  // ────────────────────────────────────────────────────────────────
  // User properties — segmentation dimensions
  // ────────────────────────────────────────────────────────────────

  /// Set the number of logged-in accounts (multi-account feature).
  Future<void> setAccountCount(int count) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'account_count', value: '$count');
    } catch (_) {}
  }

  /// Set a bucketed total log count for user segmentation.
  Future<void> setLogCountBucket(int count) async {
    if (!_ready) return;
    final bucket = switch (count) {
      0 => '0',
      <= 10 => '1-10',
      <= 50 => '11-50',
      <= 200 => '51-200',
      _ => '200+',
    };
    try {
      await _analytics!.setUserProperty(name: 'total_log_count', value: bucket);
    } catch (_) {}
  }

  /// Set the app version as a user property for version-based filtering.
  Future<void> setAppVersion(String version) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'app_version', value: version);
    } catch (_) {}
  }

  /// Set the authentication method used.
  Future<void> setAuthMethod(String method) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'auth_method', value: method);
    } catch (_) {}
  }

  /// Set the sync status as a user property.
  Future<void> setSyncStatus(String status) async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'sync_status', value: status);
    } catch (_) {}
  }

  /// Reset user properties on sign-out.
  Future<void> clearUserProperties() async {
    if (!_ready) return;
    try {
      await _analytics!.setUserProperty(name: 'account_count', value: null);
      await _analytics!.setUserProperty(name: 'total_log_count', value: null);
      await _analytics!.setUserProperty(name: 'auth_method', value: null);
      await _analytics!.setUserProperty(name: 'sync_status', value: null);
    } catch (_) {}
  }
}
