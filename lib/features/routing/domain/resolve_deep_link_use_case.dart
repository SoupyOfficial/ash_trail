import 'package:fpdart/fpdart.dart';
import '../../../core/failures/app_failure.dart';
import 'route_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves an incoming deep link [Uri] into a domain [RouteIntent].
/// Supported forms:
/// - / (home)
/// - /log/<id>
/// - ashtrail://log/<id>
/// - https://ashtrail.app/log/<id> (future custom domain)
typedef ResolveDeepLinkUseCase = Either<AppFailure, RouteIntent> Function(
    Uri uri);

final resolveDeepLinkUseCaseProvider = Provider<ResolveDeepLinkUseCase>((ref) {
  return (uri) {
    final host = uri.host; // ashtrail://log/abc => host 'log'
    final segments = uri.pathSegments; // ashtrail://log/abc => ['abc']

    // Root/home
    if (segments.isEmpty || (segments.length == 1 && segments.first.isEmpty)) {
      return right(const RouteIntentHome());
    }

    final hostIsApp = host.isEmpty || host == 'ashtrail.app';

    // Pattern A: /log/<id> (optionally with supported host)
    if (hostIsApp && segments.length == 2 && segments.first == 'log') {
      final id = segments[1];
      if (id.isEmpty) {
        return left(
            const AppFailure.validation(message: 'Empty log id', field: 'id'));
      }
      return right(RouteIntentLogDetail(id: id));
    }

    // Pattern B: ashtrail://log/<id> (host=log, one segment = id)
    if (host == 'log' && segments.length == 1) {
      final id = segments[0];
      if (id.isEmpty) {
        return left(
            const AppFailure.validation(message: 'Empty log id', field: 'id'));
      }
      return right(RouteIntentLogDetail(id: id));
    }

    return left(const AppFailure.notFound(message: 'Unrecognized deep link'));
  };
});
