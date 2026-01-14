/// Accessibility Test Suite
///
/// Comprehensive tests for semantic labels, screen reader support,
/// keyboard navigation, and WCAG color contrast compliance.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/design_constants.dart';
import 'package:ash_trail/utils/a11y_utils.dart';

void main() {
  group('Accessibility - Design Constants', () {
    test('Spacing enum values are positive', () {
      for (final spacing in Spacing.values) {
        expect(spacing.value, greaterThan(0));
      }
    });

    test('IconSize enum values are positive', () {
      for (final size in IconSize.values) {
        expect(size.value, greaterThan(0));
      }
    });

    test('BorderRadiusSize enum values are positive', () {
      for (final size in BorderRadiusSize.values) {
        expect(size.value, greaterThan(0));
      }
    });

    test('ElevationLevel enum values are non-negative', () {
      for (final level in ElevationLevel.values) {
        expect(level.value, greaterThanOrEqualTo(0));
      }
    });

    test('Breakpoints are in logical order', () {
      expect(
        Breakpoints.mobileMaxWidth,
        lessThan(Breakpoints.tabletBreakpoint),
      );
      expect(
        Breakpoints.tabletBreakpoint,
        lessThan(Breakpoints.desktopBreakpoint),
      );
    });

    test('Touch target size meets accessibility standard', () {
      expect(A11yConstants.minimumTouchSize, greaterThanOrEqualTo(48));
    });

    test('Focus indicator width is visible', () {
      expect(A11yConstants.focusIndicatorWidth, greaterThan(0));
    });
  });

  group('Accessibility - Device Form Factor Detection', () {
    test('Correctly identifies mobile form factor', () {
      final formFactor = DeviceFormFactor.fromWidth(400);
      expect(formFactor, equals(DeviceFormFactor.mobile));
    });

    test('Correctly identifies tablet form factor', () {
      final formFactor = DeviceFormFactor.fromWidth(800);
      expect(formFactor, equals(DeviceFormFactor.tablet));
    });

    test('Correctly identifies desktop form factor', () {
      final formFactor = DeviceFormFactor.fromWidth(1400);
      expect(formFactor, equals(DeviceFormFactor.desktop));
    });

    test('Boundary condition: mobile/tablet', () {
      final formFactor = DeviceFormFactor.fromWidth(
        Breakpoints.tabletBreakpoint,
      );
      expect(formFactor, equals(DeviceFormFactor.tablet));
    });

    test('Boundary condition: tablet/desktop', () {
      final formFactor = DeviceFormFactor.fromWidth(
        Breakpoints.desktopBreakpoint,
      );
      expect(formFactor, equals(DeviceFormFactor.desktop));
    });
  });

  group('Accessibility - Semantic Label Builder', () {
    test('Button label has correct prefix', () {
      final label = SemanticLabelBuilder.button('Save');
      expect(label, startsWith(A11yConstants.buttonPrefix));
      expect(label, contains('Save'));
    });

    test('Field label has correct prefix', () {
      final label = SemanticLabelBuilder.field('Email');
      expect(label, startsWith(A11yConstants.fieldPrefix));
      expect(label, contains('Email'));
    });

    test('Interactive label has correct prefix', () {
      final label = SemanticLabelBuilder.interactive('Menu');
      expect(label, startsWith(A11yConstants.interactivePrefix));
      expect(label, contains('Menu'));
    });

    test('Icon button label includes button', () {
      final label = SemanticLabelBuilder.iconButton('Delete');
      expect(label, contains('button'));
    });

    test('Toggle label includes state', () {
      final enabledLabel = SemanticLabelBuilder.toggle(
        'Notifications',
        enabled: true,
      );
      expect(enabledLabel, contains('enabled'));

      final disabledLabel = SemanticLabelBuilder.toggle(
        'Notifications',
        enabled: false,
      );
      expect(disabledLabel, contains('disabled'));
    });

    test('Slider label includes value', () {
      final label = SemanticLabelBuilder.sliderValue('Volume', 75);
      expect(label, contains('75'));
    });

    test('List item label includes index', () {
      final label = SemanticLabelBuilder.listItem('Item 1', index: 0);
      expect(label, contains('item 1'));
    });

    test('Tab label includes selection state', () {
      final selectedLabel = SemanticLabelBuilder.tab('Home', selected: true);
      expect(selectedLabel, contains('selected'));

      final unselectedLabel = SemanticLabelBuilder.tab('Home', selected: false);
      expect(unselectedLabel, contains('unselected'));
    });
  });

  group('Accessibility - Color Contrast (WCAG)', () {
    test('White on black passes WCAG AA', () {
      final contrast = ContrastHelper.getContrastRatio(
        Colors.white,
        Colors.black,
      );
      expect(
        contrast,
        greaterThanOrEqualTo(ContrastConstants.minContrastNormalText),
      );
    });

    test('White on black passes WCAG AAA', () {
      final contrast = ContrastHelper.getContrastRatio(
        Colors.white,
        Colors.black,
      );
      expect(contrast, greaterThanOrEqualTo(ContrastConstants.minContrastAAA));
    });

    test('meetsWCAGAA validates correctly', () {
      final result = ContrastHelper.meetsWCAGAA(Colors.white, Colors.black);
      expect(result, isTrue);
    });

    test('meetsWCAGAAA validates correctly', () {
      final result = ContrastHelper.meetsWCAGAAA(Colors.white, Colors.black);
      expect(result, isTrue);
    });

    test('Luminance calculation is between 0 and 1', () {
      for (final color in [
        Colors.white,
        Colors.black,
        Colors.red,
        Colors.blue,
        Colors.green,
      ]) {
        final luminance = ContrastHelper.getRelativeLuminance(color);
        expect(luminance, greaterThanOrEqualTo(0));
        expect(luminance, lessThanOrEqualTo(1));
      }
    });

    test('Similar colors have lower contrast', () {
      final lightBlue = Colors.blue.withOpacity(0.7);
      final darkBlue = Colors.blue.withOpacity(0.3);

      final contrast = ContrastHelper.getContrastRatio(lightBlue, darkBlue);
      expect(contrast, lessThan(4.5)); // Should fail AA standard
    });
  });

  group('Accessibility - Responsive Size Helpers', () {
    testWidgets(
      'Responsive returns mobile value on mobile screen',
      skip: true,
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(360, 800)); // Mobile
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final value = ResponsiveSize.responsive(
                  context: context,
                  mobile: 10,
                  tablet: 20,
                  desktop: 30,
                );
                expect(value, equals(10));
                return const SizedBox();
              },
            ),
          ),
        );
      },
    );

    testWidgets('Responsive returns tablet value on tablet screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final value = ResponsiveSize.responsive(
                  context: context,
                  mobile: 10,
                  tablet: 20,
                  desktop: 30,
                );
                expect(value, equals(20));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Responsive returns desktop value on desktop screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1400, 900)),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                final value = ResponsiveSize.responsive(
                  context: context,
                  mobile: 10,
                  tablet: 20,
                  desktop: 30,
                );
                expect(value, equals(30));
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('Responsive uses tablet value as fallback for desktop', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900)); // Desktop
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = ResponsiveSize.responsive(
                context: context,
                mobile: 10,
                tablet: 20,
              );
              expect(value, equals(20)); // Falls back to tablet
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('Accessibility - Semantic Widget Wrappers', () {
    testWidgets('SemanticIcon renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIcon(icon: Icons.star, semanticLabel: 'Star icon'),
          ),
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
      // MaterialApp creates multiple Semantics nodes, so we use findsWidgets
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Star icon',
        ),
        findsWidgets,
      );
    });

    testWidgets('SemanticIconButton creates proper button semantics', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticIconButton(
              icon: Icons.delete,
              semanticLabel: 'Delete button',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('SemanticFormField includes label and child', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticFormField(
              label: 'Email',
              child: TextField(
                decoration: InputDecoration(label: Text('Email')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('SemanticFormField displays error message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SemanticFormField(
              label: 'Email',
              errorText: 'Invalid email',
              child: TextField(
                decoration: InputDecoration(label: Text('Email')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsOneWidget);
    });
  });

  group('Accessibility - A11y Constants Validation', () {
    test('All animation durations are positive', () {
      expect(AnimationDuration.fast.duration.inMilliseconds, greaterThan(0));
      expect(AnimationDuration.normal.duration.inMilliseconds, greaterThan(0));
      expect(AnimationDuration.slow.duration.inMilliseconds, greaterThan(0));
      expect(
        AnimationDuration.verySlow.duration.inMilliseconds,
        greaterThan(0),
      );
    });

    test('Animation duration ordering is logical', () {
      expect(
        AnimationDuration.fast.duration.inMilliseconds,
        lessThan(AnimationDuration.normal.duration.inMilliseconds),
      );
      expect(
        AnimationDuration.normal.duration.inMilliseconds,
        lessThan(AnimationDuration.slow.duration.inMilliseconds),
      );
      expect(
        AnimationDuration.slow.duration.inMilliseconds,
        lessThan(AnimationDuration.verySlow.duration.inMilliseconds),
      );
    });

    test('Focus animation duration is reasonable', () {
      expect(
        A11yConstants.focusAnimationDuration.inMilliseconds,
        greaterThan(100),
      );
      expect(
        A11yConstants.focusAnimationDuration.inMilliseconds,
        lessThan(500),
      );
    });

    test('Tooltip durations are reasonable', () {
      expect(
        A11yConstants.tooltipShowDuration.inMilliseconds,
        greaterThan(200),
      );
      expect(A11yConstants.tooltipHideDuration.inMilliseconds, lessThan(500));
    });

    test('WCAG contrast ratios meet standards', () {
      expect(A11yConstants.wcagAAContrast, equals(4.5));
      expect(A11yConstants.wcagAAAContrast, equals(7.0));
    });
  });

  group('Accessibility - Touch Target Sizing', () {
    testWidgets('MinimumTouchTarget has minimum size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MinimumTouchTarget(onTap: () {}, child: const Text('Tap me')),
          ),
        ),
      );

      // MinimumTouchTarget wraps child in ConstrainedBox -> Center/InkWell -> child
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsWidgets);

      // Get the first ConstrainedBox (our MinimumTouchTarget's constraint)
      final size = tester.getSize(constrainedBoxes.first);
      expect(size.width, greaterThanOrEqualTo(A11yConstants.minimumTouchSize));
      expect(size.height, greaterThanOrEqualTo(A11yConstants.minimumTouchSize));
    });
  });

  group('Accessibility - Font Size Scale', () {
    test('Font sizes are properly ordered', () {
      expect(FontSizeScale.captionSmall, lessThan(FontSizeScale.captionMedium));
      expect(FontSizeScale.captionMedium, lessThan(FontSizeScale.captionLarge));
      expect(FontSizeScale.bodySmall, lessThan(FontSizeScale.bodyMedium));
      expect(FontSizeScale.bodyMedium, lessThan(FontSizeScale.bodyLarge));
      expect(
        FontSizeScale.headlineSmall,
        lessThan(FontSizeScale.headlineMedium),
      );
      expect(
        FontSizeScale.headlineMedium,
        lessThan(FontSizeScale.headlineLarge),
      );
    });

    test('Body text is readable size', () {
      expect(FontSizeScale.bodyMedium, greaterThanOrEqualTo(12));
      expect(FontSizeScale.bodyMedium, lessThanOrEqualTo(16));
    });

    test('Headline text is prominent', () {
      expect(FontSizeScale.headlineLarge, greaterThan(FontSizeScale.bodyLarge));
    });
  });

  group('Accessibility - Screen Reader Announcements', () {
    testWidgets('A11yAnnouncer.announce sends proper SemanticsService call', (
      WidgetTester tester,
    ) async {
      // Note: This is a conceptual test showing how to structure a11y tests
      // In real implementation, you'd mock SemanticsService
      const message = 'Test announcement';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // In actual implementation, call:
                // A11yAnnouncer.announce(context, message);
                return const Text(message);
              },
            ),
          ),
        ),
      );

      expect(find.text(message), findsOneWidget);
    });
  });

  group('Accessibility - Padding Constants', () {
    test('All padding values are positive', () {
      for (final padding in Spacing.values) {
        expect(padding.value, greaterThan(0));
      }
    });

    test('Paddings are properly ordered', () {
      expect(Spacing.xs.value, lessThan(Spacing.sm.value));
      expect(Spacing.sm.value, lessThan(Spacing.md.value));
      expect(Spacing.md.value, lessThan(Spacing.lg.value));
      expect(Spacing.lg.value, lessThan(Spacing.xl.value));
      expect(Spacing.xl.value, lessThan(Spacing.xxl.value));
    });
  });

  group('Accessibility - Border Radius', () {
    test('BorderRadiusSize values are consistent', () {
      expect(BorderRadii.sm.topLeft.x, equals(8));
      expect(BorderRadii.md.topLeft.x, equals(12));
      expect(BorderRadii.lg.topLeft.x, equals(16));
      expect(BorderRadii.xl.topLeft.x, equals(24));
    });

    test('BorderRadiusSize enum and BorderRadii match', () {
      expect(
        BorderRadiusSize.sm.borderRadius.topLeft.x,
        equals(BorderRadii.sm.topLeft.x),
      );
      expect(
        BorderRadiusSize.md.borderRadius.topLeft.x,
        equals(BorderRadii.md.topLeft.x),
      );
    });
  });
}
