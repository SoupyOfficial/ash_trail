import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging for Ash Trail using the [logger] package.
///
/// Provides named loggers with consistent formatting, log levels, and
/// build-mode awareness. In debug/profile, all logs >= [Level.debug] are shown.
/// In release, only [Level.warning] and above are shown.
///
/// To enable verbose logging in release/TestFlight builds (for multi-account
/// debugging), call [AppLogger.setVerboseLogging(true)] early in main().
///
/// Usage:
/// ```dart
/// final _log = AppLogger.logger('SyncService');
/// _log.i('Syncing records for user $userId');
/// _log.w('No authenticated user, skipping sync');
/// _log.e('Sync failed', error: e, stackTrace: st);
/// ```
class AppLogger {
  AppLogger._();

  static final Map<String, Logger> _loggers = {};
  static bool _initialized = false;

  /// When true, ALL log levels (including debug/info) are emitted even in
  /// release builds. Use this for TestFlight / QA diagnostics.
  static bool _verboseLogging = false;

  /// Enable or disable verbose logging in release/profile builds.
  ///
  /// When enabled, the log filter will pass all events regardless of build
  /// mode. This is useful for TestFlight builds where you need full diagnostic
  /// output to debug multi-account switching and log recording issues.
  ///
  /// Call this in main() before any loggers are created:
  /// ```dart
  /// AppLogger.setVerboseLogging(true);
  /// ```
  static void setVerboseLogging(bool enabled) {
    _verboseLogging = enabled;
    if (enabled) {
      Logger.level = Level.debug;
    } else {
      Logger.level = kDebugMode ? Level.debug : Level.warning;
    }
    // Re-initialize loggers so they pick up the new filter behaviour
    _loggers.clear();
    _initialized = false;
    _ensureInitialized();
  }

  /// Whether verbose logging is currently enabled.
  static bool get isVerboseLogging => _verboseLogging;

  /// Returns a named [Logger] instance for the given component.
  /// Reuses the same instance for a given name.
  static Logger logger(String name) {
    _ensureInitialized();
    return _loggers.putIfAbsent(name, () {
      final l = Logger(
        filter: _AppLogFilter(),
        printer: PrefixPrinter(
          PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          error: '[$name]',
          warning: '[$name]',
          info: '[$name]',
          debug: '[$name]',
          trace: '[$name]',
        ),
      );
      return l;
    });
  }

  /// Ensures global level is set based on build mode. Called automatically
  /// when first logger is created, but can be called earlier in main().
  static void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    Logger.level =
        (kDebugMode || _verboseLogging) ? Level.debug : Level.warning;
  }

  /// Diagnostic: return a summary of the current logging configuration.
  /// Useful for integration tests / TestFlight diagnostics.
  static Map<String, dynamic> get diagnostics => {
    'verboseLogging': _verboseLogging,
    'kDebugMode': kDebugMode,
    'loggerLevel': Logger.level.name,
    'activeLoggers': _loggers.keys.toList(),
  };
}

/// Log filter that respects [Logger.level] and build mode.
/// In release, only warning and above are emitted unless verbose logging is on.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    AppLogger._ensureInitialized();
    // When verbose logging is enabled, pass everything at or above Logger.level
    if (AppLogger._verboseLogging) {
      return event.level.index >= Logger.level.index;
    }
    if (!kDebugMode && event.level.index < Level.warning.index) {
      return false;
    }
    return event.level.index >= Logger.level.index;
  }
}
