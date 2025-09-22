// Use case for updating goal progress
// Handles progress updates and goal completion marking

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../domain/models/goal.dart';
import '../repositories/goal_progress_repository.dart';

/// Parameters for updating goal progress
class UpdateGoalProgressParams {
  const UpdateGoalProgressParams({
    required this.goalId,
    required this.newProgress,
    this.markAsCompleted = false,
  });

  final String goalId;
  final int newProgress;
  final bool markAsCompleted;
}

/// Use case for updating goal progress
/// Handles both progress updates and completion marking
class UpdateGoalProgressUseCase implements UseCase<Goal, UpdateGoalProgressParams> {
  const UpdateGoalProgressUseCase(this._repository);

  final GoalProgressRepository _repository;

  @override
  Future<Either<AppFailure, Goal>> call(UpdateGoalProgressParams params) async {
    try {
      // Update the progress first
      final updateResult = await _repository.updateGoalProgress(
        goalId: params.goalId,
        newProgress: params.newProgress,
      );

      return await updateResult.fold(
        (failure) async => Left(failure),
        (updatedGoal) async {
          // If marked for completion or target reached, mark as achieved
          final shouldMarkCompleted = params.markAsCompleted || 
                                    params.newProgress >= updatedGoal.target;
          
          if (shouldMarkCompleted && updatedGoal.achievedAt == null) {
            return await _repository.markGoalAsAchieved(params.goalId);
          }

          return Right(updatedGoal);
        },
      );
    } catch (error, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to update goal progress',
        cause: error,
        stackTrace: stackTrace,
      ));
    }
  }
}