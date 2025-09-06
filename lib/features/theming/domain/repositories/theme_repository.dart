// Theme repository interface for managing theme preferences.
// Abstracts theme persistence from implementation details.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/theme_mode.dart';

abstract interface class ThemeRepository {
  /// Get the current theme preference.
  /// Returns AppThemeMode.system if no preference is stored.
  Future<Either<AppFailure, AppThemeMode>> getThemePreference();

  /// Set the theme preference.
  /// Persists the preference for future app launches.
  Future<Either<AppFailure, void>> setThemePreference(AppThemeMode mode);
}
