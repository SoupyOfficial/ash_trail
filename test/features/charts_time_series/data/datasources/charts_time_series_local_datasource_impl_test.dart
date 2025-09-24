import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ash_trail/features/charts_time_series/data/datasources/charts_time_series_local_datasource_impl.dart';
import 'package:ash_trail/features/charts_time_series/data/models/chart_data_point_dto.dart';
import 'package:ash_trail/features/charts_time_series/data/models/time_series_chart_dto.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_local_datasource.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';

// Mock the SmokeLogLocalDataSource
class MockSmokeLogLocalDataSource extends Mock
    implements SmokeLogLocalDataSource {}

void main() {
  group('ChartsTimeSeriesLocalDataSourceImpl', () {
    late ChartsTimeSeriesLocalDataSourceImpl dataSource;
    late MockSmokeLogLocalDataSource mockSmokeLogDataSource;

    setUp(() {
      mockSmokeLogDataSource = MockSmokeLogLocalDataSource();
      dataSource = ChartsTimeSeriesLocalDataSourceImpl(
        smokeLogDataSource: mockSmokeLogDataSource,
      );
    });

    group('aggregateChartData', () {
      test('should aggregate smoke logs into chart data points', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        final mockSmokeLogDtos = [
          SmokeLogDto(
            id: '1',
            accountId: 'test-account',
            ts: DateTime(2023, 1, 1, 10),
            durationMs: 300000,
            moodScore: 7,
            physicalScore: 6,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SmokeLogDto(
            id: '2',
            accountId: 'test-account',
            ts: DateTime(2023, 1, 1, 15),
            durationMs: 600000,
            moodScore: 8,
            physicalScore: 7,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => mockSmokeLogDtos);

        // Act
        final result = await dataSource.aggregateChartData(config);

        // Assert
        expect(result, isA<List<ChartDataPointDto>>());
        expect(result.isNotEmpty, true);

        verify(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: config.accountId,
              startDate: config.startDate,
              endDate: config.endDate,
            )).called(1);
      });

      test('should return empty list when no smoke logs found', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        when(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.aggregateChartData(config);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('hasDataInRange', () {
      test('should return true when data exists', () async {
        // Arrange
        final mockSmokeLog = SmokeLogDto(
          id: '1',
          accountId: 'test-account',
          ts: DateTime(2023, 1, 1),
          durationMs: 300000,
          moodScore: 7,
          physicalScore: 6,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              limit: 1,
            )).thenAnswer((_) async => [mockSmokeLog]);

        // Act
        final result = await dataSource.hasDataInRange(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, true);
      });

      test('should return false when no data exists', () async {
        // Arrange
        when(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              limit: 1,
            )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.hasDataInRange(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, false);
      });
    });

    group('getChartSummary', () {
      test('should calculate chart summary from smoke logs', () async {
        // Arrange
        final mockSmokeLogDtos = [
          SmokeLogDto(
            id: '1',
            accountId: 'test-account',
            ts: DateTime(2023, 1, 1),
            durationMs: 300000, // 5 minutes
            moodScore: 7,
            physicalScore: 6,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SmokeLogDto(
            id: '2',
            accountId: 'test-account',
            ts: DateTime(2023, 1, 2),
            durationMs: 600000, // 10 minutes
            moodScore: 8,
            physicalScore: 7,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(() => mockSmokeLogDataSource.getSmokeLogsByDateRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
            )).thenAnswer((_) async => mockSmokeLogDtos);

        // Act
        final result = await dataSource.getChartSummary(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result.totalCount, 2);
        expect(result.totalDurationMs, 900000); // 300000 + 600000
        expect(result.averageDurationMs, 450000); // 900000 / 2
        expect(result.averageMoodScore, 7.5); // (7 + 8) / 2
        expect(result.averagePhysicalScore, 6.5); // (6 + 7) / 2
      });
    });

    group('cache operations', () {
      test('should cache and retrieve charts', () async {
        // This is a simple in-memory cache test
        final chartDto = TimeSeriesChartDto(
          id: 'test-chart',
          accountId: 'test-account',
          title: 'Test Chart',
          dataPoints: [],
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          aggregation: 'daily',
          metric: 'count',
          smoothing: 'none',
          createdAt: DateTime.now(),
        );

        // Act - cache the chart
        await dataSource.cacheChart(chartDto);

        // Act - retrieve the cached chart
        final cached = await dataSource.getCachedChart('test-chart');

        // Assert
        expect(cached, isNotNull);
        expect(cached?.id, 'test-chart');
      });

      test('should clear stale cache', () async {
        // Act
        await dataSource.clearStaleCache();

        // Assert - should not throw
        // Cache clearing is a void operation
      });
    });
  });
}
