import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../models/smoke_log_isar.dart';
import '../../core/failures/app_failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service wrapper for obtaining and caching the singleton Isar instance.
///
/// Adds resilience around platform plugin availability so that—during tests
/// or in edge cases where the `path_provider` plugin has not yet been
/// registered—we fall back to a safe writable directory instead of throwing
/// a [MissingPluginException]. This prevents the recording flow from
/// surfacing a cryptic "Recording failed" state caused purely by early
/// initialization order.
class IsarService {
  static Isar? _isar;
  static Future<Isar>? _opening; // Prevent concurrent opens.

  /// Directory resolver indirection (overridable in tests).
  static Future<Directory> Function() directoryResolver =
      () => getApplicationDocumentsDirectory();

  /// Obtain the singleton Isar instance (opening it if necessary).
  static Future<Isar> getInstance() async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    if (_opening != null) return _opening!; // Another caller is opening.

    _opening = _openInternal();
    try {
      _isar = await _opening!;
      return _isar!;
    } finally {
      _opening = null; // Clear latch even on failure.
    }
  }

  static Future<Isar> _openInternal() async {
    // Web: Isar uses IndexedDB; directory parameter must be omitted and
    // dart:io directory APIs are unsupported (would yield `_Namespace`).
    if (kIsWeb) {
      // Isar 3.x does not support web yet; surface a controlled error so
      // repository/provider layers can switch to the in-memory fallback.
      throw UnsupportedError('Isar 3.x has no web support');
    }

    Directory targetDir;
    try {
      targetDir = await directoryResolver();
    } on MissingPluginException catch (_) {
      targetDir = Directory.current; // Plugin not yet registered.
    } on UnsupportedError catch (_) {
      // Some desktop/web stubs throw UnsupportedError instead.
      targetDir = Directory.current;
    } catch (_) {
      targetDir = Directory.systemTemp.createTempSync('ash_trail_isar_');
    }

    try {
      return await Isar.open([
        SmokeLogIsarSchema,
      ], directory: targetDir.path);
    } on UnsupportedError catch (e) {
      // Some desktop environments (or misconfigured sandbox entitlements) can
      // surface an `_Namespace` UnsupportedError when resolving the documents
      // directory. Retry once with a temp directory so the user can still log.
      if (e.toString().contains('_Namespace')) {
        final fallback = Directory.systemTemp.createTempSync('ash_trail_isar_');
        return Isar.open([
          SmokeLogIsarSchema,
        ], directory: fallback.path);
      }
      rethrow;
    }
  }

  /// Close and dispose of the cached instance (useful for tests / hot restart).
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
