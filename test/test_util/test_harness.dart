import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Basic test harness to wrap widgets with Riverpod + Router.
class TestHarness {
  final ProviderContainer container;
  TestHarness._(this.container);

  factory TestHarness.overrides([List<Override> overrides = const []]) {
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    return TestHarness._(container);
  }

  Widget wrap(Widget child, {GoRouter? router}) {
    // Router not yet wired; placeholder for future integration.
    return UncontrolledProviderScope(
      container: container,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );
  }
}
