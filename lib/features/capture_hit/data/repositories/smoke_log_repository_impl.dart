// Repository implementation for SmokeLog operations
// Coordinates between local (Isar) and remote (Firestore) data sources
// Implements offline-first pattern with write queue and background sync

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../datasources/smoke_log_local_datasource.dart';
import '../datasources/smoke_log_remote_datasource.dart';
import '../models/smoke_log_dto.dart';
import '../../domain/repositories/smoke_log_repository.dart';

/// Repository implementation for SmokeLog operations
/// Follows offline-first pattern: local storage is source of truth,
/// remote sync happens in background with conflict resolution
class SmokeLogRepositoryImpl implements SmokeLogRepository {
  final SmokeLogLocalDataSource _localDataSource;
  final SmokeLogRemoteDataSource _remoteDataSource;

  const SmokeLogRepositoryImpl({
    required SmokeLogLocalDataSource localDataSource,
    required SmokeLogRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog) async {
    try {
      // Convert domain entity to DTO for storage
      final dto = smokeLog.toDto(isPendingSync: true);

      // Save to local storage first (offline-first)
      final savedDto = await _localDataSource.createSmokeLog(dto);

      // Trigger background sync (fire-and-forget)
      _syncToRemote(savedDto).ignore();

      return Right(savedDto.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to create smoke log: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(
      String accountId) async {
    try {
      final dto = await _localDataSource.getLastSmokeLog(accountId);
      return Right(dto?.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to retrieve last smoke log: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId) async {
    try {
      // Mark as deleted in local storage
      await _localDataSource.deleteSmokeLog(smokeLogId);

      // TODO: Trigger background sync to delete from remote
      // This would need account ID context - consider refactoring interface

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to delete smoke log: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    try {
      final dtos = await _localDataSource.getSmokeLogsByDateRange(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to retrieve smoke logs: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    try {
      final dto = smokeLog.toDto(isPendingSync: true);
      final updatedDto = await _localDataSource.updateSmokeLog(dto);

      // Trigger background sync
      _syncToRemote(updatedDto).ignore();

      return Right(updatedDto.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to update smoke log: ${e.toString()}',
      ));
    }
  }

  /// Background sync operation to push local changes to remote
  /// Implements exponential backoff for failed syncs
  Future<void> _syncToRemote(SmokeLogDto dto) async {
    try {
      // Only sync if we have connectivity (this would be checked via a connectivity service)
      await _remoteDataSource.createSmokeLog(dto);

      // Mark as synced in local storage
      await _localDataSource.markAsSynced(dto.id);
    } catch (e) {
      // Sync failed - log error and leave isPendingSync = true
      // Background sync service will retry with exponential backoff
      // TODO: Log to telemetry service
    }
  }

  /// Public method to manually trigger sync for all pending logs
  /// Used by background sync service or manual refresh
  Future<Either<AppFailure, void>> syncPendingLogs(String accountId) async {
    try {
      final pendingLogs = await _localDataSource.getPendingSyncLogs(accountId);

      if (pendingLogs.isEmpty) {
        return const Right(null);
      }

      // Batch sync for efficiency
      final syncedLogs = await _remoteDataSource.batchSyncLogs(
        accountId: accountId,
        logs: pendingLogs,
      );

      // Mark successfully synced logs
      for (final log in syncedLogs) {
        await _localDataSource.markAsSynced(log.id);
      }

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.network(
        message: 'Failed to sync pending logs: ${e.toString()}',
      ));
    }
  }
}
