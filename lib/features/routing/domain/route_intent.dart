/// Domain intents resolved from deep links before actual navigation.
sealed class RouteIntent {
  const RouteIntent();
}

class RouteIntentHome extends RouteIntent {
  const RouteIntentHome();
  @override
  String toString() => 'RouteIntent.home';
}

class RouteIntentLogDetail extends RouteIntent {
  const RouteIntentLogDetail({required this.id});
  final String id;
  @override
  String toString() => 'RouteIntent.logDetail(id: $id)';
}

class RouteIntentLogsTab extends RouteIntent {
  const RouteIntentLogsTab();
  @override
  String toString() => 'RouteIntent.logs';
}
