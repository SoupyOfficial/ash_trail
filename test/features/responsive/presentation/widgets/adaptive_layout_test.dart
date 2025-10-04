import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/adaptive_layout.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/layout_config.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('AdaptiveLayout', () {
    testWidgets('shows mobile layout on narrow screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.mobile),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Mobile'),
                tablet: Text('Tablet'),
                desktop: Text('Desktop'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows tablet layout on medium screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.tablet),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Mobile'),
                tablet: Text('Tablet'),
                desktop: Text('Desktop'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop layout on wide screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.desktop),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Mobile'),
                tablet: Text('Tablet'),
                desktop: Text('Desktop'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.tablet),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Mobile'),
                desktop: Text('Desktop'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('uses custom breakpoints when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.mobile),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Default Mobile'),
                tablet: Text('Default Tablet'),
                desktop: Text('Default Desktop'),
                breakpoints: {
                  Breakpoint.mobile: Text('Custom Mobile'),
                  Breakpoint.tablet: Text('Custom Tablet'),
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Default Mobile'), findsNothing);
      expect(find.text('Custom Mobile'), findsOneWidget);
    });

    testWidgets('falls back to default when custom breakpoint not found',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.desktop),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
              ],
              child: const AdaptiveLayout(
                mobile: Text('Default Mobile'),
                tablet: Text('Default Tablet'),
                desktop: Text('Default Desktop'),
                breakpoints: {
                  Breakpoint.mobile: Text('Custom Mobile'),
                  // No custom desktop, should fall back to default
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Custom Mobile'), findsNothing);
      expect(find.text('Default Desktop'), findsOneWidget);
    });
  });

  group('DualPaneLayout', () {
    testWidgets('shows only primary pane on mobile', (tester) async {
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
              child: const DualPaneLayout(
                primary: Text('Primary'),
                secondary: Text('Secondary'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsNothing);
    });

    testWidgets('shows both panes on desktop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.desktop),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
                screenSizeProvider.overrideWithValue(const Size(1024, 800)),
              ],
              child: const DualPaneLayout(
                primary: Text('Primary'),
                secondary: Text('Secondary'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('includes divider when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.desktop),
                layoutConfigProvider.overrideWithValue(const LayoutConfig()),
                screenSizeProvider.overrideWithValue(const Size(1024, 800)),
              ],
              child: const DualPaneLayout(
                primary: Text('Primary'),
                secondary: Text('Secondary'),
                divider: VerticalDivider(),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(VerticalDivider), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('applies layout padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.mobile),
                layoutConfigProvider.overrideWithValue(const LayoutConfig(
                  compactPadding: EdgeInsets.all(12.0),
                )),
                screenSizeProvider.overrideWithValue(const Size(375, 800)),
              ],
              child: const ResponsiveContainer(
                child: Text('Content'),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(const EdgeInsets.all(12.0)));
    });

    testWidgets('constrains content width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              overrides: [
                breakpointProvider.overrideWithValue(Breakpoint.mobile),
                layoutConfigProvider.overrideWithValue(const LayoutConfig(
                  contentMaxWidth: 800.0,
                )),
                screenSizeProvider.overrideWithValue(const Size(375, 800)),
              ],
              child: const ResponsiveContainer(
                child: Text('Content'),
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(800.0));
    });
  });
}
