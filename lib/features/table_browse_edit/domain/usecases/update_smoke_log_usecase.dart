// Use case for updating smoke logs
// Handles business logic for inline editing functionality

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../repositories/logs_table_repository.dart';

/// Use case for updating smoke log entries via inline edit
/// Implements business logic and validation for log editing
class UpdateSmokeLogUseCase {
  final LogsTableRepository _repository;

  const UpdateSmokeLogUseCase({
    required LogsTableRepository repository,
  }) : _repository = repository;

  /// Update an existing smoke log with validation
  ///
  /// Parameters:
  /// - [smokeLog]: Updated smoke log data (required)
  /// - [accountId]: Account ID for verification (required)
  ///
  /// Returns:
  /// - Updated SmokeLog if successful
  /// - AppFailure if validation fails or operation error occurs
  Future<Either<AppFailure, SmokeLog>> call({
    required SmokeLog smokeLog,
    required String accountId,
  }) async {
    // Validation: Check required fields
    if (accountId.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Account ID is required',
        field: 'accountId',
      ));
    }

    if (smokeLog.id.isEmpty) {
      return const Left(AppFailure.validation(
        message: 'Smoke log ID is required',
        field: 'id',
      ));
    }

    // Validation: Verify account ownership
    if (smokeLog.accountId != accountId) {
      return const Left(AppFailure.validation(
        message: 'Cannot update log from different account',
        field: 'accountId',
      ));
    }

    // Business logic validation: Check field constraints
    final validationResult = _validateSmokeLog(smokeLog);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Update timestamp and delegate to repository
    final updatedSmokeLog = smokeLog.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateSmokeLog(updatedSmokeLog);
  }

  /// Validate smoke log fields
  AppFailure? _validateSmokeLog(SmokeLog smokeLog) {
    // Duration validation (must be positive, max 30 minutes)
    if (smokeLog.durationMs <= 0) {
      return const AppFailure.validation(
        message: 'Duration must be greater than 0',
        field: 'durationMs',
      );
    }

    if (smokeLog.durationMs > 1800000) { // 30 minutes in milliseconds
      return const AppFailure.validation(
        message: 'Duration cannot exceed 30 minutes',
        field: 'durationMs',
      );
    }

    // Mood score validation (1-10, required)
    if (smokeLog.moodScore < 1 || smokeLog.moodScore > 10) {
      return const AppFailure.validation(
        message: 'Mood score must be between 1 and 10',
        field: 'moodScore',
      );
    }

    // Physical score validation (1-10, required)
    if (smokeLog.physicalScore < 1 || smokeLog.physicalScore > 10) {
      return const AppFailure.validation(
        message: 'Physical score must be between 1 and 10',
        field: 'physicalScore',
      );
    }

    // Potency validation (1-10 if provided)
    if (smokeLog.potency != null && 
        (smokeLog.potency! < 1 || smokeLog.potency! > 10)) {
      return const AppFailure.validation(
        message: 'Potency must be between 1 and 10',
        field: 'potency',
      );
    }

    // Timestamp validation (cannot be in future)
    if (smokeLog.ts.isAfter(DateTime.now())) {
      return const AppFailure.validation(
        message: 'Log timestamp cannot be in the future',
        field: 'ts',
      );
    }

    // Notes validation (reasonable length limit)
    if (smokeLog.notes != null && smokeLog.notes!.length > 1000) {
      return const AppFailure.validation(
        message: 'Notes cannot exceed 1000 characters',
        field: 'notes',
      );
    }

    return null;
  }
}