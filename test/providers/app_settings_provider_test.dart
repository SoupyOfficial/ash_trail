import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/models/app_settings.dart';
import 'package:ash_trail/providers/app_settings_provider.dart';
import 'package:ash_trail/providers/home_widget_config_provider.dart'
    show sharedPreferencesProvider;

void main() {
  group('AppSettings model', () {
    test('defaults have expected values', () {
      const s = AppSettings();
      expect(s.presetIndex, 0);
      expect(s.themeMode, ThemeMode.system);
      expect(s.dashboardDensity, DashboardDensity.comfortable);
      expect(s.cardCornerRadius, 12);
      expect(s.cardElevation, 2);
      expect(s.reduceMotion, false);
    });

    test('seedColor resolves for each preset', () {
      for (var i = 0; i < ThemePreset.presets.length; i++) {
        final s = AppSettings(presetIndex: i);
        expect(s.seedColor, ThemePreset.presets[i].seedColor);
      }
    });

    test('presetIndex is clamped when out of range', () {
      final s = AppSettings(presetIndex: 999);
      expect(s.seedColor, ThemePreset.presets.last.seedColor);
    });

    test('copyWith replaces only specified fields', () {
      const original = AppSettings();
      final modified = original.copyWith(presetIndex: 3, reduceMotion: true);

      expect(modified.presetIndex, 3);
      expect(modified.reduceMotion, true);
      // Other fields unchanged:
      expect(modified.themeMode, ThemeMode.system);
      expect(modified.dashboardDensity, DashboardDensity.comfortable);
      expect(modified.cardCornerRadius, 12);
      expect(modified.cardElevation, 2);
    });

    test('JSON round-trip preserves all fields', () {
      final original = AppSettings(
        presetIndex: 5,
        themeMode: ThemeMode.dark,
        dashboardDensity: DashboardDensity.compact,
        cardCornerRadius: 8,
        cardElevation: 4,
        reduceMotion: true,
      );

      final restored = AppSettings.fromJson(original.toJson());

      expect(restored, original);
    });

    test('fromJsonString with invalid JSON returns defaults', () {
      final s = AppSettings.fromJsonString('not json');
      expect(s, AppSettings.defaults());
    });

    test('equality operator works', () {
      const a = AppSettings(presetIndex: 2);
      const b = AppSettings(presetIndex: 2);
      const c = AppSettings(presetIndex: 3);

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('DashboardDensity', () {
    test('spacing multipliers are ordered', () {
      expect(
        DashboardDensity.compact.spacingMultiplier,
        lessThan(DashboardDensity.comfortable.spacingMultiplier),
      );
      expect(
        DashboardDensity.comfortable.spacingMultiplier,
        lessThan(DashboardDensity.spacious.spacingMultiplier),
      );
    });

    test('each density has a label', () {
      for (final d in DashboardDensity.values) {
        expect(d.label, isNotEmpty);
      }
    });
  });

  group('AppSettingsNotifier', () {
    late ProviderContainer container;

    Future<ProviderContainer> createContainer({
      Map<String, Object> initialValues = const {},
    }) async {
      SharedPreferences.setMockInitialValues(initialValues);
      final prefs = await SharedPreferences.getInstance();

      final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      // Force notifier creation and let async _loadSettings settle
      c.read(appSettingsProvider);
      await Future<void>.delayed(Duration.zero);

      return c;
    }

    setUp(() async {
      container = await createContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with defaults when no stored data', () {
      final settings = container.read(appSettingsProvider);
      expect(settings, AppSettings.defaults());
    });

    test('loads stored settings from SharedPreferences', () async {
      final stored = AppSettings(
        presetIndex: 4,
        themeMode: ThemeMode.dark,
        dashboardDensity: DashboardDensity.spacious,
        cardCornerRadius: 16,
        cardElevation: 6,
        reduceMotion: true,
      );

      container.dispose();
      container = await createContainer(
        initialValues: {'app_settings': stored.toJsonString()},
      );

      final settings = container.read(appSettingsProvider);
      expect(settings.presetIndex, 4);
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.dashboardDensity, DashboardDensity.spacious);
      expect(settings.cardCornerRadius, 16);
      expect(settings.cardElevation, 6);
      expect(settings.reduceMotion, true);
    });

    test('setPreset updates state and persists', () async {
      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setPreset(3);

      expect(container.read(appSettingsProvider).presetIndex, 3);
      expect(
        container.read(activeSeedColorProvider),
        ThemePreset.presets[3].seedColor,
      );
    });

    test('setPreset ignores out-of-range index', () async {
      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setPreset(-1);
      expect(container.read(appSettingsProvider).presetIndex, 0);

      await notifier.setPreset(100);
      expect(container.read(appSettingsProvider).presetIndex, 0);
    });

    test('setThemeMode updates state', () async {
      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setThemeMode(ThemeMode.dark);

      expect(container.read(activeThemeModeProvider), ThemeMode.dark);
    });

    test('setDashboardDensity updates state', () async {
      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setDashboardDensity(DashboardDensity.compact);

      expect(
        container.read(dashboardDensityProvider),
        DashboardDensity.compact,
      );
    });

    test('setCardCornerRadius clamps to [4, 24]', () async {
      final notifier = container.read(appSettingsProvider.notifier);

      await notifier.setCardCornerRadius(0);
      expect(container.read(cardCornerRadiusProvider), 4);

      await notifier.setCardCornerRadius(50);
      expect(container.read(cardCornerRadiusProvider), 24);

      await notifier.setCardCornerRadius(16);
      expect(container.read(cardCornerRadiusProvider), 16);
    });

    test('setCardElevation clamps to [0, 8]', () async {
      final notifier = container.read(appSettingsProvider.notifier);

      await notifier.setCardElevation(-1);
      expect(container.read(cardElevationProvider), 0);

      await notifier.setCardElevation(20);
      expect(container.read(cardElevationProvider), 8);

      await notifier.setCardElevation(4);
      expect(container.read(cardElevationProvider), 4);
    });

    test('setReduceMotion toggles value', () async {
      final notifier = container.read(appSettingsProvider.notifier);
      expect(container.read(reduceMotionProvider), false);

      await notifier.setReduceMotion(true);
      expect(container.read(reduceMotionProvider), true);
    });

    test('resetToDefaults reverts all fields', () async {
      final notifier = container.read(appSettingsProvider.notifier);

      // Change everything
      await notifier.setPreset(5);
      await notifier.setThemeMode(ThemeMode.dark);
      await notifier.setDashboardDensity(DashboardDensity.spacious);
      await notifier.setCardCornerRadius(20);
      await notifier.setCardElevation(6);
      await notifier.setReduceMotion(true);

      // Reset
      await notifier.resetToDefaults();

      expect(container.read(appSettingsProvider), AppSettings.defaults());
    });

    test('settings persist across container recreations', () async {
      // Set a non-default value
      final notifier = container.read(appSettingsProvider.notifier);
      await notifier.setPreset(2);

      // Read what was stored
      final prefs = container.read(sharedPreferencesProvider);
      final storedJson = prefs.getString('app_settings')!;

      container.dispose();

      // Recreate with same prefs data
      container = await createContainer(
        initialValues: {'app_settings': storedJson},
      );

      expect(container.read(appSettingsProvider).presetIndex, 2);
    });
  });
}
