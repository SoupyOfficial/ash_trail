import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';

void main() {
  group('ChartDataPoint', () {
    test('should create chart data point with valid data', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
        averageMoodScore: 7.5,
        averagePhysicalScore: 6.0,
      );

      expect(dataPoint.timestamp, DateTime(2024, 1, 1));
      expect(dataPoint.value, 5.0);
      expect(dataPoint.count, 3);
      expect(dataPoint.totalDurationMs, 150000);
      expect(dataPoint.averageMoodScore, 7.5);
      expect(dataPoint.averagePhysicalScore, 6.0);
    });

    test('should indicate hasData when count > 0', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
      );

      expect(dataPoint.hasData, isTrue);
    });

    test('should indicate no data when count = 0', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 0.0,
        count: 0,
        totalDurationMs: 0,
      );

      expect(dataPoint.hasData, isFalse);
    });

    test('should indicate score data availability', () {
      final withScores = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
        averageMoodScore: 7.5,
        averagePhysicalScore: 6.0,
      );

      final withoutScores = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
      );

      expect(withScores.hasScoreData, isTrue);
      expect(withoutScores.hasScoreData, isFalse);
    });

    test('should calculate average duration correctly', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000, // 150 seconds total
      );

      expect(dataPoint.averageDurationMs, 50000); // 50 seconds average
    });

    test('should return 0 average duration when no data', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 0.0,
        count: 0,
        totalDurationMs: 0,
      );

      expect(dataPoint.averageDurationMs, 0);
    });

    test('should format timestamp correctly for daily aggregation', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 3, 15),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
      );

      expect(dataPoint.formatTimestamp(ChartAggregation.daily), '3/15');
    });

    test('should format timestamp correctly for weekly aggregation', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 3, 15),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
      );

      expect(
          dataPoint.formatTimestamp(ChartAggregation.weekly), 'Week of 3/15');
    });

    test('should format timestamp correctly for monthly aggregation', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 3, 15),
        value: 5.0,
        count: 3,
        totalDurationMs: 150000,
      );

      expect(dataPoint.formatTimestamp(ChartAggregation.monthly), '2024-03');
    });
  });

  group('ChartAggregation enum', () {
    test('should have correct values', () {
      expect(ChartAggregation.values.length, 3);
      expect(ChartAggregation.values.contains(ChartAggregation.daily), isTrue);
      expect(ChartAggregation.values.contains(ChartAggregation.weekly), isTrue);
      expect(
          ChartAggregation.values.contains(ChartAggregation.monthly), isTrue);
    });
  });

  group('ChartMetric enum', () {
    test('should have correct values', () {
      expect(ChartMetric.values.length, 5);
      expect(ChartMetric.values.contains(ChartMetric.count), isTrue);
      expect(ChartMetric.values.contains(ChartMetric.duration), isTrue);
      expect(ChartMetric.values.contains(ChartMetric.averageDuration), isTrue);
      expect(ChartMetric.values.contains(ChartMetric.moodScore), isTrue);
      expect(ChartMetric.values.contains(ChartMetric.physicalScore), isTrue);
    });
  });

  group('ChartSmoothing enum', () {
    test('should have correct values', () {
      expect(ChartSmoothing.values.length, 3);
      expect(ChartSmoothing.values.contains(ChartSmoothing.none), isTrue);
      expect(
          ChartSmoothing.values.contains(ChartSmoothing.movingAverage), isTrue);
      expect(ChartSmoothing.values.contains(ChartSmoothing.cumulative), isTrue);
    });
  });

  group('ChartDataPoint JSON Serialization', () {
    test('should serialize to JSON correctly', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1, 12, 30),
        value: 5.5,
        count: 3,
        totalDurationMs: 150000,
        averageMoodScore: 7.5,
        averagePhysicalScore: 6.0,
      );

      final json = dataPoint.toJson();

      expect(json['timestamp'], '2024-01-01T12:30:00.000');
      expect(json['value'], 5.5);
      expect(json['count'], 3);
      expect(json['totalDurationMs'], 150000);
      expect(json['averageMoodScore'], 7.5);
      expect(json['averagePhysicalScore'], 6.0);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'timestamp': '2024-01-01T12:30:00.000',
        'value': 5.5,
        'count': 3,
        'totalDurationMs': 150000,
        'averageMoodScore': 7.5,
        'averagePhysicalScore': 6.0,
      };

      final dataPoint = ChartDataPoint.fromJson(json);

      expect(dataPoint.timestamp, DateTime(2024, 1, 1, 12, 30));
      expect(dataPoint.value, 5.5);
      expect(dataPoint.count, 3);
      expect(dataPoint.totalDurationMs, 150000);
      expect(dataPoint.averageMoodScore, 7.5);
      expect(dataPoint.averagePhysicalScore, 6.0);
    });

    test('should handle null optional fields in JSON', () {
      final json = {
        'timestamp': '2024-01-01T12:30:00.000',
        'value': 5.5,
        'count': 3,
        'totalDurationMs': 150000,
        'averageMoodScore': null,
        'averagePhysicalScore': null,
      };

      final dataPoint = ChartDataPoint.fromJson(json);

      expect(dataPoint.timestamp, DateTime(2024, 1, 1, 12, 30));
      expect(dataPoint.value, 5.5);
      expect(dataPoint.count, 3);
      expect(dataPoint.totalDurationMs, 150000);
      expect(dataPoint.averageMoodScore, isNull);
      expect(dataPoint.averagePhysicalScore, isNull);
    });

    test('should serialize and deserialize preserving data', () {
      final original = ChartDataPoint(
        timestamp: DateTime(2024, 3, 15, 8, 45, 22),
        value: 10.75,
        count: 7,
        totalDurationMs: 420000,
        averageMoodScore: 8.2,
        averagePhysicalScore: 5.9,
      );

      final json = original.toJson();
      final restored = ChartDataPoint.fromJson(json);

      expect(restored.timestamp, original.timestamp);
      expect(restored.value, original.value);
      expect(restored.count, original.count);
      expect(restored.totalDurationMs, original.totalDurationMs);
      expect(restored.averageMoodScore, original.averageMoodScore);
      expect(restored.averagePhysicalScore, original.averagePhysicalScore);
    });

    test('should handle edge case values in JSON', () {
      final dataPoint = ChartDataPoint(
        timestamp: DateTime(2024, 1, 1),
        value: 0.0,
        count: 0,
        totalDurationMs: 0,
        averageMoodScore: 0.0,
        averagePhysicalScore: 10.0,
      );

      final json = dataPoint.toJson();
      final restored = ChartDataPoint.fromJson(json);

      expect(restored.value, 0.0);
      expect(restored.count, 0);
      expect(restored.totalDurationMs, 0);
      expect(restored.averageMoodScore, 0.0);
      expect(restored.averagePhysicalScore, 10.0);
    });
  });
}
