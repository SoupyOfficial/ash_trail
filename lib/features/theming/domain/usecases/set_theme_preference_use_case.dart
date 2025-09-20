// Use case for setting the theme preference.
// Persists the theme mode for future app launches.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/theme_mode.dart';
import '../repositories/theme_repository.dart';

class SetThemePreferenceUseCase {
  const SetThemePreferenceUseCase(this._repository);

  final ThemeRepository _repository;

  /// Set the theme preference and persist it.
  Future<Either<AppFailure, void>> call(AppThemeMode mode) async {
    return _repository.setThemePreference(mode);
  }
}
