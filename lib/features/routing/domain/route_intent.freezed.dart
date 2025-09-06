// coverage:ignore-file
// Minimal placeholder for analyzer until build_runner generates full file.
part of 'route_intent.dart';

mixin _$RouteIntent {}

class RouteIntentHome implements RouteIntent {
  const RouteIntentHome();
}

class RouteIntentLogDetail implements RouteIntent {
  const RouteIntentLogDetail({required this.id});
  final String id;
}
