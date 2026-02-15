import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/app_logger.dart';
import '../models/app_settings.dart';
import '../services/error_reporting_service.dart';
import 'home_widget_config_provider.dart' show sharedPreferencesProvider;

/// SharedPreferences key for global app settings.
const String _settingsKey = 'app_settings';

final _log = AppLogger.logger('AppSettingsNotifier');

// ============================================================================
// STATE NOTIFIER
// ============================================================================

/// Manages global [AppSettings] persisted in SharedPreferences.
///
/// Follows the same pattern as [HomeLayoutConfigNotifier].
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final Ref ref;

  AppSettingsNotifier(this.ref) : super(AppSettings.defaults()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences.
  Future<void> _loadSettings() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final jsonString = prefs.getString(_settingsKey);

      if (jsonString != null) {
        state = AppSettings.fromJsonString(jsonString);
      } else {
        state = AppSettings.defaults();
        await _saveSettings();
      }
    } catch (e, st) {
      _log.e('Error loading app settings', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'AppSettingsNotifier._loadSettings',
      );
      state = AppSettings.defaults();
    }
  }

  /// Persist current state to SharedPreferences.
  Future<void> _saveSettings() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_settingsKey, state.toJsonString());
    } catch (e, st) {
      _log.e('Error saving app settings', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'AppSettingsNotifier._saveSettings',
      );
    }
  }

  // ── Mutators ──────────────────────────────────────────────────────────────

  Future<void> setPreset(int index) async {
    if (index < 0 || index >= ThemePreset.presets.length) return;
    state = state.copyWith(presetIndex: index);
    await _saveSettings();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  Future<void> setDashboardDensity(DashboardDensity density) async {
    state = state.copyWith(dashboardDensity: density);
    await _saveSettings();
  }

  Future<void> setCardCornerRadius(double radius) async {
    state = state.copyWith(cardCornerRadius: radius.clamp(4, 24));
    await _saveSettings();
  }

  Future<void> setCardElevation(double elevation) async {
    state = state.copyWith(cardElevation: elevation.clamp(0, 8));
    await _saveSettings();
  }

  Future<void> setReduceMotion(bool value) async {
    state = state.copyWith(reduceMotion: value);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    state = AppSettings.defaults();
    await _saveSettings();
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Main provider for [AppSettings] state.
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
      return AppSettingsNotifier(ref);
    });

/// Resolved seed [Color] from the active preset.
final activeSeedColorProvider = Provider<Color>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.seedColor));
});

/// Current [ThemeMode] selection.
final activeThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.themeMode));
});

/// Dashboard grid density.
final dashboardDensityProvider = Provider<DashboardDensity>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.dashboardDensity));
});

/// Card corner radius in dp.
final cardCornerRadiusProvider = Provider<double>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.cardCornerRadius));
});

/// Card elevation level.
final cardElevationProvider = Provider<double>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.cardElevation));
});

/// Whether animations should be suppressed.
final reduceMotionProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider.select((s) => s.reduceMotion));
});
