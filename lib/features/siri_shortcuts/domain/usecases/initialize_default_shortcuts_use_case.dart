// Use case for initializing default Siri shortcuts after first in-app use.
// Creates the required shortcuts (Add Log and Start Timed Log) if they don't exist.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/siri_shortcuts_entity.dart';
import '../entities/siri_shortcut_type.dart';
import '../repositories/siri_shortcuts_repository.dart';

class InitializeDefaultShortcutsUseCase {
  const InitializeDefaultShortcutsUseCase(this._repository);

  final SiriShortcutsRepository _repository;

  /// Initialize default shortcuts (Add Log and Start Timed Log) if they don't exist.
  /// This is called after first in-app use to set up the required shortcuts.
  Future<Either<AppFailure, void>> call() async {
    // Check if Siri shortcuts are supported
    final supportedResult = await _repository.isSiriShortcutsSupported();
    return supportedResult.fold(
      (failure) => Left(failure),
      (isSupported) async {
        if (!isSupported) {
          // Not an error, just not supported on this platform
          return const Right(null);
        }

        // Get existing shortcuts
        final shortcutsResult = await _repository.getShortcuts();
        return shortcutsResult.fold(
          (failure) => Left(failure),
          (existingShortcuts) async {
            final shortcutsToCreate = <SiriShortcutsEntity>[];

            // Create Add Log shortcut if it doesn't exist
            final hasAddLog = existingShortcuts.any(
              (s) => s.type == const SiriShortcutType.addLog(),
            );
            if (!hasAddLog) {
              shortcutsToCreate.add(SiriShortcutsEntity(
                id: 'add_log_shortcut',
                type: const SiriShortcutType.addLog(),
                createdAt: DateTime.now(),
              ));
            }

            // Create Start Timed Log shortcut if it doesn't exist
            final hasTimedLog = existingShortcuts.any(
              (s) => s.type == const SiriShortcutType.startTimedLog(),
            );
            if (!hasTimedLog) {
              shortcutsToCreate.add(SiriShortcutsEntity(
                id: 'start_timed_log_shortcut',
                type: const SiriShortcutType.startTimedLog(),
                createdAt: DateTime.now(),
              ));
            }

            // Create the shortcuts if any are needed
            for (final shortcut in shortcutsToCreate) {
              final createResult = await _repository.createShortcut(shortcut);
              if (createResult.isLeft()) return createResult;
            }

            return const Right(null);
          },
        );
      },
    );
  }
}
