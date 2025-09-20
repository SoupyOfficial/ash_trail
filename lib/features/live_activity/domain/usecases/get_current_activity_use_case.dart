// Use case for getting the current active recording session.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/live_activity_entity.dart';
import '../repositories/live_activity_repository.dart';

class GetCurrentActivityUseCase {
  const GetCurrentActivityUseCase(this._repository);

  final LiveActivityRepository _repository;

  /// Get the currently active recording session, if any.
  Future<Either<AppFailure, LiveActivityEntity?>> call() async {
    return _repository.getCurrentActivity();
  }
}