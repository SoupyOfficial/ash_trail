// Central application router using go_router with typed route data + Riverpod integration.
// Responsibilities:
// 1. Provide typed routes for home & log detail.
// 2. Handle unknown routes by showing home and emitting telemetry 'route_unknown'.
// 3. Emit 'route_navigate' on successful navigation transitions.
// 4. Support deep link initial location via a provider (see deepLinkInitialLocationProvider).
// NOTE: Keep this file lightweight; feature‑specific presentation (screens) reside in feature folders.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/routing/domain/route_intent.dart';
import '../../features/routing/domain/resolve_deep_link_use_case.dart';
import '../../features/routing/presentation/log_detail_screen.dart';
import '../../features/app_shell/presentation/app_shell.dart';
import '../../features/logging/presentation/logs_screen.dart';
import '../../features/table_browse_edit/presentation/screens/logs_table_screen.dart';
import '../telemetry/telemetry_service.dart';

import '../../features/loading_skeletons/presentation/widgets/widgets.dart';

// -----------------------------
// Screens (temporary minimal home; real feature screen will replace later)
// -----------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    // Simulate data loading
    _loadingTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: LoadingStateHandler(
        isLoading: _isLoading,
        loadingWidget: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: SkeletonChart(height: 200),
              ),
              SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: SkeletonList(itemCount: 3),
              ),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to AshTrail'),
              SizedBox(height: 16),
              Text('Your smoking insights dashboard'),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Settings'));
}

// Provider supplying initial deep link location (cold start). Falls back to '/'.
final deepLinkInitialLocationProvider = FutureProvider<String>((ref) async {
  // Placeholder cold-start deep link source. In a real app we'd use getInitialUri / platform channels.
  // For now, assume no external deep link and return '/'.
  return '/';
});

// Internal stream controller used to notify route changes for telemetry.
// GoRouter provider (public API)
final routerProvider = Provider<GoRouter>((ref) {
  final telemetry = ref.watch(telemetryServiceProvider);
  // Build router using explicit list (manual typed mapping for now).
  final r = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (ctx, state) =>
                const NoTransitionPage(child: HomeScreen()),
            routes: [
              GoRoute(
                path: 'log/:id',
                name: 'log-detail',
                pageBuilder: (ctx, state) {
                  final id = state.pathParameters['id']!;
                  return NoTransitionPage(child: LogDetailScreen(logId: id));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/logs',
            name: 'logs',
            pageBuilder: (ctx, state) =>
                const NoTransitionPage(child: LogsScreen()),
            routes: [
              GoRoute(
                path: 'table/:accountId',
                name: 'logs-table',
                pageBuilder: (ctx, state) {
                  final accountId = state.pathParameters['accountId']!;
                  return NoTransitionPage(
                      child: LogsTableScreen(accountId: accountId));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (ctx, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
    initialLocation: '/', // Will be overridden post-init if deep link present.
    errorBuilder: (ctx, state) {
      telemetry.logEvent('route_unknown', {'error': state.error?.toString()});
      return const HomeScreen();
    },
    observers: [
      // NavigatorObserver for push/replace distinction (modal vs full-screen future usage).
      _TelemetryNavigatorObserver(telemetry),
    ],
  );

  // After first frame, attempt deep link resolution if any.
  // Defer to ensure providers are ready.
  Future<void>.microtask(() async {
    final initial = await ref.read(deepLinkInitialLocationProvider.future);
    if (initial == '/') return; // no deep link
    final uri = Uri.tryParse(initial);
    if (uri == null) return;
    final intent = ref.read(resolveDeepLinkUseCaseProvider)(uri);
    intent.match(
      (f) => telemetry.logEvent(
          'route_unknown', {'location': initial, 'reason': f.displayMessage}),
      (ri) => switch (ri) {
        RouteIntentHome() => r.go('/'),
        RouteIntentLogsTab() => r.go('/logs'),
        RouteIntentLogDetail(:final id) => r.go('/log/$id'),
      },
    );
  });

  return r;
});

// Legacy global for main.dart (maintain backward compatibility). Will be removed once main migrated to provider.
GoRouter get appRouter => _cached ??= GoRouter(routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (ctx, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
    ]);
GoRouter? _cached;

class _TelemetryNavigatorObserver extends NavigatorObserver {
  _TelemetryNavigatorObserver(this._telemetry);
  final TelemetryService _telemetry;
  void _emit(String type, Route<dynamic>? route) {
    if (route == null) return;
    _telemetry.logEvent('route_navigate', {
      'op': type,
      'settings': route.settings.name ?? route.settings.arguments?.toString(),
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _emit('push', route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _emit('replace', newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
