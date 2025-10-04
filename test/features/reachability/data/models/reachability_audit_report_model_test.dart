// Unit tests for ReachabilityAuditReportModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:ash_trail/features/reachability/data/models/audit_recommendation_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_audit_report_model.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_zone_model.dart';
import 'package:ash_trail/features/reachability/data/models/ui_element_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReachabilityAuditReportModel', () {
    late ReachabilityAuditReportModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = ReachabilityAuditReportModel(
        id: 'test-report-123',
        timestamp: DateTime(2024, 1, 15, 14, 30, 45),
        screenName: 'Test Screen',
        screenWidth: 375.0,
        screenHeight: 812.0,
        elements: const [
          UiElementModel(
            id: 'button-1',
            label: 'Submit Button',
            bounds: Rect.fromLTWH(100.0, 200.0, 120.0, 48.0),
            type: 'button',
            isInteractive: true,
          ),
        ],
        zones: const [
          ReachabilityZoneModel(
            id: 'easy-zone',
            name: 'Easy Reach Zone',
            bounds: Rect.fromLTWH(0.0, 500.0, 375.0, 312.0),
            level: 'easy',
            description: 'Comfortable thumb zone',
          ),
        ],
        summary: const AuditSummaryModel(
          totalElements: 5,
          interactiveElements: 3,
          elementsInEasyReach: 2,
          elementsWithIssues: 1,
          avgTouchTargetSize: 45.5,
          accessibilityIssues: 0,
        ),
        recommendations: const [
          AuditRecommendationModel(
            elementId: 'button-1',
            type: 'increase_touch_target',
            priority: 1,
            description: 'Button is too small for comfortable tapping',
            suggestedFix: 'Increase button size to at least 48dp',
          ),
        ],
      );

      json = {
        'id': 'test-report-123',
        'timestamp': '2024-01-15T14:30:45.000',
        'screenName': 'Test Screen',
        'screenWidth': 375.0,
        'screenHeight': 812.0,
        'elements': [
          {
            'id': 'button-1',
            'label': 'Submit Button',
            'bounds': {
              'left': 100.0,
              'top': 200.0,
              'width': 120.0,
              'height': 48.0,
            },
            'type': 'button',
            'isInteractive': true,
          }
        ],
        'zones': [
          {
            'id': 'easy-zone',
            'name': 'Easy Reach Zone',
            'bounds': {
              'left': 0.0,
              'top': 500.0,
              'width': 375.0,
              'height': 312.0,
            },
            'level': 'easy',
            'description': 'Comfortable thumb zone',
          }
        ],
        'summary': {
          'totalElements': 5,
          'interactiveElements': 3,
          'elementsInEasyReach': 2,
          'elementsWithIssues': 1,
          'avgTouchTargetSize': 45.5,
          'accessibilityIssues': 0,
        },
        'recommendations': [
          {
            'elementId': 'button-1',
            'type': 'increase_touch_target',
            'priority': 1,
            'description': 'Button is too small for comfortable tapping',
            'suggestedFix': 'Increase button size to at least 48dp',
          }
        ],
      };
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['id'], equals('test-report-123'));
        expect(result['screenName'], equals('Test Screen'));
        expect(result['screenWidth'], equals(375.0));
        expect(result['screenHeight'], equals(812.0));
        expect(result['elements'], isA<List<UiElementModel>>());
        expect(result['zones'], isA<List<ReachabilityZoneModel>>());
        expect(result['summary'], isA<AuditSummaryModel>());
        expect(
            result['recommendations'], isA<List<AuditRecommendationModel>>());
      });

      test('should handle null recommendations in JSON', () {
        // arrange
        final modelWithoutRecs = model.copyWith(recommendations: null);

        // act
        final result = modelWithoutRecs.toJson();

        // assert
        expect(result['recommendations'], isNull);
      });

      test('should serialize timestamp correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['timestamp'], isA<String>());
        expect(result['timestamp'], contains('2024-01-15'));
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        // act
        final result = ReachabilityAuditReportModel.fromJson(json);

        // assert
        expect(result.id, equals('test-report-123'));
        expect(result.screenName, equals('Test Screen'));
        expect(result.screenWidth, equals(375.0));
        expect(result.screenHeight, equals(812.0));
        expect(result.elements, hasLength(1));
        expect(result.elements.first.bounds,
            equals(const Rect.fromLTWH(100.0, 200.0, 120.0, 48.0)));
        expect(result.zones, hasLength(1));
        expect(result.zones.first.bounds,
            equals(const Rect.fromLTWH(0.0, 500.0, 375.0, 312.0)));
        expect(result.summary.totalElements, equals(5));
        expect(result.recommendations, hasLength(1));
      });

      test('should handle null recommendations in JSON', () {
        // arrange
        final jsonWithoutRecs = Map<String, dynamic>.from(json);
        jsonWithoutRecs['recommendations'] = null;

        // act
        final result = ReachabilityAuditReportModel.fromJson(jsonWithoutRecs);

        // assert
        expect(result.recommendations, isNull);
      });

      test('should handle missing optional fields', () {
        // arrange
        final minimalJson = {
          'id': 'minimal-test',
          'timestamp': '2024-01-15T14:30:45.000',
          'screenName': 'Minimal Screen',
          'screenWidth': 300.0,
          'screenHeight': 600.0,
          'elements': <Map<String, dynamic>>[],
          'zones': <Map<String, dynamic>>[],
          'summary': {
            'totalElements': 0,
            'interactiveElements': 0,
            'elementsInEasyReach': 0,
            'elementsWithIssues': 0,
            'avgTouchTargetSize': 0.0,
            'accessibilityIssues': 0,
          },
        };

        // act
        final result = ReachabilityAuditReportModel.fromJson(minimalJson);

        // assert
        expect(result.id, equals('minimal-test'));
        expect(result.elements, isEmpty);
        expect(result.zones, isEmpty);
        expect(result.recommendations, isNull);
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.id, equals('test-report-123'));
        expect(entity.screenName, equals('Test Screen'));
        expect(entity.screenSize.width, equals(375.0));
        expect(entity.screenSize.height, equals(812.0));
        expect(entity.elements, hasLength(1));
        expect(entity.elements.first.bounds,
            equals(const Rect.fromLTWH(100.0, 200.0, 120.0, 48.0)));
        expect(entity.zones, hasLength(1));
        expect(entity.zones.first.bounds,
            equals(const Rect.fromLTWH(0.0, 500.0, 375.0, 312.0)));
        expect(entity.summary.totalElements, equals(5));
        expect(entity.recommendations, hasLength(1));
      });

      test('should handle null recommendations in entity conversion', () {
        // arrange
        final modelWithoutRecs = model.copyWith(recommendations: null);

        // act
        final entity = modelWithoutRecs.toEntity();

        // assert
        expect(entity.recommendations, isNull);
      });

      test('should create from entity correctly', () {
        // arrange
        final entity = ReachabilityAuditReport(
          id: 'entity-test',
          timestamp: DateTime(2024, 2, 1, 10, 30),
          screenName: 'Entity Screen',
          screenSize: const Size(414.0, 896.0),
          elements: const [],
          zones: const [],
          summary: const AuditSummary(
            totalElements: 10,
            interactiveElements: 5,
            elementsInEasyReach: 3,
            elementsWithIssues: 2,
            avgTouchTargetSize: 42.0,
            accessibilityIssues: 1,
          ),
        );

        // act
        final result = ReachabilityAuditReportModel.fromEntity(entity);

        // assert
        expect(result.id, equals('entity-test'));
        expect(result.screenName, equals('Entity Screen'));
        expect(result.screenWidth, equals(414.0));
        expect(result.screenHeight, equals(896.0));
        expect(result.summary.totalElements, equals(10));
        expect(result.recommendations, isNull);
      });
    });

    group('Equality and copying', () {
      test('should support equality comparison', () {
        // arrange
        final model2 = ReachabilityAuditReportModel.fromJson(json);

        // act & assert
        expect(model == model2, isTrue);
        expect(model.hashCode, equals(model2.hashCode));
      });

      test('should support copyWith', () {
        // act
        final updated = model.copyWith(
          screenName: 'Updated Screen',
          screenWidth: 400.0,
        );

        // assert
        expect(updated.screenName, equals('Updated Screen'));
        expect(updated.screenWidth, equals(400.0));
        expect(updated.id, equals(model.id)); // unchanged
        expect(updated.screenHeight, equals(model.screenHeight)); // unchanged
      });

      test('should support copyWith with null recommendations', () {
        // act
        final updated = model.copyWith(recommendations: null);

        // assert
        expect(updated.recommendations, isNull);
        expect(updated.id, equals(model.id)); // unchanged
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // Create a model that can serialize properly for round-trip
        final jsonData = {
          'id': 'test-report-123',
          'timestamp': '2024-01-15T14:30:45.000',
          'screenName': 'Test Screen',
          'screenWidth': 375.0,
          'screenHeight': 812.0,
          'elements': [
            {
              'id': 'button-1',
              'label': 'Submit Button',
              'bounds': {
                'left': 100.0,
                'top': 200.0,
                'width': 120.0,
                'height': 48.0,
              },
              'type': 'button',
              'isInteractive': true,
            }
          ],
          'zones': [
            {
              'id': 'easy-zone',
              'name': 'Easy Reach Zone',
              'bounds': {
                'left': 0.0,
                'top': 500.0,
                'width': 375.0,
                'height': 312.0,
              },
              'level': 'easy',
              'description': 'Comfortable thumb zone',
            }
          ],
          'summary': {
            'totalElements': 5,
            'interactiveElements': 3,
            'elementsInEasyReach': 2,
            'elementsWithIssues': 1,
            'avgTouchTargetSize': 45.5,
            'accessibilityIssues': 0,
          },
          'recommendations': [
            {
              'elementId': 'button-1',
              'type': 'increase_touch_target',
              'priority': 1,
              'description': 'Button is too small for comfortable tapping',
              'suggestedFix': 'Increase button size to at least 48dp',
            }
          ],
        };

        // act
        final modelFromJson = ReachabilityAuditReportModel.fromJson(jsonData);

        // assert
        expect(modelFromJson.id, equals('test-report-123'));
        expect(modelFromJson.timestamp,
            equals(DateTime.parse('2024-01-15T14:30:45.000')));
        expect(modelFromJson.screenName, equals('Test Screen'));
        expect(modelFromJson.screenWidth, equals(375.0));
        expect(modelFromJson.screenHeight, equals(812.0));
        expect(modelFromJson.elements.length, equals(1));
        expect(modelFromJson.elements.first.bounds,
            equals(const Rect.fromLTWH(100.0, 200.0, 120.0, 48.0)));
        expect(modelFromJson.zones.length, equals(1));
        expect(modelFromJson.zones.first.bounds,
            equals(const Rect.fromLTWH(0.0, 500.0, 375.0, 312.0)));
        expect(modelFromJson.summary.totalElements, equals(5));
        expect(modelFromJson.recommendations?.length, equals(1));
      });

      test('should maintain data integrity through entity round-trip', () {
        // act
        final entity = model.toEntity();
        final reconstructed = ReachabilityAuditReportModel.fromEntity(entity);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.screenName, equals(model.screenName));
        expect(reconstructed.screenWidth, equals(model.screenWidth));
        expect(reconstructed.screenHeight, equals(model.screenHeight));
        expect(reconstructed.elements, hasLength(1));
        expect(reconstructed.elements.first.bounds,
            equals(model.elements.first.bounds));
        expect(reconstructed.zones, hasLength(1));
        expect(
            reconstructed.zones.first.bounds, equals(model.zones.first.bounds));
      });
    });
  });
}
