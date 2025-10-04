// Web-only in-memory implementation of SmokeLogLocalDataSource
// Used to avoid Isar/path_provider on web where Isar 3.x is unsupported.

import '../models/smoke_log_dto.dart';
import 'smoke_log_local_datasource.dart';

class SmokeLogLocalDataSourceWeb implements SmokeLogLocalDataSource {
  final Map<String, List<SmokeLogDto>> _store = {};

  @override
  Future<SmokeLogDto> createSmokeLog(SmokeLogDto smokeLog) async {
    final list = _store.putIfAbsent(smokeLog.accountId, () => <SmokeLogDto>[]);
    // Mark pending sync for parity with IO impl; non-persistent on web.
    final saved = smokeLog.copyWith(isPendingSync: true);
    list.insert(0, saved);
    return saved;
  }

  @override
  Future<void> deleteSmokeLog(String smokeLogId) async {
    for (final entry in _store.entries) {
      final idx = entry.value.indexWhere((e) => e.id == smokeLogId);
      if (idx != -1) {
        entry.value.removeAt(idx);
        break;
      }
    }
  }

  @override
  Future<SmokeLogDto?> getLastSmokeLog(String accountId) async {
    final list = _store[accountId];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  Future<List<SmokeLogDto>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    bool includeDeleted = false,
  }) async {
    final list = _store[accountId] ?? const <SmokeLogDto>[];
    final filtered = list
        .where((e) => !e.ts.isBefore(startDate) && !e.ts.isAfter(endDate))
        .toList();
    if (limit != null && filtered.length > limit) {
      return filtered.sublist(0, limit);
    }
    return filtered;
  }

  @override
  Future<SmokeLogDto> updateSmokeLog(SmokeLogDto smokeLog) async {
    final list = _store[smokeLog.accountId] ?? <SmokeLogDto>[];
    final idx = list.indexWhere((e) => e.id == smokeLog.id);
    if (idx == -1) {
      // If not found, treat as create for resilience
      return createSmokeLog(smokeLog);
    }
    final updated = smokeLog.copyWith(
      isPendingSync: true,
      updatedAt: DateTime.now(),
    );
    list[idx] = updated;
    list.sort((a, b) => b.ts.compareTo(a.ts));
    return updated;
  }

  @override
  Future<List<SmokeLogDto>> getPendingSyncLogs(String accountId) async {
    final list = _store[accountId] ?? const <SmokeLogDto>[];
    return list.where((e) => e.isPendingSync == true).toList();
  }

  @override
  Future<void> markAsSynced(String smokeLogId) async {
    for (final entry in _store.entries) {
      final idx = entry.value.indexWhere((e) => e.id == smokeLogId);
      if (idx != -1) {
        final dto = entry.value[idx];
        entry.value[idx] = dto.copyWith(isPendingSync: false);
        break;
      }
    }
  }

  @override
  Future<void> clearAccountLogs(String accountId) async {
    _store.remove(accountId);
  }

  @override
  Future<int> getLogsCount(String accountId) async {
    return (_store[accountId] ?? const <SmokeLogDto>[]).length;
  }
}
