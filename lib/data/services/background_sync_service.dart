import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import '../../core/failures/app_failure.dart';
import '../../domain/models/smoke_log.dart';
import '../repositories/smoke_log_repository_isar.dart';

enum SyncStatus { idle, syncing, error, paused }

class BackgroundSyncService {
  final SmokeLogRepositoryIsar _repository;
  final Dio _dio;
  final Connectivity _connectivity;
  final Logger _logger;

  // Sync state management
  SyncStatus _status = SyncStatus.idle;
  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Exponential backoff parameters
  int _currentBackoffMs = 1000; // Start with 1 second
  static const int _maxBackoffMs = 300000; // Max 5 minutes
  static const double _backoffMultiplier = 2.0;
  static const int _jitterRangeMs = 1000;

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetries = 3;
  static const Duration _requestTimeout = Duration(seconds: 30);

  BackgroundSyncService({
    required SmokeLogRepositoryIsar repository,
    required Dio dio,
    required Connectivity connectivity,
    required Logger logger,
  })  : _repository = repository,
        _dio = dio,
        _connectivity = connectivity,
        _logger = logger {
    _configureHttpClient();
    _setupConnectivityListener();
  }

  SyncStatus get status => _status;

  /// Configure HTTP client with timeouts and interceptors
  void _configureHttpClient() {
    _dio.options = BaseOptions(
      connectTimeout: _requestTimeout,
      receiveTimeout: _requestTimeout,
      sendTimeout: _requestTimeout,
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
      logPrint: (object) => _logger.d('Dio: $object'),
    ));
  }

  /// Setup connectivity monitoring
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet);

        if (isConnected && _status == SyncStatus.paused) {
          _logger.i('Network connectivity restored, resuming sync');
          startPeriodicSync();
        } else if (!isConnected && _status != SyncStatus.paused) {
          _logger.w('Network connectivity lost, pausing sync');
          pauseSync();
        }
      },
      onError: (error) => _logger.e('Connectivity monitoring error: $error'),
    );
  }

  /// Start periodic background sync
  void startPeriodicSync() {
    if (_syncTimer?.isActive ?? false) return;

    _logger.i(
        'Starting periodic sync with ${_syncInterval.inMinutes} minute interval');
    _status = SyncStatus.idle;

    // Initial sync
    _performSync();

    // Schedule periodic syncs
    _syncTimer = Timer.periodic(_syncInterval, (_) => _performSync());
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _logger.i('Stopping periodic sync');
    _syncTimer?.cancel();
    _syncTimer = null;
    _status = SyncStatus.idle;
  }

  /// Pause sync due to connectivity issues
  void pauseSync() {
    _logger.w('Pausing sync due to connectivity issues');
    _syncTimer?.cancel();
    _syncTimer = null;
    _status = SyncStatus.paused;
  }

  /// Force immediate sync attempt
  Future<void> forceSyncNow() async {
    _logger.i('Force sync requested');
    await _performSync();
  }

  /// Perform sync operation with error handling and backoff
  Future<void> _performSync() async {
    if (_status == SyncStatus.syncing) {
      _logger.d('Sync already in progress, skipping');
      return;
    }

    try {
      _status = SyncStatus.syncing;
      _logger.d('Starting sync operation');

      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = connectivityResult.any((result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);

      if (!isConnected) {
        _logger.w('No network connectivity, skipping sync');
        pauseSync();
        return;
      }

      // Get dirty (unsynced) logs
      final dirtyLogsResult = await _repository.getDirtySmokeLog();

      await dirtyLogsResult.fold(
        (failure) async {
          _logger.e('Failed to get dirty logs: ${failure.displayMessage}');
          _handleSyncError(failure);
        },
        (dirtyLogs) async {
          if (dirtyLogs.isEmpty) {
            _logger.d('No logs to sync');
            _resetBackoff();
            _status = SyncStatus.idle;
            return;
          }

          _logger.i('Found ${dirtyLogs.length} logs to sync');

          // Sync each log with retry logic
          int syncedCount = 0;
          int errorCount = 0;

          for (final log in dirtyLogs) {
            final success = await _syncSingleLog(log);
            if (success) {
              syncedCount++;
            } else {
              errorCount++;
            }
          }

          _logger.i('Sync completed: $syncedCount synced, $errorCount errors');

          if (errorCount == 0) {
            _resetBackoff();
            _status = SyncStatus.idle;
          } else {
            _handleSyncError(
                const AppFailure.network(message: 'Partial sync failure'));
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Unexpected sync error: $e', error: e, stackTrace: stackTrace);
      _handleSyncError(AppFailure.unexpected(
          message: e.toString(), cause: e, stackTrace: stackTrace));
    }
  }

  /// Sync a single log with retry logic
  Future<bool> _syncSingleLog(SmokeLog log) async {
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        _logger.d('Syncing log ${log.id} (attempt $attempt)');

        // TODO: Replace with actual Firestore sync
        // This is a placeholder for the remote sync call
        final response = await _dio.post(
          '/api/smoke-logs', // Placeholder endpoint
          data: log.toJson(),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _logger.d('Successfully synced log ${log.id}');
          await _repository.markAsSynced(log.id);
          return true;
        } else {
          _logger
              .w('Sync failed for log ${log.id}: HTTP ${response.statusCode}');
        }
      } on DioException catch (e) {
        _logger.w(
            'Network error syncing log ${log.id} (attempt $attempt): ${e.message}');

        // Mark sync error on final attempt
        if (attempt == _maxRetries) {
          await _repository.markSyncError(log.id, e.message ?? 'Network error');
        }
      } catch (e) {
        _logger.e('Unexpected error syncing log ${log.id}: $e');

        // Mark sync error on final attempt
        if (attempt == _maxRetries) {
          await _repository.markSyncError(log.id, e.toString());
        }
      }

      // Wait before retry (except on last attempt)
      if (attempt < _maxRetries) {
        final delay = Duration(milliseconds: 1000 * attempt);
        await Future.delayed(delay);
      }
    }

    return false;
  }

  /// Handle sync errors with exponential backoff
  void _handleSyncError(AppFailure failure) {
    _logger.w('Sync error: ${failure.displayMessage}');
    _status = SyncStatus.error;

    // Apply exponential backoff
    _currentBackoffMs =
        min((_currentBackoffMs * _backoffMultiplier).round(), _maxBackoffMs);

    // Add jitter to prevent thundering herd
    final jitter = Random().nextInt(_jitterRangeMs);
    final delayMs = _currentBackoffMs + jitter;

    _logger.i('Scheduling next sync attempt in ${delayMs}ms');

    // Schedule retry with backoff
    Timer(Duration(milliseconds: delayMs), () {
      if (_status == SyncStatus.error) {
        _performSync();
      }
    });
  }

  /// Reset backoff to initial value after successful sync
  void _resetBackoff() {
    _currentBackoffMs = 1000;
    _logger.d('Backoff reset to initial value');
  }

  /// Clean up resources
  void dispose() {
    _logger.i('Disposing background sync service');
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _status = SyncStatus.idle;
  }
}

// Provider for background sync service
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final repository = ref.watch(smokeLogRepositoryIsarProvider).asData?.value;

  if (repository == null) {
    throw StateError('SmokeLogRepositoryIsar not available');
  }

  final dio = Dio();
  final connectivity = Connectivity();
  final logger = Logger();

  final service = BackgroundSyncService(
    repository: repository,
    dio: dio,
    connectivity: connectivity,
    logger: logger,
  );

  // Auto-dispose cleanup
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// Provider for sync status monitoring
final syncStatusProvider =
    StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final service = ref.watch(backgroundSyncServiceProvider);
  return SyncStatusNotifier(service);
});

class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final BackgroundSyncService _service;
  Timer? _statusTimer;

  SyncStatusNotifier(this._service) : super(SyncStatus.idle) {
    // Poll status every few seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      state = _service.status;
    });
  }

  void startSync() => _service.startPeriodicSync();
  void stopSync() => _service.stopPeriodicSync();
  void forceSync() => _service.forceSyncNow();

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
