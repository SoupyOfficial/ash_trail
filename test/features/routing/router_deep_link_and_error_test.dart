import 'package:ash_trail/core/routing/app_router.dart';
import 'package:ash_trail/core/telemetry/telemetry_service.dart';
import 'package:ash_trail/features/routing/domain/resolve_deep_link_use_case.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/home/presentation/providers/home_providers.dart';
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
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ], child: MaterialApp.router(routerConfig: router)));

    await tester.pumpAndSettle();

    // Navigate to unknown path
    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();
    expect(find.textContaining('Good'),
        findsWidgets); // "Good Morning", "Good Afternoon", or "Good Evening"
    expect(rec.events.any((e) => e.$1 == 'route_unknown'), isTrue);
  });

  testWidgets('deep link cold start navigates to log detail', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      deepLinkInitialLocationProvider.overrideWith((ref) async => '/log/abc'),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      deepLinkInitialLocationProvider.overrideWith((ref) async => '/log/abc'),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ], child: MaterialApp.router(routerConfig: router)));

    // Allow microtask + potential navigation (multiple frames)
    await tester.pumpAndSettle();

    // Assert log detail screen visible
    expect(find.text('Log abc'), findsOneWidget);
  });

  testWidgets('telemetry records multiple pushes (simulated replace)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    final rec = _RecordingTelemetry();
    final container = ProviderContainer(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ]);
    final router = container.read(routerProvider);
    await tester.pumpWidget(ProviderScope(overrides: [
      telemetryServiceProvider.overrideWithValue(rec),
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ], child: MaterialApp.router(routerConfig: router)));

    await tester.pumpAndSettle();

    router.go('/log/first');
    await tester.pumpAndSettle();
    expect(find.text('Log first'), findsOneWidget);

    router.go('/log/second');
    await tester.pumpAndSettle();
    expect(find.text('Log second'), findsOneWidget);

    final navEvents = rec.events.where((e) => e.$1 == 'route_navigate');
    expect(navEvents.isNotEmpty, true);
  });

  testWidgets('widget smoke tests for HomeScreen & LogDetailScreen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));

    final container = ProviderContainer(overrides: [
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ]);
    final router = container.read(routerProvider);

    await tester.pumpWidget(ProviderScope(overrides: [
      breakpointProvider.overrideWithValue(Breakpoint.tablet),
      screenSizeProvider.overrideWithValue(const Size(800, 1000)),
      homeScreenStateProvider.overrideWith((ref) async => const HomeScreenState(
            recentLogsCount: 3,
            todayLogsCount: 1,
            hasActiveRecording: false,
          )),
    ], child: MaterialApp.router(routerConfig: router)));

    await tester.pumpAndSettle();
    expect(find.textContaining('Good'),
        findsWidgets); // "Good Morning", "Good Afternoon", or "Good Evening"

    // Navigate to log detail
    router.go('/log/demo');
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
    test('/logs resolves logs tab intent', () {
      final c = ProviderContainer();
      final useCase = c.read(resolveDeepLinkUseCaseProvider);
      final result = useCase(Uri.parse('/logs'));
      expect(result.isRight(), true);
    });
  });
}
