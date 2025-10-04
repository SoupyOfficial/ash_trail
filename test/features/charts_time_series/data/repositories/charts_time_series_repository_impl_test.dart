import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/charts_time_series/data/repositories/charts_time_series_repository_impl.dart';
import 'package:ash_trail/features/charts_time_series/data/datasources/charts_time_series_local_datasource.dart';
import 'package:ash_trail/features/charts_time_series/data/models/chart_data_point_dto.dart';
import 'package:ash_trail/features/charts_time_series/data/models/time_series_chart_dto.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';
import 'package:ash_trail/features/charts_time_series/domain/repositories/charts_time_series_repository.dart';

// Mock the local data source
class MockChartsTimeSeriesLocalDataSource extends Mock
    implements ChartsTimeSeriesLocalDataSource {}

// Fake class for ChartConfig
class FakeChartConfig extends Fake implements ChartConfig {}

// Fake class for TimeSeriesChartDto
class FakeTimeSeriesChartDto extends Fake implements TimeSeriesChartDto {}

void main() {
  group('ChartsTimeSeriesRepositoryImpl', () {
    late ChartsTimeSeriesRepositoryImpl repository;
    late MockChartsTimeSeriesLocalDataSource mockLocalDataSource;

    setUpAll(() {
      registerFallbackValue(FakeChartConfig());
      registerFallbackValue(FakeTimeSeriesChartDto());
    });

    setUp(() {
      mockLocalDataSource = MockChartsTimeSeriesLocalDataSource();
      repository = ChartsTimeSeriesRepositoryImpl(
        localDataSource: mockLocalDataSource,
      );
    });

    group('generateChart', () {
      test('should return cached chart when available', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        final cachedChartDto = TimeSeriesChartDto(
          id: 'cached-chart-id',
          accountId: 'test-account',
          title: 'Cached Chart',
          dataPoints: [],
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          aggregation: 'daily',
          metric: 'count',
          smoothing: 'none',
          createdAt: DateTime(2023, 1, 1),
        );

        when(() => mockLocalDataSource.getCachedChart(any()))
            .thenAnswer((_) async => cachedChartDto);

        // Act
        final result = await repository.generateChart(config);

        // Assert
        expect(result, isA<Right<AppFailure, TimeSeriesChart>>());
        final chart =
            result.fold((l) => throw Exception('Should not fail'), (r) => r);
        expect(chart.id, 'cached-chart-id');
        expect(chart.title, 'Cached Chart');

        verify(() => mockLocalDataSource.getCachedChart(any())).called(1);
        verifyNever(() => mockLocalDataSource.aggregateChartData(any()));
      });

      test('should generate new chart when no cache available', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        final dataPointDtos = [
          ChartDataPointDto(
            timestamp: DateTime(2023, 1, 1),
            value: 5.0,
            count: 5,
            totalDurationMs: 300000,
          ),
          ChartDataPointDto(
            timestamp: DateTime(2023, 1, 2),
            value: 3.0,
            count: 3,
            totalDurationMs: 180000,
          ),
        ];

        when(() => mockLocalDataSource.getCachedChart(any()))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.aggregateChartData(any()))
            .thenAnswer((_) async => dataPointDtos);
        when(() => mockLocalDataSource.cacheChart(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.generateChart(config);

        // Assert
        expect(result, isA<Right<AppFailure, TimeSeriesChart>>());
        final chart =
            result.fold((l) => throw Exception('Should not fail'), (r) => r);

        expect(chart.accountId, 'test-account');
        expect(chart.aggregation, ChartAggregation.daily);
        expect(chart.metric, ChartMetric.count);
        expect(chart.dataPoints.length, 2);
        expect(chart.title, contains('Log Count by Day'));

        verify(() => mockLocalDataSource.getCachedChart(any())).called(1);
        verify(() => mockLocalDataSource.aggregateChartData(config)).called(1);
        verify(() => mockLocalDataSource.cacheChart(any())).called(1);
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        when(() => mockLocalDataSource.getCachedChart(any()))
            .thenThrow(Exception('Cache error'));

        // Act
        final result = await repository.generateChart(config);

        // Assert
        expect(result, isA<Left<AppFailure, TimeSeriesChart>>());
        final failure =
            result.fold((l) => l, (r) => throw Exception('Should fail'));
        expect(failure, isA<AppFailure>());
        expect(failure.message, contains('Failed to generate chart'));
      });

      test('should generate correct chart titles for different configurations',
          () async {
        // Test cases for different metrics and aggregations
        final testCases = [
          {
            'metric': ChartMetric.duration,
            'aggregation': ChartAggregation.weekly,
            'expectedTitle': 'Total Duration by Week (31 days)'
          },
          {
            'metric': ChartMetric.averageDuration,
            'aggregation': ChartAggregation.monthly,
            'expectedTitle': 'Average Duration by Month (31 days)'
          },
          {
            'metric': ChartMetric.moodScore,
            'aggregation': ChartAggregation.daily,
            'expectedTitle': 'Average Mood by Day (31 days)'
          },
          {
            'metric': ChartMetric.physicalScore,
            'aggregation': ChartAggregation.weekly,
            'expectedTitle': 'Average Physical by Week (31 days)'
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          final config = ChartConfig(
            accountId: 'test-account',
            aggregation: testCase['aggregation'] as ChartAggregation,
            metric: testCase['metric'] as ChartMetric,
            startDate: DateTime(2023, 1, 1),
            endDate: DateTime(2023, 1, 31),
            smoothing: ChartSmoothing.none,
          );

          when(() => mockLocalDataSource.getCachedChart(any()))
              .thenAnswer((_) async => null);
          when(() => mockLocalDataSource.aggregateChartData(any()))
              .thenAnswer((_) async => []);
          when(() => mockLocalDataSource.cacheChart(any()))
              .thenAnswer((_) async {});

          // Act
          final result = await repository.generateChart(config);

          // Assert
          expect(result, isA<Right<AppFailure, TimeSeriesChart>>());
          final chart = result.fold(
            (failure) => throw Exception('Should not fail'),
            (chart) => chart,
          );
          expect(chart.title, testCase['expectedTitle']);
        }
      });
    });

    group('getChartDataPoints', () {
      test('should return chart data points successfully', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        final dataPointDtos = [
          ChartDataPointDto(
            timestamp: DateTime(2023, 1, 1),
            value: 5.0,
            count: 5,
            totalDurationMs: 300000,
          ),
        ];

        when(() => mockLocalDataSource.aggregateChartData(any()))
            .thenAnswer((_) async => dataPointDtos);

        // Act
        final result = await repository.getChartDataPoints(config);

        // Assert
        expect(result, isA<Right<AppFailure, List<ChartDataPoint>>>());
        final dataPoints = result.fold(
          (failure) => throw Exception('Should not fail'),
          (dataPoints) => dataPoints,
        );
        expect(dataPoints.length, 1);
        expect(dataPoints.first.timestamp, DateTime(2023, 1, 1));
        expect(dataPoints.first.value, 5.0);

        verify(() => mockLocalDataSource.aggregateChartData(config)).called(1);
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        when(() => mockLocalDataSource.aggregateChartData(any()))
            .thenThrow(Exception('Aggregation error'));

        // Act
        final result = await repository.getChartDataPoints(config);

        // Assert
        expect(result, isA<Left<AppFailure, List<ChartDataPoint>>>());
        final failure =
            result.fold((l) => l, (r) => throw Exception('Should fail'));
        expect(failure.message, contains('Failed to get chart data points'));
      });
    });

    group('getChartSummary', () {
      test('should return chart summary successfully', () async {
        // Arrange
        const mockSummary = ChartSummary(
          totalCount: 10,
          totalDurationMs: 600000,
          averageDurationMs: 60000,
          averageMoodScore: 7.5,
          averagePhysicalScore: 6.8,
          dayCount: 31,
        );

        when(() => mockLocalDataSource.getChartSummary(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => mockSummary);

        // Act
        final result = await repository.getChartSummary(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          visibleTags: ['tag1', 'tag2'],
        );

        // Assert
        expect(result, isA<Right<AppFailure, ChartSummary>>());
        final summary = result.fold(
          (failure) => throw Exception('Should not fail'),
          (summary) => summary,
        );
        expect(summary.totalCount, 10);
        expect(summary.totalDurationMs, 600000);
        expect(summary.averageDurationMs, 60000);
        expect(summary.averageMoodScore, 7.5);
        expect(summary.averagePhysicalScore, 6.8);

        verify(() => mockLocalDataSource.getChartSummary(
              accountId: 'test-account',
              startDate: DateTime(2023, 1, 1),
              endDate: DateTime(2023, 1, 31),
              visibleTags: ['tag1', 'tag2'],
            )).called(1);
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.getChartSummary(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenThrow(Exception('Summary error'));

        // Act
        final result = await repository.getChartSummary(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, isA<Left<AppFailure, ChartSummary>>());
        final failure =
            result.fold((l) => l, (r) => throw Exception('Should fail'));
        expect(failure.message, contains('Failed to get chart summary'));
      });
    });

    group('hasDataInRange', () {
      test('should return true when data exists', () async {
        // Arrange
        when(() => mockLocalDataSource.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => true);

        // Act
        final result = await repository.hasDataInRange(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          visibleTags: ['tag1'],
        );

        // Assert
        expect(result, isA<Right<AppFailure, bool>>());
        final hasData = result.fold(
          (failure) => throw Exception('Should not fail'),
          (hasData) => hasData,
        );
        expect(hasData, true);

        verify(() => mockLocalDataSource.hasDataInRange(
              accountId: 'test-account',
              startDate: DateTime(2023, 1, 1),
              endDate: DateTime(2023, 1, 31),
              visibleTags: ['tag1'],
            )).called(1);
      });

      test('should return false when no data exists', () async {
        // Arrange
        when(() => mockLocalDataSource.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => false);

        // Act
        final result = await repository.hasDataInRange(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, isA<Right<AppFailure, bool>>());
        final hasData = result.fold(
          (failure) => throw Exception('Should not fail'),
          (hasData) => hasData,
        );
        expect(hasData, false);
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenThrow(Exception('Data check error'));

        // Act
        final result = await repository.hasDataInRange(
          accountId: 'test-account',
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, isA<Left<AppFailure, bool>>());
        final failure =
            result.fold((l) => l, (r) => throw Exception('Should fail'));
        expect(failure.message, contains('Failed to check data availability'));
      });
    });

    group('getAvailableDateRange', () {
      test('should return date range when data exists', () async {
        // Arrange
        final mockDateRange = DateRange(
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 12, 31),
        );

        when(() => mockLocalDataSource.getAvailableDateRange(any()))
            .thenAnswer((_) async => mockDateRange);

        // Act
        final result = await repository.getAvailableDateRange('test-account');

        // Assert
        expect(result, isA<Right<AppFailure, DateRange?>>());
        final dateRange = result.fold(
          (failure) => throw Exception('Should not fail'),
          (dateRange) => dateRange,
        );
        expect(dateRange, isNotNull);
        expect(dateRange!.startDate, DateTime(2023, 1, 1));
        expect(dateRange.endDate, DateTime(2023, 12, 31));

        verify(() => mockLocalDataSource.getAvailableDateRange('test-account'))
            .called(1);
      });

      test('should return null when no data exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getAvailableDateRange(any()))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getAvailableDateRange('test-account');

        // Assert
        expect(result, isA<Right<AppFailure, DateRange?>>());
        final dateRange = result.fold(
          (failure) => throw Exception('Should not fail'),
          (dateRange) => dateRange,
        );
        expect(dateRange, isNull);
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.getAvailableDateRange(any()))
            .thenThrow(Exception('Date range error'));

        // Act
        final result = await repository.getAvailableDateRange('test-account');

        // Assert
        expect(result, isA<Left<AppFailure, DateRange?>>());
        final failure =
            result.fold((l) => l, (r) => throw Exception('Should fail'));
        expect(failure.message, contains('Failed to get available date range'));
      });
    });

    group('private methods', () {
      test('should generate unique chart IDs for different configurations',
          () async {
        // Testing private method behavior through public interface
        final config1 = ChartConfig(
          accountId: 'account1',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        final config2 = ChartConfig(
          accountId: 'account2',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
        );

        when(() => mockLocalDataSource.getCachedChart(any()))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.aggregateChartData(any()))
            .thenAnswer((_) async => []);
        when(() => mockLocalDataSource.cacheChart(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.generateChart(config1);
        await repository.generateChart(config2);

        // Assert - Different account IDs should result in different cache lookups
        final captured =
            verify(() => mockLocalDataSource.getCachedChart(captureAny()))
                .captured;
        expect(captured.length, 2);
        expect(captured[0], isNot(equals(captured[1])));
      });

      test('should handle configurations with visible tags', () async {
        // Arrange
        final config = ChartConfig(
          accountId: 'test-account',
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          startDate: DateTime(2023, 1, 1),
          endDate: DateTime(2023, 1, 31),
          smoothing: ChartSmoothing.none,
          visibleTags: ['tag1', 'tag2'],
          smoothingWindow: 7,
        );

        when(() => mockLocalDataSource.getCachedChart(any()))
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.aggregateChartData(any()))
            .thenAnswer((_) async => []);
        when(() => mockLocalDataSource.cacheChart(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.generateChart(config);

        // Assert
        expect(result, isA<Right<AppFailure, TimeSeriesChart>>());
        final chart = result.fold(
          (failure) => throw Exception('Should not fail'),
          (chart) => chart,
        );
        expect(chart.visibleTags, equals(['tag1', 'tag2']));
        expect(chart.smoothingWindow, 7);
      });
    });
  });
}
