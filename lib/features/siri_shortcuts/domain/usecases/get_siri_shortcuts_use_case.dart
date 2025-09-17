// Use case for getting all configured Siri shortcuts.
// Returns the list of shortcuts available for management.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/siri_shortcuts_entity.dart';
import '../repositories/siri_shortcuts_repository.dart';

class GetSiriShortcutsUseCase {
  const GetSiriShortcutsUseCase(this._repository);

  final SiriShortcutsRepository _repository;

  /// Get all configured Siri shortcuts.
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> call() async {
    return _repository.getShortcuts();
  }
}