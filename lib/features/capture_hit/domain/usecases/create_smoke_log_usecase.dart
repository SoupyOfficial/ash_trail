// Use case for creating smoke log entries
// Handles business logic for the hold-to-record functionality

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../repositories/smoke_log_repository.dart';

/// Use case for creating smoke log entries via hold-to-record
/// Implements business logic and validation for logging hits
class CreateSmokeLogUseCase {
  final SmokeLogRepository _repository;

  const CreateSmokeLogUseCase({
    required SmokeLogRepository repository,
  }) : _repository = repository;

  /// Creates a new smoke log entry with validation
  ///
  /// Parameters:
  /// - [accountId]: ID of the account (required, non-empty)
  /// - [durationMs]: Duration in milliseconds (required, > 0, ≤ 30 minutes)
  /// - [methodId]: Optional smoking method identifier
  /// - [potency]: Optional potency rating (1-10)
  /// - [moodScore]: Mood rating (1-10, required)
  /// - [physicalScore]: Physical feeling rating (1-10, required)
  /// - [notes]: Optional user notes
  ///
  /// Returns:
  /// - [SmokeLog] if successfully created
  /// - [AppFailure] if validation fails or creation error occurs
  Future<Either<AppFailure, SmokeLog>> call({
    required String accountId,
    required int durationMs,
    String? methodId,
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
  }) async {
    // Validation: Check required fields and constraints
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (durationMs <= 0) {
      return const Left(AppFailure.validation(
        message: 'Duration must be greater than 0',
        field: 'durationMs',
      ));
    }

    // Maximum duration: 30 minutes (1,800,000 milliseconds)
    if (durationMs > 1800000) {
      return const Left(AppFailure.validation(
        message: 'Duration cannot exceed 30 minutes',
        field: 'durationMs',
      ));
    }

    // Validate mood score (1-10, required)
    if (moodScore < 1 || moodScore > 10) {
      return const Left(AppFailure.validation(
        message: 'Mood score must be between 1 and 10',
        field: 'moodScore',
      ));
    }

    // Validate physical score (1-10, required)
    if (physicalScore < 1 || physicalScore > 10) {
      return const Left(AppFailure.validation(
        message: 'Physical score must be between 1 and 10',
        field: 'physicalScore',
      ));
    }

    // Validate potency if provided (1-10)
    if (potency != null && (potency < 1 || potency > 10)) {
      return const Left(AppFailure.validation(
        message: 'Potency must be between 1 and 10',
        field: 'potency',
      ));
    }

    // Generate unique ID for the smoke log
    final now = DateTime.now();
    final id = '${accountId}_${now.millisecondsSinceEpoch}';

    // Create the smoke log entity
    final smokeLog = SmokeLog(
      id: id,
      accountId: accountId,
      ts: now,
      durationMs: durationMs,
      methodId: methodId,
      potency: potency,
      moodScore: moodScore,
      physicalScore: physicalScore,
      notes: notes?.isNotEmpty == true ? notes : null,
      deviceLocalId: null, // Will be set by device-specific services
      createdAt: now,
      updatedAt: now,
    );

    // Persist via repository (offline-first)
    return await _repository.createSmokeLog(smokeLog);
  }
}
