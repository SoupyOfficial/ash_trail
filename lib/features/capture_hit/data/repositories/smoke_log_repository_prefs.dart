// Phase 1 concrete smoke log repository using SharedPreferences for local storage.
// Provides basic data persistence until Isar database implementation in Phase 2.

import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../domain/repositories/smoke_log_repository.dart';

class SmokeLogRepositoryPrefs implements SmokeLogRepository {
  const SmokeLogRepositoryPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyPrefix = 'smoke_logs_';
  static const String _accountLogsPrefix = 'account_logs_';

  @override
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog) async {
    try {
      // Save individual log
      final logKey = '$_keyPrefix${smokeLog.id}';
      final logJson = jsonEncode(smokeLog.toJson());
      await _prefs.setString(logKey, logJson);

      // Update account's log list
      final accountKey = '$_accountLogsPrefix${smokeLog.accountId}';
      final existingIds = _prefs.getStringList(accountKey) ?? <String>[];
      if (!existingIds.contains(smokeLog.id)) {
        existingIds.add(smokeLog.id);
        // Keep newest logs first by sorting by timestamp descending
        final allLogs = await Future.wait(
          existingIds.map((id) => _getLogById(id)).toList(),
        );
        final validLogs = allLogs.whereType<SmokeLog>().toList();
        validLogs.sort((a, b) => b.ts.compareTo(a.ts));
        final sortedIds = validLogs.map((log) => log.id).toList();
        await _prefs.setStringList(accountKey, sortedIds);
      }

      return Right(smokeLog);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to save smoke log: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(
      String accountId) async {
    try {
      final accountKey = '$_accountLogsPrefix$accountId';
      final logIds = _prefs.getStringList(accountKey) ?? <String>[];

      if (logIds.isEmpty) return const Right(null);

      // Get the first (most recent) log
      final mostRecentLog = await _getLogById(logIds.first);
      return Right(mostRecentLog);
    } catch (e) {
      return Left(
          AppFailure.cache(message: 'Failed to fetch last smoke log: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId) async {
    try {
      final log = await _getLogById(smokeLogId);
      if (log == null) {
        return Left(AppFailure.notFound(
            message: 'Smoke log not found', resourceId: smokeLogId));
      }

      // Remove from storage
      final logKey = '$_keyPrefix$smokeLogId';
      await _prefs.remove(logKey);

      // Update account's log list
      final accountKey = '$_accountLogsPrefix${log.accountId}';
      final logIds = _prefs.getStringList(accountKey) ?? <String>[];
      logIds.remove(smokeLogId);
      await _prefs.setStringList(accountKey, logIds);

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to delete smoke log: $e'));
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
      final accountKey = '$_accountLogsPrefix$accountId';
      final logIds = _prefs.getStringList(accountKey) ?? <String>[];

      final logs = <SmokeLog>[];
      for (final id in logIds) {
        final log = await _getLogById(id);
        if (log != null) {
          // Apply date range filter
          if (log.ts.isAfter(startDate) && log.ts.isBefore(endDate)) {
            logs.add(log);

            // Apply limit
            if (limit != null && logs.length >= limit) break;
          }
        }
      }

      return Right(logs);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to fetch smoke logs: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    try {
      // Check if log exists
      final existingLog = await _getLogById(smokeLog.id);
      if (existingLog == null) {
        return Left(AppFailure.notFound(
            message: 'Smoke log not found', resourceId: smokeLog.id));
      }

      // Update the log
      final logKey = '$_keyPrefix${smokeLog.id}';
      final logJson = jsonEncode(smokeLog.toJson());
      await _prefs.setString(logKey, logJson);

      return Right(smokeLog);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to update smoke log: $e'));
    }
  }

  Future<SmokeLog?> _getLogById(String id) async {
    try {
      final logKey = '$_keyPrefix$id';
      final logJson = _prefs.getString(logKey);
      if (logJson == null) return null;

      final logMap = jsonDecode(logJson) as Map<String, dynamic>;
      return SmokeLog.fromJson(logMap);
    } catch (e) {
      return null;
    }
  }
}
