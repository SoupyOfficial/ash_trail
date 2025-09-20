import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_local_datasource.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_remote_datasource.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';
import 'package:ash_trail/features/capture_hit/data/repositories/smoke_log_repository_impl.dart';

// Mock classes
class MockSmokeLogLocalDataSource extends Mock
    implements SmokeLogLocalDataSource {}

class MockSmokeLogRemoteDataSource extends Mock
    implements SmokeLogRemoteDataSource {}

void main() {
  late SmokeLogRepositoryImpl repository;
  late MockSmokeLogLocalDataSource mockLocalDataSource;
  late MockSmokeLogRemoteDataSource mockRemoteDataSource;

  // Test data
  final testDateTime = DateTime.now();
  final testSmokeLog = SmokeLog(
    id: 'test-id',
    accountId: 'test-account',
    ts: testDateTime,
    durationMs: 30000,
    methodId: 'test-method',
    potency: 7,
    moodScore: 8,
    physicalScore: 6,
    notes: 'Test notes',
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  final testSmokeLogDto = SmokeLogDto(
    id: 'test-id',
    accountId: 'test-account',
    ts: testDateTime,
    durationMs: 30000,
    methodId: 'test-method',
    potency: 7,
    moodScore: 8,
    physicalScore: 6,
    notes: 'Test notes',
    createdAt: testDateTime,
    updatedAt: testDateTime,
    isPendingSync: true,
  );

  const testAccountId = 'test-account-id';

  setUp(() {
    mockLocalDataSource = MockSmokeLogLocalDataSource();
    mockRemoteDataSource = MockSmokeLogRemoteDataSource();
    repository = SmokeLogRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );

    // Set up fallback values for mocktail
    registerFallbackValue(testSmokeLogDto);
    registerFallbackValue(<SmokeLogDto>[]);
  });

  group('SmokeLogRepositoryImpl', () {
    group('createSmokeLog', () {
      test('successfully creates smoke log and saves locally', () async {
        // Arrange
        when(() => mockLocalDataSource.createSmokeLog(any()))
            .thenAnswer((_) async => testSmokeLogDto);
        when(() => mockRemoteDataSource.createSmokeLog(any()))
            .thenAnswer((_) async => testSmokeLogDto);
        when(() => mockLocalDataSource.markAsSynced(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.createSmokeLog(testSmokeLog);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLog) => expect(smokeLog.id, equals('test-id')),
        );
        verify(() => mockLocalDataSource.createSmokeLog(any())).called(1);
      });

      test('returns failure when local storage fails', () async {
        // Arrange
        when(() => mockLocalDataSource.createSmokeLog(any()))
            .thenThrow(Exception('Local storage error'));

        // Act
        final result = await repository.createSmokeLog(testSmokeLog);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (smokeLog) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.createSmokeLog(any())).called(1);
      });
    });

    group('getLastSmokeLog', () {
      test('returns smoke log when found locally', () async {
        // Arrange
        when(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => testSmokeLogDto);

        // Act
        final result = await repository.getLastSmokeLog(testAccountId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLog) {
            expect(smokeLog, isNotNull);
            expect(smokeLog!.id, equals('test-id'));
          },
        );
        verify(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .called(1);
      });

      test('returns null when no smoke log found', () async {
        // Arrange
        when(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getLastSmokeLog(testAccountId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLog) => expect(smokeLog, isNull),
        );
        verify(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .called(1);
      });

      test('returns failure when local storage fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .thenThrow(Exception('Local storage error'));

        // Act
        final result = await repository.getLastSmokeLog(testAccountId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (smokeLog) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.getLastSmokeLog(testAccountId))
            .called(1);
      });
    });

    group('deleteSmokeLog', () {
      test('successfully deletes smoke log locally', () async {
        // Arrange
        when(() => mockLocalDataSource.deleteSmokeLog('test-id'))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.deleteSmokeLog('test-id');

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.deleteSmokeLog('test-id')).called(1);
      });

      test('returns failure when local deletion fails', () async {
        // Arrange
        when(() => mockLocalDataSource.deleteSmokeLog('test-id'))
            .thenThrow(Exception('Deletion failed'));

        // Act
        final result = await repository.deleteSmokeLog('test-id');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (value) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.deleteSmokeLog('test-id')).called(1);
      });
    });

    group('getSmokeLogsByDateRange', () {
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 31);
      const limit = 50;

      test('returns smoke logs within date range', () async {
        // Arrange
        final testDtos = [testSmokeLogDto];
        when(() => mockLocalDataSource.getSmokeLogsByDateRange(
              accountId: testAccountId,
              startDate: startDate,
              endDate: endDate,
              limit: limit,
            )).thenAnswer((_) async => testDtos);

        // Act
        final result = await repository.getSmokeLogsByDateRange(
          accountId: testAccountId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLogs) {
            expect(smokeLogs.length, equals(1));
            expect(smokeLogs.first.id, equals('test-id'));
          },
        );
        verify(() => mockLocalDataSource.getSmokeLogsByDateRange(
              accountId: testAccountId,
              startDate: startDate,
              endDate: endDate,
              limit: limit,
            )).called(1);
      });

      test('returns empty list when no logs found', () async {
        // Arrange
        when(() => mockLocalDataSource.getSmokeLogsByDateRange(
              accountId: testAccountId,
              startDate: startDate,
              endDate: endDate,
              limit: limit,
            )).thenAnswer((_) async => <SmokeLogDto>[]);

        // Act
        final result = await repository.getSmokeLogsByDateRange(
          accountId: testAccountId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLogs) => expect(smokeLogs, isEmpty),
        );
      });

      test('returns failure when local storage fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getSmokeLogsByDateRange(
              accountId: testAccountId,
              startDate: startDate,
              endDate: endDate,
              limit: limit,
            )).thenThrow(Exception('Local storage error'));

        // Act
        final result = await repository.getSmokeLogsByDateRange(
          accountId: testAccountId,
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (smokeLogs) => fail('Expected failure but got success'),
        );
      });
    });

    group('updateSmokeLog', () {
      test('successfully updates smoke log locally', () async {
        // Arrange
        final updatedDto = testSmokeLogDto.copyWith(notes: 'Updated notes');
        when(() => mockLocalDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => updatedDto);
        when(() => mockRemoteDataSource.createSmokeLog(any()))
            .thenAnswer((_) async => updatedDto);
        when(() => mockLocalDataSource.markAsSynced(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateSmokeLog(testSmokeLog);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (smokeLog) => expect(smokeLog.id, equals('test-id')),
        );
        verify(() => mockLocalDataSource.updateSmokeLog(any())).called(1);
      });

      test('returns failure when local update fails', () async {
        // Arrange
        when(() => mockLocalDataSource.updateSmokeLog(any()))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateSmokeLog(testSmokeLog);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (smokeLog) => fail('Expected failure but got success'),
        );
        verify(() => mockLocalDataSource.updateSmokeLog(any())).called(1);
      });
    });

    group('syncPendingLogs', () {
      test('successfully syncs pending logs when available', () async {
        // Arrange
        final pendingLogs = [testSmokeLogDto];
        final syncedLogs = [testSmokeLogDto];

        when(() => mockLocalDataSource.getPendingSyncLogs(testAccountId))
            .thenAnswer((_) async => pendingLogs);
        when(() => mockRemoteDataSource.batchSyncLogs(
              accountId: testAccountId,
              logs: pendingLogs,
            )).thenAnswer((_) async => syncedLogs);
        when(() => mockLocalDataSource.markAsSynced(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.syncPendingLogs(testAccountId);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.getPendingSyncLogs(testAccountId))
            .called(1);
        verify(() => mockRemoteDataSource.batchSyncLogs(
              accountId: testAccountId,
              logs: pendingLogs,
            )).called(1);
        verify(() => mockLocalDataSource.markAsSynced('test-id')).called(1);
      });

      test('returns success when no pending logs exist', () async {
        // Arrange
        when(() => mockLocalDataSource.getPendingSyncLogs(testAccountId))
            .thenAnswer((_) async => <SmokeLogDto>[]);

        // Act
        final result = await repository.syncPendingLogs(testAccountId);

        // Assert
        expect(result.isRight(), isTrue);
        verify(() => mockLocalDataSource.getPendingSyncLogs(testAccountId))
            .called(1);
        verifyNever(() => mockRemoteDataSource.batchSyncLogs(
              accountId: any(named: 'accountId'),
              logs: any(named: 'logs'),
            ));
      });

      test('returns failure when sync fails', () async {
        // Arrange
        final pendingLogs = [testSmokeLogDto];

        when(() => mockLocalDataSource.getPendingSyncLogs(testAccountId))
            .thenAnswer((_) async => pendingLogs);
        when(() => mockRemoteDataSource.batchSyncLogs(
              accountId: testAccountId,
              logs: pendingLogs,
            )).thenThrow(Exception('Sync failed'));

        // Act
        final result = await repository.syncPendingLogs(testAccountId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (value) => fail('Expected failure but got success'),
        );
      });
    });

    group('constructor', () {
      test('creates repository with required dependencies', () {
        // Act
        final repo = SmokeLogRepositoryImpl(
          localDataSource: mockLocalDataSource,
          remoteDataSource: mockRemoteDataSource,
        );

        // Assert
        expect(repo, isNotNull);
        expect(repo, isA<SmokeLogRepositoryImpl>());
      });
    });
  });
}
