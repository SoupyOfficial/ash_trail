import 'package:ash_trail/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter', () {
    testWidgets('HomeScreen should display home text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
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
      final container = ProviderContainer();
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);

      container.dispose();
    });
  });
}
