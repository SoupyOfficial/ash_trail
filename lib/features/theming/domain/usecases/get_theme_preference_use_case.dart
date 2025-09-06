// Use case for retrieving the current theme preference.
// Returns the stored theme mode or defaults to system.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/theme_mode.dart';
import '../repositories/theme_repository.dart';

class GetThemePreferenceUseCase {
  const GetThemePreferenceUseCase(this._repository);

  final ThemeRepository _repository;

  /// Get the current theme preference.
  /// Returns AppThemeMode.system as default if no preference exists.
  Future<Either<AppFailure, AppThemeMode>> call() async {
    return _repository.getThemePreference();
  }
}
