// Repository implementation for logs table operations
// Coordinates between local and remote data sources with offline-first pattern

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../capture_hit/data/models/smoke_log_dto.dart';
import '../datasources/logs_table_local_datasource.dart';
import '../datasources/logs_table_remote_datasource.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';
import '../../domain/repositories/logs_table_repository.dart';

/// Repository implementation for logs table operations
/// Follows offline-first pattern: local storage is primary source,
/// remote operations happen in background with conflict resolution
class LogsTableRepositoryImpl implements LogsTableRepository {
  final LogsTableLocalDataSource _localDataSource;
  final LogsTableRemoteDataSource _remoteDataSource;

  const LogsTableRepositoryImpl({
    required LogsTableLocalDataSource localDataSource,
    required LogsTableRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<AppFailure, List<SmokeLog>>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  }) async {
    try {
      // Get data from local storage (offline-first)
      final dtos = await _localDataSource.getFilteredSortedLogs(
        accountId: accountId,
        filter: filter,
        sort: sort,
        limit: limit,
        offset: offset,
      );

      // Convert DTOs to domain entities
      final entities = dtos.map((dto) => dto.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to retrieve filtered smoke logs: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, int>> getLogsCount({
    required String accountId,
    LogFilter? filter,
  }) async {
    try {
      final count = await _localDataSource.getLogsCount(
        accountId: accountId,
        filter: filter,
      );
      return Right(count);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to get logs count: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    try {
      // Convert to DTO with pending sync flag
      final dto = smokeLog.toDto(isPendingSync: true);

      // Update in local storage first
      final updatedDto = await _localDataSource.updateSmokeLog(dto);

      // Trigger background sync (fire-and-forget)
      _syncUpdateToRemote(updatedDto).ignore();

      return Right(updatedDto.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to update smoke log: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  }) async {
    try {
      // Delete from local storage (soft delete)
      await _localDataSource.deleteSmokeLog(
        smokeLogId: smokeLogId,
        accountId: accountId,
      );

      // Trigger background sync for deletion
      _syncDeleteToRemote(smokeLogId, accountId).ignore();

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to delete smoke log: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, int>> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  }) async {
    try {
      // Batch delete from local storage
      final deletedCount = await _localDataSource.deleteSmokeLogsBatch(
        smokeLogIds: smokeLogIds,
        accountId: accountId,
      );

      // Trigger background sync for batch deletion
      _syncBatchDeleteToRemote(smokeLogIds, accountId).ignore();

      return Right(deletedCount);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to batch delete smoke logs: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog>> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  }) async {
    try {
      final dto = await _localDataSource.getSmokeLogById(
        smokeLogId: smokeLogId,
        accountId: accountId,
      );

      if (dto == null) {
        return Left(AppFailure.notFound(
          message: 'Smoke log not found',
          resourceId: smokeLogId,
        ));
      }

      return Right(dto.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to get smoke log by ID: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, List<String>>> getUsedMethodIds({
    required String accountId,
  }) async {
    try {
      final methodIds = await _localDataSource.getUsedMethodIds(
        accountId: accountId,
      );
      return Right(methodIds);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to get used method IDs: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, List<String>>> getUsedTagIds({
    required String accountId,
  }) async {
    try {
      final tagIds = await _localDataSource.getUsedTagIds(
        accountId: accountId,
      );
      return Right(tagIds);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to get used tag IDs: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, int>> addTagsToLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    try {
      // Write to local first
      final created = await _localDataSource.addTagsToLogsBatch(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      // Fire-and-forget remote sync
      _syncBatchAddTagsToRemote(accountId, smokeLogIds, tagIds).ignore();

      return Right(created);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to batch add tags: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<AppFailure, int>> removeTagsFromLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    try {
      final deleted = await _localDataSource.removeTagsFromLogsBatch(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      _syncBatchRemoveTagsFromRemote(accountId, smokeLogIds, tagIds).ignore();

      return Right(deleted);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to batch remove tags: ${e.toString()}',
      ));
    }
  }

  /// Background sync operation for updates
  Future<void> _syncUpdateToRemote(SmokeLogDto dto) async {
    try {
      await _remoteDataSource.updateSmokeLog(dto);
      // Mark as synced in local storage (this would be implemented)
    } catch (e) {
      // Sync failed - leave pending sync flag for retry
      // TODO: Log to telemetry service
    }
  }

  /// Background sync operation for single deletion
  Future<void> _syncDeleteToRemote(String smokeLogId, String accountId) async {
    try {
      await _remoteDataSource.deleteSmokeLog(
        smokeLogId: smokeLogId,
        accountId: accountId,
      );
    } catch (e) {
      // Sync failed - deletion will be retried by background service
      // TODO: Log to telemetry service
    }
  }

  /// Background sync operation for batch deletion
  Future<void> _syncBatchDeleteToRemote(
    List<String> smokeLogIds,
    String accountId,
  ) async {
    try {
      await _remoteDataSource.deleteSmokeLogsBatch(
        smokeLogIds: smokeLogIds,
        accountId: accountId,
      );
    } catch (e) {
      // Sync failed - deletions will be retried by background service
      // TODO: Log to telemetry service
    }
  }

  /// Background sync operation for batch tag add
  Future<void> _syncBatchAddTagsToRemote(
    String accountId,
    List<String> smokeLogIds,
    List<String> tagIds,
  ) async {
    try {
      await _remoteDataSource.addTagsToLogsBatch(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );
    } catch (e) {
      // Leave pending sync flags for retry
    }
  }

  /// Background sync operation for batch tag removal
  Future<void> _syncBatchRemoveTagsFromRemote(
    String accountId,
    List<String> smokeLogIds,
    List<String> tagIds,
  ) async {
    try {
      await _remoteDataSource.removeTagsFromLogsBatch(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );
    } catch (e) {
      // Leave pending sync flags for retry
    }
  }

  /// Public method for manual sync operations
  /// Used by background sync service or pull-to-refresh
  Future<Either<AppFailure, void>> syncWithRemote({
    required String accountId,
    LogFilter? filter,
    bool forceFullSync = false,
  }) async {
    try {
      if (forceFullSync) {
        // Full sync: fetch all data from remote and merge with local
        await _remoteDataSource.getFilteredSortedLogs(
          accountId: accountId,
          filter: filter,
        );

        // TODO: Implement merge logic with conflict resolution
        // This would involve comparing timestamps and applying merge rules
      }

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.network(
        message: 'Failed to sync with remote: ${e.toString()}',
      ));
    }
  }
}
