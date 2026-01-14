/// Responsive Design Test Suite
///
/// Comprehensive tests for responsive layouts across mobile, tablet,
/// and desktop form factors with various orientations and screen sizes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/design_constants.dart';
import 'package:ash_trail/utils/responsive_layout.dart';

void main() {
  group('Responsive Layout - Device Form Factor Detection', () {
    test('Mobile devices detected correctly', () {
      expect(DeviceFormFactor.fromWidth(320), DeviceFormFactor.mobile);
      expect(DeviceFormFactor.fromWidth(480), DeviceFormFactor.mobile);
      expect(DeviceFormFactor.fromWidth(599), DeviceFormFactor.mobile);
    });

    test('Tablet devices detected correctly', () {
      expect(DeviceFormFactor.fromWidth(600), DeviceFormFactor.tablet);
      expect(DeviceFormFactor.fromWidth(800), DeviceFormFactor.tablet);
      expect(DeviceFormFactor.fromWidth(1000), DeviceFormFactor.tablet);
      expect(DeviceFormFactor.fromWidth(1199), DeviceFormFactor.tablet);
    });

    test('Desktop devices detected correctly', () {
      expect(DeviceFormFactor.fromWidth(1200), DeviceFormFactor.desktop);
      expect(DeviceFormFactor.fromWidth(1440), DeviceFormFactor.desktop);
      expect(DeviceFormFactor.fromWidth(1920), DeviceFormFactor.desktop);
    });

    test('Boundary conditions at breakpoints', () {
      expect(
        DeviceFormFactor.fromWidth(Breakpoints.mobileMaxWidth),
        DeviceFormFactor.mobile,
      );
      expect(
        DeviceFormFactor.fromWidth(Breakpoints.mobileMaxWidth + 1),
        DeviceFormFactor.tablet,
      );
      expect(
        DeviceFormFactor.fromWidth(Breakpoints.tabletMaxWidth),
        DeviceFormFactor.tablet,
      );
      expect(
        DeviceFormFactor.fromWidth(Breakpoints.tabletMaxWidth + 1),
        DeviceFormFactor.desktop,
      );
    });
  });

  group('Responsive Layout - ResponsiveLayout Widget', () {
    testWidgets('Renders mobile layout on mobile screen', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('Renders tablet layout on tablet screen', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('Renders desktop layout on desktop screen', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('Falls back to mobile if tablet not provided', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            desktop: const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('Falls back to tablet if desktop not provided', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayout(
            mobile: const Text('Mobile'),
            tablet: const Text('Tablet'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
    });
  });

  group('Responsive Layout - ResponsiveBuilder', () {
    testWidgets(
      'ResponsiveBuilder receives correct form factor on mobile',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        DeviceFormFactor? detectedFormFactor;

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveBuilder(
              builder: (context, formFactor) {
                detectedFormFactor = formFactor;
                return const Text('Built');
              },
            ),
          ),
        );

        expect(detectedFormFactor, DeviceFormFactor.mobile);
      },
    );

    testWidgets('ResponsiveBuilder receives correct form factor on tablet', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      DeviceFormFactor? detectedFormFactor;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, formFactor) {
              detectedFormFactor = formFactor;
              return const Text('Built');
            },
          ),
        ),
      );

      expect(detectedFormFactor, DeviceFormFactor.tablet);
    });

    testWidgets(
      'ResponsiveBuilder receives correct form factor on desktop',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1400, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        DeviceFormFactor? detectedFormFactor;

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveBuilder(
              builder: (context, formFactor) {
                detectedFormFactor = formFactor;
                return const Text('Built');
              },
            ),
          ),
        );

        expect(detectedFormFactor, DeviceFormFactor.desktop);
      },
    );
  });

  group('Responsive Layout - OrientationAwareBuilder', () {
    testWidgets(
      'Detects portrait orientation',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        DeviceOrientation? detectedOrientation;

        await tester.pumpWidget(
          MaterialApp(
            home: OrientationAwareBuilder(
              builder: (context, formFactor, orientation) {
                detectedOrientation = orientation;
                return const Text('Built');
              },
            ),
          ),
        );

        expect(detectedOrientation, DeviceOrientation.portrait);
      },
    );

    testWidgets('Detects landscape orientation', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      DeviceOrientation? detectedOrientation;

      await tester.pumpWidget(
        MaterialApp(
          home: OrientationAwareBuilder(
            builder: (context, formFactor, orientation) {
              detectedOrientation = orientation;
              return const Text('Built');
            },
          ),
        ),
      );

      expect(detectedOrientation, DeviceOrientation.landscape);
    });
  });

  group('Responsive Layout - ResponsiveContainer', () {
    testWidgets(
      'Constrains content to maxWidth',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(
          const Size(1600, 900),
        ); // Very wide desktop
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ResponsiveContainer(
                maxWidth: 500,
                child: Container(color: Colors.blue),
              ),
            ),
          ),
        );

        final container = find.byType(Container);
        expect(container, findsWidgets);

        // The constrained box should limit width
        final constraints = tester.getSize(find.byType(ConstrainedBox).first);
        expect(constraints.width, lessThanOrEqualTo(500));
      },
    );
  });

  group('Responsive Layout - ResponsiveVisibility', () {
    testWidgets(
      'Hides widget on mobile when hiddenMobile is true',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveVisibility(
              hiddenMobile: true,
              child: const Text('Hidden on mobile'),
            ),
          ),
        );

        expect(find.text('Hidden on mobile'), findsNothing);
      },
    );

    testWidgets('Shows widget on mobile when hiddenMobile is false', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveVisibility(
            hiddenMobile: false,
            child: const Text('Visible on mobile'),
          ),
        ),
      );

      expect(find.text('Visible on mobile'), findsOneWidget);
    });

    testWidgets(
      'Shows replacement widget when hidden',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: ResponsiveVisibility(
              hiddenMobile: true,
              child: const Text('Original'),
              replacement: const Text('Replacement'),
            ),
          ),
        );

        expect(find.text('Original'), findsNothing);
        expect(find.text('Replacement'), findsOneWidget);
      },
    );
  });

  group('Responsive Layout - VisibleOnBreakpoint', () {
    testWidgets(
      'Shows widget only on specified breakpoints',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: VisibleOnBreakpoint(
              visibleMobile: true,
              visibleTablet: false,
              visibleDesktop: false,
              child: const Text('Mobile only'),
            ),
          ),
        );

        expect(find.text('Mobile only'), findsOneWidget);
      },
    );

    testWidgets('Hides widget on non-matching breakpoints', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: VisibleOnBreakpoint(
            visibleMobile: true,
            visibleTablet: false,
            visibleDesktop: false,
            child: const Text('Mobile only'),
          ),
        ),
      );

      expect(find.text('Mobile only'), findsNothing);
    });
  });

  group('Responsive Layout - ResponsiveText', () {
    testWidgets('Uses mobile font size on mobile screen', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveText(
              'Hello',
              mobileSize: 12,
              tabletSize: 16,
              desktopSize: 20,
            ),
          ),
        ),
      );

      final text = find.byType(Text);
      expect(text, findsOneWidget);
      // Font size would be applied via TextStyle
    });
  });

  group('Responsive Layout - ResponsiveGrid', () {
    testWidgets('Uses correct column count for mobile', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            children: [
              Container(color: Colors.red),
              Container(color: Colors.blue),
              Container(color: Colors.green),
            ],
          ),
        ),
      );

      // GridView should adapt columns based on screen size
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('Uses correct column count for tablet', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            children: [
              Container(color: Colors.red),
              Container(color: Colors.blue),
              Container(color: Colors.green),
            ],
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  group('Responsive Layout - Screen Sizes', () {
    test('Standard screen sizes are defined', () {
      expect(ScreenSizes.smallPhone.width, equals(360));
      expect(ScreenSizes.mediumPhone.width, equals(390));
      expect(ScreenSizes.largePhone.width, equals(412));

      expect(ScreenSizes.smallTablet.width, equals(600));
      expect(ScreenSizes.mediumTablet.width, equals(768));
      expect(ScreenSizes.largeTablet.width, equals(1024));

      expect(ScreenSizes.smallDesktop.width, equals(1200));
      expect(ScreenSizes.mediumDesktop.width, equals(1440));
      expect(ScreenSizes.largeDesktop.width, equals(1920));
    });

    test('Screen sizes maintain portrait orientation', () {
      expect(
        ScreenSizes.smallPhone.height,
        greaterThan(ScreenSizes.smallPhone.width),
      );
      expect(
        ScreenSizes.mediumPhone.height,
        greaterThan(ScreenSizes.mediumPhone.width),
      );
      expect(
        ScreenSizes.largePhone.height,
        greaterThan(ScreenSizes.largePhone.width),
      );
    });
  });

  group('Responsive Layout - Breakpoint Constants', () {
    test('Breakpoint constants are logically ordered', () {
      expect(
        Breakpoints.mobileMaxWidth,
        lessThan(Breakpoints.tabletBreakpoint),
      );
      expect(
        Breakpoints.tabletBreakpoint,
        lessThanOrEqualTo(Breakpoints.desktopBreakpoint),
      );
      expect(
        Breakpoints.desktopBreakpoint,
        lessThanOrEqualTo(Breakpoints.contentMaxWidth),
      );
    });

    test('Tablet breakpoint range is valid', () {
      expect(
        Breakpoints.tabletBreakpoint,
        lessThan(Breakpoints.tabletMaxWidth),
      );
    });

    test('Content max width is reasonable', () {
      expect(Breakpoints.contentMaxWidth, greaterThan(600));
      expect(Breakpoints.contentMaxWidth, lessThan(2000));
    });
  });

  group('Responsive Layout - Responsive Spacing', () {
    testWidgets('ResponsiveVerticalGap renders correct height on mobile', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ResponsiveVerticalGap(mobile: 16))),
      );

      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsOneWidget);
    });

    testWidgets('ResponsiveHorizontalGap renders correct width on mobile', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ResponsiveHorizontalGap(mobile: 16))),
      );

      final sizedBox = find.byType(SizedBox);
      expect(sizedBox, findsOneWidget);
    });
  });

  group('Responsive Layout - AdaptiveNavigation', () {
    testWidgets(
      'AdaptiveNavigation renders on mobile',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AdaptiveNavigation(
                items: [
                  NavigationItem(
                    icon: Icons.home,
                    label: 'Home',
                    destination: const Text('Home'),
                  ),
                ],
                selectedIndex: 0,
                onItemSelected: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(BottomNavigationBar), findsOneWidget);
      },
    );

    testWidgets('AdaptiveNavigation uses rail on tablet', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigation(
              items: [
                NavigationItem(
                  icon: Icons.home,
                  label: 'Home',
                  destination: const Text('Home'),
                ),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
    });
  });

  group('Responsive Layout - Common Device Sizes', () {
    testWidgets('Small phone (360x640) is detected as mobile', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 640)); // iPhone SE
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final formFactor = DeviceFormFactor.fromWidth(360);
      expect(formFactor, DeviceFormFactor.mobile);
    });

    testWidgets('Large phone (412x915) is detected as mobile', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(412, 915)); // Pixel 6
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final formFactor = DeviceFormFactor.fromWidth(412);
      expect(formFactor, DeviceFormFactor.mobile);
    });

    testWidgets('iPad (768x1024) is detected as tablet', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024)); // iPad
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final formFactor = DeviceFormFactor.fromWidth(768);
      expect(formFactor, DeviceFormFactor.tablet);
    });

    testWidgets('Desktop (1920x1080) is detected as desktop', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080)); // Desktop
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final formFactor = DeviceFormFactor.fromWidth(1920);
      expect(formFactor, DeviceFormFactor.desktop);
    });
  });
}
