/// Domain entity representing an error event captured by the error boundary.
/// Contains sanitized error information that respects privacy settings.
class ErrorEvent {
  const ErrorEvent({
    required this.timestamp,
    required this.errorType,
    required this.message,
    this.sanitizedStackTrace,
    this.context,
    required this.wasAnalyticsOptIn,
  });

  final DateTime timestamp;
  final String errorType;
  final String message;
  final String? sanitizedStackTrace;
  final Map<String, dynamic>? context;
  final bool wasAnalyticsOptIn;

  /// Creates an error event from a caught error and stack trace.
  /// Sanitizes the information based on analytics opt-in preference.
  factory ErrorEvent.fromError({
    required Object error,
    required StackTrace stackTrace,
    required bool analyticsOptIn,
    Map<String, dynamic>? additionalContext,
  }) {
    final errorType = error.runtimeType.toString();
    final message =
        analyticsOptIn ? error.toString() : 'An unexpected error occurred';

    final sanitizedStackTrace =
        analyticsOptIn ? _sanitizeStackTrace(stackTrace.toString()) : null;

    final context = analyticsOptIn
        ? {
            'errorDetails': error.toString(),
            ...?additionalContext,
          }
        : {
            'hasAdditionalContext': additionalContext != null,
          };

    return ErrorEvent(
      timestamp: DateTime.now(),
      errorType: errorType,
      message: message,
      sanitizedStackTrace: sanitizedStackTrace,
      context: context,
      wasAnalyticsOptIn: analyticsOptIn,
    );
  }

  /// Sanitizes stack trace by removing potential PII and keeping only
  /// relevant error information.
  static String _sanitizeStackTrace(String stackTrace) {
    final lines = stackTrace.split('\n');
    final sanitizedLines = <String>[];

    for (final line in lines.take(10)) {
      // Limit to first 10 lines
      // Remove file paths that might contain usernames
      var sanitized = line.replaceAll(RegExp(r'file:///.*?/'), 'file:///.../');
      // Remove package paths that might contain sensitive info
      sanitized =
          sanitized.replaceAll(RegExp(r'package:[^/]+/'), 'package:.../');
      sanitizedLines.add(sanitized);
    }

    return sanitizedLines.join('\n');
  }

  /// Creates a user-friendly error summary for display
  String get displaySummary {
    if (wasAnalyticsOptIn) {
      return 'Error: $errorType\nMessage: $message';
    } else {
      return 'An unexpected error occurred. Enable analytics sharing in settings for detailed error information.';
    }
  }

  /// Creates diagnostic information suitable for sharing
  String get diagnosticInfo {
    final buffer = StringBuffer();
    buffer.writeln('AshTrail Error Report');
    buffer.writeln('Timestamp: ${timestamp.toIso8601String()}');
    buffer.writeln('Error Type: $errorType');
    buffer.writeln('Analytics Opt-in: $wasAnalyticsOptIn');
    buffer.writeln();

    if (wasAnalyticsOptIn) {
      buffer.writeln('Message: $message');
      if (sanitizedStackTrace != null) {
        buffer.writeln();
        buffer.writeln('Stack Trace:');
        buffer.writeln(sanitizedStackTrace);
      }
      if (context != null && context!.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Context: ${context.toString()}');
      }
    } else {
      buffer.writeln('Message: [Redacted - Analytics opt-out]');
      buffer.writeln('Details: [Redacted - Analytics opt-out]');
    }

    return buffer.toString();
  }
}
