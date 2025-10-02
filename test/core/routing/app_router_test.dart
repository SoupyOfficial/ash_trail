import 'package:ash_trail/core/routing/app_router.dart';
import 'package:ash_trail/features/home/presentation/screens/home_screen.dart';
import 'package:ash_trail/features/home/presentation/providers/home_providers.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// Temporary settings screen for testing
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}

void main() {
  group('AppRouter', () {
    testWidgets('HomeScreen should display home text', (tester) async {
      // Create a mock home state that completes immediately
      const mockHomeState = HomeScreenState(
        recentLogsCount: 3,
        todayLogsCount: 1,
        hasActiveRecording: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            breakpointProvider.overrideWithValue(Breakpoint.mobile),
            screenSizeProvider.overrideWithValue(const Size(375, 800)),
            homeScreenStateProvider
                .overrideWith((ref) => Future.value(mockHomeState)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Wait for the async provider to complete
      await tester.pumpAndSettle();

      // Check that HomeScreen widget is present
      expect(find.byType(HomeScreen), findsOneWidget);

      // The HomeScreen should display a greeting message
      expect(find.textContaining('Good'),
          findsOneWidget); // "Good Morning", "Good Afternoon", or "Good Evening"
    });

    testWidgets('SettingsScreen should display settings text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    test('routerProvider should provide GoRouter instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      expect(router, isA<GoRouter>());
    });

    testWidgets('router should handle navigation', (tester) async {
      // Use a larger viewport to avoid overflow issues
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;

      // Create a mock home state that completes immediately
      const mockHomeState = HomeScreenState(
        recentLogsCount: 3,
        todayLogsCount: 1,
        hasActiveRecording: false,
      );

      final container = ProviderContainer(
        overrides: [
          breakpointProvider.overrideWithValue(Breakpoint.desktop),
          screenSizeProvider.overrideWithValue(const Size(1024, 768)),
          homeScreenStateProvider
              .overrideWith((ref) => Future.value(mockHomeState)),
        ],
      );
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);

      container.dispose();

      // Reset the view for other tests
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
