import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/otel_service.dart';

void main() {
  group('OTelService', () {
    test('instance returns singleton', () {
      expect(OTelService.instance, same(OTelService.instance));
      expect(OTelService(), same(OTelService.instance));
    });

    test('is not initialized by default', () {
      expect(OTelService.instance.isInitialized, isFalse);
    });

    test('traceSpan executes operation when not initialized', () async {
      var executed = false;
      final result = await OTelService.instance.traceSpan('test', () async {
        executed = true;
        return 42;
      });
      expect(executed, isTrue);
      expect(result, 42);
    });

    test('traceSpan propagates exceptions when not initialized', () async {
      expect(
        () => OTelService.instance.traceSpan('test', () async {
          throw StateError('boom');
        }),
        throwsA(isA<StateError>()),
      );
    });

    test('startSpan returns null when not initialized', () {
      expect(OTelService.instance.startSpan('test'), isNull);
    });

    test('startHttpClientSpan returns null when not initialized', () {
      expect(
        OTelService.instance.startHttpClientSpan(
          method: 'GET',
          url: 'https://example.com/api',
        ),
        isNull,
      );
    });

    test(
      'convenience trace methods work as passthrough when not initialized',
      () async {
        // All trace wrappers should execute the operation directly
        expect(
          await OTelService.instance.traceStartup('test', () async => 'ok'),
          'ok',
        );
        expect(await OTelService.instance.traceSync(() async => 'ok'), 'ok');
        expect(
          await OTelService.instance.traceTokenRefresh(() async => 'ok'),
          'ok',
        );
        expect(await OTelService.instance.traceExport(() async => 'ok'), 'ok');
        expect(
          await OTelService.instance.traceGoogleSignIn(() async => 'ok'),
          'ok',
        );
        expect(
          await OTelService.instance.traceAccountSwitch(() async => 'ok'),
          'ok',
        );
      },
    );

    test('metric methods are silent no-ops when not initialized', () {
      // None of these should throw
      OTelService.instance.recordSyncPush(5);
      OTelService.instance.recordSyncPull(3);
      OTelService.instance.recordLogCreated();
      OTelService.instance.recordLogCreated(eventType: 'smoke');
      OTelService.instance.recordError('network');
      OTelService.instance.recordSyncDuration(1500);
      OTelService.instance.recordHttpRequestDuration(200);
      OTelService.instance.recordHttpRequestDuration(
        500,
        method: 'POST',
        statusCode: 200,
      );
    });

    test('shutdown is a no-op when not initialized', () async {
      // Should complete without error
      await OTelService.instance.shutdown();
    });

    test('diagnostics returns expected structure when not initialized', () {
      final diag = OTelService.instance.diagnostics;
      expect(diag['initialized'], isFalse);
      expect(diag['hasTracer'], isFalse);
      expect(diag['hasMeter'], isFalse);
      expect(diag, contains('endpoint'));
      expect(diag, contains('enabled'));
    });

    test(
      'initialize is no-op when OTEL_EXPORTER_OTLP_ENDPOINT is not set',
      () async {
        // Without the dart-define, initialize should skip silently
        await OTelService.instance.initialize();
        // Still not initialized because no endpoint was configured
        expect(OTelService.instance.isInitialized, isFalse);
      },
    );
  });
}
