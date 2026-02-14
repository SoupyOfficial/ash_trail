# app_performance_service

> **Source:** `lib/services/app_performance_service.dart`

## Purpose

Singleton wrapper around Firebase Performance for custom traces. Active in ALL build modes (debug, profile, release/TestFlight). When Firebase is not initialized (unit tests), all trace methods execute the wrapped operation directly without any trace overhead (zero-overhead fallback). Dual-writes to `OTelService` spans alongside Firebase traces.

## Dependencies

- `package:firebase_core/firebase_core.dart` — `Firebase.apps`
- `package:firebase_performance/firebase_performance.dart` — `FirebasePerformance`, `Trace`
- `../logging/app_logger.dart` — Structured logging
- `otel_service.dart` — `OTelService` for dual-write spans

## Pseudo-Code

### Class: AppPerformanceService (Singleton)

```
CLASS AppPerformanceService

  SINGLETON via factory constructor + static _instance

  GETTER _ready → bool
    RETURN Firebase.apps.isNotEmpty

  // ── Generic Trace Wrapper ──

  ASYNC FUNCTION trace<T>(name, operation, {attributes?, metrics?}) → T
    IF NOT _ready → RETURN operation()

    otelSpan = OTelService.instance.startSpan(name, attributes)

    firebaseTrace = FirebasePerformance.instance.newTrace(name)
    SET attributes on firebaseTrace
    START firebaseTrace

    TRY:
      result = AWAIT operation()
      SET 'success' = 'true' on trace
      SET metrics on trace
      otelSpan.endSuccess()
      RETURN result
    CATCH:
      SET 'success' = 'false', 'error_type' on trace
      otelSpan.endError(e, st)
      RETHROW
    FINALLY:
      STOP firebaseTrace

  // ── Manual Trace Handle ──

  ASYNC FUNCTION startTrace(name, {attributes?}) → Trace?
    IF NOT _ready → RETURN null
    CREATE and START trace, SET attributes
    RETURN trace    // caller must call trace.stop()

  // ── Domain-Specific Trace Helpers ──

  traceStartup<T>(phase, operation)      → trace('startup_$phase', operation)
  traceSync<T>(operation, {attributes?}) → trace('sync', operation, ...)
  traceTokenRefresh<T>(operation)        → trace('token_refresh', operation)
  traceExport<T>(operation, {attributes?}) → trace('data_export', operation, ...)
  traceGoogleSignIn<T>(operation)        → trace('google_sign_in', operation)
  traceAccountSwitch<T>(operation)       → trace('account_switch', operation)

END CLASS
```

## Notes

- All domain trace helpers delegate to the generic `trace()` method.
- `trace()` dual-writes: creates both a Firebase Performance `Trace` and an `OTelService` span.
- `startTrace()` returns a raw `Trace?` handle for cases where the caller needs to set metrics mid-operation.
