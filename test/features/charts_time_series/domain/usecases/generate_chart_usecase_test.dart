import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/charts_time_series/domain/usecases/generate_chart_usecase.dart';
import 'package:ash_trail/features/charts_time_series/domain/repositories/charts_time_series_repository.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockChartsTimeSeriesRepository extends Mock
    implements ChartsTimeSeriesRepository {}

class FakeChartConfig extends Fake implements ChartConfig {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChartConfig());
  });

  group('GenerateChartUseCase', () {
    late GenerateChartUseCase useCase;
    late MockChartsTimeSeriesRepository mockRepository;

    setUp(() {
      mockRepository = MockChartsTimeSeriesRepository();
      useCase = GenerateChartUseCase(repository: mockRepository);
    });

    test('should generate chart successfully with valid config', () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      final expectedChart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Generated Chart',
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

      when(() => mockRepository.generateChart(config))
          .thenAnswer((_) async => Right(expectedChart));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success, got failure: $failure'),
        (chart) {
          expect(chart.id, 'test-chart');
          expect(chart.accountId, 'test-account');
          expect(chart.aggregation, ChartAggregation.daily);
          expect(chart.metric, ChartMetric.count);
        },
      );

      verify(() => mockRepository.generateChart(config)).called(1);
    });

    test('should return validation failure for empty account ID', () async {
      // Arrange
      final config = ChartConfig(
        accountId: '',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.toString().contains('Account ID is required'), isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test('should return validation failure for invalid time range', () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 31),
        endDate: DateTime(2024, 1, 1),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure
                  .toString()
                  .contains('End date must be after or equal to start date'),
              isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test('should return validation failure for excessive time range', () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2026, 1, 1), // More than 2 years
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure.toString().contains('Date range cannot exceed 2 years'),
              isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test('should return validation failure for future end date', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: futureDate,
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure.toString().contains(
                  'End date cannot be more than 7 days in the future'),
              isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test('should return validation failure for invalid smoothing window',
        () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.movingAverage,
        smoothingWindow: 1, // Less than 2
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure
                  .toString()
                  .contains('Smoothing window must be at least 2'),
              isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test(
        'should return validation failure when smoothing window exceeds date range',
        () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 5), // 5 days
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.movingAverage,
        smoothingWindow: 10, // More than 5 days
      );

      final params = GenerateChartParams(config: config);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(
              failure
                  .toString()
                  .contains('Smoothing window cannot exceed date range'),
              isTrue);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verifyNever(() => mockRepository.generateChart(any()));
    });

    test('should handle repository failure', () async {
      // Arrange
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final params = GenerateChartParams(config: config);

      const expectedFailure = AppFailure.cache(message: 'Database error');
      when(() => mockRepository.generateChart(config))
          .thenAnswer((_) async => const Left(expectedFailure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, expectedFailure);
        },
        (chart) => fail('Expected failure, got success'),
      );

      verify(() => mockRepository.generateChart(config)).called(1);
    });
  });
}
