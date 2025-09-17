// Use case for completing a live activity recording session.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/live_activity_entity.dart';
import '../repositories/live_activity_repository.dart';

class CompleteActivityUseCase {
  const CompleteActivityUseCase(this._repository);

  final LiveActivityRepository _repository;

  /// Complete the current recording session.
  /// Validates that an active session exists before completing.
  Future<Either<AppFailure, LiveActivityEntity>> call(String activityId) async {
    // Validate the activity exists and is active
    final activityResult = await _repository.getActivityById(activityId);

    return activityResult.fold(
      (failure) => Left(failure),
      (activity) async {
        if (!activity.isActive) {
          return const Left(AppFailure.validation(
            message: 'Cannot complete inactive recording session',
          ));
        }

        return _repository.completeActivity(activityId);
      },
    );
  }
}
