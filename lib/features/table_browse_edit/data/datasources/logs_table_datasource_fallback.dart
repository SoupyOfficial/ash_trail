// Fallback in-memory implementations for logs table data sources
// Provides a lightweight offline-friendly default when Isar/Firestore
// integrations are not yet wired up. The local implementation reuses the
// generic SmokeLog local data source to hydrate data and maintains an
// in-memory tag index so table features keep functioning in development
// environments.

import 'package:collection/collection.dart';

import '../../../capture_hit/data/datasources/smoke_log_local_datasource.dart';
import '../../../capture_hit/data/models/smoke_log_dto.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';
import 'logs_table_local_datasource.dart';
import 'logs_table_remote_datasource.dart';

/// Sentinel date used when no explicit end date is provided.
final DateTime _fallbackMaxDate = DateTime.utc(2100, 01, 01);

/// In-memory fallback for [LogsTableLocalDataSource].
/// It leverages the shared [SmokeLogLocalDataSource] to read and write
/// SmokeLog records, then layers on the filtering, sorting, pagination, and
/// tag batching logic required by the table feature.
class LogsTableLocalDataSourceFallback implements LogsTableLocalDataSource {
  LogsTableLocalDataSourceFallback({
    required SmokeLogLocalDataSource smokeLogLocalDataSource,
    DateTime Function()? nowBuilder,
  })  : _smokeLogLocalDataSource = smokeLogLocalDataSource,
        _nowBuilder = nowBuilder ?? DateTime.now;

  final SmokeLogLocalDataSource _smokeLogLocalDataSource;
  final DateTime Function() _nowBuilder;

  /// Maintains tag assignments per log ID so include/exclude filters work.
  final Map<String, Set<String>> _tagsByLogId = {};

  @override
  Future<List<SmokeLogDto>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  }) async {
    final logs = await _loadAndFilter(
      accountId: accountId,
      filter: filter,
      sort: sort,
    );

    return _applyPagination(logs, limit: limit, offset: offset);
  }

  @override
  Future<int> getLogsCount({
    required String accountId,
    LogFilter? filter,
  }) async {
    final logs = await _loadAndFilter(
      accountId: accountId,
      filter: filter,
      sort: null,
    );
    return logs.length;
  }

  @override
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog) async {
    // Ensure updated timestamp reflects the moment of the edit so ordering
    // honours recent updates even in fallback mode.
    final updatedDto = smokeLog.copyWith(updatedAt: _nowBuilder());
    return _smokeLogLocalDataSource.updateSmokeLog(updatedDto);
  }

  @override
  Future<void> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  }) async {
    await _smokeLogLocalDataSource.deleteSmokeLog(smokeLogId);
    _tagsByLogId.remove(smokeLogId);
  }

  @override
  Future<int> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  }) async {
    var deleted = 0;
    for (final id in smokeLogIds) {
      await deleteSmokeLog(smokeLogId: id, accountId: accountId);
      deleted += 1;
    }
    return deleted;
  }

  @override
  Future<SmokeLogDto?> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  }) async {
    final logs = await _smokeLogLocalDataSource.getSmokeLogsByDateRange(
      accountId: accountId,
      startDate: DateTime.fromMillisecondsSinceEpoch(0),
      endDate: _fallbackMaxDate,
    );

    return logs.firstWhereOrNull((dto) => dto.id == smokeLogId);
  }

  @override
  Future<List<String>> getUsedMethodIds({
    required String accountId,
  }) async {
    final logs = await _smokeLogLocalDataSource.getSmokeLogsByDateRange(
      accountId: accountId,
      startDate: DateTime.fromMillisecondsSinceEpoch(0),
      endDate: _fallbackMaxDate,
    );

    final unique = <String>{};
    for (final log in logs) {
      final methodId = log.methodId;
      if (methodId != null && methodId.isNotEmpty) {
        unique.add(methodId);
      }
    }
    return unique.toList(growable: false);
  }

  @override
  Future<List<String>> getUsedTagIds({
    required String accountId,
  }) async {
    final assigned = _tagsByLogId.values.flattened.toSet();
    return assigned.toList(growable: false);
  }

  @override
  Future<int> addTagsToLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    if (tagIds.isEmpty || smokeLogIds.isEmpty) {
      return 0;
    }

    var createdEdges = 0;
    for (final logId in smokeLogIds) {
      final tags = _tagsByLogId.putIfAbsent(logId, () => <String>{});
      for (final tagId in tagIds) {
        if (tags.add(tagId)) {
          createdEdges += 1;
        }
      }
    }
    return createdEdges;
  }

  @override
  Future<int> removeTagsFromLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    if (tagIds.isEmpty || smokeLogIds.isEmpty) {
      return 0;
    }

    var deletedEdges = 0;
    for (final logId in smokeLogIds) {
      final tags = _tagsByLogId[logId];
      if (tags == null) continue;

      for (final tagId in tagIds) {
        if (tags.remove(tagId)) {
          deletedEdges += 1;
        }
      }

      if (tags.isEmpty) {
        _tagsByLogId.remove(logId);
      }
    }
    return deletedEdges;
  }

  Future<List<SmokeLogDto>> _loadAndFilter({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
  }) async {
    final start = filter?.startDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final end = filter?.endDate ?? _fallbackMaxDate;

    final rawLogs = await _smokeLogLocalDataSource.getSmokeLogsByDateRange(
      accountId: accountId,
      startDate: start,
      endDate: end,
    );

    final filtered =
        rawLogs.where((log) => _matchesFilter(log, filter)).toList();
    _sortInPlace(filtered, sort ?? LogSort.defaultSort);
    return filtered;
  }

  bool _matchesFilter(SmokeLogDto log, LogFilter? filter) {
    if (filter == null) {
      return true;
    }

    if (filter.methodIds != null && filter.methodIds!.isNotEmpty) {
      final methodId = log.methodId;
      if (methodId == null || !filter.methodIds!.contains(methodId)) {
        return false;
      }
    }

    final includeTags = filter.includeTagIds;
    if (includeTags != null && includeTags.isNotEmpty) {
      final assigned = _tagsByLogId[log.id] ?? const <String>{};
      if (!includeTags.every(assigned.contains)) {
        return false;
      }
    }

    final excludeTags = filter.excludeTagIds;
    if (excludeTags != null && excludeTags.isNotEmpty) {
      final assigned = _tagsByLogId[log.id] ?? const <String>{};
      if (excludeTags.any(assigned.contains)) {
        return false;
      }
    }

    if (filter.minMoodScore != null && log.moodScore < filter.minMoodScore!) {
      return false;
    }

    if (filter.maxMoodScore != null && log.moodScore > filter.maxMoodScore!) {
      return false;
    }

    if (filter.minPhysicalScore != null &&
        log.physicalScore < filter.minPhysicalScore!) {
      return false;
    }

    if (filter.maxPhysicalScore != null &&
        log.physicalScore > filter.maxPhysicalScore!) {
      return false;
    }

    if (filter.minDurationMs != null &&
        log.durationMs < filter.minDurationMs!) {
      return false;
    }

    if (filter.maxDurationMs != null &&
        log.durationMs > filter.maxDurationMs!) {
      return false;
    }

    final search = filter.searchText?.trim();
    if (search != null && search.isNotEmpty) {
      final haystack = log.notes?.toLowerCase() ?? '';
      if (!haystack.contains(search.toLowerCase())) {
        return false;
      }
    }

    return true;
  }

  void _sortInPlace(List<SmokeLogDto> logs, LogSort sort) {
    logs.sort((a, b) {
      final fieldComparison = switch (sort.field) {
        LogSortField.timestamp => a.ts.compareTo(b.ts),
        LogSortField.duration => a.durationMs.compareTo(b.durationMs),
        LogSortField.moodScore => a.moodScore.compareTo(b.moodScore),
        LogSortField.physicalScore =>
          a.physicalScore.compareTo(b.physicalScore),
        LogSortField.createdAt => a.createdAt.compareTo(b.createdAt),
        LogSortField.updatedAt => a.updatedAt.compareTo(b.updatedAt),
      };

      if (fieldComparison != 0) {
        return sort.order == LogSortOrder.ascending
            ? fieldComparison
            : -fieldComparison;
      }

      // Fall back to ID comparison so ordering is deterministic when values tie.
      return sort.order == LogSortOrder.ascending
          ? a.id.compareTo(b.id)
          : b.id.compareTo(a.id);
    });
  }

  List<SmokeLogDto> _applyPagination(
    List<SmokeLogDto> logs, {
    required int? limit,
    required int? offset,
  }) {
    final skip = offset ?? 0;
    if (skip >= logs.length) {
      return <SmokeLogDto>[];
    }

    final sliced = logs.skip(skip);
    if (limit == null) {
      return sliced.toList(growable: false);
    }

    return sliced.take(limit).toList(growable: false);
  }
}

/// No-op remote implementation used until Firestore wiring is available.
/// It ensures the repository can be constructed without explicit overrides
/// while making it easy to layer real behaviour later by simply overriding
/// the provider at composition time.
class LogsTableRemoteDataSourceNoop implements LogsTableRemoteDataSource {
  const LogsTableRemoteDataSourceNoop();

  @override
  Future<List<SmokeLogDto>> getFilteredSortedLogs({
    required String accountId,
    LogFilter? filter,
    LogSort? sort,
    int? limit,
    int? offset,
  }) async {
    return const <SmokeLogDto>[];
  }

  @override
  Future<int> getLogsCount({
    required String accountId,
    LogFilter? filter,
  }) async {
    return 0;
  }

  @override
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog) async {
    return smokeLog;
  }

  @override
  Future<void> deleteSmokeLog({
    required String smokeLogId,
    required String accountId,
  }) async {}

  @override
  Future<int> deleteSmokeLogsBatch({
    required List<String> smokeLogIds,
    required String accountId,
  }) async {
    return 0;
  }

  @override
  Future<SmokeLogDto?> getSmokeLogById({
    required String smokeLogId,
    required String accountId,
  }) async {
    return null;
  }

  @override
  Future<List<String>> getUsedMethodIds({
    required String accountId,
  }) async {
    return const <String>[];
  }

  @override
  Future<List<String>> getUsedTagIds({
    required String accountId,
  }) async {
    return const <String>[];
  }

  @override
  Future<List<SmokeLogDto>> batchSyncLogs({
    required String accountId,
    required List<SmokeLogDto> logs,
  }) async {
    return logs;
  }

  @override
  Future<int> addTagsToLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    return 0;
  }

  @override
  Future<int> removeTagsFromLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    return 0;
  }
}
