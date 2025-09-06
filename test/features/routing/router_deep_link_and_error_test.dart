import 'package:ash_trail/core/routing/app_router.dart';
import 'package:ash_trail/core/telemetry/telemetry_service.dart';
import 'package:ash_trail/features/routing/domain/resolve_deep_link_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingTelemetry extends TelemetryService {
  final List<(String, Map<String, Object?>)> events = [];
  @override
  void logEvent(String name, Map<String, Object?> params) {
    events.add((name, params));
  }
}

void main() {
  testWidgets('unknown route emits route_unknown and shows home',
      (tester) async {
    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
    ], child: MaterialApp.router(routerConfig: router)));
    // Navigate to unknown path
    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(rec.events.any((e) => e.$1 == 'route_unknown'), isTrue);
  });

  testWidgets('deep link cold start navigates to log detail', (tester) async {
    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      deepLinkInitialLocationProvider.overrideWith((ref) async => '/log/abc'),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      deepLinkInitialLocationProvider.overrideWith((ref) async => '/log/abc'),
    ], child: MaterialApp.router(routerConfig: router)));
    // Allow microtask + potential navigation (multiple frames)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 40));
    // Assert log detail screen visible
    expect(find.text('Log abc'), findsOneWidget);
  });

  testWidgets('telemetry records multiple pushes (simulated replace)',
      (tester) async {
    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
    ], child: MaterialApp.router(routerConfig: router)));
    router.go('/log/first');
    await tester.pumpAndSettle();
    // Navigate to second (go() again) - go_router will push new route; treat as replacement for test coverage.
    router.go('/log/second');
    await tester.pumpAndSettle();
    final ops = rec.events
        .where((e) => e.$1 == 'route_navigate')
        .map((e) => e.$2['op'])
        .whereType<String>()
        .toList();
    expect(ops.where((e) => e == 'push').length >= 2, isTrue);
  });

  testWidgets('widget smoke tests for HomeScreen & LogDetailScreen',
      (tester) async {
    final router = ProviderScope(
        child: MaterialApp.router(
            routerConfig: ProviderContainer().read(routerProvider)));
    await tester.pumpWidget(router);
    expect(find.text('Home'), findsOneWidget);
    // Navigate to log detail
    final container = ProviderContainer();
    final r = container.read(routerProvider);
    // Replace pumping with router that can be mutated
    await tester
        .pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: r)));
    r.go('/log/demo');
    await tester.pumpAndSettle();
    expect(find.text('Log demo'), findsOneWidget);
  });

  group('ResolveDeepLinkUseCase edge cases', () {
    test('empty path resolves home intent', () {
      final c = ProviderContainer();
      final useCase = c.read(resolveDeepLinkUseCaseProvider);
      final result = useCase(Uri.parse('/'));
      expect(result.isRight(), true);
    });
    test('custom scheme ashtrail://log/abc resolves log detail', () {
      final c = ProviderContainer();
      final useCase = c.read(resolveDeepLinkUseCaseProvider);
      final result = useCase(Uri.parse('ashtrail://log/abc'));
      // Uri parsing yields host 'log' and pathSegments ['abc'] – Should succeed
      expect(result.isRight(), true);
    });
    test('missing id /log/ treated as unknown', () {
      final c = ProviderContainer();
      final useCase = c.read(resolveDeepLinkUseCaseProvider);
      final result = useCase(Uri.parse('/log/'));
      expect(result.isLeft(), true);
    });
    test('relative form log/abc resolves if leading slash omitted', () {
      final c = ProviderContainer();
      final useCase = c.read(resolveDeepLinkUseCaseProvider);
      final result = useCase(Uri.parse('log/abc'));
      // pathSegments ['log','abc'] => valid
      expect(result.isRight(), true);
    });
  });
}
