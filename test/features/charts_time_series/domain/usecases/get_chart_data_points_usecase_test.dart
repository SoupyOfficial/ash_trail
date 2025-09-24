import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ash_trail/features/charts_time_series/domain/usecases/get_chart_data_points_usecase.dart';
import 'package:ash_trail/features/charts_time_series/domain/repositories/charts_time_series_repository.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockChartsTimeSeriesRepository extends Mock
    implements ChartsTimeSeriesRepository {}

class FakeChartConfig extends Fake implements ChartConfig {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeChartConfig());
  });

  late GetChartDataPointsUseCase useCase;
  late MockChartsTimeSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockChartsTimeSeriesRepository();
    useCase = GetChartDataPointsUseCase(repository: mockRepository);
  });

  group('GetChartDataPointsUseCase', () {
    final validConfig = ChartConfig(
      accountId: 'test-account-id',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
      aggregation: ChartAggregation.daily,
      metric: ChartMetric.count,
      smoothing: ChartSmoothing.none,
      smoothingWindow: 7,
      visibleTags: null,
    );

    final mockDataPoints = [
      ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 10.0,
        count: 5,
        totalDurationMs: 150000,
      ),
      ChartDataPoint(
        timestamp: DateTime(2024, 1, 2),
        value: 15.0,
        count: 8,
        totalDurationMs: 240000,
      ),
    ];

    test('should return chart data points when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getChartDataPoints(any()))
          .thenAnswer((_) async => Right(mockDataPoints));

      // Act
      final result = await useCase.call(validConfig);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (dataPoints) {
          expect(dataPoints, equals(mockDataPoints));
          expect(dataPoints.length, equals(2));
        },
      );

      verify(() => mockRepository.getChartDataPoints(validConfig)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = AppFailure.network(message: 'Network error');
      when(() => mockRepository.getChartDataPoints(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(validConfig);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (dataPoints) => fail('Should not return data points'),
      );

      verify(() => mockRepository.getChartDataPoints(validConfig)).called(1);
    });

    test('should return validation failure when accountId is empty', () async {
      // Arrange
      final configWithEmptyAccountId = validConfig.copyWith(accountId: '');

      // Act
      final result = await useCase.call(configWithEmptyAccountId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.message, equals('Account ID is required'));
        },
        (dataPoints) => fail('Should not return data points'),
      );

      verifyNever(() => mockRepository.getChartDataPoints(any()));
    });

    test('should return validation failure when date range is invalid',
        () async {
      // Arrange
      final configWithInvalidDateRange = ChartConfig(
        accountId: 'test-account-id',
        startDate: DateTime(2024, 1, 31), // End date before start date
        endDate: DateTime(2024, 1, 1),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        smoothingWindow: 7,
        visibleTags: null,
      );

      // Act
      final result = await useCase.call(configWithInvalidDateRange);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.message, equals('Invalid date range'));
        },
        (dataPoints) => fail('Should not return data points'),
      );

      verifyNever(() => mockRepository.getChartDataPoints(any()));
    });

    test('should validate config with minimal required fields', () async {
      // Arrange
      final minimalConfig = ChartConfig(
        accountId: 'test',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 2),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        smoothingWindow: 7,
        visibleTags: null,
      );

      when(() => mockRepository.getChartDataPoints(any()))
          .thenAnswer((_) async => Right(mockDataPoints));

      // Act
      final result = await useCase.call(minimalConfig);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getChartDataPoints(minimalConfig)).called(1);
    });
  });
}
