// Use case for starting a new live activity recording session.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/live_activity_entity.dart';
import '../repositories/live_activity_repository.dart';

class StartActivityUseCase {
  const StartActivityUseCase(this._repository);

  final LiveActivityRepository _repository;

  /// Start a new recording session.
  /// Ensures no other active session exists before starting.
  Future<Either<AppFailure, LiveActivityEntity>> call() async {
    // Check if there's already an active session
    final currentResult = await _repository.getCurrentActivity();

    return currentResult.fold(
      (failure) => Left(failure),
      (currentActivity) async {
        if (currentActivity != null && currentActivity.isActive) {
          return const Left(AppFailure.conflict(
            message: 'Another recording session is already active',
          ));
        }

        // Start new session
        return _repository.startActivity();
      },
    );
  }
}
