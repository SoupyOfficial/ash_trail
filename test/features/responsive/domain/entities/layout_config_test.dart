import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/responsive/domain/entities/layout_config.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('LayoutConfig', () {
    test('creates with default values', () {
      const config = LayoutConfig();

      expect(config.minimumTapTarget, equals(48.0));
      expect(config.dualPaneBreakpoint, equals(840.0));
      expect(config.compactMaxWidth, equals(600.0));
      expect(config.contentMaxWidth, equals(1200.0));
      expect(config.padding, equals(const EdgeInsets.all(16.0)));
      expect(config.compactPadding, equals(const EdgeInsets.all(12.0)));
      expect(config.gutter, equals(16.0));
    });

    test('creates with custom values', () {
      const config = LayoutConfig(
        minimumTapTarget: 56.0,
        dualPaneBreakpoint: 1000.0,
        compactMaxWidth: 500.0,
        contentMaxWidth: 1400.0,
        padding: EdgeInsets.all(20.0),
        compactPadding: EdgeInsets.all(10.0),
        gutter: 24.0,
      );

      expect(config.minimumTapTarget, equals(56.0));
      expect(config.dualPaneBreakpoint, equals(1000.0));
      expect(config.compactMaxWidth, equals(500.0));
      expect(config.contentMaxWidth, equals(1400.0));
      expect(config.padding, equals(const EdgeInsets.all(20.0)));
      expect(config.compactPadding, equals(const EdgeInsets.all(10.0)));
      expect(config.gutter, equals(24.0));
    });

    group('paddingFor', () {
      test('returns compact padding for mobile breakpoint', () {
        const config = LayoutConfig(
          padding: EdgeInsets.all(16.0),
          compactPadding: EdgeInsets.all(8.0),
        );

        final padding = config.paddingFor(Breakpoint.mobile);
        expect(padding, equals(const EdgeInsets.all(8.0)));
      });

      test('returns normal padding for tablet breakpoint', () {
        const config = LayoutConfig(
          padding: EdgeInsets.all(16.0),
          compactPadding: EdgeInsets.all(8.0),
        );

        final padding = config.paddingFor(Breakpoint.tablet);
        expect(padding, equals(const EdgeInsets.all(16.0)));
      });

      test('returns normal padding for desktop breakpoint', () {
        const config = LayoutConfig(
          padding: EdgeInsets.all(16.0),
          compactPadding: EdgeInsets.all(8.0),
        );

        final padding = config.paddingFor(Breakpoint.desktop);
        expect(padding, equals(const EdgeInsets.all(16.0)));
      });
    });

    group('supportsDualPane', () {
      test('returns false for width below threshold', () {
        const config = LayoutConfig(dualPaneBreakpoint: 840.0);

        expect(config.supportsDualPane(800.0), isFalse);
        expect(config.supportsDualPane(839.9), isFalse);
      });

      test('returns true for width at or above threshold', () {
        const config = LayoutConfig(dualPaneBreakpoint: 840.0);

        expect(config.supportsDualPane(840.0), isTrue);
        expect(config.supportsDualPane(1024.0), isTrue);
        expect(config.supportsDualPane(1920.0), isTrue);
      });

      test('works with custom threshold', () {
        const config = LayoutConfig(dualPaneBreakpoint: 1000.0);

        expect(config.supportsDualPane(999.9), isFalse);
        expect(config.supportsDualPane(1000.0), isTrue);
        expect(config.supportsDualPane(1200.0), isTrue);
      });
    });

    group('constrainContentWidth', () {
      test('returns screen width when below max content width', () {
        const config = LayoutConfig(contentMaxWidth: 1200.0);

        expect(config.constrainContentWidth(800.0), equals(800.0));
        expect(config.constrainContentWidth(1024.0), equals(1024.0));
        expect(config.constrainContentWidth(1199.9), equals(1199.9));
      });

      test('returns max content width when screen is wider', () {
        const config = LayoutConfig(contentMaxWidth: 1200.0);

        expect(config.constrainContentWidth(1200.0), equals(1200.0));
        expect(config.constrainContentWidth(1400.0), equals(1200.0));
        expect(config.constrainContentWidth(1920.0), equals(1200.0));
      });

      test('works with custom max content width', () {
        const config = LayoutConfig(contentMaxWidth: 1000.0);

        expect(config.constrainContentWidth(800.0), equals(800.0));
        expect(config.constrainContentWidth(1000.0), equals(1000.0));
        expect(config.constrainContentWidth(1200.0), equals(1000.0));
      });
    });
  });
}
