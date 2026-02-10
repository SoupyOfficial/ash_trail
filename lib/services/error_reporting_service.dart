import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';
import '../models/app_error.dart';
import 'crash_reporting_service.dart';

/// Centralized error reporting service that bridges [AppError], [AppLogger],
/// and [CrashReportingService] into a single, consistent pipeline.
///
/// Every error in the app should flow through [ErrorReportingService.report]
/// so that:
///   1. It is logged at the correct level with full context.
///   2. It is forwarded to Crashlytics when appropriate.
///   3. Metrics / counts are tracked for diagnostics.
///
/// Usage:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, st) {
///   ErrorReportingService.instance.report(
///     AppError.from(e, st),
///     stackTrace: st,
///   );
/// }
/// ```
class ErrorReportingService {
  static final _log = AppLogger.logger('ErrorReporting');

  // Singleton
  static final ErrorReportingService _instance =
      ErrorReportingService._internal();
  static ErrorReportingService get instance => _instance;
  factory ErrorReportingService() => _instance;
  ErrorReportingService._internal();

  // ---------------------------------------------------------------------------
  // Error counters for diagnostics (per-session, not persisted)
  // ---------------------------------------------------------------------------
  final Map<ErrorCategory, int> _errorCounts = {};
  final List<_ErrorEntry> _recentErrors = [];
  static const int _maxRecentErrors = 50;

  /// Report an [AppError] through the unified pipeline.
  ///
  /// [context] is an optional human-readable label describing where the error
  /// occurred (e.g. 'SyncService.pushBatch').
  void report(AppError error, {StackTrace? stackTrace, String? context}) {
    // 1. Increment counters
    _errorCounts[error.category] = (_errorCounts[error.category] ?? 0) + 1;

    // 2. Keep a circular buffer of recent errors
    _recentErrors.add(
      _ErrorEntry(error: error, timestamp: DateTime.now(), context: context),
    );
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }

    // 3. Log at the appropriate level
    final logMessage =
        context != null
            ? '[$context] ${error.toLogString()}'
            : error.toLogString();

    switch (error.severity) {
      case ErrorSeverity.info:
        _log.i(logMessage);
      case ErrorSeverity.warning:
        _log.w(
          logMessage,
          error: error.originalError,
          stackTrace: stackTrace ?? error.stackTrace,
        );
      case ErrorSeverity.error:
        _log.e(
          logMessage,
          error: error.originalError,
          stackTrace: stackTrace ?? error.stackTrace,
        );
      case ErrorSeverity.fatal:
        _log.f(
          logMessage,
          error: error.originalError,
          stackTrace: stackTrace ?? error.stackTrace,
        );
    }

    // 4. Forward non-trivial errors to Crashlytics in non-debug builds
    if (!kDebugMode || error.severity == ErrorSeverity.fatal) {
      _forwardToCrashlytics(error, stackTrace);
    }
  }

  /// Convenience: report a raw exception, auto-classifying it.
  void reportException(
    Object exception, {
    StackTrace? stackTrace,
    String? context,
  }) {
    if (exception is AppError) {
      report(exception, stackTrace: stackTrace, context: context);
    } else {
      report(
        AppError.from(exception, stackTrace),
        stackTrace: stackTrace,
        context: context,
      );
    }
  }

  /// Wrap an async operation so that failures are automatically reported.
  ///
  /// Returns `null` on failure (the error is still reported).
  /// ```dart
  /// final data = await ErrorReportingService.instance.guard(
  ///   () => fetchData(),
  ///   context: 'HomeScreen.loadData',
  /// );
  /// ```
  Future<T?> guard<T>(Future<T> Function() action, {String? context}) async {
    try {
      return await action();
    } catch (e, st) {
      reportException(e, stackTrace: st, context: context);
      return null;
    }
  }

  /// Synchronous version of [guard].
  T? guardSync<T>(T Function() action, {String? context}) {
    try {
      return action();
    } catch (e, st) {
      reportException(e, stackTrace: st, context: context);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------------

  /// Return a snapshot of error counters (for diagnostics screen).
  Map<String, dynamic> get diagnostics => {
    'errorCounts': _errorCounts.map((k, v) => MapEntry(k.name, v)),
    'recentErrorCount': _recentErrors.length,
    'recentErrors':
        _recentErrors.reversed
            .take(10)
            .map(
              (e) => {
                'timestamp': e.timestamp.toIso8601String(),
                'category': e.error.category.name,
                'severity': e.error.severity.name,
                'message': e.error.message,
                'code': e.error.code,
                'context': e.context,
              },
            )
            .toList(),
  };

  /// Reset all counters (useful between test runs).
  @visibleForTesting
  void reset() {
    _errorCounts.clear();
    _recentErrors.clear();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _forwardToCrashlytics(AppError error, StackTrace? stackTrace) {
    try {
      // Set contextual keys
      if (error.code != null) {
        CrashReportingService.setCustomKey('error_code', error.code!);
      }
      CrashReportingService.setCustomKey('error_category', error.category.name);

      CrashReportingService.recordError(
        error.originalError ?? error,
        stackTrace ?? error.stackTrace ?? StackTrace.current,
        reason: error.toLogString(),
        fatal: error.severity == ErrorSeverity.fatal,
      );
    } catch (e) {
      // Swallow – never let reporting itself crash the app.
      _log.w('Failed to forward error to Crashlytics', error: e);
    }
  }
}

/// Internal bookkeeping entry.
class _ErrorEntry {
  final AppError error;
  final DateTime timestamp;
  final String? context;
  const _ErrorEntry({
    required this.error,
    required this.timestamp,
    this.context,
  });
}
