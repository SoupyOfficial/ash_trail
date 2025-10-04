import 'package:ash_trail/features/responsive/domain/entities/layout_config.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'LayoutConfig paddingFor returns compact on mobile and padding otherwise',
      () {
    const config = LayoutConfig(
      padding: const EdgeInsets.all(20),
      compactPadding: const EdgeInsets.all(10),
      contentMaxWidth: 1000,
    );
    expect(config.paddingFor(Breakpoint.mobile), const EdgeInsets.all(10));
    expect(config.paddingFor(Breakpoint.tablet), const EdgeInsets.all(20));
    expect(config.paddingFor(Breakpoint.desktop), const EdgeInsets.all(20));
  });

  test('LayoutConfig supportsDualPane and constrainContentWidth', () {
    const config = LayoutConfig(contentMaxWidth: 1200);
    expect(config.supportsDualPane(839), false);
    expect(config.supportsDualPane(840), true);
    expect(config.constrainContentWidth(800), 800);
    expect(config.constrainContentWidth(1600), 1200);
  });
}
