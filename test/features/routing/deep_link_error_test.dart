import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/routing/domain/resolve_deep_link_use_case.dart';

void main() {
  test('invalid deep link returns notFound failure', () {
    final c = ProviderContainer();
    final useCase = c.read(resolveDeepLinkUseCaseProvider);
    final result = useCase(Uri.parse('/bogus/extra'));
    expect(result.isLeft(), true);
  });

  test('empty id under log returns validation failure', () {
    final c = ProviderContainer();
    final useCase = c.read(resolveDeepLinkUseCaseProvider);
    final result = useCase(Uri.parse('/log/'));
    expect(result.isLeft(), true);
  });
}
