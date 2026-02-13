import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../logging/app_logger.dart';
import 'otel_service.dart';

/// Singleton wrapper around Firebase Performance for custom traces.
///
/// Active in ALL build modes (debug, profile, release/TestFlight).
/// The only guard is Firebase initialization — in unit tests where
/// Firebase.apps.isEmpty, all trace methods execute the operation
/// without wrapping it in a trace (zero-overhead fallback).
class AppPerformanceService {
  // ignore: unused_field
  static final _log = AppLogger.logger('Performance');
  static final AppPerformanceService _instance =
      AppPerformanceService._internal();
  static AppPerformanceService get instance => _instance;
  factory AppPerformanceService() => _instance;
  AppPerformanceService._internal();

  /// Returns true when Firebase is available.
  /// No kDebugMode check — traces run in ALL build modes including TestFlight.
  bool get _ready => Firebase.apps.isNotEmpty;

  /// Generic trace wrapper. All other trace methods delegate here.
  ///
  /// When Firebase is not available (unit tests), executes [operation] directly
  /// without any trace overhead.
  Future<T> trace<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    if (!_ready) return operation();

    // Dual-write: start an OTel span alongside the Firebase trace.
    // OTelService handles the not-initialized case internally (returns null).
    final otelSpan = OTelService.instance.startSpan(
      name,
      attributes: attributes,
    );

    final trace = FirebasePerformance.instance.newTrace(name);
    attributes?.forEach(trace.putAttribute);
    await trace.start();
    try {
      final result = await operation();
      trace.putAttribute('success', 'true');
      metrics?.forEach(trace.setMetric);
      otelSpan?.endSuccess();
      return result;
    } catch (e, st) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error_type', e.runtimeType.toString());
      otelSpan?.endError(e, st);
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Trace with an explicit [Trace] handle for setting metrics mid-operation.
  ///
  /// Returns a started [Trace] that the caller must stop with `trace.stop()`.
  /// Returns `null` when Firebase is unavailable (unit tests).
  Future<Trace?> startTrace(
    String name, {
    Map<String, String>? attributes,
  }) async {
    if (!_ready) return null;
    final t = FirebasePerformance.instance.newTrace(name);
    attributes?.forEach(t.putAttribute);
    await t.start();
    return t;
  }

  /// Trace an app startup phase (Firebase init, Hive init, etc.)
  Future<T> traceStartup<T>(String phase, Future<T> Function() operation) {
    return trace('startup_$phase', operation);
  }

  /// Trace a sync cycle.
  Future<T> traceSync<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return trace('sync', operation, attributes: attributes);
  }

  /// Trace a token refresh / Cloud Function call.
  Future<T> traceTokenRefresh<T>(Future<T> Function() operation) {
    return trace('token_refresh', operation);
  }

  /// Trace a data export operation.
  Future<T> traceExport<T>(
    Future<T> Function() operation, {
    Map<String, String>? attributes,
  }) {
    return trace('data_export', operation, attributes: attributes);
  }

  /// Trace a Google Sign-In flow (multi-step: Google → Firebase → token).
  Future<T> traceGoogleSignIn<T>(Future<T> Function() operation) {
    return trace('google_sign_in', operation);
  }

  /// Trace account switching (token generation + re-auth).
  Future<T> traceAccountSwitch<T>(Future<T> Function() operation) {
    return trace('account_switch', operation);
  }
}
