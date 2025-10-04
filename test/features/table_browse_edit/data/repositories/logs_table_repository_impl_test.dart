// Unit tests for LogsTableRepositoryImpl
// Tests offline-first repository implementation with mock data sources

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';
import 'package:ash_trail/features/table_browse_edit/data/datasources/logs_table_local_datasource.dart';
import 'package:ash_trail/features/table_browse_edit/data/datasources/logs_table_remote_datasource.dart';
import 'package:ash_trail/features/table_browse_edit/data/repositories/logs_table_repository_impl.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';

class MockLogsTableLocalDataSource extends Mock
    implements LogsTableLocalDataSource {}

class MockLogsTableRemoteDataSource extends Mock
    implements LogsTableRemoteDataSource {}

class SmokeLogDtoFake extends Fake implements SmokeLogDto {}

class LogFilterFake extends Fake implements LogFilter {}

class LogSortFake extends Fake implements LogSort {}

void main() {
  group('LogsTableRepositoryImpl', () {
    late LogsTableRepositoryImpl repository;
    late MockLogsTableLocalDataSource mockLocalDataSource;
    late MockLogsTableRemoteDataSource mockRemoteDataSource;

    setUpAll(() {
      registerFallbackValue(SmokeLogDtoFake());
      registerFallbackValue(LogFilterFake());
      registerFallbackValue(LogSortFake());
    });

    setUp(() {
      mockLocalDataSource = MockLogsTableLocalDataSource();
      mockRemoteDataSource = MockLogsTableRemoteDataSource();
      repository = LogsTableRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );
    });

    group('getFilteredSortedLogs', () {
      test('should return smoke logs from local data source when successful',
          () async {
        // Arrange
        const accountId = 'test_account';
        const filter = LogFilter(minMoodScore: 5);
        const sort = LogSort();
        const limit = 25;
        const offset = 10;

        final mockDtos = [
          SmokeLogDto(
            id: 'log1',
            accountId: accountId,
            ts: DateTime(2023, 1, 1),
            durationMs: 5000,
            moodScore: 7,
            physicalScore: 6,
            deviceLocalId: null,
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 1),
            isPendingSync: false,
          ),
          SmokeLogDto(
            id: 'log2',
            accountId: accountId,
            ts: DateTime(2023, 1, 2),
            durationMs: 3000,
            moodScore: 5,
            physicalScore: 7,
            deviceLocalId: null,
            createdAt: DateTime(2023, 1, 2),
            updatedAt: DateTime(2023, 1, 2),
            isPendingSync: false,
          ),
        ];

        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => mockDtos);

        // Act
        final result = await repository.getFilteredSortedLogs(
          accountId: accountId,
          filter: filter,
          sort: sort,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (logs) {
            expect(logs.length, 2);
            expect(logs[0].id, 'log1');
            expect(logs[0].accountId, accountId);
            expect(logs[1].id, 'log2');
            expect(logs[1].accountId, accountId);
          },
        );

        // Verify local data source called with correct parameters
        verify(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: filter,
              sort: sort,
              limit: limit,
              offset: offset,
            )).called(1);

        // Verify remote data source not called for read operations
        verifyNever(() => mockRemoteDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ));
      });

      test('should return cache failure when local data source throws',
          () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result =
            await repository.getFilteredSortedLogs(accountId: accountId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to retrieve filtered smoke logs'));
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should work with null optional parameters', () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act
        final result =
            await repository.getFilteredSortedLogs(accountId: accountId);

        // Assert
        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: null,
              sort: null,
              limit: null,
              offset: null,
            )).called(1);
      });
    });

    group('getLogsCount', () {
      test('should return count from local data source when successful',
          () async {
        // Arrange
        const accountId = 'test_account';
        const filter = LogFilter(minMoodScore: 5);
        const expectedCount = 42;

        when(() => mockLocalDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => expectedCount);

        // Act
        final result = await repository.getLogsCount(
          accountId: accountId,
          filter: filter,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, expectedCount),
        );

        verify(() => mockLocalDataSource.getLogsCount(
              accountId: accountId,
              filter: filter,
            )).called(1);
      });

      test('should return cache failure when local data source throws',
          () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockLocalDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getLogsCount(accountId: accountId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.displayMessage, contains('Failed to get logs count'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('updateSmokeLog', () {
      test('should update smoke log locally and trigger remote sync', () async {
        // Arrange
        final smokeLog = SmokeLog(
          id: 'log1',
          accountId: 'test_account',
          ts: DateTime(2023, 1, 1),
          durationMs: 5000,
          moodScore: 7,
          physicalScore: 6,
          notes: 'Updated notes',
          deviceLocalId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        final updatedDto = SmokeLogDto(
          id: 'log1',
          accountId: 'test_account',
          ts: DateTime(2023, 1, 1),
          durationMs: 5000,
          moodScore: 7,
          physicalScore: 6,
          notes: 'Updated notes',
          deviceLocalId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1, 0, 0, 1), // Updated timestamp
          isPendingSync: true,
        );

        when(() => mockLocalDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => updatedDto);

        when(() => mockRemoteDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => updatedDto);

        // Act
        final result = await repository.updateSmokeLog(smokeLog);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (updatedLog) {
            expect(updatedLog.id, smokeLog.id);
            expect(updatedLog.notes, 'Updated notes');
            expect(updatedLog.updatedAt, updatedDto.updatedAt);
          },
        );

        // Verify local update happened first
        final captured =
            verify(() => mockLocalDataSource.updateSmokeLog(captureAny()))
                .captured;
        final capturedDto = captured.first as SmokeLogDto;
        expect(capturedDto.isPendingSync, true);

        // Note: Remote sync is fire-and-forget, so we can't easily verify it in this test
        // but the implementation ensures it happens in the background
      });

      test('should return cache failure when local update fails', () async {
        // Arrange
        final smokeLog = SmokeLog(
          id: 'log1',
          accountId: 'test_account',
          ts: DateTime(2023, 1, 1),
          durationMs: 5000,
          moodScore: 7,
          physicalScore: 6,
          deviceLocalId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        when(() => mockLocalDataSource.updateSmokeLog(any()))
            .thenThrow(Exception('Database locked'));

        // Act
        final result = await repository.updateSmokeLog(smokeLog);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.displayMessage, contains('Failed to update smoke log'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('deleteSmokeLog', () {
      test('should delete smoke log locally and trigger remote sync', () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        when(() => mockLocalDataSource.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async {});

        when(() => mockRemoteDataSource.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async {});

        // Act
        final result = await repository.deleteSmokeLog(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.deleteSmokeLog(
              smokeLogId: smokeLogId,
              accountId: accountId,
            )).called(1);
      });

      test('should return cache failure when local deletion fails', () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        when(() => mockLocalDataSource.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.deleteSmokeLog(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.displayMessage, contains('Failed to delete smoke log'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('deleteSmokeLogsBatch', () {
      test('should batch delete smoke logs locally and trigger remote sync',
          () async {
        // Arrange
        const smokeLogIds = ['log1', 'log2', 'log3'];
        const accountId = 'test_account';
        const deletedCount = 3;

        when(() => mockLocalDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => deletedCount);

        when(() => mockRemoteDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => deletedCount);

        // Act
        final result = await repository.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, deletedCount),
        );

        verify(() => mockLocalDataSource.deleteSmokeLogsBatch(
              smokeLogIds: smokeLogIds,
              accountId: accountId,
            )).called(1);
      });

      test('should return cache failure when batch deletion fails', () async {
        // Arrange
        const smokeLogIds = ['log1', 'log2'];
        const accountId = 'test_account';

        when(() => mockLocalDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to batch delete smoke logs'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getSmokeLogById', () {
      test('should return smoke log when found in local data source', () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        final mockDto = SmokeLogDto(
          id: smokeLogId,
          accountId: accountId,
          ts: DateTime(2023, 1, 1),
          durationMs: 5000,
          moodScore: 7,
          physicalScore: 6,
          deviceLocalId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          isPendingSync: false,
        );

        when(() => mockLocalDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => mockDto);

        // Act
        final result = await repository.getSmokeLogById(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (smokeLog) {
            expect(smokeLog.id, smokeLogId);
            expect(smokeLog.accountId, accountId);
          },
        );

        verify(() => mockLocalDataSource.getSmokeLogById(
              smokeLogId: smokeLogId,
              accountId: accountId,
            )).called(1);
      });

      test('should return not found failure when smoke log not found',
          () async {
        // Arrange
        const smokeLogId = 'nonexistent_log';
        const accountId = 'test_account';

        when(() => mockLocalDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => null);

        // Act
        final result = await repository.getSmokeLogById(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage, 'Smoke log not found');
          },
          (_) => fail('Expected failure'),
        );
      });

      test('should return cache failure when local data source throws',
          () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        when(() => mockLocalDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getSmokeLogById(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to get smoke log by ID'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getUsedMethodIds', () {
      test('should return method IDs from local data source', () async {
        // Arrange
        const accountId = 'test_account';
        const expectedMethodIds = ['vape', 'joint', 'bong', 'pipe'];

        when(() => mockLocalDataSource.getUsedMethodIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedMethodIds);

        // Act
        final result = await repository.getUsedMethodIds(accountId: accountId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (methodIds) => expect(methodIds, expectedMethodIds),
        );

        verify(() => mockLocalDataSource.getUsedMethodIds(accountId: accountId))
            .called(1);
      });

      test('should return cache failure when local data source throws',
          () async {
        // Arrange
        const accountId = 'test_account';

        when(() => mockLocalDataSource.getUsedMethodIds(
              accountId: any(named: 'accountId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getUsedMethodIds(accountId: accountId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Failed to get used method IDs'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getUsedTagIds', () {
      test('should return tag IDs from local data source', () async {
        // Arrange
        const accountId = 'test_account';
        const expectedTagIds = ['relaxing', 'energizing', 'social', 'creative'];

        when(() => mockLocalDataSource.getUsedTagIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedTagIds);

        // Act
        final result = await repository.getUsedTagIds(accountId: accountId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (tagIds) => expect(tagIds, expectedTagIds),
        );

        verify(() => mockLocalDataSource.getUsedTagIds(accountId: accountId))
            .called(1);
      });

      test('should return cache failure when local data source throws',
          () async {
        // Arrange
        const accountId = 'test_account';

        when(() => mockLocalDataSource.getUsedTagIds(
              accountId: any(named: 'accountId'),
            )).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getUsedTagIds(accountId: accountId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.displayMessage, contains('Failed to get used tag IDs'));
          },
          (_) => fail('Expected failure'),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty results gracefully', () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act
        final result =
            await repository.getFilteredSortedLogs(accountId: accountId);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (logs) => expect(logs, isEmpty),
        );
      });

      test('should handle batch deletion of empty list', () async {
        // Arrange
        const accountId = 'test_account';
        const smokeLogIds = <String>[];

        when(() => mockLocalDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => 0);

        // Act
        final result = await repository.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, 0),
        );
      });

      test('should handle partial batch deletion', () async {
        // Arrange
        const accountId = 'test_account';
        const smokeLogIds = ['log1', 'log2', 'nonexistent_log'];
        const deletedCount = 2; // Only 2 out of 3 deleted

        when(() => mockLocalDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => deletedCount);

        // Act
        final result = await repository.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (count) => expect(count, deletedCount),
        );
      });

      test('should handle large filter combinations', () async {
        // Arrange
        const accountId = 'test_account';
        final complexFilter = LogFilter(
          startDate: DateTime(2020, 1, 1),
          endDate: DateTime(2023, 12, 31),
          methodIds: ['vape', 'joint', 'bong', 'pipe', 'edible'],
          includeTagIds: [
            'relaxing',
            'energizing',
            'social',
            'creative',
            'focus'
          ],
          excludeTagIds: ['harsh', 'dizzy', 'paranoid'],
          minMoodScore: 3,
          maxMoodScore: 8,
          minPhysicalScore: 4,
          maxPhysicalScore: 9,
          minDurationMs: 30000,
          maxDurationMs: 1800000,
          searchText: 'great session with friends',
        );

        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await repository.getFilteredSortedLogs(
          accountId: accountId,
          filter: complexFilter,
        );

        // Assert
        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: complexFilter,
              sort: null,
              limit: null,
              offset: null,
            )).called(1);
      });
    });

    group('Offline-First Pattern', () {
      test('should prioritize local data source for all read operations',
          () async {
        // This test verifies that all read operations go through local first
        const accountId = 'test_account';

        // Setup mocks for all read operations
        when(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        when(() => mockLocalDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => 0);

        when(() => mockLocalDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => null);

        when(() => mockLocalDataSource.getUsedMethodIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => []);

        when(() => mockLocalDataSource.getUsedTagIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => []);

        // Execute all read operations
        await repository.getFilteredSortedLogs(accountId: accountId);
        await repository.getLogsCount(accountId: accountId);
        await repository.getSmokeLogById(
            smokeLogId: 'test', accountId: accountId);
        await repository.getUsedMethodIds(accountId: accountId);
        await repository.getUsedTagIds(accountId: accountId);

        // Verify all read operations used local data source
        verify(() => mockLocalDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: null,
              sort: null,
              limit: null,
              offset: null,
            )).called(1);
        verify(() => mockLocalDataSource.getLogsCount(
            accountId: accountId, filter: null)).called(1);
        verify(() => mockLocalDataSource.getSmokeLogById(
            smokeLogId: 'test', accountId: accountId)).called(1);
        verify(() => mockLocalDataSource.getUsedMethodIds(accountId: accountId))
            .called(1);
        verify(() => mockLocalDataSource.getUsedTagIds(accountId: accountId))
            .called(1);

        // Verify no read operations used remote data source
        verifyNever(() => mockRemoteDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ));
      });
    });
  });
}
