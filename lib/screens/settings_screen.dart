import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../providers/app_settings_provider.dart';
import '../utils/design_constants.dart';

/// Global settings screen for theme, dashboard display, and accessibility.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        key: const Key('app_bar_settings'),
        title: const Text('Settings'),
        actions: [
          PopupMenuButton<String>(
            key: const Key('settings_overflow_menu'),
            onSelected: (value) {
              if (value == 'reset') {
                _showResetConfirmation(context, ref);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset to Defaults'),
                  ),
                ],
          ),
        ],
      ),
      body: ListView(
        padding: Paddings.lg,
        children: [
          // ── Section 1: Color Theme ──────────────────────────────────────
          _SectionHeader(title: 'Color Theme'),
          SizedBox(height: Spacing.sm.value),
          _ColorThemeSelector(
            presets: ThemePreset.presets,
            selectedIndex: settings.presetIndex,
            onSelected: (index) {
              HapticFeedback.selectionClick();
              ref.read(appSettingsProvider.notifier).setPreset(index);
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: Spacing.xs.value),
            child: Text(
              settings.presetName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: Spacing.xl.value),

          // ── Section 2: Appearance ───────────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          SizedBox(height: Spacing.sm.value),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              key: const Key('settings_theme_mode'),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (modes) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setThemeMode(modes.first);
              },
            ),
          ),
          SizedBox(height: Spacing.xl.value),

          // ── Section 3: Dashboard Display ────────────────────────────────
          _SectionHeader(title: 'Dashboard Display'),
          SizedBox(height: Spacing.sm.value),

          // Density
          Text('Density', style: textTheme.titleSmall),
          SizedBox(height: Spacing.xs.value),
          Text(
            'Adjusts spacing between dashboard widgets',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: Spacing.sm.value),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<DashboardDensity>(
              key: const Key('settings_density'),
              segments:
                  DashboardDensity.values
                      .map((d) => ButtonSegment(value: d, label: Text(d.label)))
                      .toList(),
              selected: {settings.dashboardDensity},
              onSelectionChanged: (densities) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setDashboardDensity(densities.first);
              },
            ),
          ),
          SizedBox(height: Spacing.lg.value),

          // Card Corner Radius
          _CardStyleSlider(
            key: const Key('settings_card_radius_slider'),
            label: 'Card Corner Radius',
            value: settings.cardCornerRadius,
            min: 4,
            max: 24,
            divisions: 10,
            valueLabel: '${settings.cardCornerRadius.round()}',
            onChanged: (v) {
              ref.read(appSettingsProvider.notifier).setCardCornerRadius(v);
            },
          ),
          SizedBox(height: Spacing.sm.value),

          // Card Elevation
          _CardStyleSlider(
            key: const Key('settings_card_elevation_slider'),
            label: 'Card Elevation',
            value: settings.cardElevation,
            min: 0,
            max: 8,
            divisions: 8,
            valueLabel: '${settings.cardElevation.round()}',
            onChanged: (v) {
              ref.read(appSettingsProvider.notifier).setCardElevation(v);
            },
          ),
          SizedBox(height: Spacing.sm.value),

          // Preview card
          _CardPreview(
            cornerRadius: settings.cardCornerRadius,
            elevation: settings.cardElevation,
          ),
          SizedBox(height: Spacing.xl.value),

          // ── Section 4: Accessibility ────────────────────────────────────
          _SectionHeader(title: 'Accessibility'),
          SizedBox(height: Spacing.sm.value),
          SwitchListTile(
            key: const Key('settings_reduce_motion_switch'),
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimizes animations throughout the app'),
            secondary: const Icon(Icons.accessibility_new),
            value: settings.reduceMotion,
            onChanged: (value) {
              ref.read(appSettingsProvider.notifier).setReduceMotion(value);
            },
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.lg.value),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reset to Defaults'),
            content: const Text(
              'This will restore all settings to their default values.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(appSettingsProvider.notifier).resetToDefaults();
                  Navigator.pop(ctx);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }
}

// ============================================================================
// SECTION HEADER
// ============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// ============================================================================
// COLOR THEME SELECTOR
// ============================================================================

class _ColorThemeSelector extends StatelessWidget {
  final List<ThemePreset> presets;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ColorThemeSelector({
    required this.presets,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: Spacing.md.value,
      runSpacing: Spacing.md.value,
      alignment: WrapAlignment.center,
      children: List.generate(presets.length, (index) {
        final preset = presets[index];
        final isSelected = index == selectedIndex;

        return Semantics(
          label: '${preset.name} color theme${isSelected ? ', selected' : ''}',
          button: true,
          selected: isSelected,
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              key: Key('settings_theme_preset_$index'),
              duration: AnimationDuration.fast.duration,
              width: A11yConstants.minimumTouchSize,
              height: A11yConstants.minimumTouchSize,
              decoration: BoxDecoration(
                color: preset.seedColor,
                shape: BoxShape.circle,
                border:
                    isSelected
                        ? Border.all(color: colorScheme.primary, width: 3)
                        : Border.all(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: preset.seedColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================================
// CARD STYLE SLIDER
// ============================================================================

class _CardStyleSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  const _CardStyleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 3,
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            valueLabel,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CARD PREVIEW
// ============================================================================

class _CardPreview extends StatelessWidget {
  final double cornerRadius;
  final double elevation;

  const _CardPreview({required this.cornerRadius, required this.elevation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        child: Padding(
          padding: Paddings.lg,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.preview, color: colorScheme.primary),
              SizedBox(width: Spacing.sm.value),
              Text(
                'Card Preview',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
