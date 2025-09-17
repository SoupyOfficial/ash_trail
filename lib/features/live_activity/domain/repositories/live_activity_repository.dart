// Repository interface for managing live activity recording sessions.
// Handles persistence and lifecycle of recording activities.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/live_activity_entity.dart';

abstract interface class LiveActivityRepository {
  /// Get the currently active recording session, if any.
  /// Returns null wrapped in Right if no active session exists.
  Future<Either<AppFailure, LiveActivityEntity?>> getCurrentActivity();

  /// Start a new recording session.
  /// Returns the created activity entity.
  Future<Either<AppFailure, LiveActivityEntity>> startActivity();

  /// Complete the current recording session.
  /// Marks the session as completed and sets the end time.
  Future<Either<AppFailure, LiveActivityEntity>> completeActivity(String activityId);

  /// Cancel the current recording session.
  /// Marks the session as cancelled with optional reason.
  Future<Either<AppFailure, LiveActivityEntity>> cancelActivity(
    String activityId, {
    String? reason,
  });

  /// Get a specific activity by ID.
  Future<Either<AppFailure, LiveActivityEntity>> getActivityById(String id);

  /// Stream of the current active activity for real-time updates.
  /// Emits null when no activity is active.
  Stream<LiveActivityEntity?> watchCurrentActivity();

  /// Clean up any orphaned activities on app startup.
  /// Sets orphaned active activities to cancelled status.
  Future<Either<AppFailure, void>> cleanupOrphanedActivities();
}