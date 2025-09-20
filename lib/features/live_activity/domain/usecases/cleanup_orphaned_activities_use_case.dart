// Use case for cleaning up orphaned recording activities.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../repositories/live_activity_repository.dart';

class CleanupOrphanedActivitiesUseCase {
  const CleanupOrphanedActivitiesUseCase(this._repository);

  final LiveActivityRepository _repository;

  /// Clean up any orphaned activities on app startup.
  /// This ensures no activities remain active if the app was killed unexpectedly.
  Future<Either<AppFailure, void>> call() async {
    return _repository.cleanupOrphanedActivities();
  }
}