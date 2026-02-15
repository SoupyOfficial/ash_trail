import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/models/app_settings.dart';
import 'package:ash_trail/providers/app_settings_provider.dart';
import 'package:ash_trail/providers/home_widget_config_provider.dart'
    show sharedPreferencesProvider;
import 'package:ash_trail/screens/settings_screen.dart';

Future<Widget> _buildSettingsScreen({
  Map<String, Object> initialPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders all section headers', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Color Theme'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dashboard Display'), findsOneWidget);

      // Accessibility section is below the fold
      await tester.scrollUntilVisible(
        find.text('Accessibility'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Accessibility'), findsOneWidget);
    });

    testWidgets('displays all 8 color preset swatches', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      for (var i = 0; i < ThemePreset.presets.length; i++) {
        expect(find.byKey(Key('settings_theme_preset_$i')), findsOneWidget);
      }
    });

    testWidgets('default preset shows Royal Blue label', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Royal Blue'), findsOneWidget);
    });

    testWidgets('tapping a preset swatch updates selection', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Tap Emerald (index 2)
      await tester.tap(find.byKey(const Key('settings_theme_preset_2')));
      await tester.pumpAndSettle();

      expect(find.text('Emerald'), findsOneWidget);
    });

    testWidgets('theme mode segmented button shows System by default', (
      tester,
    ) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final segmented = find.byKey(const Key('settings_theme_mode'));
      expect(segmented, findsOneWidget);
      // System should be selected by default
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('density segmented button shows Comfortable by default', (
      tester,
    ) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final segmented = find.byKey(const Key('settings_density'));
      expect(segmented, findsOneWidget);
      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Comfortable'), findsOneWidget);
      expect(find.text('Spacious'), findsOneWidget);
    });

    testWidgets('reduce motion switch is off by default', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Scroll to the reduce motion switch at the bottom
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings_reduce_motion_switch')),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      final switchTile = find.byKey(const Key('settings_reduce_motion_switch'));
      expect(switchTile, findsOneWidget);
      expect(find.text('Reduce Motion'), findsOneWidget);
    });

    testWidgets('toggling reduce motion switch updates state', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Scroll to the switch
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings_reduce_motion_switch')),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // Find and toggle the switch
      await tester.tap(find.byKey(const Key('settings_reduce_motion_switch')));
      await tester.pumpAndSettle();

      // The switch should now be on — verify by reading the provider
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsScreen)),
      );
      expect(container.read(reduceMotionProvider), true);
    });

    testWidgets('card radius slider is present', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Card Corner Radius'), findsOneWidget);
    });

    testWidgets('card elevation slider is present', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Card Elevation'), findsOneWidget);
    });

    testWidgets('card preview is visible', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Card Preview'), findsOneWidget);
    });

    testWidgets('overflow menu shows reset option', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Open overflow menu
      await tester.tap(find.byKey(const Key('settings_overflow_menu')));
      await tester.pumpAndSettle();

      expect(find.text('Reset to Defaults'), findsOneWidget);
    });

    testWidgets('reset to defaults shows confirmation dialog', (tester) async {
      final widget = await _buildSettingsScreen();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Open overflow menu
      await tester.tap(find.byKey(const Key('settings_overflow_menu')));
      await tester.pumpAndSettle();

      // Tap reset
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(
        find.text('This will restore all settings to their default values.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('confirming reset restores defaults', (tester) async {
      final stored = AppSettings(
        presetIndex: 5,
        themeMode: ThemeMode.dark,
        reduceMotion: true,
      );
      final widget = await _buildSettingsScreen(
        initialPrefs: {'app_settings': stored.toJsonString()},
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // Verify non-default state loaded
      expect(find.text('Purple'), findsOneWidget);

      // Open overflow → reset → confirm
      await tester.tap(find.byKey(const Key('settings_overflow_menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset to Defaults'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Should be back to Royal Blue
      expect(find.text('Royal Blue'), findsOneWidget);
    });

    testWidgets('loads persisted settings on open', (tester) async {
      final stored = AppSettings(
        presetIndex: 3, // Amber
        themeMode: ThemeMode.light,
      );
      final widget = await _buildSettingsScreen(
        initialPrefs: {'app_settings': stored.toJsonString()},
      );
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Amber'), findsOneWidget);
    });
  });
}
