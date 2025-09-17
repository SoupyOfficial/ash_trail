// Use case for cancelling a live activity recording session.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/live_activity_entity.dart';
import '../repositories/live_activity_repository.dart';

class CancelActivityUseCase {
  const CancelActivityUseCase(this._repository);

  final LiveActivityRepository _repository;

  /// Cancel the current recording session.
  /// Validates that an active session exists before cancelling.
  Future<Either<AppFailure, LiveActivityEntity>> call(
    String activityId, {
    String? reason,
  }) async {
    // Validate the activity exists and is active
    final activityResult = await _repository.getActivityById(activityId);
    
    return activityResult.fold(
      (failure) => Left(failure),
      (activity) async {
        if (!activity.isActive) {
          return const Left(AppFailure.validation(
            message: 'Cannot cancel inactive recording session',
          ));
        }
        
        return _repository.cancelActivity(activityId, reason: reason);
      },
    );
  }
}