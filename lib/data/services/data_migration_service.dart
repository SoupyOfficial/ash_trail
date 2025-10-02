import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/failures/app_failure.dart';
import '../../domain/models/smoke_log.dart';
import '../repositories/smoke_log_repository_isar.dart';

/// Service for migrating data from SharedPreferences (Phase 1) to Isar (Phase 2)
/// Handles the one-time migration of existing smoke logs and user preferences
class DataMigrationService {
  final SharedPreferences _prefs;
  final SmokeLogRepositoryIsar _isarRepository;
  final Logger _logger;

  static const String _migrationCompleteKey = 'data_migration_completed_v2';
  static const String _smokeLogs = 'smoke_logs_';
  static const String _lastLogKey = 'last_smoke_log_';

  DataMigrationService({
    required SharedPreferences prefs,
    required SmokeLogRepositoryIsar isarRepository,
    required Logger logger,
  })  : _prefs = prefs,
        _isarRepository = isarRepository,
        _logger = logger;

  /// Check if migration has already been completed
  bool get isMigrationCompleted =>
      _prefs.getBool(_migrationCompleteKey) ?? false;

  /// Perform complete data migration from SharedPreferences to Isar
  Future<Either<AppFailure, void>> migrateAllData() async {
    if (isMigrationCompleted) {
      _logger.i('Data migration already completed, skipping');
      return const Right(null);
    }

    try {
      _logger.i('Starting data migration from SharedPreferences to Isar');

      // Get all account IDs from SharedPreferences keys
      final accountIds = _extractAccountIds();

      if (accountIds.isEmpty) {
        _logger.i('No account data found in SharedPreferences');
        await _markMigrationComplete();
        return const Right(null);
      }

      int totalMigrated = 0;
      int totalErrors = 0;

      // Migrate smoke logs for each account
      for (final accountId in accountIds) {
        final result = await _migrateAccountSmokeLog(accountId);

        await result.fold(
          (failure) async {
            _logger.e(
                'Failed to migrate data for account $accountId: ${failure.displayMessage}');
            totalErrors++;
          },
          (migratedCount) async {
            _logger.i('Migrated $migratedCount logs for account $accountId');
            totalMigrated += migratedCount;
          },
        );
      }

      _logger.i(
          'Migration completed: $totalMigrated logs migrated, $totalErrors errors');

      if (totalErrors == 0) {
        await _markMigrationComplete();
        await _cleanupOldData(accountIds);
        return const Right(null);
      } else {
        return Left(AppFailure.cache(
            message:
                'Migration completed with errors: $totalErrors account migrations failed'));
      }
    } catch (e, stackTrace) {
      _logger.e('Unexpected error during migration',
          error: e, stackTrace: stackTrace);
      return Left(AppFailure.unexpected(
        message: 'Migration failed: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Extract all unique account IDs from SharedPreferences keys
  Set<String> _extractAccountIds() {
    final accountIds = <String>{};
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_smokeLogs)) {
        final accountId = key.substring(_smokeLogs.length);
        if (accountId.isNotEmpty) {
          accountIds.add(accountId);
        }
      }
    }

    _logger.d('Found ${accountIds.length} account IDs: $accountIds');
    return accountIds;
  }

  /// Migrate smoke logs for a specific account
  Future<Either<AppFailure, int>> _migrateAccountSmokeLog(
      String accountId) async {
    try {
      final logsKey = _smokeLogs + accountId;
      final logsJson = _prefs.getStringList(logsKey) ?? [];

      if (logsJson.isEmpty) {
        _logger.d('No smoke logs found for account $accountId');
        return const Right(0);
      }

      _logger.i('Migrating ${logsJson.length} logs for account $accountId');

      int migratedCount = 0;
      int errorCount = 0;

      for (final logJsonString in logsJson) {
        try {
          final logJson = jsonDecode(logJsonString) as Map<String, dynamic>;
          final smokeLog = SmokeLog.fromJson(logJson);

          // Save to Isar repository
          final saveResult = await _isarRepository.createSmokeLog(smokeLog);

          await saveResult.fold(
            (failure) async {
              _logger.w(
                  'Failed to save log ${smokeLog.id}: ${failure.displayMessage}');
              errorCount++;
            },
            (savedLog) async {
              migratedCount++;
              _logger.d('Successfully migrated log ${savedLog.id}');
            },
          );
        } catch (e) {
          _logger.w('Failed to parse log from SharedPreferences: $e');
          errorCount++;
        }
      }

      if (errorCount > 0) {
        _logger.w(
            'Migration errors for account $accountId: $errorCount out of ${logsJson.length} logs failed');
      }

      return Right(migratedCount);
    } catch (e) {
      _logger.e('Error migrating account $accountId: $e');
      return Left(AppFailure.cache(
          message: 'Failed to migrate account $accountId: ${e.toString()}'));
    }
  }

  /// Mark migration as completed
  Future<void> _markMigrationComplete() async {
    await _prefs.setBool(_migrationCompleteKey, true);
    _logger.i('Migration marked as completed');
  }

  /// Clean up old SharedPreferences data after successful migration
  Future<void> _cleanupOldData(Set<String> accountIds) async {
    try {
      _logger.i('Cleaning up old SharedPreferences data');

      int removedKeys = 0;

      // Remove smoke logs
      for (final accountId in accountIds) {
        final logsKey = _smokeLogs + accountId;
        final lastLogKey = _lastLogKey + accountId;

        if (_prefs.containsKey(logsKey)) {
          await _prefs.remove(logsKey);
          removedKeys++;
        }

        if (_prefs.containsKey(lastLogKey)) {
          await _prefs.remove(lastLogKey);
          removedKeys++;
        }
      }

      _logger.i('Cleanup completed: $removedKeys keys removed');
    } catch (e) {
      _logger.w('Error during cleanup (non-critical): $e');
      // Don't fail migration for cleanup errors
    }
  }

  /// Verify migration integrity by comparing counts
  Future<Either<AppFailure, MigrationReport>> verifyMigration() async {
    try {
      final accountIds = _extractAccountIds();
      final report = MigrationReport();

      for (final accountId in accountIds) {
        // Count in SharedPreferences
        final logsKey = _smokeLogs + accountId;
        final prefsCount = (_prefs.getStringList(logsKey) ?? []).length;

        // Count in Isar
        final isarCountResult =
            await _isarRepository.getSmokeLogsCount(accountId);

        await isarCountResult.fold(
          (failure) async {
            report.errors.add(
                'Failed to count Isar logs for $accountId: ${failure.displayMessage}');
          },
          (isarCount) async {
            report.accountComparisons[accountId] = AccountComparison(
              prefsCount: prefsCount,
              isarCount: isarCount,
            );

            if (prefsCount == isarCount) {
              report.successfulAccounts++;
            } else {
              report.mismatchAccounts++;
              report.errors.add(
                  'Count mismatch for $accountId: SharedPrefs=$prefsCount, Isar=$isarCount');
            }
          },
        );
      }

      return Right(report);
    } catch (e) {
      return Left(AppFailure.unexpected(
          message: 'Migration verification failed: ${e.toString()}'));
    }
  }

  /// Force reset migration flag (for testing/development)
  Future<void> resetMigrationFlag() async {
    await _prefs.remove(_migrationCompleteKey);
    _logger.w('Migration flag reset - next app start will trigger migration');
  }
}

/// Report of migration verification results
class MigrationReport {
  final Map<String, AccountComparison> accountComparisons = {};
  final List<String> errors = [];
  int successfulAccounts = 0;
  int mismatchAccounts = 0;

  bool get isSuccessful => errors.isEmpty && mismatchAccounts == 0;

  int get totalAccounts => accountComparisons.length;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Migration Report:');
    buffer.writeln('- Total accounts: $totalAccounts');
    buffer.writeln('- Successful: $successfulAccounts');
    buffer.writeln('- Mismatches: $mismatchAccounts');
    buffer.writeln('- Errors: ${errors.length}');

    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('  - $error');
      }
    }

    return buffer.toString();
  }
}

/// Comparison of counts between SharedPreferences and Isar for an account
class AccountComparison {
  final int prefsCount;
  final int isarCount;

  AccountComparison({
    required this.prefsCount,
    required this.isarCount,
  });

  bool get matches => prefsCount == isarCount;
}
