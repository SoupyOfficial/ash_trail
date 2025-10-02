// Implementation of SmokeLog local data source using Isar
// Provides offline-first data access for smoke log operations

import '../../../../data/services/isar_service.dart';
import '../../../../data/models/smoke_log_isar.dart';
import '../models/smoke_log_dto.dart';
import 'smoke_log_local_datasource.dart';

/// Concrete implementation of SmokeLogLocalDataSource using Isar
/// Handles local storage operations with proper error handling
class SmokeLogLocalDataSourceImpl implements SmokeLogLocalDataSource {
  final IsarSmokeLogService _isarService;

  const SmokeLogLocalDataSourceImpl(this._isarService);

  @override
  Future<SmokeLogDto> createSmokeLog(SmokeLogDto smokeLog) async {
    // Convert DTO to domain model, then to Isar model
    final domainModel = smokeLog.toEntity();
    final isarModel = SmokeLogIsar.fromDomain(domainModel);

    final result = await _isarService.saveSmokeLog(isarModel);

    return result.fold(
      (failure) => throw failure,
      (savedIsar) => savedIsar.toDomain().toDto(isPendingSync: true),
    );
  }

  @override
  Future<SmokeLogDto?> getLastSmokeLog(String accountId) async {
    final result = await _isarService.getSmokeLogsByAccount(accountId);

    return result.fold(
      (failure) => throw failure,
      (isarList) {
        if (isarList.isEmpty) return null;
        return isarList.first.toDomain().toDto();
      },
    );
  }

  @override
  Future<void> deleteSmokeLog(String smokeLogId) async {
    final result = await _isarService.deleteSmokeLog(smokeLogId);

    result.fold(
      (failure) => throw failure,
      (_) => {},
    );
  }

  @override
  Future<List<SmokeLogDto>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    bool includeDeleted = false,
  }) async {
    final result = await _isarService.getSmokeLogsInDateRange(
      accountId,
      startDate,
      endDate,
    );

    return result.fold(
      (failure) => throw failure,
      (isarList) {
        var filteredList = isarList;

        // Note: SmokeLogIsar doesn't have isDeleted field, so we ignore includeDeleted for now
        // This would need to be implemented if we add soft delete functionality

        // Apply limit if specified
        if (limit != null && filteredList.length > limit) {
          filteredList = filteredList.take(limit).toList();
        }

        return filteredList.map((isar) => isar.toDomain().toDto()).toList();
      },
    );
  }

  @override
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog) async {
    // Mark as pending sync when updating
    final updatedDto = smokeLog.copyWith(
      isPendingSync: true,
      updatedAt: DateTime.now(),
    );

    final domainModel = updatedDto.toEntity();
    final isarModel = SmokeLogIsar.fromDomain(domainModel);

    final result = await _isarService.saveSmokeLog(isarModel);

    return result.fold(
      (failure) => throw failure,
      (savedIsar) => savedIsar.toDomain().toDto(isPendingSync: true),
    );
  }

  @override
  Future<List<SmokeLogDto>> getPendingSyncLogs(String accountId) async {
    final result = await _isarService.getDirtySmokeLog();

    return result.fold(
      (failure) => throw failure,
      (isarList) {
        // Filter by account ID since getDirtySmokeLog returns all dirty logs
        final accountLogs =
            isarList.where((log) => log.accountId == accountId).toList();

        return accountLogs
            .map((isar) => isar.toDomain().toDto(isPendingSync: true))
            .toList();
      },
    );
  }

  @override
  Future<void> markAsSynced(String smokeLogId) async {
    final result = await _isarService.markAsSynced(smokeLogId);

    result.fold(
      (failure) => throw failure,
      (_) => {},
    );
  }

  @override
  Future<void> clearAccountLogs(String accountId) async {
    // Get all logs for account first
    final result = await _isarService.getSmokeLogsByAccount(accountId);

    await result.fold(
      (failure) => throw failure,
      (isarList) async {
        // Delete each log
        for (final log in isarList) {
          await _isarService.deleteSmokeLog(log.logId);
        }
      },
    );
  }

  @override
  Future<int> getLogsCount(String accountId) async {
    final result = await _isarService.getSmokeLogsCount(accountId);

    return result.fold(
      (failure) => throw failure,
      (count) => count,
    );
  }
}
