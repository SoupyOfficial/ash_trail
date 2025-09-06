import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/routing/domain/resolve_deep_link_use_case.dart';
import 'package:ash_trail/features/routing/domain/route_intent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('resolves home deep link', () {
    final container = ProviderContainer();
    final useCase = container.read(resolveDeepLinkUseCaseProvider);
    final result = useCase(Uri.parse('/'));
    expect(result.isRight(), true);
    result.match((l) => fail('Expected right'),
        (r) => expect(r, isA<RouteIntentHome>()));
  });

  test('resolves log detail deep link', () {
    final container = ProviderContainer();
    final useCase = container.read(resolveDeepLinkUseCaseProvider);
    final result = useCase(Uri.parse('/log/abc123'));
    expect(result.isRight(), true);
    result.match((l) => fail('Expected right'), (r) {
      expect(r, isA<RouteIntentLogDetail>());
      if (r is RouteIntentLogDetail) expect(r.id, 'abc123');
    });
  });

  test('unknown path returns failure', () {
    final container = ProviderContainer();
    final useCase = container.read(resolveDeepLinkUseCaseProvider);
    final result = useCase(Uri.parse('/nope'));
    expect(result.isLeft(), true);
  });
}
