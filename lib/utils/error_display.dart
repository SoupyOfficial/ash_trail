import 'package:flutter/material.dart';
import '../models/app_error.dart';
import '../services/error_reporting_service.dart';

/// Standardized UI utilities for displaying errors consistently.
///
/// Follows design doc 11.3 – user errors surface as snackbars / inline text,
/// system errors surface as generic messages, and fatals trigger a full-screen
/// fallback.
class ErrorDisplay {
  ErrorDisplay._();

  // ---------------------------------------------------------------------------
  // SnackBar helpers
  // ---------------------------------------------------------------------------

  /// Show a [SnackBar] styled for the given [AppError].
  ///
  /// Automatically chooses colour / icon based on [ErrorSeverity].
  /// The [context] parameter is the Flutter build context.
  /// [reportContext] is an optional string for logging (e.g. 'QuickLog.submit').
  static void showSnackBar(
    BuildContext context,
    AppError error, {
    String? reportContext,
    Duration? duration,
    SnackBarAction? action,
  }) {
    // Report through the pipeline
    ErrorReportingService.instance.report(error, context: reportContext);

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_iconFor(error.severity), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _colorFor(error.severity),
        behavior: SnackBarBehavior.floating,
        duration: duration ?? _durationFor(error.severity),
        action: action,
      ),
    );
  }

  /// Convenience: show a snackbar from a raw exception.
  static void showException(
    BuildContext context,
    Object exception, {
    StackTrace? stackTrace,
    String? reportContext,
  }) {
    final appError = AppError.from(exception, stackTrace);
    showSnackBar(context, appError, reportContext: reportContext);
  }

  // ---------------------------------------------------------------------------
  // Inline error widget (for forms / empty states)
  // ---------------------------------------------------------------------------

  /// A compact inline error widget suitable for embedding in forms or lists.
  static Widget inline(AppError error) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colorFor(error.severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _colorFor(error.severity).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _iconFor(error.severity),
            color: _colorFor(error.severity),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(color: _colorFor(error.severity), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Full-screen error fallback
  // ---------------------------------------------------------------------------

  /// Full-screen error widget for unrecoverable states.
  ///
  /// Includes a retry callback so the user can attempt to recover.
  static Widget fullScreen({required AppError error, VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconFor(error.severity),
              size: 48,
              color: _colorFor(error.severity),
            ),
            const SizedBox(height: 16),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AsyncValue error handler (for Riverpod)
  // ---------------------------------------------------------------------------

  /// Standard error widget for use in Riverpod `AsyncValue.when(error: ...)`.
  ///
  /// ```dart
  /// myAsyncValue.when(
  ///   data: (d) => ...,
  ///   loading: () => ...,
  ///   error: (e, st) => ErrorDisplay.asyncError(e, st, onRetry: () => ref.refresh(myProvider)),
  /// );
  /// ```
  static Widget asyncError(
    Object error,
    StackTrace? stackTrace, {
    VoidCallback? onRetry,
    String? reportContext,
  }) {
    final appError = AppError.from(error, stackTrace);
    ErrorReportingService.instance.report(
      appError,
      stackTrace: stackTrace,
      context: reportContext,
    );
    return fullScreen(error: appError, onRetry: onRetry);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static IconData _iconFor(ErrorSeverity severity) => switch (severity) {
    ErrorSeverity.info => Icons.info_outline,
    ErrorSeverity.warning => Icons.warning_amber_rounded,
    ErrorSeverity.error => Icons.error_outline,
    ErrorSeverity.fatal => Icons.dangerous,
  };

  static Color _colorFor(ErrorSeverity severity) => switch (severity) {
    ErrorSeverity.info => const Color(0xFF2196F3), // blue
    ErrorSeverity.warning => const Color(0xFFF57C00), // orange
    ErrorSeverity.error => const Color(0xFFD32F2F), // red
    ErrorSeverity.fatal => const Color(0xFFB71C1C), // dark red
  };

  static Duration _durationFor(ErrorSeverity severity) => switch (severity) {
    ErrorSeverity.info => const Duration(seconds: 2),
    ErrorSeverity.warning => const Duration(seconds: 3),
    ErrorSeverity.error => const Duration(seconds: 4),
    ErrorSeverity.fatal => const Duration(seconds: 6),
  };
}
