// Theme repository implementation using SharedPreferences.
// Persists theme preferences locally with fallback handling.

import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/theme_mode.dart';
import '../../domain/repositories/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  const ThemeRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  static const String _themePreferenceKey = 'theme_preference';

  @override
  Future<Either<AppFailure, AppThemeMode>> getThemePreference() async {
    try {
      final modeString = _prefs.getString(_themePreferenceKey);
      if (modeString == null) {
        // Default to system preference if no stored value
        return right(AppThemeMode.system);
      }
      final mode = AppThemeMode.fromString(modeString);
      return right(mode);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to retrieve theme preference',
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> setThemePreference(AppThemeMode mode) async {
    try {
      final success =
          await _prefs.setString(_themePreferenceKey, mode.toString());
      if (!success) {
        return left(AppFailure.cache(
          message: 'Failed to save theme preference',
        ));
      }
      return right(null);
    } catch (e) {
      return left(AppFailure.cache(
        message: 'Failed to save theme preference',
      ));
    }
  }
}
