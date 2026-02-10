/// Standardized error types for Ash Trail per design doc 11. Error Handling.
///
/// All errors are classified by [ErrorCategory] and [ErrorSeverity] so they
/// can be logged, reported, and surfaced to users in a consistent way.
library;

/// Error category per design doc 11.3 Error Classification.
enum ErrorCategory {
  /// Invalid user input or action (recoverable, not a bug).
  validation,

  /// Authentication / authorization failures.
  auth,

  /// Network or connectivity issues.
  network,

  /// Local database read/write failures.
  database,

  /// Cloud sync failures (Firestore, etc.).
  sync,

  /// Platform service errors (location, notifications, etc.).
  platform,

  /// Unexpected / programmer errors.
  unexpected,
}

/// How severe the error is – drives logging level & UI treatment.
enum ErrorSeverity {
  /// Informational only; no user action needed.
  info,

  /// Something degraded but the app can continue.
  warning,

  /// Operation failed; user should be notified.
  error,

  /// Unrecoverable; app may need to restart.
  fatal,
}

/// Unified error object used throughout the app.
///
/// Prefer creating instances via the named constructors for common cases
/// (e.g. [AppError.validation], [AppError.network]).
class AppError implements Exception {
  /// Human-readable message safe to show to the user.
  final String message;

  /// Optional technical detail for logging (never shown to user).
  final String? technicalDetail;

  /// The broad category this error falls into.
  final ErrorCategory category;

  /// Severity level.
  final ErrorSeverity severity;

  /// The original exception, if any.
  final Object? originalError;

  /// The original stack trace, if any.
  final StackTrace? stackTrace;

  /// Machine-readable error code for programmatic handling.
  /// Convention: `<CATEGORY>_<SPECIFIC>`, e.g. `AUTH_TOKEN_EXPIRED`.
  final String? code;

  const AppError({
    required this.message,
    this.technicalDetail,
    this.category = ErrorCategory.unexpected,
    this.severity = ErrorSeverity.error,
    this.originalError,
    this.stackTrace,
    this.code,
  });

  // ---------------------------------------------------------------------------
  // Named constructors for common error patterns
  // ---------------------------------------------------------------------------

  /// Validation / user-input error.
  const AppError.validation({
    required String message,
    String? code,
    String? technicalDetail,
  }) : this(
         message: message,
         category: ErrorCategory.validation,
         severity: ErrorSeverity.warning,
         code: code ?? 'VALIDATION_ERROR',
         technicalDetail: technicalDetail,
       );

  /// Authentication error.
  factory AppError.auth({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.auth,
      severity: ErrorSeverity.error,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'AUTH_ERROR',
    );
  }

  /// Network / connectivity error.
  factory AppError.network({
    String message =
        'Unable to connect. Please check your internet and try again.',
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.network,
      severity: ErrorSeverity.warning,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'NETWORK_ERROR',
    );
  }

  /// Local database error.
  factory AppError.database({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.database,
      severity: ErrorSeverity.error,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'DATABASE_ERROR',
    );
  }

  /// Sync / cloud error.
  factory AppError.sync({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.sync,
      severity: ErrorSeverity.warning,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'SYNC_ERROR',
    );
  }

  /// Platform service error (location, notifications, etc.).
  factory AppError.platform({
    required String message,
    Object? originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.platform,
      severity: ErrorSeverity.warning,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'PLATFORM_ERROR',
    );
  }

  /// Unexpected / programmer error.
  factory AppError.unexpected({
    String message = 'An unexpected error occurred. Please try again.',
    required Object originalError,
    StackTrace? stackTrace,
    String? code,
  }) {
    return AppError(
      message: message,
      category: ErrorCategory.unexpected,
      severity: ErrorSeverity.error,
      originalError: originalError,
      stackTrace: stackTrace,
      code: code ?? 'UNEXPECTED_ERROR',
      technicalDetail: originalError.toString(),
    );
  }

  /// Create from a raw exception, attempting to classify it automatically.
  factory AppError.from(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) return error;

    // Classify known exception types
    final errorString = error.toString().toLowerCase();

    if (error is ArgumentError) {
      return AppError.validation(
        message: error.message?.toString() ?? 'Invalid input',
        technicalDetail: error.toString(),
      );
    }

    if (errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('network')) {
      return AppError.network(originalError: error, stackTrace: stackTrace);
    }

    if (errorString.contains('hive') ||
        errorString.contains('box') ||
        errorString.contains('database')) {
      return AppError.database(
        message: 'A database error occurred. Please restart the app.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('permission') || errorString.contains('denied')) {
      return AppError.platform(
        message: 'Permission denied. Please check your settings.',
        originalError: error,
        stackTrace: stackTrace,
        code: 'PLATFORM_PERMISSION_DENIED',
      );
    }

    return AppError.unexpected(originalError: error, stackTrace: stackTrace);
  }

  /// User-facing display string.
  @override
  String toString() => message;

  /// Full diagnostic string for logging.
  String toLogString() {
    final buffer =
        StringBuffer()
          ..write('[${category.name.toUpperCase()}]')
          ..write('[${severity.name.toUpperCase()}]');
    if (code != null) buffer.write('[$code]');
    buffer.write(' $message');
    if (technicalDetail != null) buffer.write(' | detail: $technicalDetail');
    if (originalError != null) buffer.write(' | cause: $originalError');
    return buffer.toString();
  }
}
