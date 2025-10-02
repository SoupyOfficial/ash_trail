import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:fpdart/fpdart.dart';

import '../../core/failures/app_failure.dart';
import '../repositories/smoke_log_repository_isar.dart';
import '../services/data_migration_service.dart';
import '../services/background_sync_service.dart';

/// Service for initializing Phase 2 data persistence layer
/// Handles migration from Phase 1, database setup, and background sync initialization
class Phase2InitializationService {
  final DataMigrationService _migrationService;
  final BackgroundSyncService _syncService;
  final Logger _logger;

  bool _isInitialized = false;

  Phase2InitializationService({
    required DataMigrationService migrationService,
    required BackgroundSyncService syncService,
    required Logger logger,
  })  : _migrationService = migrationService,
        _syncService = syncService,
        _logger = logger;

  bool get isInitialized => _isInitialized;

  /// Initialize Phase 2 data persistence layer
  /// This should be called during app startup after basic Isar setup
  Future<Either<AppFailure, void>> initialize() async {
    if (_isInitialized) {
      _logger.d('Phase 2 already initialized');
      return const Right(null);
    }

    try {
      _logger.i('Initializing Phase 2 data persistence layer');

      // Step 1: Perform data migration if needed
      if (!_migrationService.isMigrationCompleted) {
        _logger.i('Starting data migration from SharedPreferences to Isar');

        final migrationResult = await _migrationService.migrateAllData();

        await migrationResult.fold(
          (failure) async {
            _logger.e('Migration failed: ${failure.displayMessage}');
            return Left(failure);
          },
          (_) async {
            _logger.i('Data migration completed successfully');

            // Verify migration integrity
            final verifyResult = await _migrationService.verifyMigration();

            return await verifyResult.fold(
              (failure) async {
                _logger.e(
                    'Migration verification failed: ${failure.displayMessage}');
                return Left(failure);
              },
              (report) async {
                _logger.i(
                    'Migration verification completed: ${report.toString()}');

                if (!report.isSuccessful) {
                  _logger.w(
                      'Migration verification found issues, but continuing...');
                }

                return const Right(null);
              },
            );
          },
        );

        // Return early if migration failed
        if (migrationResult.isLeft()) {
          return migrationResult;
        }
      } else {
        _logger.i('Data migration already completed');
      }

      // Step 2: Initialize background sync service
      _logger.i('Starting background sync service');
      _syncService.startPeriodicSync();

      // Step 3: Mark as initialized
      _isInitialized = true;
      _logger.i('Phase 2 initialization completed successfully');

      return const Right(null);
    } catch (e, stackTrace) {
      _logger.e('Phase 2 initialization failed',
          error: e, stackTrace: stackTrace);
      return Left(AppFailure.unexpected(
        message: 'Phase 2 initialization failed: ${e.toString()}',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// Shutdown Phase 2 services gracefully
  Future<void> shutdown() async {
    if (!_isInitialized) return;

    try {
      _logger.i('Shutting down Phase 2 services');

      // Stop background sync
      _syncService.stopPeriodicSync();

      _isInitialized = false;
      _logger.i('Phase 2 shutdown completed');
    } catch (e) {
      _logger.e('Error during Phase 2 shutdown: $e');
    }
  }

  /// Force immediate sync (for testing or manual trigger)
  Future<void> forceSyncNow() async {
    if (!_isInitialized) {
      _logger.w('Cannot force sync - Phase 2 not initialized');
      return;
    }

    await _syncService.forceSyncNow();
  }

  /// Get migration status for debugging
  Future<Either<AppFailure, MigrationReport>> getMigrationReport() async {
    return await _migrationService.verifyMigration();
  }

  /// Reset migration for development/testing
  Future<void> resetMigrationForTesting() async {
    if (_isInitialized) {
      _logger
          .w('Resetting migration while initialized - this may cause issues');
    }

    await _migrationService.resetMigrationFlag();
    _logger
        .w('Migration flag reset - next initialization will trigger migration');
  }
}

// Provider for Phase 2 initialization service
final phase2InitializationServiceProvider =
    FutureProvider<Phase2InitializationService>((ref) async {
  final logger = Logger();

  // Get dependencies
  final prefs = await SharedPreferences.getInstance();
  final isarRepository = await ref.watch(smokeLogRepositoryIsarProvider.future);
  final syncService = ref.watch(backgroundSyncServiceProvider);

  // Create migration service
  final migrationService = DataMigrationService(
    prefs: prefs,
    isarRepository: isarRepository,
    logger: logger,
  );

  // Create and return initialization service
  final initService = Phase2InitializationService(
    migrationService: migrationService,
    syncService: syncService,
    logger: logger,
  );

  // Auto-dispose cleanup
  ref.onDispose(() {
    initService.shutdown();
  });

  return initService;
});

// Provider for initialization status
final phase2InitializationStatusProvider = FutureProvider<bool>((ref) async {
  final service = await ref.watch(phase2InitializationServiceProvider.future);

  // Trigger initialization
  final result = await service.initialize();

  return result.fold(
    (failure) {
      // Log error but don't fail the provider completely
      // This allows the app to continue running with degraded functionality
      final logger = Logger();
      logger.e('Phase 2 initialization failed: ${failure.displayMessage}');
      return false;
    },
    (_) => true,
  );
});

// Helper provider to ensure Phase 2 is initialized before using other providers
final ensurePhase2InitializedProvider = FutureProvider<void>((ref) async {
  final isInitialized =
      await ref.watch(phase2InitializationStatusProvider.future);

  if (!isInitialized) {
    throw StateError(
        'Phase 2 initialization failed - some features may not work correctly');
  }
});
