import 'package:ash_trail/core/telemetry/telemetry_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetryService', () {
    test('DebugTelemetryService should log events', () {
      final service = DebugTelemetryService();

      // This should not throw and should execute the print statement
      service.logEvent('test_event', {'key': 'value'});
      service.logEvent('simple_event', {});

      // Just testing that the method executes without error
      expect(service, isA<TelemetryService>());
    });

    test('telemetryServiceProvider should provide DebugTelemetryService', () {
      final container = ProviderContainer();
      final service = container.read(telemetryServiceProvider);

      expect(service, isA<DebugTelemetryService>());
      expect(service, isA<TelemetryService>());

      container.dispose();
    });

    test('TelemetryService interface should be implementable', () {
      final service = TestTelemetryService();
      service.logEvent('test', {'data': 123});

      expect(service.events, hasLength(1));
      expect(service.events.first.name, equals('test'));
      expect(service.events.first.params, equals({'data': 123}));
    });
  });
}

class TestTelemetryService implements TelemetryService {
  final List<TelemetryEvent> events = [];

  @override
  void logEvent(String name, Map<String, Object?> params) {
    events.add(TelemetryEvent(name, params));
  }
}

class TelemetryEvent {
  final String name;
  final Map<String, Object?> params;

  TelemetryEvent(this.name, this.params);
}
