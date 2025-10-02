import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';

void main() {
  group('TimeSeriesChart', () {
    late List<ChartDataPoint> sampleDataPoints;

    setUp(() {
      sampleDataPoints = [
        ChartDataPoint(
          timestamp: DateTime(2024, 1, 1),
          value: 5.0,
          count: 3,
          totalDurationMs: 150000,
          averageMoodScore: 7.0,
          averagePhysicalScore: 6.0,
        ),
        ChartDataPoint(
          timestamp: DateTime(2024, 1, 2),
          value: 3.0,
          count: 2,
          totalDurationMs: 100000,
          averageMoodScore: 6.5,
          averagePhysicalScore: 5.5,
        ),
        ChartDataPoint(
          timestamp: DateTime(2024, 1, 3),
          value: 0.0,
          count: 0,
          totalDurationMs: 0,
        ),
      ];
    });

    test('should create chart with valid data', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.id, 'test-chart');
      expect(chart.accountId, 'test-account');
      expect(chart.title, 'Test Chart');
      expect(chart.aggregation, ChartAggregation.daily);
      expect(chart.metric, ChartMetric.count);
      expect(chart.smoothing, ChartSmoothing.none);
      expect(chart.dataPoints, sampleDataPoints);
    });

    test('should indicate hasData when dataPoints is not empty', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.hasData, isTrue);
    });

    test('should indicate no data when dataPoints is empty', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: [],
        createdAt: DateTime.now(),
      );

      expect(chart.hasData, isFalse);
    });

    test('should indicate hasValidData when some points have data', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.hasValidData, isTrue);
    });

    test('should calculate total count correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.totalCount, 5); // 3 + 2 + 0
    });

    test('should calculate total duration correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.totalDurationMs, 250000); // 150000 + 100000 + 0
    });

    test('should calculate average value correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      // Weighted average: (5.0 * 3 + 3.0 * 2 + 0.0 * 0) / (3 + 2 + 0) = 21.0 / 5 = 4.2
      expect(chart.averageValue, 4.2);
    });

    test('should find max value correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.maxValue, 5.0);
    });

    test('should find min value correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.minValue, 0.0);
    });

    test('should format title correctly', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Daily Usage',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.formattedTitle, 'Daily Usage - Count (31 days)');
    });

    test('should return only valid data points', () {
      final chart = TimeSeriesChart(
        id: 'test-chart',
        accountId: 'test-account',
        title: 'Test Chart',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        dataPoints: sampleDataPoints,
        createdAt: DateTime.now(),
      );

      expect(chart.validDataPoints.length, 2); // Only first two have count > 0
      expect(chart.validDataPoints[0].count, 3);
      expect(chart.validDataPoints[1].count, 2);
    });
  });

  group('ChartConfig', () {
    test('should create config with valid data', () {
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
        smoothingWindow: 7,
        visibleTags: ['tag1', 'tag2'],
      );

      expect(config.accountId, 'test-account');
      expect(config.startDate, DateTime(2024, 1, 1));
      expect(config.endDate, DateTime(2024, 1, 31));
      expect(config.aggregation, ChartAggregation.daily);
      expect(config.metric, ChartMetric.count);
      expect(config.smoothing, ChartSmoothing.none);
      expect(config.smoothingWindow, 7);
      expect(config.visibleTags, ['tag1', 'tag2']);
    });

    test('should validate time range correctly', () {
      final validConfig = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final invalidConfig = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 31),
        endDate: DateTime(2024, 1, 1),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      final equalConfig = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 15),
        endDate: DateTime(2024, 1, 15),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      expect(validConfig.isValidTimeRange, isTrue);
      expect(invalidConfig.isValidTimeRange, isFalse);
      expect(equalConfig.isValidTimeRange, isTrue); // Same day is valid
    });

    test('should calculate day count correctly', () {
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      expect(config.dayCount, 31);
    });

    test('should identify smoothing window requirement', () {
      final movingAverageConfig = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.movingAverage,
      );

      final noneConfig = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.daily,
        metric: ChartMetric.count,
        smoothing: ChartSmoothing.none,
      );

      expect(movingAverageConfig.requiresSmoothingWindow, isTrue);
      expect(noneConfig.requiresSmoothingWindow, isFalse);
    });
  });

  group('TimeSeriesChart JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final chart = TimeSeriesChart(
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
        createdAt: DateTime(2024, 1, 1, 12, 0),
        smoothingWindow: 7,
        visibleTags: ['tag1', 'tag2'],
      );

      final json = chart.toJson();

      expect(json['id'], 'test-chart');
      expect(json['accountId'], 'test-account');
      expect(json['title'], 'Test Chart');
      expect(json['startDate'], '2024-01-01T00:00:00.000');
      expect(json['endDate'], '2024-01-31T00:00:00.000');
      expect(json['aggregation'], 'daily');
      expect(json['metric'], 'count');
      expect(json['smoothing'], 'none');
      expect(json['dataPoints'], isA<List>());
      expect(json['createdAt'], '2024-01-01T12:00:00.000');
      expect(json['smoothingWindow'], 7);
      expect(json['visibleTags'], ['tag1', 'tag2']);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-chart',
        'accountId': 'test-account',
        'title': 'Test Chart',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'aggregation': 'daily',
        'metric': 'count',
        'smoothing': 'none',
        'dataPoints': [
          {
            'timestamp': '2024-01-01T00:00:00.000',
            'value': 5.0,
            'count': 3,
            'totalDurationMs': 150000,
          }
        ],
        'createdAt': '2024-01-01T12:00:00.000',
        'smoothingWindow': 7,
        'visibleTags': ['tag1', 'tag2'],
      };

      final chart = TimeSeriesChart.fromJson(json);

      expect(chart.id, 'test-chart');
      expect(chart.accountId, 'test-account');
      expect(chart.title, 'Test Chart');
      expect(chart.startDate, DateTime(2024, 1, 1));
      expect(chart.endDate, DateTime(2024, 1, 31));
      expect(chart.aggregation, ChartAggregation.daily);
      expect(chart.metric, ChartMetric.count);
      expect(chart.smoothing, ChartSmoothing.none);
      expect(chart.dataPoints.length, 1);
      expect(chart.createdAt, DateTime(2024, 1, 1, 12, 0));
      expect(chart.smoothingWindow, 7);
      expect(chart.visibleTags, ['tag1', 'tag2']);
    });

    test('should handle all enum values in JSON serialization', () {
      // Test all aggregation types
      for (final aggregation in ChartAggregation.values) {
        final chart = TimeSeriesChart(
          id: 'test',
          accountId: 'test',
          title: 'Test',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          aggregation: aggregation,
          metric: ChartMetric.count,
          smoothing: ChartSmoothing.none,
          dataPoints: [],
          createdAt: DateTime.now(),
        );

        final json = chart.toJson();
        final restored = TimeSeriesChart.fromJson(json);
        expect(restored.aggregation, aggregation);
      }

      // Test all metric types
      for (final metric in ChartMetric.values) {
        final chart = TimeSeriesChart(
          id: 'test',
          accountId: 'test',
          title: 'Test',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          aggregation: ChartAggregation.daily,
          metric: metric,
          smoothing: ChartSmoothing.none,
          dataPoints: [],
          createdAt: DateTime.now(),
        );

        final json = chart.toJson();
        final restored = TimeSeriesChart.fromJson(json);
        expect(restored.metric, metric);
      }

      // Test all smoothing types
      for (final smoothing in ChartSmoothing.values) {
        final chart = TimeSeriesChart(
          id: 'test',
          accountId: 'test',
          title: 'Test',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          aggregation: ChartAggregation.daily,
          metric: ChartMetric.count,
          smoothing: smoothing,
          dataPoints: [],
          createdAt: DateTime.now(),
        );

        final json = chart.toJson();
        final restored = TimeSeriesChart.fromJson(json);
        expect(restored.smoothing, smoothing);
      }
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'id': 'test-chart',
        'accountId': 'test-account',
        'title': 'Test Chart',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'aggregation': 'daily',
        'metric': 'count',
        'smoothing': 'none',
        'dataPoints': [],
        'createdAt': '2024-01-01T12:00:00.000',
        'smoothingWindow': null,
        'visibleTags': null,
      };

      final chart = TimeSeriesChart.fromJson(json);
      expect(chart.smoothingWindow, isNull);
      expect(chart.visibleTags, isNull);
    });
  });

  group('ChartConfig JSON Serialization', () {
    test('should serialize ChartConfig to JSON correctly', () {
      final config = ChartConfig(
        accountId: 'test-account',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        aggregation: ChartAggregation.weekly,
        metric: ChartMetric.duration,
        smoothing: ChartSmoothing.movingAverage,
        smoothingWindow: 5,
        visibleTags: ['work', 'stress'],
      );

      final json = config.toJson();

      expect(json['accountId'], 'test-account');
      expect(json['startDate'], '2024-01-01T00:00:00.000');
      expect(json['endDate'], '2024-01-31T00:00:00.000');
      expect(json['aggregation'], 'weekly');
      expect(json['metric'], 'duration');
      expect(json['smoothing'], 'movingAverage');
      expect(json['smoothingWindow'], 5);
      expect(json['visibleTags'], ['work', 'stress']);
    });

    test('should deserialize ChartConfig from JSON correctly', () {
      final json = {
        'accountId': 'test-account',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'aggregation': 'monthly',
        'metric': 'averageDuration',
        'smoothing': 'cumulative',
        'smoothingWindow': 10,
        'visibleTags': ['health', 'social'],
      };

      final config = ChartConfig.fromJson(json);

      expect(config.accountId, 'test-account');
      expect(config.startDate, DateTime(2024, 1, 1));
      expect(config.endDate, DateTime(2024, 1, 31));
      expect(config.aggregation, ChartAggregation.monthly);
      expect(config.metric, ChartMetric.averageDuration);
      expect(config.smoothing, ChartSmoothing.cumulative);
      expect(config.smoothingWindow, 10);
      expect(config.visibleTags, ['health', 'social']);
    });

    test('should handle default smoothingWindow value', () {
      final json = {
        'accountId': 'test-account',
        'startDate': '2024-01-01T00:00:00.000',
        'endDate': '2024-01-31T00:00:00.000',
        'aggregation': 'daily',
        'metric': 'count',
        'smoothing': 'none',
        'visibleTags': null,
      };

      final config = ChartConfig.fromJson(json);
      expect(config.smoothingWindow, 7); // Default value
    });
  });
}
