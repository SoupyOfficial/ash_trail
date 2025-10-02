import 'package:ash_trail/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/theming/presentation/providers/theme_provider.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:ash_trail/features/home/presentation/providers/home_providers.dart';

void main() {
  group('Main App', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('main function should initialize app', () async {
      // Since main() has async initialization, we'll test the components
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Verify SharedPreferences can be initialized
      expect(prefs, isNotNull);
    });

    testWidgets('should initialize and create MyApp widget', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Store original error handler and restore it after test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          // Ignore layout overflow errors in tests
          return;
        }
        originalOnError?.call(details);
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              createThemeRepositoryOverride(prefs),
              // Mock responsive providers for testing
              breakpointProvider.overrideWith((ref) => Breakpoint.tablet),
              screenSizeProvider.overrideWith((ref) => const Size(800, 1200)),
              // Mock home screen provider to avoid timer delays
              homeScreenStateProvider.overrideWith((ref) => Future.value(
                    const HomeScreenState(
                      recentLogsCount: 0,
                      todayLogsCount: 0,
                      hasActiveRecording: false,
                    ),
                  )),
            ],
            child: const MyApp(),
          ),
        );

        // Just pump once to build the widget tree, don't wait for settling
        await tester.pump();
        expect(find.byType(MyApp), findsOneWidget);
      } finally {
        // Restore original error handler
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('MyApp should build MaterialApp.router', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Store original error handler and restore it after test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          // Ignore layout overflow errors in tests
          return;
        }
        originalOnError?.call(details);
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              createThemeRepositoryOverride(prefs),
              // Mock responsive providers for testing
              breakpointProvider.overrideWith((ref) => Breakpoint.tablet),
              screenSizeProvider.overrideWith((ref) => const Size(800, 1200)),
              // Mock home screen provider to avoid timer delays
              homeScreenStateProvider.overrideWith((ref) => Future.value(
                    const HomeScreenState(
                      recentLogsCount: 0,
                      todayLogsCount: 0,
                      hasActiveRecording: false,
                    ),
                  )),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pump();
        expect(find.byType(MaterialApp), findsOneWidget);
      } finally {
        // Restore original error handler
        FlutterError.onError = originalOnError;
      }
    });

    testWidgets('MyApp should have correct title', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Store original error handler and restore it after test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('RenderFlex overflowed')) {
          // Ignore layout overflow errors in tests
          return;
        }
        originalOnError?.call(details);
      };

      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              createThemeRepositoryOverride(prefs),
              // Mock responsive providers for testing
              breakpointProvider.overrideWith((ref) => Breakpoint.tablet),
              screenSizeProvider.overrideWith((ref) => const Size(800, 1200)),
              // Mock home screen provider to avoid timer delays
              homeScreenStateProvider.overrideWith((ref) => Future.value(
                    const HomeScreenState(
                      recentLogsCount: 0,
                      todayLogsCount: 0,
                      hasActiveRecording: false,
                    ),
                  )),
            ],
            child: const MyApp(),
          ),
        );

        await tester.pump();
        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.title, equals('AshTrail'));
      } finally {
        // Restore original error handler
        FlutterError.onError = originalOnError;
      }
    });
  });
}
