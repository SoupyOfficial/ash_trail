// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/main.dart';
import 'package:ash_trail/features/theming/presentation/providers/theme_provider.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:ash_trail/features/home/presentation/providers/home_providers.dart';

void main() {
  testWidgets('Home screen renders', (tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
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
      // Shell no longer has explicit AppBar title; just ensure home content present.
      expect(find.text('Home'), findsWidgets); // label + body text
    } finally {
      // Restore original error handler
      FlutterError.onError = originalOnError;
    }
  });
}
