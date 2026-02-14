import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/responsive_layout.dart';
import 'package:ash_trail/utils/design_constants.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows mobile widget on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
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

    testWidgets('shows tablet widget on medium screens', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
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

    testWidgets('shows desktop widget on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
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

    testWidgets('falls back to mobile when tablet is null', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ResponsiveLayout(mobile: Text('Mobile'))),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });

    testWidgets('falls back to tablet when desktop is null', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: Text('Mobile'),
              tablet: Text('Tablet'),
            ),
          ),
        ),
      );

      expect(find.text('Tablet'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('provides mobile form factor on narrow screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      DeviceFormFactor? capturedFormFactor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, formFactor) {
                capturedFormFactor = formFactor;
                return Text('Form: $formFactor');
              },
            ),
          ),
        ),
      );

      expect(capturedFormFactor, DeviceFormFactor.mobile);
    });

    testWidgets('provides tablet form factor on medium screens', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      DeviceFormFactor? capturedFormFactor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, formFactor) {
                capturedFormFactor = formFactor;
                return Text('Form: $formFactor');
              },
            ),
          ),
        ),
      );

      expect(capturedFormFactor, DeviceFormFactor.tablet);
    });

    testWidgets('provides desktop form factor on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      DeviceFormFactor? capturedFormFactor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveBuilder(
              builder: (context, formFactor) {
                capturedFormFactor = formFactor;
                return Text('Form: $formFactor');
              },
            ),
          ),
        ),
      );

      expect(capturedFormFactor, DeviceFormFactor.desktop);
    });
  });

  group('OrientationAwareBuilder', () {
    testWidgets('provides portrait orientation', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      DeviceOrientation? capturedOrientation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrientationAwareBuilder(
              builder: (context, formFactor, orientation) {
                capturedOrientation = orientation;
                return Text('Orientation: $orientation');
              },
            ),
          ),
        ),
      );

      expect(capturedOrientation, DeviceOrientation.portrait);
    });

    testWidgets('provides landscape orientation', (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      DeviceOrientation? capturedOrientation;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrientationAwareBuilder(
              builder: (context, formFactor, orientation) {
                capturedOrientation = orientation;
                return Text('Orientation: $orientation');
              },
            ),
          ),
        ),
      );

      expect(capturedOrientation, DeviceOrientation.landscape);
    });
  });

  group('ResponsivePadding', () {
    testWidgets('applies mobile padding on narrow screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsivePadding(
              mobilePadding: 8,
              tabletPadding: 16,
              desktopPadding: 24,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('respects symmetrical parameter', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsivePadding(
              mobilePadding: 16,
              symmetrical: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('applies max width constraint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContainer(maxWidth: 600, child: Text('Container')),
          ),
        ),
      );

      expect(find.text('Container'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });

  group('ResponsiveGrid', () {
    testWidgets('renders children in grid', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGrid(
              mobileColumns: 2,
              tabletColumns: 3,
              desktopColumns: 4,
              children: [
                Text('Item 1'),
                Text('Item 2'),
                Text('Item 3'),
                Text('Item 4'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('respects spacing parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGrid(spacing: 24, children: [Text('A'), Text('B')]),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(
        gridView.gridDelegate,
        isA<SliverGridDelegateWithFixedCrossAxisCount>(),
      );
    });
  });

  group('ResponsiveGap', () {
    testWidgets('renders SizedBox with mobile gap', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveGap(mobile: 16, tablet: 24, desktop: 32),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('ResponsiveVerticalGap', () {
    testWidgets('renders vertical gap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ResponsiveVerticalGap(mobile: 20)),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('ResponsiveHorizontalGap', () {
    testWidgets('renders horizontal gap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Text('Left'),
                ResponsiveHorizontalGap(mobile: 16),
                Text('Right'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('ResponsiveVisibility', () {
    testWidgets('shows child when visible is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveVisibility(visible: true, child: Text('Visible')),
          ),
        ),
      );

      expect(find.text('Visible'), findsOneWidget);
    });

    testWidgets('hides child when visible is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveVisibility(visible: false, child: Text('Visible')),
          ),
        ),
      );

      expect(find.text('Visible'), findsNothing);
    });

    testWidgets('shows replacement when hidden', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveVisibility(
              visible: false,
              replacement: Text('Replacement'),
              child: Text('Visible'),
            ),
          ),
        ),
      );

      expect(find.text('Visible'), findsNothing);
      expect(find.text('Replacement'), findsOneWidget);
    });

    testWidgets('hides on mobile when hiddenMobile is true', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveVisibility(
              hiddenMobile: true,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
    });
  });

  group('VisibleOnBreakpoint', () {
    testWidgets('shows on mobile when visibleMobile is true', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibleOnBreakpoint(
              visibleMobile: true,
              visibleTablet: false,
              visibleDesktop: false,
              child: Text('Mobile Only'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Only'), findsOneWidget);
    });

    testWidgets('hides on mobile when visibleMobile is false', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibleOnBreakpoint(
              visibleMobile: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
    });

    testWidgets('shows replacement when not visible', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VisibleOnBreakpoint(
              visibleMobile: false,
              replacement: Text('Fallback'),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
      expect(find.text('Fallback'), findsOneWidget);
    });
  });

  group('ResponsiveText', () {
    testWidgets('renders text with responsive font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveText(
              'Hello World',
              mobileSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies base style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveText(
              'Styled',
              mobileSize: 14,
              baseStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Styled'));
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('applies maxLines and overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveText(
              'Long text',
              mobileSize: 14,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Long text'));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('ResponsiveSliverPadding', () {
    testWidgets('wraps sliver with padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ResponsiveSliverPadding(
                  mobilePadding: 16,
                  sliver: const SliverToBoxAdapter(child: Text('Content')),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(SliverPadding), findsOneWidget);
    });
  });

  group('AdaptiveNavigation', () {
    testWidgets('shows bottom navigation on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AdaptiveNavigation(
              items: [
                NavigationItem(
                  icon: Icons.home,
                  label: 'Home',
                  destination: Container(),
                ),
                NavigationItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  destination: Container(),
                ),
              ],
              selectedIndex: 0,
              onItemSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('shows navigation rail on tablet', (tester) async {
      tester.view.physicalSize = const Size(800, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveNavigation(
              items: [
                NavigationItem(
                  icon: Icons.home,
                  label: 'Home',
                  destination: Container(),
                ),
                NavigationItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  destination: Container(),
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

    testWidgets('handles item selection', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AdaptiveNavigation(
              items: [
                NavigationItem(
                  icon: Icons.home,
                  label: 'Home',
                  destination: Container(),
                ),
                NavigationItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  destination: Container(),
                ),
              ],
              selectedIndex: 0,
              onItemSelected: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(selectedIndex, 1);
    });
  });

  group('AdaptiveDialog', () {
    testWidgets('shows bottom sheet content on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveDialog(
              title: 'Dialog Title',
              content: Text('Dialog content'),
            ),
          ),
        ),
      );

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
    });

    testWidgets('shows AlertDialog on desktop', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveDialog(
              title: 'Dialog Title',
              content: Text('Dialog content'),
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Dialog Title'), findsOneWidget);
    });

    testWidgets('shows actions', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveDialog(
              title: 'Title',
              content: const Text('Content'),
              actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('NavigationItem', () {
    test('creates with required properties', () {
      final item = NavigationItem(
        icon: Icons.home,
        label: 'Home',
        destination: Container(),
      );

      expect(item.icon, Icons.home);
      expect(item.label, 'Home');
      expect(item.destination, isA<Container>());
    });
  });

  group('DeviceFormFactor', () {
    test('fromWidth returns mobile for narrow screens', () {
      expect(DeviceFormFactor.fromWidth(400), DeviceFormFactor.mobile);
    });

    test('fromWidth returns tablet for medium screens', () {
      expect(DeviceFormFactor.fromWidth(800), DeviceFormFactor.tablet);
    });

    test('fromWidth returns desktop for wide screens', () {
      expect(DeviceFormFactor.fromWidth(1400), DeviceFormFactor.desktop);
    });

    test('fromWidth handles boundary values', () {
      // Just below tablet breakpoint
      expect(DeviceFormFactor.fromWidth(599), DeviceFormFactor.mobile);
      // At tablet breakpoint
      expect(DeviceFormFactor.fromWidth(600), DeviceFormFactor.tablet);
      // Just below desktop breakpoint
      expect(DeviceFormFactor.fromWidth(1199), DeviceFormFactor.tablet);
      // At desktop breakpoint
      expect(DeviceFormFactor.fromWidth(1200), DeviceFormFactor.desktop);
    });
  });

  group('DashboardGridConfig', () {
    test('mobile: 2 columns for narrow screens', () {
      final config = DashboardGridConfig.fromWidth(400);
      expect(config.crossAxisCount, 2);
      expect(config.crossAxisSpacing, 8);
      expect(config.mainAxisSpacing, 8);
      expect(config.padding, 16);
    });

    test('mobile: 2 columns at max mobile width', () {
      final config = DashboardGridConfig.fromWidth(599);
      expect(config.crossAxisCount, 2);
    });

    test('tablet: 3 columns at tablet breakpoint', () {
      final config = DashboardGridConfig.fromWidth(600);
      expect(config.crossAxisCount, 3);
      expect(config.crossAxisSpacing, 12);
      expect(config.mainAxisSpacing, 12);
      expect(config.padding, 24);
    });

    test('tablet: 3 columns at max tablet width', () {
      final config = DashboardGridConfig.fromWidth(1199);
      expect(config.crossAxisCount, 3);
    });

    test('desktop: 4 columns at desktop breakpoint', () {
      final config = DashboardGridConfig.fromWidth(1200);
      expect(config.crossAxisCount, 4);
      expect(config.crossAxisSpacing, 16);
      expect(config.mainAxisSpacing, 16);
      expect(config.padding, 24);
    });

    test('desktop: 4 columns for very wide screens', () {
      final config = DashboardGridConfig.fromWidth(2000);
      expect(config.crossAxisCount, 4);
    });
  });
}
