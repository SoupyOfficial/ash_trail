import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_local_datasource.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';
import 'package:ash_trail/features/table_browse_edit/data/datasources/logs_table_datasource_fallback.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';

class _FakeSmokeLogLocalDataSource implements SmokeLogLocalDataSource {
  _FakeSmokeLogLocalDataSource(List<SmokeLogDto> initialLogs) {
    for (final log in initialLogs) {
      _store[log.id] = log;
    }
  }

  final Map<String, SmokeLogDto> _store = {};

  @override
  Future<void> clearAccountLogs(String accountId) async {
    _store.removeWhere((key, value) => value.accountId == accountId);
  }

  @override
  Future<SmokeLogDto> createSmokeLog(SmokeLogDto smokeLog) async {
    _store[smokeLog.id] = smokeLog;
    return smokeLog;
  }

  @override
  Future<void> deleteSmokeLog(String smokeLogId) async {
    _store.remove(smokeLogId);
  }

  @override
  Future<SmokeLogDto?> getLastSmokeLog(String accountId) async {
    final logs = _store.values
        .where((log) => log.accountId == accountId)
        .toList()
      ..sort((a, b) => b.ts.compareTo(a.ts));
    return logs.isEmpty ? null : logs.first;
  }

  @override
  Future<int> getLogsCount(String accountId) async {
    return _store.values.where((log) => log.accountId == accountId).length;
  }

  @override
  Future<List<SmokeLogDto>> getPendingSyncLogs(String accountId) async {
    return const <SmokeLogDto>[];
  }

  @override
  Future<List<SmokeLogDto>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    bool includeDeleted = false,
  }) async {
    final logs = _store.values.where((log) {
      return log.accountId == accountId &&
          !log.isDeleted &&
          !log.ts.isBefore(startDate) &&
          !log.ts.isAfter(endDate);
    }).toList()
      ..sort((a, b) => b.ts.compareTo(a.ts));

    if (limit != null && logs.length > limit) {
      return logs.take(limit).toList();
    }
    return logs;
  }

  @override
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog) async {
    _store[smokeLog.id] = smokeLog;
    return smokeLog;
  }

  @override
  Future<void> markAsSynced(String smokeLogId) async {}
}

SmokeLogDto _buildLog({
  required String id,
  required String accountId,
  required DateTime ts,
  required int durationMs,
  int moodScore = 5,
  int physicalScore = 5,
  String? methodId,
  String? notes,
}) {
  final createdAt = ts.subtract(const Duration(minutes: 5));
  return SmokeLogDto(
    id: id,
    accountId: accountId,
    ts: ts,
    durationMs: durationMs,
    moodScore: moodScore,
    physicalScore: physicalScore,
    methodId: methodId,
    notes: notes,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

void main() {
  group('LogsTableLocalDataSourceFallback', () {
    late LogsTableLocalDataSourceFallback fallback;
    const accountId = 'acct-1';

    setUp(() {
      final logs = <SmokeLogDto>[
        _buildLog(
          id: 'log-1',
          accountId: accountId,
          ts: DateTime.utc(2024, 03, 01, 12),
          durationMs: 180000,
          moodScore: 6,
          physicalScore: 7,
          methodId: 'method-a',
          notes: 'Morning session with citrus flavor',
        ),
        _buildLog(
          id: 'log-2',
          accountId: accountId,
          ts: DateTime.utc(2024, 03, 02, 8),
          durationMs: 240000,
          moodScore: 8,
          physicalScore: 6,
          methodId: 'method-b',
          notes: 'Quick break outdoors',
        ),
        _buildLog(
          id: 'log-3',
          accountId: 'acct-2',
          ts: DateTime.utc(2024, 03, 03, 18),
          durationMs: 120000,
          moodScore: 4,
          physicalScore: 5,
          methodId: 'method-a',
        ),
      ];

      fallback = LogsTableLocalDataSourceFallback(
        smokeLogLocalDataSource: _FakeSmokeLogLocalDataSource(logs),
      );
    });

    test('filters by method and sorts using requested order', () async {
      final result = await fallback.getFilteredSortedLogs(
        accountId: accountId,
        filter: const LogFilter(methodIds: ['method-a']),
        sort: const LogSort(
          field: LogSortField.timestamp,
          order: LogSortOrder.ascending,
        ),
        limit: null,
        offset: null,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'log-1');
    });

    test('applies tag include and exclude filters', () async {
      await fallback.addTagsToLogsBatch(
        accountId: accountId,
        smokeLogIds: const ['log-1', 'log-2'],
        tagIds: const ['t-focus'],
      );
      await fallback.addTagsToLogsBatch(
        accountId: accountId,
        smokeLogIds: const ['log-2'],
        tagIds: const ['t-relax'],
      );

      final includeResult = await fallback.getFilteredSortedLogs(
        accountId: accountId,
        filter: const LogFilter(includeTagIds: ['t-focus']),
        sort: null,
        limit: null,
        offset: null,
      );

      expect(includeResult, hasLength(2));
      expect(includeResult.map((log) => log.id).toSet(), {'log-1', 'log-2'});

      final excludeResult = await fallback.getFilteredSortedLogs(
        accountId: accountId,
        filter: const LogFilter(excludeTagIds: ['t-relax']),
        sort: null,
        limit: null,
        offset: null,
      );

      expect(excludeResult.map((log) => log.id), ['log-1']);
    });

    test('counts logs after filters are applied', () async {
      final count = await fallback.getLogsCount(
        accountId: accountId,
        filter: const LogFilter(minMoodScore: 7),
      );

      expect(count, 1);
    });

    test('removes logs in batch and clears tag assignments', () async {
      await fallback.addTagsToLogsBatch(
        accountId: accountId,
        smokeLogIds: const ['log-1'],
        tagIds: const ['t-cleanup'],
      );

      final deleted = await fallback.deleteSmokeLogsBatch(
        smokeLogIds: const ['log-1'],
        accountId: accountId,
      );

      expect(deleted, 1);

      final tags = await fallback.getUsedTagIds(accountId: accountId);
      expect(tags, isEmpty);
    });
  });
}
