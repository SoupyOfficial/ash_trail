// Theme provider for managing application theme state.
// Integrates with system theme preferences and provides reactive theme updates.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/get_theme_preference_use_case.dart';
import '../../domain/usecases/set_theme_preference_use_case.dart';
import '../../data/repositories/theme_repository_impl.dart';

// Repository provider
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  // In production, this should always be overridden in main.dart
  // This fallback helps prevent crashes in tests that don't override it
  throw UnimplementedError(
    'themeRepositoryProvider must be overridden with a concrete implementation. '
    'Make sure to call createThemeRepositoryOverride() in your ProviderScope overrides.',
  );
});

// Use case providers
final getThemePreferenceUseCaseProvider =
    Provider<GetThemePreferenceUseCase>((ref) {
  return GetThemePreferenceUseCase(ref.watch(themeRepositoryProvider));
});

final setThemePreferenceUseCaseProvider =
    Provider<SetThemePreferenceUseCase>((ref) {
  return SetThemePreferenceUseCase(ref.watch(themeRepositoryProvider));
});

// Current theme mode provider
final currentThemeModeProvider =
    StateNotifierProvider<ThemeModeController, AppThemeMode>((ref) {
  return ThemeModeController(ref);
});

// Resolved theme data provider that considers system brightness
final currentThemeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(currentThemeModeProvider);
  final platformBrightness = ref.watch(platformBrightnessProvider);

  return switch (themeMode) {
    AppThemeMode.light => AppTheme.lightTheme,
    AppThemeMode.dark => AppTheme.darkTheme,
    AppThemeMode.system => platformBrightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme,
  };
});

// Platform brightness provider for system theme detection
final platformBrightnessProvider = Provider<Brightness>((ref) {
  // Default to dark as specified in requirements when system preference unavailable
  try {
    return PlatformDispatcher.instance.platformBrightness;
  } catch (_) {
    return Brightness.dark;
  }
});

class ThemeModeController extends StateNotifier<AppThemeMode> {
  ThemeModeController(this._ref) : super(AppThemeMode.system) {
    _loadThemePreference();
  }

  final Ref _ref;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> _loadThemePreference() async {
    if (_isLoading) return;
    _isLoading = true;

    final result = await _ref.read(getThemePreferenceUseCaseProvider).call();

    if (mounted) {
      result.fold(
        (failure) {
          // If we can't load preference, default to dark mode as per requirements
          state = AppThemeMode.dark;
        },
        (themeMode) {
          state = themeMode;
        },
      );
    }

    _isLoading = false;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    // Update state immediately for instant UI response
    state = mode;

    // Persist the preference
    final result =
        await _ref.read(setThemePreferenceUseCaseProvider).call(mode);
    result.fold(
      (failure) {
        // Could show error to user here, but for now we'll just log it
        // The UI change has already been applied for responsiveness
      },
      (_) {
        // Successfully persisted
      },
    );
  }
}

// Provider override helper for dependency injection
Override createThemeRepositoryOverride(SharedPreferences prefs) {
  return themeRepositoryProvider.overrideWithValue(
    ThemeRepositoryImpl(prefs),
  );
}
