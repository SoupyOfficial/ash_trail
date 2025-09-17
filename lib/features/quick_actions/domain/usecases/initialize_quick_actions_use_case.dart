// Initialize quick actions use case
// Pure business logic for setting up quick actions

import 'package:fpdart/fpdart.dart';
import '../entities/quick_action_entity.dart';
import '../repositories/quick_actions_repository.dart';
import '../../../../core/failures/app_failure.dart';

class InitializeQuickActionsUseCase {
  const InitializeQuickActionsUseCase(this._repository);

  final QuickActionsRepository _repository;

  Future<Either<AppFailure, void>> call() async {
    // First initialize the platform
    final initResult = await _repository.initialize();
    if (initResult.isLeft()) return initResult;

    // Define the available quick actions based on requirements
    final actions = [
      const QuickActionEntity(
        type: QuickActionTypes.logHit,
        localizedTitle: 'Log Hit',
        localizedSubtitle: 'Quick record smoking session',
        icon: 'add',
      ),
      const QuickActionEntity(
        type: QuickActionTypes.viewLogs,
        localizedTitle: 'View Logs',
        localizedSubtitle: 'See your smoking history',
        icon: 'list',
      ),
      // Start Timed Log will be added based on feature flag
      const QuickActionEntity(
        type: QuickActionTypes.startTimedLog,
        localizedTitle: 'Start Timed Log',
        localizedSubtitle: 'Begin timing session',
        icon: 'timer',
      ),
    ];

    // Set up the actions on the platform
    return _repository.setupActions(actions);
  }
}
