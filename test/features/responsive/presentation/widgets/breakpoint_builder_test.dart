import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/responsive/presentation/widgets/breakpoint_builder.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('BreakpointBuilder', () {
    testWidgets('provides correct breakpoint to builder on mobile',
        (tester) async {
      Breakpoint? capturedBreakpoint;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: ProviderScope(
              child: BreakpointBuilder(
                builder: (context, breakpoint, child) {
                  capturedBreakpoint = breakpoint;
                  return Text('Breakpoint: ${breakpoint.name}');
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedBreakpoint, equals(Breakpoint.mobile));
      expect(find.text('Breakpoint: mobile'), findsOneWidget);
    });

    testWidgets('provides correct breakpoint to builder on tablet',
        (tester) async {
      Breakpoint? capturedBreakpoint;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: ProviderScope(
              child: BreakpointBuilder(
                builder: (context, breakpoint, child) {
                  capturedBreakpoint = breakpoint;
                  return Text('Breakpoint: ${breakpoint.name}');
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedBreakpoint, equals(Breakpoint.tablet));
      expect(find.text('Breakpoint: tablet'), findsOneWidget);
    });

    testWidgets('provides correct breakpoint to builder on desktop',
        (tester) async {
      Breakpoint? capturedBreakpoint;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: ProviderScope(
              child: BreakpointBuilder(
                builder: (context, breakpoint, child) {
                  capturedBreakpoint = breakpoint;
                  return Text('Breakpoint: ${breakpoint.name}');
                },
              ),
            ),
          ),
        ),
      );

      expect(capturedBreakpoint, equals(Breakpoint.desktop));
      expect(find.text('Breakpoint: desktop'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('shows mobile widget on mobile breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: const ResponsiveBuilder(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows tablet widget on tablet breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: const ResponsiveBuilder(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop widget on desktop breakpoint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: const ResponsiveBuilder(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
              desktop: Text('Desktop'),
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
            child: const ResponsiveBuilder(
              mobile: Text('Mobile'),
              desktop: Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('falls back through tablet to mobile when desktop not provided',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1024, 800)),
            child: const ResponsiveBuilder(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
    });
  });

  group('BreakpointContext extension', () {
    testWidgets('provides correct breakpoint properties', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(375, 800)),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(capturedContext.breakpoint, equals(Breakpoint.mobile));
      expect(capturedContext.isMobile, isTrue);
      expect(capturedContext.isTablet, isFalse);
      expect(capturedContext.isDesktop, isFalse);
      expect(capturedContext.isWideLayout, isFalse);
      expect(capturedContext.isCompactLayout, isTrue);
    });

    testWidgets('provides correct properties for tablet breakpoint',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 800)),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(capturedContext.breakpoint, equals(Breakpoint.tablet));
      expect(capturedContext.isMobile, isFalse);
      expect(capturedContext.isTablet, isTrue);
      expect(capturedContext.isDesktop, isFalse);
      expect(capturedContext.isWideLayout, isFalse);
      expect(capturedContext.isCompactLayout, isFalse);
    });

    testWidgets('provides correct properties for desktop breakpoint',
        (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Test');
              },
            ),
          ),
        ),
      );

      expect(capturedContext.breakpoint, equals(Breakpoint.desktop));
      expect(capturedContext.isMobile, isFalse);
      expect(capturedContext.isTablet, isFalse);
      expect(capturedContext.isDesktop, isTrue);
      expect(capturedContext.isWideLayout, isTrue);
      expect(capturedContext.isCompactLayout, isFalse);
    });
  });
}
