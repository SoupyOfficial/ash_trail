// Unit tests for AuditSummaryModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';

void main() {
  group('AuditSummaryModel', () {
    late AuditSummaryModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = const AuditSummaryModel(
        totalElements: 10,
        interactiveElements: 7,
        elementsInEasyReach: 5,
        elementsWithIssues: 3,
        avgTouchTargetSize: 46.5,
        accessibilityIssues: 2,
      );

      json = {
        'totalElements': 10,
        'interactiveElements': 7,
        'elementsInEasyReach': 5,
        'elementsWithIssues': 3,
        'avgTouchTargetSize': 46.5,
        'accessibilityIssues': 2,
      };
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['totalElements'], equals(10));
        expect(result['interactiveElements'], equals(7));
        expect(result['elementsInEasyReach'], equals(5));
        expect(result['elementsWithIssues'], equals(3));
        expect(result['avgTouchTargetSize'], equals(46.5));
        expect(result['accessibilityIssues'], equals(2));
      });

      test('should serialize with zero values', () {
        // arrange
        const emptyModel = AuditSummaryModel(
          totalElements: 0,
          interactiveElements: 0,
          elementsInEasyReach: 0,
          elementsWithIssues: 0,
          avgTouchTargetSize: 0.0,
          accessibilityIssues: 0,
        );

        // act
        final result = emptyModel.toJson();

        // assert
        expect(result['totalElements'], equals(0));
        expect(result['interactiveElements'], equals(0));
        expect(result['elementsInEasyReach'], equals(0));
        expect(result['elementsWithIssues'], equals(0));
        expect(result['avgTouchTargetSize'], equals(0.0));
        expect(result['accessibilityIssues'], equals(0));
      });

      test('should serialize with maximum values', () {
        // arrange
        const maxModel = AuditSummaryModel(
          totalElements: 100,
          interactiveElements: 95,
          elementsInEasyReach: 90,
          elementsWithIssues: 50,
          avgTouchTargetSize: 80.5,
          accessibilityIssues: 25,
        );

        // act
        final result = maxModel.toJson();

        // assert
        expect(result['totalElements'], equals(100));
        expect(result['interactiveElements'], equals(95));
        expect(result['elementsInEasyReach'], equals(90));
        expect(result['elementsWithIssues'], equals(50));
        expect(result['avgTouchTargetSize'], equals(80.5));
        expect(result['accessibilityIssues'], equals(25));
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        // act
        final result = AuditSummaryModel.fromJson(json);

        // assert
        expect(result.totalElements, equals(10));
        expect(result.interactiveElements, equals(7));
        expect(result.elementsInEasyReach, equals(5));
        expect(result.elementsWithIssues, equals(3));
        expect(result.avgTouchTargetSize, equals(46.5));
        expect(result.accessibilityIssues, equals(2));
      });

      test('should handle different numeric types in JSON', () {
        // arrange
        final jsonWithDoubles = {
          'totalElements': 15.0,
          'interactiveElements': 12.0,
          'elementsInEasyReach': 8.0,
          'elementsWithIssues': 4.0,
          'avgTouchTargetSize': 48,
          'accessibilityIssues': 3.0,
        };

        // act
        final result = AuditSummaryModel.fromJson(jsonWithDoubles);

        // assert
        expect(result.totalElements, equals(15));
        expect(result.interactiveElements, equals(12));
        expect(result.elementsInEasyReach, equals(8));
        expect(result.elementsWithIssues, equals(4));
        expect(result.avgTouchTargetSize, equals(48.0));
        expect(result.accessibilityIssues, equals(3));
      });

      test('should handle edge case values in JSON', () {
        // arrange
        final edgeCaseJson = {
          'totalElements': 1,
          'interactiveElements': 1,
          'elementsInEasyReach': 0,
          'elementsWithIssues': 1,
          'avgTouchTargetSize': 24.0,
          'accessibilityIssues': 0,
        };

        // act
        final result = AuditSummaryModel.fromJson(edgeCaseJson);

        // assert
        expect(result.totalElements, equals(1));
        expect(result.interactiveElements, equals(1));
        expect(result.elementsInEasyReach, equals(0));
        expect(result.elementsWithIssues, equals(1));
        expect(result.avgTouchTargetSize, equals(24.0));
        expect(result.accessibilityIssues, equals(0));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.totalElements, equals(10));
        expect(entity.interactiveElements, equals(7));
        expect(entity.elementsInEasyReach, equals(5));
        expect(entity.elementsWithIssues, equals(3));
        expect(entity.avgTouchTargetSize, equals(46.5));
        expect(entity.accessibilityIssues, equals(2));
      });

      test('should create from entity correctly', () {
        // arrange
        const entity = AuditSummary(
          totalElements: 20,
          interactiveElements: 15,
          elementsInEasyReach: 12,
          elementsWithIssues: 5,
          avgTouchTargetSize: 52.3,
          accessibilityIssues: 3,
        );

        // act
        final result = AuditSummaryModel.fromEntity(entity);

        // assert
        expect(result.totalElements, equals(20));
        expect(result.interactiveElements, equals(15));
        expect(result.elementsInEasyReach, equals(12));
        expect(result.elementsWithIssues, equals(5));
        expect(result.avgTouchTargetSize, equals(52.3));
        expect(result.accessibilityIssues, equals(3));
      });

      test('should handle perfect audit scores', () {
        // arrange - perfect audit with no issues
        const perfectEntity = AuditSummary(
          totalElements: 10,
          interactiveElements: 8,
          elementsInEasyReach: 8,
          elementsWithIssues: 0,
          avgTouchTargetSize: 48.0,
          accessibilityIssues: 0,
        );

        // act
        final modelFromEntity = AuditSummaryModel.fromEntity(perfectEntity);
        final backToEntity = modelFromEntity.toEntity();

        // assert
        expect(backToEntity.elementsWithIssues, equals(0));
        expect(backToEntity.accessibilityIssues, equals(0));
        expect(backToEntity.elementsInEasyReach,
            equals(backToEntity.interactiveElements));
      });
    });

    group('Equality and copying', () {
      test('should support equality comparison', () {
        // arrange
        final model2 = AuditSummaryModel.fromJson(json);

        // act & assert
        expect(model == model2, isTrue);
        expect(model.hashCode, equals(model2.hashCode));
      });

      test('should support copyWith', () {
        // act
        final updated = model.copyWith(
          totalElements: 15,
          avgTouchTargetSize: 50.0,
        );

        // assert
        expect(updated.totalElements, equals(15));
        expect(updated.avgTouchTargetSize, equals(50.0));
        expect(updated.interactiveElements,
            equals(model.interactiveElements)); // unchanged
        expect(updated.elementsInEasyReach,
            equals(model.elementsInEasyReach)); // unchanged
      });

      test('should support copyWith for all properties', () {
        // act
        final updated = model.copyWith(
          totalElements: 25,
          interactiveElements: 20,
          elementsInEasyReach: 18,
          elementsWithIssues: 7,
          avgTouchTargetSize: 55.2,
          accessibilityIssues: 4,
        );

        // assert
        expect(updated.totalElements, equals(25));
        expect(updated.interactiveElements, equals(20));
        expect(updated.elementsInEasyReach, equals(18));
        expect(updated.elementsWithIssues, equals(7));
        expect(updated.avgTouchTargetSize, equals(55.2));
        expect(updated.accessibilityIssues, equals(4));
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // act
        final jsonData = model.toJson();
        final reconstructed = AuditSummaryModel.fromJson(jsonData);

        // assert
        expect(reconstructed.totalElements, equals(model.totalElements));
        expect(reconstructed.interactiveElements,
            equals(model.interactiveElements));
        expect(reconstructed.elementsInEasyReach,
            equals(model.elementsInEasyReach));
        expect(
            reconstructed.elementsWithIssues, equals(model.elementsWithIssues));
        expect(
            reconstructed.avgTouchTargetSize, equals(model.avgTouchTargetSize));
        expect(reconstructed.accessibilityIssues,
            equals(model.accessibilityIssues));
      });

      test('should maintain data integrity through entity round-trip', () {
        // act
        final entity = model.toEntity();
        final reconstructed = AuditSummaryModel.fromEntity(entity);

        // assert
        expect(reconstructed.totalElements, equals(model.totalElements));
        expect(reconstructed.interactiveElements,
            equals(model.interactiveElements));
        expect(reconstructed.elementsInEasyReach,
            equals(model.elementsInEasyReach));
        expect(
            reconstructed.elementsWithIssues, equals(model.elementsWithIssues));
        expect(
            reconstructed.avgTouchTargetSize, equals(model.avgTouchTargetSize));
        expect(reconstructed.accessibilityIssues,
            equals(model.accessibilityIssues));
      });
    });

    group('Data validation scenarios', () {
      test('should handle reasonable audit results', () {
        final scenarios = [
          // Small app
          (5, 3, 2, 1, 44.0, 1),
          // Medium app
          (25, 18, 15, 3, 47.5, 2),
          // Large app
          (100, 75, 60, 15, 49.2, 8),
        ];

        for (final (total, interactive, easy, issues, avgSize, a11yIssues)
            in scenarios) {
          // arrange
          final testModel = AuditSummaryModel(
            totalElements: total,
            interactiveElements: interactive,
            elementsInEasyReach: easy,
            elementsWithIssues: issues,
            avgTouchTargetSize: avgSize,
            accessibilityIssues: a11yIssues,
          );

          // act & assert - no exceptions during serialization
          final json = testModel.toJson();
          final reconstructed = AuditSummaryModel.fromJson(json);
          expect(reconstructed.totalElements, equals(total));
          expect(reconstructed.avgTouchTargetSize, equals(avgSize));
        }
      });

      test('should handle zero interactive elements', () {
        // arrange - app with only static content
        const staticModel = AuditSummaryModel(
          totalElements: 10,
          interactiveElements: 0,
          elementsInEasyReach: 0,
          elementsWithIssues: 0,
          avgTouchTargetSize: 0.0,
          accessibilityIssues: 0,
        );

        // act
        final json = staticModel.toJson();
        final reconstructed = AuditSummaryModel.fromJson(json);

        // assert
        expect(reconstructed.interactiveElements, equals(0));
        expect(reconstructed.avgTouchTargetSize, equals(0.0));
      });
    });
  });
}
