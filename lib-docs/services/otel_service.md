# otel_service

> **Source:** `lib/services/otel_service.dart`

## Purpose

Singleton wrapper around the Dartastic OpenTelemetry SDK. Provides distributed tracing (spans) and custom metrics exported via OTLP. Runs alongside Firebase Performance and Analytics as a dual-write strategy. Active in ALL build modes when an OTLP endpoint is configured via `--dart-define`. When no endpoint is set or `initialize()` has not been called (unit tests), all methods are silent no-ops with zero overhead.

## Dependencies

- `package:dartastic_opentelemetry/dartastic_opentelemetry.dart` — `OTel`, `Tracer`, `Span`, `SpanStatusCode`
- `../logging/app_logger.dart` — Structured logging

## Configuration (via `--dart-define`)

```
flutter run \
  --dart-define=OTEL_EXPORTER_OTLP_ENDPOINT=https://your-collector:4318 \
  --dart-define=OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  --dart-define=OTEL_SERVICE_NAME=ash_trail
```

Set `--dart-define=OTEL_ENABLED=false` to disable OTel even when an endpoint is configured.

## Pseudo-Code

### Class: OTelSpanHandle

```
CLASS OTelSpanHandle
  FIELDS: _span: Span

  setAttribute(key, value)      — set string attribute (swallows exceptions)
  setIntAttribute(key, value)   — set int attribute (swallows exceptions)
  endSuccess()                  — set status OK, end span
  endError(error, [stackTrace]) — set status Error, record exception, end span
END CLASS
```

### Class: OTelService (Singleton)

```
CLASS OTelService

  SINGLETON via factory constructor + static _instance

  FIELDS:
    _initialized: bool
    _tracer: Tracer?
    _meter, _syncPushCounter, _syncPullCounter,
    _logCreatedCounter, _errorCounter,
    _syncDurationHistogram, _httpRequestDurationHistogram

  GETTER isInitialized → bool
  GETTER _ready → _initialized && _tracer != null

  // ── Initialization ──

  ASYNC FUNCTION initialize({serviceName = 'ash_trail'}) → void
    IF already initialized → RETURN
    IF OTEL_ENABLED=false (dart-define) → LOG and RETURN
    IF OTEL_EXPORTER_OTLP_ENDPOINT is empty → LOG and RETURN
    TRY:
      OTel.initialize(serviceName)
      _tracer = OTel.tracer()
      _meter = OTel.meter()
      _createMetricInstruments()
      _initialized = true
    CATCH: LOG error (non-fatal)

  PRIVATE _createMetricInstruments() → void
    CREATE counters:
      ash_trail.sync.push_count       — records pushed
      ash_trail.sync.pull_count       — records pulled
      ash_trail.log.created_count     — log records created
      ash_trail.errors                — errors by category
    CREATE histograms:
      ash_trail.sync.duration         — sync cycle duration (ms)
      ash_trail.http.request_duration — HTTP request duration (ms)

  // ── Tracing API — Span Lifecycle ──

  FUNCTION startSpan(name, {attributes?}) → OTelSpanHandle?
    IF NOT _ready → RETURN null
    CREATE span from _tracer, SET attributes → RETURN OTelSpanHandle

  FUNCTION startHttpClientSpan({method, url}) → OTelSpanHandle?
    IF NOT _ready → RETURN null
    CREATE span '$method $path', SET http.method, http.url → RETURN handle

  // ── Tracing API — Operation Wrappers ──

  ASYNC traceSpan<T>(name, operation, {attributes?}) → T
    IF NOT _ready → RETURN operation()
    START span, TRY operation, endSuccess/endError

  traceStartup<T>(phase, operation)      → traceSpan('startup.$phase', ...)
  traceSync<T>(operation, {attributes?}) → traceSpan('sync', ...)
  traceTokenRefresh<T>(operation)        → traceSpan('token_refresh', ...)
  traceExport<T>(operation, {attributes?}) → traceSpan('data_export', ...)
  traceGoogleSignIn<T>(operation)        → traceSpan('google_sign_in', ...)
  traceAccountSwitch<T>(operation)       → traceSpan('account_switch', ...)

  // ── Metrics API ──

  recordSyncPush(count)               — _syncPushCounter.add(count)
  recordSyncPull(count)               — _syncPullCounter.add(count)
  recordLogCreated({eventType?})      — _logCreatedCounter.add(1)
  recordError(category)               — _errorCounter.add(1)
  recordSyncDuration(durationMs)      — _syncDurationHistogram.record(ms)
  recordHttpRequestDuration(durationMs, {method?, statusCode?})
                                      — _httpRequestDurationHistogram.record(ms)

  // ── Lifecycle ──

  ASYNC shutdown() → OTel.shutdown()

  // ── Diagnostics ──

  GETTER diagnostics → {initialized, hasTracer, hasMeter, endpoint, enabled}

END CLASS
```

## Notes

- Metric instrument fields use `dynamic` to avoid importing internal SDK API types.
- All public methods swallow exceptions — OTel failures never crash the app.
- Mirrors the `AppPerformanceService` trace helper API for consistent dual-write.
