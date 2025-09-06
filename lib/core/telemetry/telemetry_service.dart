import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple telemetry service abstraction.
abstract class TelemetryService {
  void logEvent(String name, Map<String, Object?> params);
}

class DebugTelemetryService implements TelemetryService {
  @override
  void logEvent(String name, Map<String, Object?> params) {
    // For now just print; real impl would batch & send to backend.
    // ignore: avoid_print
    print('[telemetry] $name ${params.isEmpty ? '' : params}');
  }
}

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return DebugTelemetryService();
});
