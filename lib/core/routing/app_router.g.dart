// GENERATED PLACEHOLDER - run build_runner to regenerate.
part of 'app_router.dart';

List<RouteBase> get $appRoutes => [
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
    ];
