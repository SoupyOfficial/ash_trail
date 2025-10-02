import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/smoke_log_isar.dart';
import '../../core/failures/app_failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IsarService {
  static Isar? _isar;

  static Future<Isar> getInstance() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open([
      SmokeLogIsarSchema,
    ], directory: dir.path);

    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}

final isarProvider = FutureProvider<Isar>((ref) async {
  return await IsarService.getInstance();
});

class IsarSmokeLogService {
  final Isar _isar;

  IsarSmokeLogService(this._isar);

  /// Save a smoke log to Isar
  Future<Either<AppFailure, SmokeLogIsar>> saveSmokeLog(
      SmokeLogIsar smokeLog) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.smokeLogIsars.put(smokeLog);
      });
      return Right(smokeLog);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to save smoke log: $e'));
    }
  }

  /// Get all smoke logs for an account
  Future<Either<AppFailure, List<SmokeLogIsar>>> getSmokeLogsByAccount(
      String accountId) async {
    try {
      final smokeLogs = await _isar.smokeLogIsars
          .where()
          .accountIdEqualTo(accountId)
          .sortByTsDesc()
          .findAll();
      return Right(smokeLogs);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to fetch smoke logs: $e'));
    }
  }

  /// Get smoke log by ID
  Future<Either<AppFailure, SmokeLogIsar?>> getSmokeLogById(
      String logId) async {
    try {
      final smokeLog =
          await _isar.smokeLogIsars.where().logIdEqualTo(logId).findFirst();
      return Right(smokeLog);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to fetch smoke log: $e'));
    }
  }

  /// Delete a smoke log
  Future<Either<AppFailure, bool>> deleteSmokeLog(String logId) async {
    try {
      final result = await _isar.writeTxn(() async {
        final smokeLog =
            await _isar.smokeLogIsars.where().logIdEqualTo(logId).findFirst();

        if (smokeLog != null) {
          return await _isar.smokeLogIsars.delete(smokeLog.id);
        }
        return false;
      });
      return Right(result);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to delete smoke log: $e'));
    }
  }

  /// Get dirty (unsynced) smoke logs
  Future<Either<AppFailure, List<SmokeLogIsar>>> getDirtySmokeLog() async {
    try {
      final smokeLogs =
          await _isar.smokeLogIsars.where().isDirtyEqualTo(true).findAll();
      return Right(smokeLogs);
    } catch (e) {
      return Left(
          AppFailure.cache(message: 'Failed to fetch dirty smoke logs: $e'));
    }
  }

  /// Mark smoke log as synced
  Future<Either<AppFailure, void>> markAsSynced(String logId) async {
    try {
      await _isar.writeTxn(() async {
        final smokeLog =
            await _isar.smokeLogIsars.where().logIdEqualTo(logId).findFirst();

        if (smokeLog != null) {
          final updated = smokeLog.copyWithSyncStatus(
            isDirty: false,
            lastSyncAt: DateTime.now(),
            syncError: null,
          );
          await _isar.smokeLogIsars.put(updated);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to mark as synced: $e'));
    }
  }

  /// Mark smoke log with sync error
  Future<Either<AppFailure, void>> markSyncError(
      String logId, String error) async {
    try {
      await _isar.writeTxn(() async {
        final smokeLog =
            await _isar.smokeLogIsars.where().logIdEqualTo(logId).findFirst();

        if (smokeLog != null) {
          final updated = smokeLog.copyWithSyncStatus(
            syncError: error,
          );
          await _isar.smokeLogIsars.put(updated);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to mark sync error: $e'));
    }
  }

  /// Get smoke logs count for an account
  Future<Either<AppFailure, int>> getSmokeLogsCount(String accountId) async {
    try {
      final count =
          await _isar.smokeLogIsars.where().accountIdEqualTo(accountId).count();
      return Right(count);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to count smoke logs: $e'));
    }
  }

  /// Get smoke logs for date range
  Future<Either<AppFailure, List<SmokeLogIsar>>> getSmokeLogsInDateRange(
    String accountId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final smokeLogs = await _isar.smokeLogIsars
          .where()
          .accountIdEqualTo(accountId)
          .filter()
          .tsBetween(startDate, endDate)
          .sortByTsDesc()
          .findAll();
      return Right(smokeLogs);
    } catch (e) {
      return Left(AppFailure.cache(
          message: 'Failed to fetch smoke logs in date range: $e'));
    }
  }
}

final isarSmokeLogServiceProvider =
    FutureProvider<IsarSmokeLogService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return IsarSmokeLogService(isar);
});
