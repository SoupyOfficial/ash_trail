import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/charts_time_series/data/models/chart_data_point_dto.dart';
import 'package:ash_trail/features/charts_time_series/domain/entities/chart_data_point.dart';

void main() {
  group('ChartDataPointDto', () {
    late ChartDataPointDto chartDataPointDto;
    late DateTime testTimestamp;

    setUp(() {
      testTimestamp = DateTime.fromMillisecondsSinceEpoch(
          1672531200000); // 2023-01-01 00:00:00 UTC

      chartDataPointDto = ChartDataPointDto(
        timestamp: testTimestamp,
        value: 15.7,
        count: 6,
        totalDurationMs: 360000, // 6 minutes
        averageMoodScore: 8.2,
        averagePhysicalScore: 7.4,
      );
    });

    group('constructor', () {
      test('creates instance with all fields', () {
        expect(chartDataPointDto.timestamp, equals(testTimestamp));
        expect(chartDataPointDto.value, equals(15.7));
        expect(chartDataPointDto.count, equals(6));
        expect(chartDataPointDto.totalDurationMs, equals(360000));
        expect(chartDataPointDto.averageMoodScore, equals(8.2));
        expect(chartDataPointDto.averagePhysicalScore, equals(7.4));
      });

      test('creates instance with only required fields', () {
        final minimalDto = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 10.0,
          count: 3,
          totalDurationMs: 180000,
        );

        expect(minimalDto.timestamp, equals(testTimestamp));
        expect(minimalDto.value, equals(10.0));
        expect(minimalDto.count, equals(3));
        expect(minimalDto.totalDurationMs, equals(180000));
        expect(minimalDto.averageMoodScore, isNull);
        expect(minimalDto.averagePhysicalScore, isNull);
      });

      test('handles zero values correctly', () {
        final zeroDto = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 0.0,
          count: 0,
          totalDurationMs: 0,
          averageMoodScore: 0.0,
          averagePhysicalScore: 0.0,
        );

        expect(zeroDto.value, equals(0.0));
        expect(zeroDto.count, equals(0));
        expect(zeroDto.totalDurationMs, equals(0));
        expect(zeroDto.averageMoodScore, equals(0.0));
        expect(zeroDto.averagePhysicalScore, equals(0.0));
      });
    });

    group('JSON serialization', () {
      test('fromJson creates correct instance', () {
        final json = {
          'timestamp': testTimestamp.toIso8601String(),
          'value': 22.3,
          'count': 4,
          'totalDurationMs': 240000,
          'averageMoodScore': 9.1,
          'averagePhysicalScore': 8.5,
        };

        final dto = ChartDataPointDto.fromJson(json);

        expect(dto.timestamp, equals(testTimestamp));
        expect(dto.value, equals(22.3));
        expect(dto.count, equals(4));
        expect(dto.totalDurationMs, equals(240000));
        expect(dto.averageMoodScore, equals(9.1));
        expect(dto.averagePhysicalScore, equals(8.5));
      });

      test('fromJson handles null optional fields', () {
        final json = {
          'timestamp': testTimestamp.toIso8601String(),
          'value': 18.5,
          'count': 2,
          'totalDurationMs': 120000,
          'averageMoodScore': null,
          'averagePhysicalScore': null,
        };

        final dto = ChartDataPointDto.fromJson(json);

        expect(dto.timestamp, equals(testTimestamp));
        expect(dto.value, equals(18.5));
        expect(dto.count, equals(2));
        expect(dto.totalDurationMs, equals(120000));
        expect(dto.averageMoodScore, isNull);
        expect(dto.averagePhysicalScore, isNull);
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'timestamp': testTimestamp.toIso8601String(),
          'value': 14.2,
          'count': 7,
          'totalDurationMs': 420000,
        };

        final dto = ChartDataPointDto.fromJson(json);

        expect(dto.timestamp, equals(testTimestamp));
        expect(dto.value, equals(14.2));
        expect(dto.count, equals(7));
        expect(dto.totalDurationMs, equals(420000));
        expect(dto.averageMoodScore, isNull);
        expect(dto.averagePhysicalScore, isNull);
      });

      test('toJson produces correct map', () {
        final json = chartDataPointDto.toJson();

        expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
        expect(json['value'], equals(15.7));
        expect(json['count'], equals(6));
        expect(json['totalDurationMs'], equals(360000));
        expect(json['averageMoodScore'], equals(8.2));
        expect(json['averagePhysicalScore'], equals(7.4));
      });

      test('toJson handles null optional fields', () {
        final dtoWithNulls = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 12.0,
          count: 1,
          totalDurationMs: 60000,
        );

        final json = dtoWithNulls.toJson();

        expect(json['timestamp'], equals(testTimestamp.toIso8601String()));
        expect(json['value'], equals(12.0));
        expect(json['count'], equals(1));
        expect(json['totalDurationMs'], equals(60000));
        expect(json['averageMoodScore'], isNull);
        expect(json['averagePhysicalScore'], isNull);
      });

      test('round trip JSON serialization preserves data', () {
        final json = chartDataPointDto.toJson();
        final reconstructed = ChartDataPointDto.fromJson(json);

        expect(reconstructed, equals(chartDataPointDto));
      });

      test('round trip with null values preserves data', () {
        final dtoWithNulls = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 5.5,
          count: 2,
          totalDurationMs: 120000,
        );

        final json = dtoWithNulls.toJson();
        final reconstructed = ChartDataPointDto.fromJson(json);

        expect(reconstructed, equals(dtoWithNulls));
      });

      test('handles JSON string conversion', () {
        final jsonString = jsonEncode(chartDataPointDto.toJson());
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final reconstructed = ChartDataPointDto.fromJson(jsonMap);

        expect(reconstructed, equals(chartDataPointDto));
      });

      test('handles nested JSON arrays', () {
        final dtoList = [
          chartDataPointDto,
          ChartDataPointDto(
            timestamp: testTimestamp.add(const Duration(days: 1)),
            value: 20.1,
            count: 8,
            totalDurationMs: 480000,
          ),
        ];

        final jsonList = dtoList.map((dto) => dto.toJson()).toList();
        final jsonString = jsonEncode(jsonList);
        final reconstructedJsonList = jsonDecode(jsonString) as List<dynamic>;
        final reconstructedDtos = reconstructedJsonList
            .map((json) =>
                ChartDataPointDto.fromJson(json as Map<String, dynamic>))
            .toList();

        expect(reconstructedDtos, hasLength(2));
        expect(reconstructedDtos[0], equals(dtoList[0]));
        expect(reconstructedDtos[1], equals(dtoList[1]));
      });
    });

    group('entity mapping', () {
      test('toEntity converts DTO to domain entity correctly', () {
        final entity = chartDataPointDto.toEntity();

        expect(entity.timestamp, equals(testTimestamp));
        expect(entity.value, equals(15.7));
        expect(entity.count, equals(6));
        expect(entity.totalDurationMs, equals(360000));
        expect(entity.averageMoodScore, equals(8.2));
        expect(entity.averagePhysicalScore, equals(7.4));
      });

      test('toEntity handles null optional fields', () {
        final dtoWithNulls = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 11.3,
          count: 4,
          totalDurationMs: 240000,
        );

        final entity = dtoWithNulls.toEntity();

        expect(entity.timestamp, equals(testTimestamp));
        expect(entity.value, equals(11.3));
        expect(entity.count, equals(4));
        expect(entity.totalDurationMs, equals(240000));
        expect(entity.averageMoodScore, isNull);
        expect(entity.averagePhysicalScore, isNull);
      });

      test('toEntity preserves precision for double values', () {
        final preciseDto = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 3.14159,
          count: 1,
          totalDurationMs: 123456,
          averageMoodScore: 7.89123,
          averagePhysicalScore: 6.54321,
        );

        final entity = preciseDto.toEntity();

        expect(entity.value, equals(3.14159));
        expect(entity.averageMoodScore, equals(7.89123));
        expect(entity.averagePhysicalScore, equals(6.54321));
      });
    });

    group('ChartDataPoint entity to DTO mapping', () {
      test('toDto converts domain entity to DTO correctly', () {
        final entity = ChartDataPoint(
          timestamp: testTimestamp,
          value: 25.8,
          count: 9,
          totalDurationMs: 540000,
          averageMoodScore: 9.5,
          averagePhysicalScore: 8.7,
        );

        final dto = entity.toDto();

        expect(dto.timestamp, equals(testTimestamp));
        expect(dto.value, equals(25.8));
        expect(dto.count, equals(9));
        expect(dto.totalDurationMs, equals(540000));
        expect(dto.averageMoodScore, equals(9.5));
        expect(dto.averagePhysicalScore, equals(8.7));
      });

      test('toDto handles null optional fields', () {
        final entity = ChartDataPoint(
          timestamp: testTimestamp,
          value: 13.6,
          count: 5,
          totalDurationMs: 300000,
        );

        final dto = entity.toDto();

        expect(dto.timestamp, equals(testTimestamp));
        expect(dto.value, equals(13.6));
        expect(dto.count, equals(5));
        expect(dto.totalDurationMs, equals(300000));
        expect(dto.averageMoodScore, isNull);
        expect(dto.averagePhysicalScore, isNull);
      });

      test('round trip entity-DTO conversion preserves data', () {
        final originalEntity = ChartDataPoint(
          timestamp: testTimestamp,
          value: 19.4,
          count: 7,
          totalDurationMs: 420000,
          averageMoodScore: 8.8,
          averagePhysicalScore: 7.9,
        );

        final dto = originalEntity.toDto();
        final reconstructedEntity = dto.toEntity();

        expect(reconstructedEntity.timestamp, equals(originalEntity.timestamp));
        expect(reconstructedEntity.value, equals(originalEntity.value));
        expect(reconstructedEntity.count, equals(originalEntity.count));
        expect(reconstructedEntity.totalDurationMs,
            equals(originalEntity.totalDurationMs));
        expect(reconstructedEntity.averageMoodScore,
            equals(originalEntity.averageMoodScore));
        expect(reconstructedEntity.averagePhysicalScore,
            equals(originalEntity.averagePhysicalScore));
      });

      test('round trip with null values preserves data', () {
        final originalEntity = ChartDataPoint(
          timestamp: testTimestamp,
          value: 16.2,
          count: 3,
          totalDurationMs: 180000,
        );

        final dto = originalEntity.toDto();
        final reconstructedEntity = dto.toEntity();

        expect(reconstructedEntity.timestamp, equals(originalEntity.timestamp));
        expect(reconstructedEntity.value, equals(originalEntity.value));
        expect(reconstructedEntity.count, equals(originalEntity.count));
        expect(reconstructedEntity.totalDurationMs,
            equals(originalEntity.totalDurationMs));
        expect(reconstructedEntity.averageMoodScore, isNull);
        expect(reconstructedEntity.averagePhysicalScore, isNull);
      });
    });

    group('freezed functionality', () {
      test('equality works correctly', () {
        final dto1 = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 12.5,
          count: 4,
          totalDurationMs: 240000,
          averageMoodScore: 7.5,
          averagePhysicalScore: 6.8,
        );

        final dto2 = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 12.5,
          count: 4,
          totalDurationMs: 240000,
          averageMoodScore: 7.5,
          averagePhysicalScore: 6.8,
        );

        expect(dto1, equals(dto2));
        expect(dto1.hashCode, equals(dto2.hashCode));
      });

      test('inequality works correctly', () {
        final dto1 = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 12.5,
          count: 4,
          totalDurationMs: 240000,
        );

        final dto2 = ChartDataPointDto(
          timestamp: testTimestamp,
          value: 12.6, // Different value
          count: 4,
          totalDurationMs: 240000,
        );

        expect(dto1, isNot(equals(dto2)));
        expect(dto1.hashCode, isNot(equals(dto2.hashCode)));
      });

      test('copyWith works correctly', () {
        final modified = chartDataPointDto.copyWith(
          value: 30.0,
          count: 10,
        );

        expect(modified.timestamp, equals(chartDataPointDto.timestamp));
        expect(modified.value, equals(30.0));
        expect(modified.count, equals(10));
        expect(modified.totalDurationMs,
            equals(chartDataPointDto.totalDurationMs));
        expect(modified.averageMoodScore,
            equals(chartDataPointDto.averageMoodScore));
        expect(modified.averagePhysicalScore,
            equals(chartDataPointDto.averagePhysicalScore));
      });

      test('copyWith can set null values', () {
        final modified = chartDataPointDto.copyWith(
          averageMoodScore: null,
          averagePhysicalScore: null,
        );

        expect(modified.timestamp, equals(chartDataPointDto.timestamp));
        expect(modified.value, equals(chartDataPointDto.value));
        expect(modified.count, equals(chartDataPointDto.count));
        expect(modified.totalDurationMs,
            equals(chartDataPointDto.totalDurationMs));
        expect(modified.averageMoodScore, isNull);
        expect(modified.averagePhysicalScore, isNull);
      });

      test('toString provides useful representation', () {
        final stringRep = chartDataPointDto.toString();

        expect(stringRep, contains('ChartDataPointDto'));
        expect(stringRep, contains('15.7'));
        expect(stringRep, contains('6'));
        expect(stringRep, contains('360000'));
      });
    });

    group('edge cases and validation', () {
      test('handles extreme timestamp values', () {
        final extremeTimestamp =
            DateTime.fromMillisecondsSinceEpoch(0); // Unix epoch
        final dto = ChartDataPointDto(
          timestamp: extremeTimestamp,
          value: 1.0,
          count: 1,
          totalDurationMs: 1000,
        );

        expect(dto.timestamp, equals(extremeTimestamp));

        final json = dto.toJson();
        final reconstructed = ChartDataPointDto.fromJson(json);
        expect(reconstructed.timestamp, equals(extremeTimestamp));
      });

      test('handles very large values', () {
        final largeDto = ChartDataPointDto(
          timestamp: testTimestamp,
          value: double.maxFinite,
          count: 999999999,
          totalDurationMs: 999999999,
          averageMoodScore: 10.0,
          averagePhysicalScore: 10.0,
        );

        expect(largeDto.value, equals(double.maxFinite));
        expect(largeDto.count, equals(999999999));
        expect(largeDto.totalDurationMs, equals(999999999));
      });

      test('handles very small values', () {
        final smallDto = ChartDataPointDto(
          timestamp: testTimestamp,
          value: double.minPositive,
          count: 0,
          totalDurationMs: 0,
          averageMoodScore: 0.0,
          averagePhysicalScore: 0.0,
        );

        expect(smallDto.value, equals(double.minPositive));
        expect(smallDto.count, equals(0));
        expect(smallDto.totalDurationMs, equals(0));
        expect(smallDto.averageMoodScore, equals(0.0));
        expect(smallDto.averagePhysicalScore, equals(0.0));
      });
    });
  });
}
