import 'package:fpdart/fpdart.dart';
import '../../domain/models/smoke_log.dart';
import '../../features/capture_hit/domain/repositories/smoke_log_repository.dart';
import '../../core/failures/app_failure.dart';
import '../services/isar_service.dart';
import '../models/smoke_log_isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmokeLogRepositoryIsar implements SmokeLogRepository {
  final IsarSmokeLogService _isarService;

  SmokeLogRepositoryIsar(this._isarService);

  @override
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog) async {
    final isarModel = SmokeLogIsar.fromDomain(smokeLog);

    final result = await _isarService.saveSmokeLog(isarModel);

    return result.fold(
      (failure) => Left(failure),
      (savedIsar) => Right(savedIsar.toDomain()),
    );
  }

  @override
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(
      String accountId) async {
    final result = await _isarService.getSmokeLogsByAccount(accountId);

    return result.fold(
      (failure) => Left(failure),
      (isarList) {
        if (isarList.isEmpty) {
          return const Right(null);
        }
        return Right(isarList.first.toDomain());
      },
    );
  }

  @override
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId) async {
    final result = await _isarService.deleteSmokeLog(smokeLogId);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final result = await _isarService.getSmokeLogsInDateRange(
        accountId, startDate, endDate);

    return result.fold(
      (failure) => Left(failure),
      (isarList) => Right(isarList.map((isar) => isar.toDomain()).toList()),
    );
  }

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    // For updates, we create a new Isar model with updated timestamp
    final updatedSmokeLog = smokeLog.copyWith(
      updatedAt: DateTime.now(),
    );
    final isarModel = SmokeLogIsar.fromDomain(updatedSmokeLog);

    final result = await _isarService.saveSmokeLog(isarModel);

    return result.fold(
      (failure) => Left(failure),
      (savedIsar) => Right(savedIsar.toDomain()),
    );
  }

  // Additional methods for Isar-specific functionality

  /// Save a smoke log (used internally)
  Future<Either<AppFailure, SmokeLog>> saveSmokeLog(SmokeLog smokeLog) async {
    return createSmokeLog(smokeLog);
  }

  /// Get smoke logs by account (for compatibility with existing code)
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByAccount(
      String accountId) async {
    final result = await _isarService.getSmokeLogsByAccount(accountId);

    return result.fold(
      (failure) => Left(failure),
      (isarList) => Right(isarList.map((isar) => isar.toDomain()).toList()),
    );
  }

  /// Get smoke log by ID
  Future<Either<AppFailure, SmokeLog?>> getSmokeLogById(String logId) async {
    final result = await _isarService.getSmokeLogById(logId);

    return result.fold(
      (failure) => Left(failure),
      (isarModel) => Right(isarModel?.toDomain()),
    );
  }

  /// Get smoke logs count
  Future<Either<AppFailure, int>> getSmokeLogsCount(String accountId) async {
    return await _isarService.getSmokeLogsCount(accountId);
  }

  /// Get unsynced smoke logs for background sync
  Future<Either<AppFailure, List<SmokeLog>>> getDirtySmokeLog() async {
    final result = await _isarService.getDirtySmokeLog();

    return result.fold(
      (failure) => Left(failure),
      (isarList) => Right(isarList.map((isar) => isar.toDomain()).toList()),
    );
  }

  /// Mark smoke log as successfully synced
  Future<Either<AppFailure, void>> markAsSynced(String logId) async {
    return await _isarService.markAsSynced(logId);
  }

  /// Mark smoke log with sync error
  Future<Either<AppFailure, void>> markSyncError(
      String logId, String error) async {
    return await _isarService.markSyncError(logId, error);
  }
}

final smokeLogRepositoryIsarProvider =
    FutureProvider<SmokeLogRepositoryIsar>((ref) async {
  final isarService = await ref.watch(isarSmokeLogServiceProvider.future);
  return SmokeLogRepositoryIsar(isarService);
});

// (Unified provider lives in smoke_log_repository_provider.dart)
