import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ash_trail/features/app_shell/presentation/app_shell.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('wide screen shows navigation rail instead of bottom nav',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          pageBuilder: (c, s) => const NoTransitionPage(
                  child: AppShell(
                child: Text('Wide content'),
              ))),
    ]);

    // Wrap with MediaQuery to control size
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(size: Size(1024, 768)),
          child: child!,
        ),
      ),
    ));

    // Should have NavigationRail, not NavigationBar
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // Should have vertical divider
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testWidgets('narrow screen shows bottom nav bar', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          pageBuilder: (c, s) => const NoTransitionPage(
                  child: AppShell(
                child: Text('Narrow content'),
              ))),
    ]);

    // Wrap with MediaQuery to control size for narrow screen
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(size: Size(375, 812)),
          child: child!,
        ),
      ),
    ));

    // Should have NavigationBar, not NavigationRail
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // Should have at least one SafeArea (may be multiple due to nesting)
    expect(find.byType(SafeArea), findsWidgets);

    // Should have FloatingActionButton
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('fab tap shows snackbar placeholder', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          pageBuilder: (c, s) => const NoTransitionPage(
                  child: AppShell(
                child: Text('Content'),
              ))),
    ]);

    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Record action'), findsOneWidget);
  });

  testWidgets('charts tab shows coming soon snackbar', (tester) async {
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          pageBuilder: (c, s) => const NoTransitionPage(
                  child: AppShell(
                child: Text('Content'),
              ))),
    ]);

    await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)));

    // Tap Charts navigation item (index 2)
    await tester.tap(find.text('Charts'));
    await tester.pumpAndSettle();

    expect(find.text('Charts coming soon'), findsOneWidget);
  });
}
