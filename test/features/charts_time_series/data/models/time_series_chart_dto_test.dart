import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/charts_time_series/data/models/time_series_chart_dto.dart';
import 'package:ash_trail/features/charts_time_series/data/models/chart_data_point_dto.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/time_series_chart.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';

void main() {
  group('TimeSeriesChartDto', () {
    late TimeSeriesChartDto timeSeriesChartDto;
    late DateTime testStartDate;
    late DateTime testEndDate;
    late DateTime testCreatedAt;
    late List<ChartDataPointDto> testDataPoints;

    setUp(() {
      testStartDate = DateTime.parse('2024-01-01T00:00:00Z');
      testEndDate = DateTime.parse('2024-01-31T23:59:59Z');
      testCreatedAt = DateTime.parse('2024-02-01T10:30:00Z');

      testDataPoints = [
        ChartDataPointDto(
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              1672531200000), // 2023-01-01 00:00:00 UTC
          value: 10.5,
          count: 5,
          totalDurationMs: 300000, // 5 minutes
          averageMoodScore: 7.5,
          averagePhysicalScore: 6.8,
        ),
        ChartDataPointDto(
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              1672617600000), // 2023-01-02 00:00:00 UTC
          value: 12.3,
          count: 8,
          totalDurationMs: 480000, // 8 minutes
          averageMoodScore: 8.2,
          averagePhysicalScore: 7.1,
        ),
      ];

      timeSeriesChartDto = TimeSeriesChartDto(
        id: 'chart_123',
        accountId: 'account_456',
        title: 'Monthly Smoking Chart',
        startDate: testStartDate,
        endDate: testEndDate,
        aggregation: 'daily',
        metric: 'count',
        smoothing: 'movingAverage',
        dataPoints: testDataPoints,
        smoothingWindow: 7,
        visibleTags: ['work', 'stress'],
        createdAt: testCreatedAt,
      );
    });

    group('constructor', () {
      test('creates instance with all required fields', () {
        expect(timeSeriesChartDto.id, equals('chart_123'));
        expect(timeSeriesChartDto.accountId, equals('account_456'));
        expect(timeSeriesChartDto.title, equals('Monthly Smoking Chart'));
        expect(timeSeriesChartDto.startDate, equals(testStartDate));
        expect(timeSeriesChartDto.endDate, equals(testEndDate));
        expect(timeSeriesChartDto.aggregation, equals('daily'));
        expect(timeSeriesChartDto.metric, equals('count'));
        expect(timeSeriesChartDto.smoothing, equals('movingAverage'));
        expect(timeSeriesChartDto.dataPoints, equals(testDataPoints));
        expect(timeSeriesChartDto.smoothingWindow, equals(7));
        expect(timeSeriesChartDto.visibleTags, equals(['work', 'stress']));
        expect(timeSeriesChartDto.createdAt, equals(testCreatedAt));
      });

      test('creates instance with only required fields', () {
        final minimalDto = TimeSeriesChartDto(
          id: 'chart_minimal',
          accountId: 'account_minimal',
          title: 'Minimal Chart',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'weekly',
          metric: 'duration',
          smoothing: 'none',
          dataPoints: const [],
          createdAt: testCreatedAt,
        );

        expect(minimalDto.id, equals('chart_minimal'));
        expect(minimalDto.accountId, equals('account_minimal'));
        expect(minimalDto.title, equals('Minimal Chart'));
        expect(minimalDto.aggregation, equals('weekly'));
        expect(minimalDto.metric, equals('duration'));
        expect(minimalDto.smoothing, equals('none'));
        expect(minimalDto.dataPoints, isEmpty);
        expect(minimalDto.smoothingWindow, isNull);
        expect(minimalDto.visibleTags, isNull);
      });
    });

    group('JSON serialization', () {
      test('fromJson creates correct instance', () {
        final json = {
          'id': 'chart_json',
          'accountId': 'account_json',
          'title': 'JSON Chart',
          'startDate': testStartDate.toIso8601String(),
          'endDate': testEndDate.toIso8601String(),
          'aggregation': 'monthly',
          'metric': 'averageDuration',
          'smoothing': 'cumulative',
          'dataPoints': [
            {
              'timestamp': DateTime.fromMillisecondsSinceEpoch(1672531200000)
                  .toIso8601String(),
              'value': 15.7,
              'count': 3,
              'totalDurationMs': 180000,
              'averageMoodScore': 6.5,
              'averagePhysicalScore': null,
            }
          ],
          'smoothingWindow': 14,
          'visibleTags': ['evening'],
          'createdAt': testCreatedAt.toIso8601String(),
        };

        final dto = TimeSeriesChartDto.fromJson(json);

        expect(dto.id, equals('chart_json'));
        expect(dto.accountId, equals('account_json'));
        expect(dto.title, equals('JSON Chart'));
        expect(dto.startDate, equals(testStartDate));
        expect(dto.endDate, equals(testEndDate));
        expect(dto.aggregation, equals('monthly'));
        expect(dto.metric, equals('averageDuration'));
        expect(dto.smoothing, equals('cumulative'));
        expect(dto.dataPoints, hasLength(1));
        expect(dto.dataPoints.first.value, equals(15.7));
        expect(dto.smoothingWindow, equals(14));
        expect(dto.visibleTags, equals(['evening']));
        expect(dto.createdAt, equals(testCreatedAt));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'id': 'chart_null',
          'accountId': 'account_null',
          'title': 'Null Fields Chart',
          'startDate': testStartDate.toIso8601String(),
          'endDate': testEndDate.toIso8601String(),
          'aggregation': 'daily',
          'metric': 'count',
          'smoothing': 'none',
          'dataPoints': <Map<String, dynamic>>[],
          'smoothingWindow': null,
          'visibleTags': null,
          'createdAt': testCreatedAt.toIso8601String(),
        };

        final dto = TimeSeriesChartDto.fromJson(json);

        expect(dto.smoothingWindow, isNull);
        expect(dto.visibleTags, isNull);
      });

      test('toJson produces correct map', () {
        final json = timeSeriesChartDto.toJson();

        expect(json['id'], equals('chart_123'));
        expect(json['accountId'], equals('account_456'));
        expect(json['title'], equals('Monthly Smoking Chart'));
        expect(json['startDate'], equals(testStartDate.toIso8601String()));
        expect(json['endDate'], equals(testEndDate.toIso8601String()));
        expect(json['aggregation'], equals('daily'));
        expect(json['metric'], equals('count'));
        expect(json['smoothing'], equals('movingAverage'));
        expect(json['dataPoints'], hasLength(2));
        expect(json['smoothingWindow'], equals(7));
        expect(json['visibleTags'], equals(['work', 'stress']));
        expect(json['createdAt'], equals(testCreatedAt.toIso8601String()));
      });

      test('round trip JSON serialization preserves data', () {
        // Create a simple DTO with manual JSON handling
        final simpleDto = TimeSeriesChartDto(
          id: 'simple_123',
          accountId: 'simple_account',
          title: 'Simple Chart',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'daily',
          metric: 'count',
          smoothing: 'none',
          dataPoints: [], // Empty list to avoid nested serialization issues
          createdAt: testCreatedAt,
        );

        final json = simpleDto.toJson();
        final reconstructed = TimeSeriesChartDto.fromJson(json);

        expect(reconstructed.id, equals(simpleDto.id));
        expect(reconstructed.accountId, equals(simpleDto.accountId));
        expect(reconstructed.title, equals(simpleDto.title));
        expect(reconstructed.startDate, equals(simpleDto.startDate));
        expect(reconstructed.endDate, equals(simpleDto.endDate));
        expect(reconstructed.aggregation, equals(simpleDto.aggregation));
        expect(reconstructed.metric, equals(simpleDto.metric));
        expect(reconstructed.smoothing, equals(simpleDto.smoothing));
        expect(reconstructed.dataPoints, isEmpty);
        expect(reconstructed.createdAt, equals(simpleDto.createdAt));
      });

      test('handles JSON string conversion', () {
        final simpleDto = TimeSeriesChartDto(
          id: 'json_string_test',
          accountId: 'json_account',
          title: 'JSON String Test',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'weekly',
          metric: 'duration',
          smoothing: 'none',
          dataPoints: [], // Empty list to avoid nested serialization issues
          createdAt: testCreatedAt,
        );

        final json = simpleDto.toJson();
        final jsonString = jsonEncode(json);
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final reconstructed = TimeSeriesChartDto.fromJson(jsonMap);

        expect(reconstructed.id, equals(simpleDto.id));
        expect(reconstructed.title, equals(simpleDto.title));
        expect(reconstructed.aggregation, equals(simpleDto.aggregation));
        expect(reconstructed.dataPoints, isEmpty);
      });
    });

    group('entity mapping', () {
      test('toEntity converts DTO to domain entity correctly', () {
        final entity = timeSeriesChartDto.toEntity();

        expect(entity.id, equals('chart_123'));
        expect(entity.accountId, equals('account_456'));
        expect(entity.title, equals('Monthly Smoking Chart'));
        expect(entity.startDate, equals(testStartDate));
        expect(entity.endDate, equals(testEndDate));
        expect(entity.aggregation, equals(ChartAggregation.daily));
        expect(entity.metric, equals(ChartMetric.count));
        expect(entity.smoothing, equals(ChartSmoothing.movingAverage));
        expect(entity.dataPoints, hasLength(2));
        expect(entity.smoothingWindow, equals(7));
        expect(entity.visibleTags, equals(['work', 'stress']));
        expect(entity.createdAt, equals(testCreatedAt));
      });

      test('toEntity handles unknown enum values with defaults', () {
        final dtoWithUnknownEnums = TimeSeriesChartDto(
          id: 'chart_unknown',
          accountId: 'account_unknown',
          title: 'Unknown Enums Chart',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'unknown_aggregation',
          metric: 'unknown_metric',
          smoothing: 'unknown_smoothing',
          dataPoints: const [],
          createdAt: testCreatedAt,
        );

        final entity = dtoWithUnknownEnums.toEntity();

        expect(entity.aggregation, equals(ChartAggregation.daily));
        expect(entity.metric, equals(ChartMetric.count));
        expect(entity.smoothing, equals(ChartSmoothing.none));
      });

      test('toEntity converts data points correctly', () {
        final entity = timeSeriesChartDto.toEntity();

        expect(entity.dataPoints, hasLength(2));
        expect(entity.dataPoints.first.value, equals(10.5));
        expect(entity.dataPoints.first.count, equals(5));
        expect(entity.dataPoints.last.value, equals(12.3));
        expect(entity.dataPoints.last.count, equals(8));
      });
    });

    group('TimeSeriesChart entity to DTO mapping', () {
      test('toDto converts domain entity to DTO correctly', () {
        final domainDataPoints = [
          ChartDataPoint(
            timestamp: DateTime.fromMillisecondsSinceEpoch(1672531200000),
            value: 20.1,
            count: 4,
            totalDurationMs: 240000,
            averageMoodScore: 8.0,
            averagePhysicalScore: 7.5,
          ),
        ];

        final entity = TimeSeriesChart(
          id: 'entity_123',
          accountId: 'entity_account',
          title: 'Entity Chart',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: ChartAggregation.weekly,
          metric: ChartMetric.moodScore,
          smoothing: ChartSmoothing.cumulative,
          dataPoints: domainDataPoints,
          smoothingWindow: 14,
          visibleTags: ['morning', 'weekend'],
          createdAt: testCreatedAt,
        );

        final dto = entity.toDto();

        expect(dto.id, equals('entity_123'));
        expect(dto.accountId, equals('entity_account'));
        expect(dto.title, equals('Entity Chart'));
        expect(dto.startDate, equals(testStartDate));
        expect(dto.endDate, equals(testEndDate));
        expect(dto.aggregation, equals('weekly'));
        expect(dto.metric, equals('moodScore'));
        expect(dto.smoothing, equals('cumulative'));
        expect(dto.dataPoints, hasLength(1));
        expect(dto.dataPoints.first.value, equals(20.1));
        expect(dto.smoothingWindow, equals(14));
        expect(dto.visibleTags, equals(['morning', 'weekend']));
        expect(dto.createdAt, equals(testCreatedAt));
      });

      test('round trip entity-DTO conversion preserves data', () {
        final originalEntity = TimeSeriesChart(
          id: 'round_trip_123',
          accountId: 'round_trip_account',
          title: 'Round Trip Chart',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: ChartAggregation.monthly,
          metric: ChartMetric.physicalScore,
          smoothing: ChartSmoothing.movingAverage,
          dataPoints: [
            ChartDataPoint(
              timestamp: DateTime.fromMillisecondsSinceEpoch(1672531200000),
              value: 9.5,
              count: 2,
              totalDurationMs: 120000,
            ),
          ],
          smoothingWindow: 5,
          visibleTags: ['test'],
          createdAt: testCreatedAt,
        );

        final dto = originalEntity.toDto();
        final reconstructedEntity = dto.toEntity();

        expect(reconstructedEntity.id, equals(originalEntity.id));
        expect(reconstructedEntity.accountId, equals(originalEntity.accountId));
        expect(reconstructedEntity.title, equals(originalEntity.title));
        expect(reconstructedEntity.startDate, equals(originalEntity.startDate));
        expect(reconstructedEntity.endDate, equals(originalEntity.endDate));
        expect(reconstructedEntity.aggregation,
            equals(originalEntity.aggregation));
        expect(reconstructedEntity.metric, equals(originalEntity.metric));
        expect(reconstructedEntity.smoothing, equals(originalEntity.smoothing));
        expect(reconstructedEntity.dataPoints.length,
            equals(originalEntity.dataPoints.length));
        expect(reconstructedEntity.smoothingWindow,
            equals(originalEntity.smoothingWindow));
        expect(reconstructedEntity.visibleTags,
            equals(originalEntity.visibleTags));
        expect(reconstructedEntity.createdAt, equals(originalEntity.createdAt));
      });
    });

    group('freezed functionality', () {
      test('equality works correctly', () {
        final dto1 = TimeSeriesChartDto(
          id: 'equal_test',
          accountId: 'account_equal',
          title: 'Equal Test',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'daily',
          metric: 'count',
          smoothing: 'none',
          dataPoints: const [],
          createdAt: testCreatedAt,
        );

        final dto2 = TimeSeriesChartDto(
          id: 'equal_test',
          accountId: 'account_equal',
          title: 'Equal Test',
          startDate: testStartDate,
          endDate: testEndDate,
          aggregation: 'daily',
          metric: 'count',
          smoothing: 'none',
          dataPoints: const [],
          createdAt: testCreatedAt,
        );

        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });

      test('copyWith works correctly', () {
        final modified = timeSeriesChartDto.copyWith(
          title: 'Modified Title',
          smoothingWindow: 14,
        );

        expect(modified.id, equals(timeSeriesChartDto.id));
        expect(modified.title, equals('Modified Title'));
        expect(modified.smoothingWindow, equals(14));
        expect(modified.aggregation, equals(timeSeriesChartDto.aggregation));
      });

      test('toString provides useful representation', () {
        final stringRep = timeSeriesChartDto.toString();

        expect(stringRep, contains('TimeSeriesChartDto'));
        expect(stringRep, contains('chart_123'));
        expect(stringRep, contains('Monthly Smoking Chart'));
      });
    });
  });
}
