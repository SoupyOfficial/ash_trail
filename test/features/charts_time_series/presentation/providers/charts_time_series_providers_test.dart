import 'package:test/test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/features/charts_time_series/presentation/providers/charts_time_series_providers.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/repositories/charts_time_series_repository.dart'
    as repo;
import 'package:ash_trail/features/charts_time_series/domain/usecases/get_chart_data_points_usecase.dart';
import 'package:ash_trail/features/charts_time_series/domain/usecases/generate_chart_usecase.dart';
import 'package:ash_trail/features/charts_time_series/domain/usecases/check_data_availability_usecase.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockChartsTimeSeriesRepository extends Mock
    implements repo.ChartsTimeSeriesRepository {}

class FakeChartConfig extends Fake implements ChartConfig {}

class FakeGenerateChartParams extends Fake implements GenerateChartParams {}

class FakeCheckDataAvailabilityParams extends Fake
    implements CheckDataAvailabilityParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChartConfig());
    registerFallbackValue(FakeGenerateChartParams());
    registerFallbackValue(FakeCheckDataAvailabilityParams());
  });

  group('Charts Time Series Providers', () {
    late ProviderContainer container;
    late MockChartsTimeSeriesRepository mockRepository;

    setUp(() {
      mockRepository = MockChartsTimeSeriesRepository();

      container = ProviderContainer(
        overrides: [
          chartsTimeSeriesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Repository Provider', () {
      test('should provide charts time series repository', () {
        final repository = container.read(chartsTimeSeriesRepositoryProvider);
        expect(repository, isA<repo.ChartsTimeSeriesRepository>());
      });
    });

    group('Use Case Providers', () {
      test('should provide get chart data points use case', () {
        final useCase = container.read(getChartDataPointsUseCaseProvider);
        expect(useCase, isA<GetChartDataPointsUseCase>());
      });

      test('should provide generate chart use case', () {
        final useCase = container.read(generateChartUseCaseProvider);
        expect(useCase, isA<GenerateChartUseCase>());
      });

      test('should provide check data availability use case', () {
        final useCase = container.read(checkDataAvailabilityUseCaseProvider);
        expect(useCase, isA<CheckDataAvailabilityUseCase>());
      });
    });

    group('ChartConfigNotifier', () {
      test('should initialize with default configuration', () {
        final notifier = ChartConfigNotifier('test-account');
        final config = notifier.state;

        expect(config.accountId, 'test-account');
        expect(config.aggregation, ChartAggregation.daily);
        expect(config.metric, ChartMetric.count);
        expect(config.smoothing, ChartSmoothing.none);
        expect(config.smoothingWindow, 7);
        expect(config.visibleTags, isNull);
        expect(config.startDate.isBefore(DateTime.now()), isTrue);
        expect(config.endDate.isAfter(config.startDate), isTrue);
      });

      test('should update aggregation', () {
        final notifier = ChartConfigNotifier('test-account');
        notifier.setAggregation(ChartAggregation.weekly);

        expect(notifier.state.aggregation, ChartAggregation.weekly);
      });

      test('should update metric', () {
        final notifier = ChartConfigNotifier('test-account');
        notifier.setMetric(ChartMetric.duration);

        expect(notifier.state.metric, ChartMetric.duration);
      });

      test('should update smoothing', () {
        final notifier = ChartConfigNotifier('test-account');
        notifier.setSmoothing(ChartSmoothing.movingAverage);

        expect(notifier.state.smoothing, ChartSmoothing.movingAverage);
      });

      test('should update date range', () {
        final notifier = ChartConfigNotifier('test-account');
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        notifier.setDateRange(startDate, endDate);

        expect(notifier.state.startDate, startDate);
        expect(notifier.state.endDate, endDate);
      });

      test('should update smoothing window', () {
        final notifier = ChartConfigNotifier('test-account');
        notifier.setSmoothingWindow(14);

        expect(notifier.state.smoothingWindow, 14);
      });

      test('should update visible tags', () {
        final notifier = ChartConfigNotifier('test-account');
        final tags = ['work', 'stress', 'social'];

        notifier.setVisibleTags(tags);

        expect(notifier.state.visibleTags, tags);
      });

      test('should clear visible tags when setting to null', () {
        final notifier = ChartConfigNotifier('test-account');
        notifier.setVisibleTags(['tag1']);
        notifier.setVisibleTags(null);

        expect(notifier.state.visibleTags, isNull);
      });
    });

    group('ChartConfigNotifier Provider', () {
      test('should create notifier with correct account ID', () {
        final config =
            container.read(chartConfigNotifierProvider('test-account-123'));
        expect(config.accountId, 'test-account-123');
      });

      test('should create separate notifiers for different accounts', () {
        final config1 =
            container.read(chartConfigNotifierProvider('account-1'));
        final config2 =
            container.read(chartConfigNotifierProvider('account-2'));

        expect(config1.accountId, 'account-1');
        expect(config2.accountId, 'account-2');
      });
    });

    group('Chart Data Provider', () {
      test('should return chart data on success', () async {
        final expectedChart = TimeSeriesChart(
          id: 'test-chart',
          accountId: 'test-account',
          title: 'Test Chart',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          smoothing: ChartSmoothing.none,
          dataPoints: [
            ChartDataPoint(
              timestamp: DateTime(2024, 1, 1),
              value: 5.0,
              count: 3,
              totalDurationMs: 150000,
            ),
          ],
          createdAt: DateTime.now(),
        );

        when(() => mockRepository.generateChart(any()))
            .thenAnswer((_) async => Right(expectedChart));

        final result =
            await container.read(chartDataProvider('test-account').future);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not fail'),
          (chart) => expect(chart.id, 'test-chart'),
        );
      });

      test('should return failure when repository fails', () async {
        const expectedFailure = AppFailure.network(message: 'Network error');
        when(() => mockRepository.generateChart(any()))
            .thenAnswer((_) async => const Left(expectedFailure));

        final result =
            await container.read(chartDataProvider('test-account').future);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, expectedFailure),
          (chart) => fail('Should not succeed'),
        );
      });
    });

    group('Chart Data Points Provider', () {
      test('should return data points on success', () async {
        final expectedDataPoints = [
          ChartDataPoint(
            timestamp: DateTime(2024, 1, 1),
            value: 5.0,
            count: 3,
            totalDurationMs: 150000,
          ),
          ChartDataPoint(
            timestamp: DateTime(2024, 1, 2),
            value: 3.0,
            count: 2,
            totalDurationMs: 100000,
          ),
        ];

        when(() => mockRepository.getChartDataPoints(any()))
            .thenAnswer((_) async => Right(expectedDataPoints));

        final result = await container
            .read(chartDataPointsProvider('test-account').future);

        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not fail'),
          (dataPoints) => expect(dataPoints.length, 2),
        );
      });

      test('should return failure when repository fails', () async {
        const expectedFailure = AppFailure.cache(message: 'Cache error');
        when(() => mockRepository.getChartDataPoints(any()))
            .thenAnswer((_) async => const Left(expectedFailure));

        final result = await container
            .read(chartDataPointsProvider('test-account').future);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, expectedFailure),
          (dataPoints) => fail('Should not succeed'),
        );
      });
    });

    group('Has Chart Data Provider', () {
      test('should return true when data is available', () async {
        when(() => mockRepository.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => const Right(true));

        final result =
            await container.read(hasChartDataProvider('test-account').future);

        expect(result, isTrue);
      });

      test('should return false when no data is available', () async {
        when(() => mockRepository.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => const Right(false));

        final result =
            await container.read(hasChartDataProvider('test-account').future);

        expect(result, isFalse);
      });

      test('should return false when repository fails', () async {
        const failure = AppFailure.network(message: 'Network error');
        when(() => mockRepository.hasDataInRange(
              accountId: any(named: 'accountId'),
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              visibleTags: any(named: 'visibleTags'),
            )).thenAnswer((_) async => const Left(failure));

        final result =
            await container.read(hasChartDataProvider('test-account').future);

        expect(result, isFalse);
      });
    });

    group('ChartUIStateNotifier', () {
      test('should initialize with default UI state', () {
        final notifier = ChartUIStateNotifier();
        final state = notifier.state;

        expect(state.selectedDataPoint, isNull);
        expect(state.isZoomed, isFalse);
        expect(state.panOffset, 0.0);
        expect(state.visibleDateRange, isNull);
        expect(state.showLegend, isTrue);
        expect(state.showTooltip, isFalse);
      });

      test('should select data point', () {
        final notifier = ChartUIStateNotifier();
        final dataPoint = ChartDataPoint(
          timestamp: DateTime(2024, 1, 1),
          value: 5.0,
          count: 3,
          totalDurationMs: 150000,
        );

        notifier.selectDataPoint(dataPoint);

        expect(notifier.state.selectedDataPoint, dataPoint);
      });

      test('should clear selected data point', () {
        final notifier = ChartUIStateNotifier();
        final dataPoint = ChartDataPoint(
          timestamp: DateTime(2024, 1, 1),
          value: 5.0,
          count: 3,
          totalDurationMs: 150000,
        );

        notifier.selectDataPoint(dataPoint);
        notifier.selectDataPoint(null);

        expect(notifier.state.selectedDataPoint, isNull);
      });

      test('should set zoom state', () {
        final notifier = ChartUIStateNotifier();

        notifier.setZoom(true);
        expect(notifier.state.isZoomed, isTrue);

        notifier.setZoom(false);
        expect(notifier.state.isZoomed, isFalse);
      });

      test('should set pan offset', () {
        final notifier = ChartUIStateNotifier();

        notifier.setPanOffset(50.0);
        expect(notifier.state.panOffset, 50.0);

        notifier.setPanOffset(-25.5);
        expect(notifier.state.panOffset, -25.5);
      });

      test('should set visible date range', () {
        final notifier = ChartUIStateNotifier();
        final dateRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );

        notifier.setVisibleDateRange(dateRange);
        expect(notifier.state.visibleDateRange, dateRange);

        notifier.setVisibleDateRange(null);
        expect(notifier.state.visibleDateRange, isNull);
      });

      test('should toggle legend visibility', () {
        final notifier = ChartUIStateNotifier();

        expect(notifier.state.showLegend, isTrue);

        notifier.toggleLegend();
        expect(notifier.state.showLegend, isFalse);

        notifier.toggleLegend();
        expect(notifier.state.showLegend, isTrue);
      });

      test('should show/hide tooltip', () {
        final notifier = ChartUIStateNotifier();

        notifier.showTooltip(true);
        expect(notifier.state.showTooltip, isTrue);

        notifier.showTooltip(false);
        expect(notifier.state.showTooltip, isFalse);
      });
    });

    group('ChartUIState', () {
      test('should create state with all properties', () {
        final dataPoint = ChartDataPoint(
          timestamp: DateTime(2024, 1, 1),
          value: 5.0,
          count: 3,
          totalDurationMs: 150000,
        );

        final dateRange = DateRange(
          start: DateTime(2024, 1, 1),
          end: DateTime(2024, 1, 31),
        );

        final state = ChartUIState(
          selectedDataPoint: dataPoint,
          isZoomed: true,
          panOffset: 25.0,
          visibleDateRange: dateRange,
          showLegend: false,
          showTooltip: true,
        );

        expect(state.selectedDataPoint, dataPoint);
        expect(state.isZoomed, isTrue);
        expect(state.panOffset, 25.0);
        expect(state.visibleDateRange, dateRange);
        expect(state.showLegend, isFalse);
        expect(state.showTooltip, isTrue);
      });

      test('should copy with updated properties', () {
        final originalState = ChartUIState(
          selectedDataPoint: null,
          isZoomed: false,
          panOffset: 0.0,
          visibleDateRange: null,
          showLegend: true,
          showTooltip: false,
        );

        final updatedState = originalState.copyWith(
          isZoomed: true,
          panOffset: 10.0,
          showTooltip: true,
        );

        expect(updatedState.selectedDataPoint, originalState.selectedDataPoint);
        expect(updatedState.isZoomed, isTrue);
        expect(updatedState.panOffset, 10.0);
        expect(updatedState.visibleDateRange, originalState.visibleDateRange);
        expect(updatedState.showLegend, originalState.showLegend);
        expect(updatedState.showTooltip, isTrue);
      });
    });

    group('DateRange', () {
      test('should create date range with start and end', () {
        final start = DateTime(2024, 1, 1);
        final end = DateTime(2024, 1, 31);

        final range = DateRange(start: start, end: end);

        expect(range.start, start);
        expect(range.end, end);
      });
    });
  });
}
