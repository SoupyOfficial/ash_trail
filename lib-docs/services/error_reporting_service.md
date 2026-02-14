# error_reporting_service

> **Source:** `lib/services/error_reporting_service.dart`

## Purpose

Centralized error reporting pipeline that bridges `AppError`, `AppLogger`, `CrashReportingService`, `AppAnalyticsService`, and `OTelService`. Every error in the app should flow through `ErrorReportingService.report()` so it is logged, forwarded to Crashlytics, and counted for diagnostics.

## Dependencies

- `package:flutter/foundation.dart` — `kDebugMode`
- `../logging/app_logger.dart` — Structured logging
- `../models/app_error.dart` — `AppError`, `ErrorCategory`, `ErrorSeverity`
- `app_analytics_service.dart` — `AppAnalyticsService` for error event counting
- `crash_reporting_service.dart` — `CrashReportingService` for Crashlytics
- `otel_service.dart` — `OTelService` for error metric counting

## Pseudo-Code

### Class: ErrorReportingService (Singleton)

```
CLASS ErrorReportingService

  SINGLETON via factory constructor + static _instance

  FIELDS:
    _errorCounts: Map<ErrorCategory, int>      — per-session counter
    _recentErrors: List<_ErrorEntry>           — circular buffer (max 50)
    _reportedThisSession: Set<String>          — dedup keys for Crashlytics

  // ── Core Pipeline ──

  FUNCTION report(AppError error, {stackTrace?, context?}) → void
    1. INCREMENT _errorCounts[error.category]
    2. ADD to _recentErrors circular buffer (cap at 50)
    3. LOG at appropriate level based on error.severity:
         info → _log.i
         warning → _log.w
         error → _log.e
         fatal → _log.f
    4. FORWARD to Crashlytics (non-debug OR fatal):
         Deduplicate by 'category:code' key per session
         Set custom keys, call CrashReportingService.recordError
    5. FORWARD to AppAnalyticsService.logError(category, severity)
    6. RECORD OTel error metric via OTelService.recordError

  // ── Convenience Methods ──

  FUNCTION reportException(exception, {stackTrace?, context?}) → void
    IF exception IS AppError → report(exception, ...)
    ELSE → report(AppError.from(exception, stackTrace), ...)

  ASYNC FUNCTION guard<T>(action, {context?}) → T?
    TRY: RETURN AWAIT action()
    CATCH: reportException(e, st, context) → RETURN null

  FUNCTION guardSync<T>(action, {context?}) → T?
    TRY: RETURN action()
    CATCH: reportException(e, st, context) → RETURN null

  // ── Diagnostics ──

  GETTER diagnostics → Map<String, dynamic>
    RETURN {
      errorCounts: _errorCounts mapped by name,
      recentErrorCount: count,
      recentErrors: last 10 entries with timestamp/category/severity/message/code/context
    }

  @visibleForTesting
  FUNCTION reset() → clear all counters and buffers

  FUNCTION resetSession() → clear dedup set (call on app foreground)

END CLASS
```

## Notes

- Crashlytics forwarding deduplicates: each unique `category:code` pair is reported only once per cold start.
- In debug mode, errors are NOT forwarded to Crashlytics unless severity is `fatal`.
- `guard()` and `guardSync()` are wrappers that auto-report and return `null` on failure.
