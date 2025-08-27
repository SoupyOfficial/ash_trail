// Central application router using go_router. New feature routes are appended via generator/scaffold.
// Assumption: Typed route generation will be introduced; for now manual list with placeholder HomeRoute.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// A simple placeholder home screen; real features will replace this.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('AshTrail')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Home'),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Action'),
              ),
            ],
          ),
        ),
      );
}

// Router instance (singleton via top-level final). In future, may depend on auth state providers.
final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (ctx, state) => const NoTransitionPage(child: HomeScreen()),
    ),
  ],
  errorBuilder: (ctx, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text(state.error?.toString() ?? 'Unknown error')),
  ),
);
