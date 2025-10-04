// Unit tests for LogsTableLocalDataSource interface
// Tests the local data source contract and validation

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';
import 'package:ash_trail/features/table_browse_edit/data/datasources/logs_table_local_datasource.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';

/// Mock implementation to verify interface contract
class MockLogsTableLocalDataSource extends Mock
    implements LogsTableLocalDataSource {}

class SmokeLogDtoFake extends Fake implements SmokeLogDto {}

class LogFilterFake extends Fake implements LogFilter {}

class LogSortFake extends Fake implements LogSort {}

void main() {
  group('LogsTableLocalDataSource Interface Contract', () {
    late MockLogsTableLocalDataSource mockDataSource;

    setUpAll(() {
      registerFallbackValue(SmokeLogDtoFake());
      registerFallbackValue(LogFilterFake());
      registerFallbackValue(LogSortFake());
    });

    setUp(() {
      mockDataSource = MockLogsTableLocalDataSource();
    });

    group('getFilteredSortedLogs', () {
      test('should accept all required and optional parameters', () async {
        // Arrange
        const accountId = 'test_account';
        const filter = LogFilter(minMoodScore: 5);
        const sort = LogSort();
        const limit = 25;
        const offset = 10;

        final expectedResult = <SmokeLogDto>[
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
        ];

        when(() => mockDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await mockDataSource.getFilteredSortedLogs(
          accountId: accountId,
          filter: filter,
          sort: sort,
          limit: limit,
          offset: offset,
        );

        // Assert
        expect(result, equals(expectedResult));
        verify(() => mockDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: filter,
              sort: sort,
              limit: limit,
              offset: offset,
            )).called(1);
      });

      test('should handle null optional parameters', () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await mockDataSource.getFilteredSortedLogs(
          accountId: accountId,
        );

        // Assert
        expect(result, isA<List<SmokeLogDto>>());
        verify(() => mockDataSource.getFilteredSortedLogs(
              accountId: accountId,
              filter: null,
              sort: null,
              limit: null,
              offset: null,
            )).called(1);
      });

      test('should return Future<List<SmokeLogDto>>', () async {
        // Arrange
        when(() => mockDataSource.getFilteredSortedLogs(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
              sort: any(named: 'sort'),
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          mockDataSource.getFilteredSortedLogs(accountId: 'test'),
          isA<Future<List<SmokeLogDto>>>(),
        );
      });
    });

    group('getLogsCount', () {
      test('should accept required accountId and optional filter', () async {
        // Arrange
        const accountId = 'test_account';
        const filter = LogFilter(minMoodScore: 5);
        const expectedCount = 42;

        when(() => mockDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => expectedCount);

        // Act
        final result = await mockDataSource.getLogsCount(
          accountId: accountId,
          filter: filter,
        );

        // Assert
        expect(result, equals(expectedCount));
        verify(() => mockDataSource.getLogsCount(
              accountId: accountId,
              filter: filter,
            )).called(1);
      });

      test('should handle null filter parameter', () async {
        // Arrange
        const accountId = 'test_account';
        when(() => mockDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => 0);

        // Act
        final result = await mockDataSource.getLogsCount(
          accountId: accountId,
        );

        // Assert
        expect(result, isA<int>());
        verify(() => mockDataSource.getLogsCount(
              accountId: accountId,
              filter: null,
            )).called(1);
      });

      test('should return Future<int>', () async {
        // Arrange
        when(() => mockDataSource.getLogsCount(
              accountId: any(named: 'accountId'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => 0);

        // Act & Assert
        expect(
          mockDataSource.getLogsCount(accountId: 'test'),
          isA<Future<int>>(),
        );
      });
    });

    group('updateSmokeLog', () {
      test('should accept SmokeLogDto parameter and return updated DTO',
          () async {
        // Arrange
        final inputDto = SmokeLogDto(
          id: 'log1',
          accountId: 'test_account',
          ts: DateTime(2023, 1, 1),
          durationMs: 5000,
          moodScore: 7,
          physicalScore: 6,
          deviceLocalId: null,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
          isPendingSync: false,
        );

        final updatedDto = inputDto.copyWith(
          updatedAt: DateTime(2023, 1, 1, 0, 0, 1),
          isPendingSync: true,
        );

        when(() => mockDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => updatedDto);

        // Act
        final result = await mockDataSource.updateSmokeLog(inputDto);

        // Assert
        expect(result, equals(updatedDto));
        verify(() => mockDataSource.updateSmokeLog(inputDto)).called(1);
      });

      test('should return Future<SmokeLogDto>', () async {
        // Arrange
        final dto = SmokeLogDtoFake();
        when(() => mockDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => dto);

        // Act & Assert
        expect(
          mockDataSource.updateSmokeLog(dto),
          isA<Future<SmokeLogDto>>(),
        );
      });
    });

    group('deleteSmokeLog', () {
      test('should accept required parameters', () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        when(() => mockDataSource.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async {});

        // Act
        await mockDataSource.deleteSmokeLog(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        verify(() => mockDataSource.deleteSmokeLog(
              smokeLogId: smokeLogId,
              accountId: accountId,
            )).called(1);
      });

      test('should return Future<void>', () async {
        // Arrange
        when(() => mockDataSource.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async {});

        // Act & Assert
        expect(
          mockDataSource.deleteSmokeLog(
            smokeLogId: 'test',
            accountId: 'test',
          ),
          isA<Future<void>>(),
        );
      });
    });

    group('deleteSmokeLogsBatch', () {
      test('should accept required parameters and return deleted count',
          () async {
        // Arrange
        const smokeLogIds = ['log1', 'log2', 'log3'];
        const accountId = 'test_account';
        const expectedDeletedCount = 3;

        when(() => mockDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedDeletedCount);

        // Act
        final result = await mockDataSource.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );

        // Assert
        expect(result, equals(expectedDeletedCount));
        verify(() => mockDataSource.deleteSmokeLogsBatch(
              smokeLogIds: smokeLogIds,
              accountId: accountId,
            )).called(1);
      });

      test('should return Future<int>', () async {
        // Arrange
        when(() => mockDataSource.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => 0);

        // Act & Assert
        expect(
          mockDataSource.deleteSmokeLogsBatch(
            smokeLogIds: [],
            accountId: 'test',
          ),
          isA<Future<int>>(),
        );
      });
    });

    group('getSmokeLogById', () {
      test('should accept required parameters and return nullable DTO',
          () async {
        // Arrange
        const smokeLogId = 'log1';
        const accountId = 'test_account';

        final expectedDto = SmokeLogDto(
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

        when(() => mockDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedDto);

        // Act
        final result = await mockDataSource.getSmokeLogById(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );

        // Assert
        expect(result, equals(expectedDto));
        verify(() => mockDataSource.getSmokeLogById(
              smokeLogId: smokeLogId,
              accountId: accountId,
            )).called(1);
      });

      test('should handle null return for not found', () async {
        // Arrange
        when(() => mockDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => null);

        // Act
        final result = await mockDataSource.getSmokeLogById(
          smokeLogId: 'nonexistent',
          accountId: 'test',
        );

        // Assert
        expect(result, isNull);
      });

      test('should return Future<SmokeLogDto?>', () async {
        // Arrange
        when(() => mockDataSource.getSmokeLogById(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          mockDataSource.getSmokeLogById(
            smokeLogId: 'test',
            accountId: 'test',
          ),
          isA<Future<SmokeLogDto?>>(),
        );
      });
    });

    group('getUsedMethodIds', () {
      test('should accept required accountId and return string list', () async {
        // Arrange
        const accountId = 'test_account';
        const expectedMethodIds = ['vape', 'joint', 'bong', 'pipe'];

        when(() => mockDataSource.getUsedMethodIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedMethodIds);

        // Act
        final result = await mockDataSource.getUsedMethodIds(
          accountId: accountId,
        );

        // Assert
        expect(result, equals(expectedMethodIds));
        verify(() => mockDataSource.getUsedMethodIds(accountId: accountId))
            .called(1);
      });

      test('should return Future<List<String>>', () async {
        // Arrange
        when(() => mockDataSource.getUsedMethodIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          mockDataSource.getUsedMethodIds(accountId: 'test'),
          isA<Future<List<String>>>(),
        );
      });
    });

    group('getUsedTagIds', () {
      test('should accept required accountId and return string list', () async {
        // Arrange
        const accountId = 'test_account';
        const expectedTagIds = ['relaxing', 'energizing', 'social', 'creative'];

        when(() => mockDataSource.getUsedTagIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => expectedTagIds);

        // Act
        final result = await mockDataSource.getUsedTagIds(
          accountId: accountId,
        );

        // Assert
        expect(result, equals(expectedTagIds));
        verify(() => mockDataSource.getUsedTagIds(accountId: accountId))
            .called(1);
      });

      test('should return Future<List<String>>', () async {
        // Arrange
        when(() => mockDataSource.getUsedTagIds(
              accountId: any(named: 'accountId'),
            )).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          mockDataSource.getUsedTagIds(accountId: 'test'),
          isA<Future<List<String>>>(),
        );
      });
    });

    group('Contract Validation', () {
      test('should implement all required methods', () {
        // This test verifies that our mock implements all interface methods
        expect(mockDataSource, isA<LogsTableLocalDataSource>());

        // Verify method signatures exist by attempting to stub them
        when(() => mockDataSource.getFilteredSortedLogs(
              accountId: 'test',
            )).thenAnswer((_) async => []);

        when(() => mockDataSource.getLogsCount(
              accountId: 'test',
            )).thenAnswer((_) async => 0);

        when(() => mockDataSource.updateSmokeLog(any()))
            .thenAnswer((_) async => SmokeLogDtoFake());

        when(() => mockDataSource.deleteSmokeLog(
              smokeLogId: 'test',
              accountId: 'test',
            )).thenAnswer((_) async {});

        when(() => mockDataSource.deleteSmokeLogsBatch(
              smokeLogIds: ['test'],
              accountId: 'test',
            )).thenAnswer((_) async => 0);

        when(() => mockDataSource.getSmokeLogById(
              smokeLogId: 'test',
              accountId: 'test',
            )).thenAnswer((_) async => null);

        when(() => mockDataSource.getUsedMethodIds(
              accountId: 'test',
            )).thenAnswer((_) async => []);

        when(() => mockDataSource.getUsedTagIds(
              accountId: 'test',
            )).thenAnswer((_) async => []);

        // If we reach this point, all methods are properly defined
        expect(true, isTrue);
      });
    });
  });
}
