import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/responsive_padding.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/layout_config.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('ResponsivePadding', () {
    testWidgets('applies mobile padding on mobile breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.mobile),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(375, 800)),
            ],
            child: const ResponsivePadding(
              mobile: EdgeInsets.all(8.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(8.0)));
    });

    testWidgets('applies tablet padding on tablet breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.tablet),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(768, 1024)),
            ],
            child: const ResponsivePadding(
              mobile: EdgeInsets.all(8.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(12.0)));
    });

    testWidgets('applies desktop padding on desktop breakpoint',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.desktop),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(1024, 768)),
            ],
            child: const ResponsivePadding(
              mobile: EdgeInsets.all(8.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('falls back to mobile when tablet not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.tablet),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(768, 1024)),
            ],
            child: const ResponsivePadding(
              mobile: EdgeInsets.all(8.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(8.0)));
    });

    testWidgets('uses config defaults when no explicit padding provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.mobile),
              layoutConfigProvider.overrideWithValue(const LayoutConfig(
                compactPadding: EdgeInsets.all(10.0),
              )),
              screenSizeProvider.overrideWithValue(const Size(375, 800)),
            ],
            child: const ResponsivePadding(
              child: Text('Content'),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(10.0)));
    });

    testWidgets('handles zero padding values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.mobile),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
                screenSizeProvider.overrideWithValue(const Size(375, 800)),
              ],
              child: const ResponsivePadding(
                mobile: EdgeInsets.zero,
                tablet: EdgeInsets.all(0),
                desktop: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Text('Zero Padding Test'),
              ),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(EdgeInsets.zero));
    });

    testWidgets('handles extreme padding values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.desktop),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
                screenSizeProvider.overrideWithValue(const Size(1200, 800)),
              ],
              child: const ResponsivePadding(
                desktop: EdgeInsets.all(1000),
                child: Text('Extreme Padding Test'),
              ),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, equals(const EdgeInsets.all(1000)));
    });

    testWidgets('handles asymmetric padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.tablet),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
                screenSizeProvider.overrideWithValue(const Size(700, 800)),
              ],
              child: const ResponsivePadding(
                tablet:
                    EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40),
                child: Text('Asymmetric Padding Test'),
              ),
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(
          padding.padding,
          equals(
              const EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40)));
    });
  });

  group('ResponsiveMargin', () {
    testWidgets('applies mobile margin on mobile breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.mobile),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(375, 800)),
            ],
            child: const ResponsiveMargin(
              mobile: EdgeInsets.all(8.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, equals(const EdgeInsets.all(8.0)));
    });

    testWidgets('applies desktop margin on desktop breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.desktop),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(1024, 768)),
            ],
            child: const ResponsiveMargin(
              mobile: EdgeInsets.all(8.0),
              tablet: EdgeInsets.all(12.0),
              desktop: EdgeInsets.all(16.0),
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('defaults to zero margin when none provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.mobile),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(375, 800)),
            ],
            child: const ResponsiveMargin(
              child: Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, equals(EdgeInsets.zero));
    });
  });

  group('ResponsiveSpacing', () {
    test('returns correct spacing for each breakpoint', () {
      expect(
        ResponsiveSpacing.spacing(
          Breakpoint.mobile,
          mobile: 4.0,
          tablet: 8.0,
          desktop: 12.0,
        ),
        equals(4.0),
      );

      expect(
        ResponsiveSpacing.spacing(
          Breakpoint.tablet,
          mobile: 4.0,
          tablet: 8.0,
          desktop: 12.0,
        ),
        equals(8.0),
      );

      expect(
        ResponsiveSpacing.spacing(
          Breakpoint.desktop,
          mobile: 4.0,
          tablet: 8.0,
          desktop: 12.0,
        ),
        equals(12.0),
      );
    });

    test('small spacing returns correct values', () {
      expect(ResponsiveSpacing.small(Breakpoint.mobile), equals(4.0));
      expect(ResponsiveSpacing.small(Breakpoint.tablet), equals(6.0));
      expect(ResponsiveSpacing.small(Breakpoint.desktop), equals(8.0));
    });

    test('medium spacing returns correct values', () {
      expect(ResponsiveSpacing.medium(Breakpoint.mobile), equals(8.0));
      expect(ResponsiveSpacing.medium(Breakpoint.tablet), equals(12.0));
      expect(ResponsiveSpacing.medium(Breakpoint.desktop), equals(16.0));
    });

    test('large spacing returns correct values', () {
      expect(ResponsiveSpacing.large(Breakpoint.mobile), equals(16.0));
      expect(ResponsiveSpacing.large(Breakpoint.tablet), equals(20.0));
      expect(ResponsiveSpacing.large(Breakpoint.desktop), equals(24.0));
    });

    test('extra large spacing returns correct values', () {
      expect(ResponsiveSpacing.extraLarge(Breakpoint.mobile), equals(24.0));
      expect(ResponsiveSpacing.extraLarge(Breakpoint.tablet), equals(32.0));
      expect(ResponsiveSpacing.extraLarge(Breakpoint.desktop), equals(40.0));
    });
  });

  group('ResponsiveGap', () {
    testWidgets('creates vertical gap with correct height on mobile',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.mobile),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(375, 800)),
            ],
            child: const Column(
              children: [
                Text('Top'),
                ResponsiveGap(
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                ),
                Text('Bottom'),
              ],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(16.0));
      expect(sizedBox.width, isNull);
    });

    testWidgets('creates horizontal gap with correct width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.desktop),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(1024, 768)),
            ],
            child: const Row(
              children: [
                Text('Left'),
                ResponsiveGap(
                  mobile: 16.0,
                  tablet: 20.0,
                  desktop: 24.0,
                  axis: Axis.horizontal,
                ),
                Text('Right'),
              ],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, equals(24.0));
      expect(sizedBox.height, isNull);
    });

    testWidgets('falls back to mobile size when others not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            overrides: [
              breakpointProvider.overrideWithValue(Breakpoint.tablet),
              layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              screenSizeProvider.overrideWithValue(const Size(768, 1024)),
            ],
            child: const Column(
              children: [
                Text('Top'),
                ResponsiveGap(mobile: 12.0),
                Text('Bottom'),
              ],
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, equals(12.0));
    });
  });
}
