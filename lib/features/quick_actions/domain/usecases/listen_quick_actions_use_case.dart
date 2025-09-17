// Listen for quick actions invocations use case
// Pure business logic for handling quick action events

import 'package:fpdart/fpdart.dart';
import '../entities/quick_action_entity.dart';
import '../repositories/quick_actions_repository.dart';
import '../../../../core/failures/app_failure.dart';

class ListenQuickActionsUseCase {
  const ListenQuickActionsUseCase(this._repository);

  final QuickActionsRepository _repository;

  Either<AppFailure, Stream<QuickActionEntity>> call() {
    try {
      return Right(_repository.actionStream);
    } catch (e) {
      return Left(AppFailure.unexpected(
        message: 'Failed to listen for quick actions',
        cause: e,
      ));
    }
  }
}
