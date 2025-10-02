import 'dart:async';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/data/repositories/smoke_log_repository_isar.dart';
import 'package:ash_trail/data/services/background_sync_service.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockSmokeLogRepositoryIsar extends Mock
    implements SmokeLogRepositoryIsar {}

class MockDio extends Mock implements Dio {}

class MockConnectivity extends Mock implements Connectivity {}

class MockLogger extends Mock implements Logger {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockBackgroundSyncService extends Mock implements BackgroundSyncService {}

final syncProvider = FutureProvider.autoDispose<void>((ref) async {
  final service = ref.watch(backgroundSyncServiceProvider);
  await service.forceSyncNow();
});

void main() {
  late MockSmokeLogRepositoryIsar mockRepository;
  late MockDio mockDio;
  late MockConnectivity mockConnectivity;
  late MockLogger mockLogger;
  late BackgroundSyncService service;

  final smokeLog = SmokeLog(
    id: '1',
    accountId: 'acc1',
    ts: DateTime.now(),
    durationMs: 1000,
    moodScore: 5,
    physicalScore: 5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(Uri.parse('/api/smoke-logs'));
  });

  setUp(() {
    mockRepository = MockSmokeLogRepositoryIsar();
    mockDio = MockDio();
    mockConnectivity = MockConnectivity();
    mockLogger = MockLogger();

    // Mock Dio options
    when(() => mockDio.options).thenReturn(BaseOptions());
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => const Stream.empty());

    service = BackgroundSyncService(
      repository: mockRepository,
      dio: mockDio,
      connectivity: mockConnectivity,
      logger: mockLogger,
    );

    // Suppress logger output during tests
    when(() => mockLogger.d(any())).thenAnswer((_) {});
    when(() => mockLogger.i(any())).thenAnswer((_) {});
    when(() => mockLogger.w(any())).thenAnswer((_) {});
    when(() => mockLogger.e(any(),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'))).thenAnswer((_) {});
  });

  tearDown(() {
    service.dispose();
  });

  group('BackgroundSyncService', () {
    test('initial status is idle', () {
      expect(service.status, SyncStatus.idle);
    });

    test('startPeriodicSync performs initial sync and can be stopped',
        () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => const Right([]));

      service.startPeriodicSync();
      await untilCalled(() => mockRepository.getDirtySmokeLog());

      verify(() => mockLogger.i(any(that: contains('Starting periodic sync'))))
          .called(1);
      verify(() => mockRepository.getDirtySmokeLog()).called(1);

      service.stopPeriodicSync();
      verify(() => mockLogger.i('Stopping periodic sync')).called(1);
    });

    test('forceSyncNow performs a sync', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => const Right([]));

      await service.forceSyncNow();

      verify(() => mockLogger.i('Force sync requested')).called(1);
      verify(() => mockRepository.getDirtySmokeLog()).called(1);
    });

    test('sync pauses when network is lost and resumes when reconnected',
        () async {
      final connectivityController =
          StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => const Right([]));

      // Re-initialize service to attach the new listener
      service = BackgroundSyncService(
        repository: mockRepository,
        dio: mockDio,
        connectivity: mockConnectivity,
        logger: mockLogger,
      );

      // Start with wifi
      service.startPeriodicSync();
      await untilCalled(() => mockRepository.getDirtySmokeLog());

      // Lose connection
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero); // Allow stream to be processed
      expect(service.status, SyncStatus.paused);
      verify(() => mockLogger.w('Network connectivity lost, pausing sync'))
          .called(1);

      // Regain connection
      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(Duration.zero); // Allow stream to be processed
      verify(() => mockLogger.i('Network connectivity restored, resuming sync'))
          .called(1);

      await connectivityController.close();
    });

    test('performSync does nothing if already syncing', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog()).thenAnswer((_) async {
        // This will be called by the first _performSync.
        // The second call should not happen.
        await Future.delayed(const Duration(milliseconds: 50));
        return const Right([]);
      });

      // Don't await the first call
      service.forceSyncNow();
      // This second call should be skipped
      await service.forceSyncNow();

      verify(() => mockLogger.d('Sync already in progress, skipping'))
          .called(1);
      verify(() => mockRepository.getDirtySmokeLog()).called(1);
    });

    test('performSync pauses if no network connectivity', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      await service.forceSyncNow();

      expect(service.status, SyncStatus.paused);
      verify(() => mockLogger.w('No network connectivity, skipping sync'))
          .called(1);
      verifyNever(() => mockRepository.getDirtySmokeLog());
    });

    test('performSync handles failure when getting dirty logs', () async {
      const failure = AppFailure.cache(message: 'DB error');
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => const Left(failure));

      await service.forceSyncNow();

      verify(() => mockLogger
          .e('Failed to get dirty logs: ${failure.displayMessage}')).called(1);
      expect(service.status, SyncStatus.error);
    });

    test('performSync does nothing if no dirty logs', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => const Right([]));

      await service.forceSyncNow();

      verify(() => mockLogger.d('No logs to sync')).called(1);
      verifyNever(() => mockDio.post(any(), data: any(named: 'data')));
      expect(service.status, SyncStatus.idle);
    });

    test('successfully syncs a single dirty log', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => Right([smokeLog]));
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => mockResponse);
      when(() => mockRepository.markAsSynced(smokeLog.id))
          .thenAnswer((_) async => const Right(unit));

      await service.forceSyncNow();

      verify(() => mockDio.post('/api/smoke-logs', data: smokeLog.toJson()))
          .called(1);
      verify(() => mockRepository.markAsSynced(smokeLog.id)).called(1);
      expect(service.status, SyncStatus.idle);
    });

    test('handles sync failure for a single log and retries', () async {
      final dioException = DioException(
          requestOptions: RequestOptions(path: ''), message: 'Network error');
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => Right([smokeLog]));
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenThrow(dioException);
      when(() => mockRepository.markSyncError(smokeLog.id, any()))
          .thenAnswer((_) async => const Right(unit));

      await service.forceSyncNow();

      verify(() => mockDio.post(any(), data: any(named: 'data')))
          .called(3); // 1 initial + 2 retries
      verify(() => mockRepository.markSyncError(smokeLog.id, 'Network error'))
          .called(1);
      expect(service.status, SyncStatus.error);
    });

    test('handles partial sync failure', () async {
      final goodLog = SmokeLog(
          id: 'good',
          accountId: 'acc1',
          ts: DateTime.now(),
          durationMs: 1000,
          moodScore: 5,
          physicalScore: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      final badLog = SmokeLog(
          id: 'bad',
          accountId: 'acc1',
          ts: DateTime.now(),
          durationMs: 2000,
          moodScore: 3,
          physicalScore: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      final mockSuccessResponse = MockResponse<dynamic>();
      when(() => mockSuccessResponse.statusCode).thenReturn(200);
      final dioException = DioException(
          requestOptions: RequestOptions(path: ''), message: 'Network error');

      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);
      when(() => mockRepository.getDirtySmokeLog())
          .thenAnswer((_) async => Right([goodLog, badLog]));

      // Mock good log sync
      when(() => mockDio.post(any(), data: goodLog.toJson()))
          .thenAnswer((_) async => mockSuccessResponse);
      when(() => mockRepository.markAsSynced(goodLog.id))
          .thenAnswer((_) async => const Right(unit));

      // Mock bad log sync
      when(() => mockDio.post(any(), data: badLog.toJson()))
          .thenThrow(dioException);
      when(() => mockRepository.markSyncError(badLog.id, any()))
          .thenAnswer((_) async => const Right(unit));

      await service.forceSyncNow();

      verify(() => mockRepository.markAsSynced(goodLog.id)).called(1);
      verify(() => mockRepository.markSyncError(badLog.id, 'Network error'))
          .called(1);
      expect(service.status, SyncStatus.error);
    });

    test('dispose cancels timers and subscriptions', () {
      final connectivityController =
          StreamController<List<ConnectivityResult>>();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);

      service = BackgroundSyncService(
        repository: mockRepository,
        dio: mockDio,
        connectivity: mockConnectivity,
        logger: mockLogger,
      );
      service.startPeriodicSync();

      service.dispose();

      verify(() => mockLogger.i('Disposing background sync service')).called(1);
      expect(connectivityController.hasListener, isFalse);
    });
  });

  group('syncProvider', () {
    test('executes sync on the service and reports state', () async {
      final mockService = MockBackgroundSyncService();
      when(() => mockService.forceSyncNow()).thenAnswer((_) async {});

      final container = ProviderContainer(
        overrides: [
          backgroundSyncServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final listener = Listener<AsyncValue<void>>();
      container.listen(syncProvider, listener.call, fireImmediately: true);

      // Initial state should be loading
      expect(listener.log.first, const AsyncValue<void>.loading());

      // Wait for the future to complete
      await container.read(syncProvider.future);

      // Final state should be data(null)
      expect(listener.log.last, const AsyncValue<void>.data(null));

      // Verify that sync was called
      verify(() => mockService.forceSyncNow()).called(1);
    });
  });
}

class Listener<T> {
  final List<T> log = [];

  void call(T? previous, T next) {
    log.add(next);
  }
}
