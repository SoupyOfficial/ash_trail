import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/responsive/presentation/providers/layout_provider.dart';
import 'package:ash_trail/features/responsive/domain/entities/layout_config.dart';
import 'package:ash_trail/features/responsive/domain/entities/breakpoint.dart';

void main() {
  group('Layout Providers', () {
    group('breakpointProvider', () {
      test('throws UnimplementedError when not overridden', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(breakpointProvider),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('returns overridden value', () {
        final container = ProviderContainer(
          overrides: [
            breakpointProvider.overrideWithValue(Breakpoint.tablet),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(breakpointProvider), equals(Breakpoint.tablet));
      });
    });

    group('screenSizeProvider', () {
      test('throws UnimplementedError when not overridden', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(
          () => container.read(screenSizeProvider),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('returns overridden value', () {
        const testSize = Size(1024, 768);
        final container = ProviderContainer(
          overrides: [
            screenSizeProvider.overrideWithValue(testSize),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(screenSizeProvider), equals(testSize));
      });
    });

    group('layoutConfigProvider', () {
      test('returns default LayoutConfig', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final config = container.read(layoutConfigProvider);
        expect(config, isA<LayoutConfig>());
        expect(config.minimumTapTarget, equals(48.0));
        expect(config.dualPaneBreakpoint, equals(840.0));
      });

      test('returns overridden value', () {
        const customConfig = LayoutConfig(
          minimumTapTarget: 56.0,
          dualPaneBreakpoint: 1000.0,
        );
        final container = ProviderContainer(
          overrides: [
            layoutConfigProvider.overrideWithValue(customConfig),
          ],
        );
        addTearDown(container.dispose);

        final config = container.read(layoutConfigProvider);
        expect(config.minimumTapTarget, equals(56.0));
        expect(config.dualPaneBreakpoint, equals(1000.0));
      });
    });

    group('layoutStateProvider', () {
      test('combines breakpoint, config, and screen size', () {
        const testSize = Size(768, 1024);
        const testConfig = LayoutConfig(minimumTapTarget: 56.0);

        final container = ProviderContainer(
          overrides: [
            breakpointProvider.overrideWithValue(Breakpoint.tablet),
            screenSizeProvider.overrideWithValue(testSize),
            layoutConfigProvider.overrideWithValue(testConfig),
          ],
        );
        addTearDown(container.dispose);

        final layoutState = container.read(layoutStateProvider);

        expect(layoutState.breakpoint, equals(Breakpoint.tablet));
        expect(layoutState.screenSize, equals(testSize));
        expect(layoutState.config.minimumTapTarget, equals(56.0));
      });

      test('provides correct layout properties', () {
        final container = ProviderContainer(
          overrides: [
            breakpointProvider.overrideWithValue(Breakpoint.mobile),
            screenSizeProvider.overrideWithValue(const Size(375, 800)),
            layoutConfigProvider.overrideWithValue(const LayoutConfig()),
          ],
        );
        addTearDown(container.dispose);

        final layoutState = container.read(layoutStateProvider);

        expect(layoutState.isCompact, isTrue);
        expect(layoutState.isWide, isFalse);
        expect(layoutState.supportsDualPane, isFalse);
      });

      test('provides correct layout properties for desktop', () {
        final container = ProviderContainer(
          overrides: [
            breakpointProvider.overrideWithValue(Breakpoint.desktop),
            screenSizeProvider.overrideWithValue(const Size(1024, 768)),
            layoutConfigProvider.overrideWithValue(const LayoutConfig()),
          ],
        );
        addTearDown(container.dispose);

        final layoutState = container.read(layoutStateProvider);

        expect(layoutState.isCompact, isFalse);
        expect(layoutState.isWide, isTrue);
        expect(layoutState.supportsDualPane, isTrue);
      });
    });
  });

  group('LayoutState', () {
    test('creates with all required properties', () {
      const layoutState = LayoutState(
        breakpoint: Breakpoint.tablet,
        config: LayoutConfig(),
        screenSize: Size(768, 1024),
      );

      expect(layoutState.breakpoint, equals(Breakpoint.tablet));
      expect(layoutState.config, isA<LayoutConfig>());
      expect(layoutState.screenSize, equals(const Size(768, 1024)));
    });

    test('delegates properties to breakpoint', () {
      const mobileState = LayoutState(
        breakpoint: Breakpoint.mobile,
        config: LayoutConfig(),
        screenSize: Size(375, 800),
      );

      expect(mobileState.isWide, isFalse);
      expect(mobileState.isCompact, isTrue);
      expect(mobileState.supportsDualPane, isFalse);

      const desktopState = LayoutState(
        breakpoint: Breakpoint.desktop,
        config: LayoutConfig(),
        screenSize: Size(1024, 768),
      );

      expect(desktopState.isWide, isTrue);
      expect(desktopState.isCompact, isFalse);
      expect(desktopState.supportsDualPane, isTrue);
    });
  });
}
