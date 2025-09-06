import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('Breakpoint', () {
    group('fromWidth', () {
      test('returns mobile for width < 600', () {
        expect(Breakpoint.fromWidth(300), equals(Breakpoint.mobile));
        expect(Breakpoint.fromWidth(599), equals(Breakpoint.mobile));
      });

      test('returns tablet for width 600-839', () {
        expect(Breakpoint.fromWidth(600), equals(Breakpoint.tablet));
        expect(Breakpoint.fromWidth(700), equals(Breakpoint.tablet));
        expect(Breakpoint.fromWidth(839), equals(Breakpoint.tablet));
      });

      test('returns desktop for width >= 840', () {
        expect(Breakpoint.fromWidth(840), equals(Breakpoint.desktop));
        expect(Breakpoint.fromWidth(1200), equals(Breakpoint.desktop));
      });
    });

    group('properties', () {
      test('isWide returns true only for desktop', () {
        expect(Breakpoint.mobile.isWide, isFalse);
        expect(Breakpoint.tablet.isWide, isFalse);
        expect(Breakpoint.desktop.isWide, isTrue);
      });

      test('isCompact returns true only for mobile', () {
        expect(Breakpoint.mobile.isCompact, isTrue);
        expect(Breakpoint.tablet.isCompact, isFalse);
        expect(Breakpoint.desktop.isCompact, isFalse);
      });

      test('supportsDualPane returns true only for wide layouts', () {
        expect(Breakpoint.mobile.supportsDualPane, isFalse);
        expect(Breakpoint.tablet.supportsDualPane, isFalse);
        expect(Breakpoint.desktop.supportsDualPane, isTrue);
      });

      test('useNavigationRail matches isWide', () {
        expect(Breakpoint.mobile.useNavigationRail,
            equals(Breakpoint.mobile.isWide));
        expect(Breakpoint.tablet.useNavigationRail,
            equals(Breakpoint.tablet.isWide));
        expect(Breakpoint.desktop.useNavigationRail,
            equals(Breakpoint.desktop.isWide));
      });

      test('useBottomNavigation is opposite of useNavigationRail', () {
        expect(Breakpoint.mobile.useBottomNavigation,
            equals(!Breakpoint.mobile.useNavigationRail));
        expect(Breakpoint.tablet.useBottomNavigation,
            equals(!Breakpoint.tablet.useNavigationRail));
        expect(Breakpoint.desktop.useBottomNavigation,
            equals(!Breakpoint.desktop.useNavigationRail));
      });
    });
  });
}
