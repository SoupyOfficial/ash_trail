import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging for Ash Trail using the [logger] package.
///
/// Provides named loggers with consistent formatting, log levels, and
/// build-mode awareness. In debug/profile, all logs >= [Level.debug] are shown.
/// In release, only [Level.warning] and above are shown.
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
    Logger.level = kDebugMode ? Level.debug : Level.warning;
  }
}

/// Log filter that respects [Logger.level] and build mode.
/// In release, only warning and above are emitted.
class _AppLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    AppLogger._ensureInitialized();
    if (!kDebugMode && event.level.index < Level.warning.index) {
      return false;
    }
    return event.level.index >= Logger.level.index;
  }
}
