import 'package:fpdart/fpdart.dart';
import '../../core/failures/app_failure.dart';
import '../../domain/models/smoke_log.dart';
import '../../features/capture_hit/domain/repositories/smoke_log_repository.dart';

/// In-memory fallback implementation used when persistent storage
/// (Isar/path_provider) fails to initialize on a given platform.
/// This prevents UX dead-ends (e.g. recording button always failing) while
/// clearly segregating data that is ephemeral for the session only.
class SmokeLogRepositoryMemory implements SmokeLogRepository {
  final _store = <String, List<SmokeLog>>{}; // accountId -> logs (newest first)

  void clear() => _store.clear();

  @override
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog) async {
    final list = _store.putIfAbsent(smokeLog.accountId, () => <SmokeLog>[]);
    list.insert(0, smokeLog); // keep newest at index 0
    return Right(smokeLog);
  }

  @override
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId) async {
    for (final list in _store.values) {
      final idx = list.indexWhere((l) => l.id == smokeLogId);
      if (idx != -1) {
        list.removeAt(idx);
        break;
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(
      String accountId) async {
    final list = _store[accountId];
    return Right(list == null || list.isEmpty ? null : list.first);
  }

  @override
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    final list = _store[accountId] ?? const <SmokeLog>[];
    final filtered = list
        .where((l) => !l.ts.isBefore(startDate) && !l.ts.isAfter(endDate))
        .toList();
    if (limit != null && filtered.length > limit) {
      return Right(filtered.sublist(0, limit));
    }
    return Right(filtered);
  }

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    final list = _store[smokeLog.accountId];
    if (list == null) {
      return const Left(AppFailure.cache(message: 'Log not found for update'));
    }
    final idx = list.indexWhere((l) => l.id == smokeLog.id);
    if (idx == -1) {
      return const Left(AppFailure.cache(message: 'Log not found for update'));
    }
    list[idx] = smokeLog.copyWith(updatedAt: DateTime.now());
    // Keep ordering (newest first) – move if timestamp changed significantly.
    list.sort((a, b) => b.ts.compareTo(a.ts));
    return Right(list[idx]);
  }
}

/// Simple diagnostic helper – allows UI/telemetry to know persistence tier.
enum SmokeLogPersistenceTier { isar, memory }
