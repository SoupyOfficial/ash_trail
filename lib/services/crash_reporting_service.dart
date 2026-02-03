import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

/// Service for reporting crashes and errors to Firebase Crashlytics
/// Automatically integrates with TestFlight for crash monitoring
class CrashReportingService {
  static final _log = AppLogger.logger('CrashReportingService');
  static final CrashReportingService _instance =
      CrashReportingService._internal();

  factory CrashReportingService() {
    return _instance;
  }

  CrashReportingService._internal();

  /// Initialize crash reporting
  /// Should be called once at app startup
  static Future<void> initialize() async {
    try {
      // Pass all uncaught errors from the Flutter framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      };

      // Handle errors not caught by Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable collection in debug mode for testing (optional)
      if (kDebugMode) {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          true,
        );
      }

      if (kDebugMode) {
        _log.i('Crash reporting initialized');
      }
    } catch (e) {
      _log.e('Error initializing crash reporting', error: e);
    }
  }

  /// Record a custom error
  /// Useful for catching exceptions that might not automatically be reported
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        _log.d('Error recorded: $error, Fatal: $fatal');
      }
    } catch (e) {
      _log.e('Failed to record error', error: e);
    }
  }

  /// Set custom key-value data to be sent with crash reports
  /// Useful for adding context about app state when crash occurs
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      _log.e('Failed to set custom key', error: e);
    }
  }

  /// Set user ID for crash reports
  /// Helps identify which user experienced the crash
  static Future<void> setUserId(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      _log.e('Failed to set user ID', error: e);
    }
  }

  /// Clear user ID (useful on logout)
  static Future<void> clearUserId() async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier('');
    } catch (e) {
      _log.e('Failed to clear user ID', error: e);
    }
  }

  /// Log a message that will be included with crash reports
  /// Useful for tracking app flow and debugging
  static void logMessage(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      _log.e('Failed to log message', error: e);
    }
  }

  /// Check if crashlytics collection is enabled
  static Future<bool> isCrashlyticsCollectionEnabled() async {
    try {
      return FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled;
    } catch (e) {
      _log.e('Failed to check crashlytics status', error: e);
      return false;
    }
  }
}
