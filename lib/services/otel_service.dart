import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import '../logging/app_logger.dart';

/// Opaque handle to an active OpenTelemetry span.
///
/// Returned by [OTelService.startSpan] and [OTelService.startHttpClientSpan].
/// The caller must end the span by calling [endSuccess] or [endError].
/// All methods are safe to call — exceptions are swallowed internally.
class OTelSpanHandle {
  final Span _span;
  OTelSpanHandle._(this._span);

  /// Set a string attribute on the span.
  void setAttribute(String key, String value) {
    try {
      _span.setStringAttribute(key, value);
    } catch (_) {}
  }

  /// Set an int attribute on the span.
  void setIntAttribute(String key, int value) {
    try {
      _span.setIntAttribute(key, value);
    } catch (_) {}
  }

  /// Mark the span as successful and end it.
  void endSuccess() {
    try {
      _span.setStatus(SpanStatusCode.Ok);
      _span.end();
    } catch (_) {}
  }

  /// Mark the span as failed, record the exception, and end it.
  void endError(Object error, [StackTrace? stackTrace]) {
    try {
      _span.setStatus(SpanStatusCode.Error, error.toString());
      _span.recordException(error, stackTrace: stackTrace);
      _span.end();
    } catch (_) {}
  }
}

/// Singleton wrapper around the Dartastic OpenTelemetry SDK.
///
/// Provides distributed tracing (spans) and custom metrics exported via OTLP
/// to Google Cloud's `telemetry.googleapis.com` endpoint (or any OTel-compatible
/// backend). Runs **alongside** Firebase Performance and Analytics as a
/// dual-write strategy.
///
/// Active in ALL build modes when an OTLP endpoint is configured via
/// `--dart-define`. When no endpoint is set or [initialize] has not been called
/// (unit tests), all methods are silent no-ops with zero overhead.
///
/// ## Configuration (via `--dart-define`)
///
/// ```
/// flutter run \
///   --dart-define=OTEL_EXPORTER_OTLP_ENDPOINT=https://your-collector:4318 \
///   --dart-define=OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
///   --dart-define=OTEL_SERVICE_NAME=ash_trail
/// ```
///
/// Set `--dart-define=OTEL_ENABLED=false` to disable OTel even when an
/// endpoint is configured (useful for CI).
class OTelService {
  static final _log = AppLogger.logger('OTelService');
  static final OTelService _instance = OTelService._internal();
  static OTelService get instance => _instance;
  factory OTelService() => _instance;
  OTelService._internal();

  bool _initialized = false;
  Tracer? _tracer;

  // Dartastic metric types (APIMeter, APICounter, APIHistogram) are not
  // re-exported by the SDK barrel file. We use dynamic for these private
  // fields since they're only accessed internally via well-known methods
  // (.add(), .record()). This avoids importing the API package directly.
  dynamic _meter;
  dynamic _syncPushCounter;
  dynamic _syncPullCounter;
  dynamic _logCreatedCounter;
  dynamic _errorCounter;
  dynamic _syncDurationHistogram;
  dynamic _httpRequestDurationHistogram;

  /// Whether OpenTelemetry is initialized and active.
  bool get isInitialized => _initialized;

  /// Whether the service is ready to record telemetry.
  bool get _ready => _initialized && _tracer != null;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize OpenTelemetry with the Dartastic SDK.
  ///
  /// Call early in `main()`, after `WidgetsFlutterBinding.ensureInitialized()`
  /// and `Firebase.initializeApp()`. This is **non-fatal** — the app works
  /// fine without OTel.
  ///
  /// [serviceName] defaults to `'ash_trail'`. All other configuration
  /// (endpoint, protocol, headers, sampling) is read from `--dart-define`
  /// environment variables automatically by the Dartastic SDK.
  Future<void> initialize({String serviceName = 'ash_trail'}) async {
    if (_initialized) return;

    // Kill switch via dart-define
    const otelEnabled = bool.fromEnvironment(
      'OTEL_ENABLED',
      defaultValue: true,
    );
    if (!otelEnabled) {
      _log.i('OpenTelemetry disabled via OTEL_ENABLED=false');
      return;
    }

    // Check if an OTLP endpoint is configured
    const endpoint = String.fromEnvironment('OTEL_EXPORTER_OTLP_ENDPOINT');
    if (endpoint.isEmpty) {
      _log.i(
        'OpenTelemetry skipped — no OTEL_EXPORTER_OTLP_ENDPOINT configured',
      );
      return;
    }

    try {
      _log.i('Initializing OpenTelemetry → $endpoint');

      // Dartastic reads all OTEL_* dart-define env vars automatically
      await OTel.initialize(serviceName: serviceName);

      _tracer = OTel.tracer();
      _meter = OTel.meter();

      _createMetricInstruments();

      _initialized = true;
      _log.i('OpenTelemetry initialized: service=$serviceName');
    } catch (e, st) {
      _log.e(
        'OpenTelemetry initialization failed (non-fatal)',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _createMetricInstruments() {
    final meter = _meter;
    if (meter == null) return;

    try {
      _syncPushCounter = meter.createCounter<num>(
        name: 'ash_trail.sync.push_count',
        description: 'Number of records pushed during sync',
        unit: '{records}',
      );

      _syncPullCounter = meter.createCounter<num>(
        name: 'ash_trail.sync.pull_count',
        description: 'Number of records pulled during sync',
        unit: '{records}',
      );

      _logCreatedCounter = meter.createCounter<num>(
        name: 'ash_trail.log.created_count',
        description: 'Number of log records created',
        unit: '{records}',
      );

      _errorCounter = meter.createCounter<num>(
        name: 'ash_trail.errors',
        description: 'Application error count by category',
        unit: '{errors}',
      );

      _syncDurationHistogram = meter.createHistogram<num>(
        name: 'ash_trail.sync.duration',
        description: 'Sync cycle duration',
        unit: 'ms',
      );

      _httpRequestDurationHistogram = meter.createHistogram<num>(
        name: 'ash_trail.http.request_duration',
        description: 'HTTP request duration',
        unit: 'ms',
      );
    } catch (e) {
      _log.w('Failed to create some OTel metric instruments', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Tracing API — Span lifecycle
  // ---------------------------------------------------------------------------

  /// Start a span manually. Returns an [OTelSpanHandle] the caller must end
  /// by calling [OTelSpanHandle.endSuccess] or [OTelSpanHandle.endError].
  ///
  /// Returns `null` when OTel is not initialized (unit tests, no endpoint).
  OTelSpanHandle? startSpan(String name, {Map<String, String>? attributes}) {
    if (!_ready) return null;
    try {
      final span = _tracer!.startSpan(name);
      if (attributes != null) {
        for (final entry in attributes.entries) {
          span.setStringAttribute(entry.key, entry.value);
        }
      }
      return OTelSpanHandle._(span);
    } catch (e) {
      _log.w('Failed to start OTel span: $name', error: e);
      return null;
    }
  }

  /// Start a span for an outgoing HTTP request with standard OTel semantic
  /// conventions (`http.method`, `http.url`).
  ///
  /// Returns `null` when OTel is not initialized.
  OTelSpanHandle? startHttpClientSpan({
    required String method,
    required String url,
  }) {
    if (!_ready) return null;
    try {
      final span = _tracer!.startSpan('$method ${Uri.parse(url).path}');
      span.setStringAttribute('http.method', method);
      span.setStringAttribute('http.url', url);
      return OTelSpanHandle._(span);
    } catch (e) {
      _log.w('Failed to start HTTP span', error: e);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Tracing API — Operation wrappers
  // ---------------------------------------------------------------------------

  /// Create an OTel span around an async operation.
  ///
  /// Mirrors [AppPerformanceService.trace] to enable dual-write. When OTel is
  /// not initialized, executes [operation] directly with zero overhead.
  Future<T> traceSpan<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) async {
    if (!_ready) return operation();

    final spanHandle = startSpan(name, attributes: attributes);
    try {
      final result = await operation();
      spanHandle?.endSuccess();
      return result;
    } catch (e, st) {
      spanHandle?.endError(e, st);
      rethrow;
    }
  }

  /// Trace a startup phase.
  Future<T> traceStartup<T>(String phase, Future<T> Function() operation) {
    return traceSpan(
      'startup.$phase',
      operation,
      attributes: {'startup.phase': phase},
    );
  }

  /// Trace a sync cycle.
  Future<T> traceSync<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return traceSpan('sync', operation, attributes: attributes);
  }

  /// Trace a token refresh / Cloud Function call.
  Future<T> traceTokenRefresh<T>(Future<T> Function() operation) {
    return traceSpan('token_refresh', operation);
  }

  /// Trace a data export operation.
  Future<T> traceExport<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return traceSpan('data_export', operation, attributes: attributes);
  }

  /// Trace a Google Sign-In flow.
  Future<T> traceGoogleSignIn<T>(Future<T> Function() operation) {
    return traceSpan('google_sign_in', operation);
  }

  /// Trace account switching.
  Future<T> traceAccountSwitch<T>(Future<T> Function() operation) {
    return traceSpan('account_switch', operation);
  }

  // ---------------------------------------------------------------------------
  // Metrics API
  // ---------------------------------------------------------------------------

  /// Record sync push count.
  void recordSyncPush(int count) {
    try {
      _syncPushCounter?.add(count);
    } catch (_) {}
  }

  /// Record sync pull count.
  void recordSyncPull(int count) {
    try {
      _syncPullCounter?.add(count);
    } catch (_) {}
  }

  /// Record log creation.
  void recordLogCreated({String? eventType}) {
    try {
      _logCreatedCounter?.add(1);
    } catch (_) {}
  }

  /// Record an error occurrence with its category.
  void recordError(String category) {
    try {
      _errorCounter?.add(1);
    } catch (_) {}
  }

  /// Record sync duration in milliseconds.
  void recordSyncDuration(int durationMs) {
    try {
      _syncDurationHistogram?.record(durationMs.toDouble());
    } catch (_) {}
  }

  /// Record HTTP request duration in milliseconds.
  void recordHttpRequestDuration(
    int durationMs, {
    String? method,
    int? statusCode,
  }) {
    try {
      _httpRequestDurationHistogram?.record(durationMs.toDouble());
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Flush pending telemetry. Call on app shutdown if possible.
  Future<void> shutdown() async {
    if (!_initialized) return;
    try {
      _log.i('Shutting down OpenTelemetry...');
      await OTel.shutdown();
      _log.i('OpenTelemetry shutdown complete');
    } catch (e) {
      _log.w('OpenTelemetry shutdown error', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------------

  /// Return a snapshot of OTel configuration for the diagnostics screen.
  Map<String, dynamic> get diagnostics => {
    'initialized': _initialized,
    'hasTracer': _tracer != null,
    'hasMeter': _meter != null,
    'endpoint': const String.fromEnvironment(
      'OTEL_EXPORTER_OTLP_ENDPOINT',
      defaultValue: 'not configured',
    ),
    'enabled': const bool.fromEnvironment('OTEL_ENABLED', defaultValue: true),
  };
}
