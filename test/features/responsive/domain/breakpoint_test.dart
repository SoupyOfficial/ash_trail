import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Breakpoint.fromWidth classifies correctly', () {
    expect(Breakpoint.fromWidth(320), Breakpoint.mobile);
    expect(Breakpoint.fromWidth(599.9), Breakpoint.mobile);
    expect(Breakpoint.fromWidth(600), Breakpoint.tablet);
    expect(Breakpoint.fromWidth(700), Breakpoint.tablet);
    expect(Breakpoint.fromWidth(839.9), Breakpoint.tablet);
    expect(Breakpoint.fromWidth(840), Breakpoint.desktop);
    expect(Breakpoint.fromWidth(1920), Breakpoint.desktop);
  });

  test('Breakpoint flags behave as expected', () {
    expect(Breakpoint.mobile.isCompact, true);
    expect(Breakpoint.desktop.isWide, true);
    expect(Breakpoint.desktop.supportsDualPane, true);
    expect(Breakpoint.tablet.supportsDualPane, false);
  });
}
