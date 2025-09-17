// Use case for handling Siri shortcut invocations and recording telemetry.
// Processes shortcut invocations and routes users appropriately.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/siri_shortcut_type.dart';
import '../repositories/siri_shortcuts_repository.dart';

class HandleShortcutInvocationUseCase {
  const HandleShortcutInvocationUseCase(this._repository);

  final SiriShortcutsRepository _repository;

  /// Handle a Siri shortcut invocation by recording telemetry and returning the route.
  /// Returns the appropriate route for the user based on the shortcut type.
  Future<Either<AppFailure, String>> call(SiriShortcutType type) async {
    // Record telemetry for this invocation
    final telemetryResult = await _repository.recordShortcutInvocation(
      shortcutId: type.intentIdentifier,
      type: type,
      invokedAt: DateTime.now(),
    );

    return telemetryResult.fold(
      (failure) => Left(failure),
      (_) {
        // Return the appropriate route based on shortcut type
        if (type == const SiriShortcutType.addLog()) {
          return const Right('/log/add');
        } else if (type == const SiriShortcutType.startTimedLog()) {
          return const Right('/log/timed');
        } else {
          return const Left(AppFailure.validation(message: 'Unknown shortcut type'));
        }
      },
    );
  }
}