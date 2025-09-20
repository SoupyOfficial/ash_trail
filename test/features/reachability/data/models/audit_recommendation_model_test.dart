// Unit tests for AuditRecommendationModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/reachability/data/models/audit_recommendation_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';

void main() {
  group('AuditRecommendationModel', () {
    late AuditRecommendationModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = const AuditRecommendationModel(
        elementId: 'button-submit',
        type: 'increase_touch_target',
        description: 'Button is too small for comfortable tapping',
        priority: 1,
        suggestedFix: 'Increase button size to at least 48dp',
      );

      json = {
        'elementId': 'button-submit',
        'type': 'increase_touch_target',
        'description': 'Button is too small for comfortable tapping',
        'priority': 1,
        'suggestedFix': 'Increase button size to at least 48dp',
      };
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['elementId'], equals('button-submit'));
        expect(result['type'], equals('increase_touch_target'));
        expect(result['description'],
            equals('Button is too small for comfortable tapping'));
        expect(result['priority'], equals(1));
        expect(result['suggestedFix'],
            equals('Increase button size to at least 48dp'));
      });

      test('should serialize with null suggestedFix', () {
        // arrange
        const modelWithoutFix = AuditRecommendationModel(
          elementId: 'element-1',
          type: 'move_to_easy_reach',
          description: 'Element is in difficult reach zone',
          priority: 2,
        );

        // act
        final result = modelWithoutFix.toJson();

        // assert
        expect(result['elementId'], equals('element-1'));
        expect(result['type'], equals('move_to_easy_reach'));
        expect(result['suggestedFix'], isNull);
        expect(result['priority'], equals(2));
      });

      test('should serialize different recommendation types', () {
        final recommendations = [
          ('move_to_easy_reach', 1, 'Move to thumb-friendly zone'),
          ('increase_touch_target', 2, 'Make tap target bigger'),
          ('add_accessibility_label', 3, 'Add semantic label'),
          ('add_alternative_access', 2, 'Provide voice control'),
          ('improve_contrast', 1, 'Increase color contrast'),
        ];

        for (final (type, priority, description) in recommendations) {
          // arrange
          final testModel = AuditRecommendationModel(
            elementId: 'test-element',
            type: type,
            description: description,
            priority: priority,
            suggestedFix: 'Test fix for $type',
          );

          // act
          final result = testModel.toJson();

          // assert
          expect(result['type'], equals(type), reason: 'Failed for type $type');
          expect(result['priority'], equals(priority),
              reason: 'Failed for priority $priority');
        }
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        // act
        final result = AuditRecommendationModel.fromJson(json);

        // assert
        expect(result.elementId, equals('button-submit'));
        expect(result.type, equals('increase_touch_target'));
        expect(result.description,
            equals('Button is too small for comfortable tapping'));
        expect(result.priority, equals(1));
        expect(result.suggestedFix,
            equals('Increase button size to at least 48dp'));
      });

      test('should handle null suggestedFix in JSON', () {
        // arrange
        final jsonWithoutFix = {
          'elementId': 'element-2',
          'type': 'add_accessibility_label',
          'description': 'Missing semantic label',
          'priority': 3,
          'suggestedFix': null,
        };

        // act
        final result = AuditRecommendationModel.fromJson(jsonWithoutFix);

        // assert
        expect(result.elementId, equals('element-2'));
        expect(result.type, equals('add_accessibility_label'));
        expect(result.suggestedFix, isNull);
        expect(result.priority, equals(3));
      });

      test('should handle different numeric types for priority', () {
        // arrange
        final jsonWithDoublePriority = {
          'elementId': 'element-3',
          'type': 'improve_contrast',
          'description': 'Low contrast text',
          'priority': 2.0,
          'suggestedFix': 'Use darker text color',
        };

        // act
        final result =
            AuditRecommendationModel.fromJson(jsonWithDoublePriority);

        // assert
        expect(result.priority, equals(2));
        expect(result.type, equals('improve_contrast'));
      });

      test('should handle missing optional fields in JSON', () {
        // arrange
        final minimalJson = {
          'elementId': 'minimal-element',
          'type': 'move_to_easy_reach',
          'description': 'Element needs repositioning',
          'priority': 1,
        };

        // act
        final result = AuditRecommendationModel.fromJson(minimalJson);

        // assert
        expect(result.suggestedFix, isNull);
        expect(result.elementId, equals('minimal-element'));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.elementId, equals('button-submit'));
        expect(entity.type, equals(RecommendationType.increaseTouchTarget));
        expect(entity.description,
            equals('Button is too small for comfortable tapping'));
        expect(entity.priority, equals(1));
        expect(entity.suggestedFix,
            equals('Increase button size to at least 48dp'));
      });

      test('should handle all recommendation types in entity conversion', () {
        final typeMappings = [
          ('move_to_easy_reach', RecommendationType.moveToEasyReach),
          ('increase_touch_target', RecommendationType.increaseTouchTarget),
          ('add_accessibility_label', RecommendationType.addAccessibilityLabel),
          ('add_alternative_access', RecommendationType.addAlternativeAccess),
          ('improve_contrast', RecommendationType.improveContrast),
        ];

        for (final (stringType, enumType) in typeMappings) {
          // arrange
          final testModel = AuditRecommendationModel(
            elementId: 'test-element',
            type: stringType,
            description: 'Test description',
            priority: 2,
          );

          // act
          final entity = testModel.toEntity();

          // assert
          expect(entity.type, equals(enumType),
              reason: 'Failed for type $stringType');
        }
      });

      test('should handle unknown types in entity conversion', () {
        // arrange
        const unknownTypeModel = AuditRecommendationModel(
          elementId: 'unknown-element',
          type: 'unknown_type',
          description: 'Unknown recommendation type',
          priority: 3,
        );

        // act
        final entity = unknownTypeModel.toEntity();

        // assert - should default to moveToEasyReach for unknown types
        expect(entity.type, equals(RecommendationType.moveToEasyReach));
      });

      test('should create from entity correctly', () {
        // arrange
        const entity = AuditRecommendation(
          elementId: 'entity-button',
          type: RecommendationType.addAccessibilityLabel,
          description: 'Button needs semantic label',
          priority: 2,
          suggestedFix: 'Add meaningful accessibility label',
        );

        // act
        final result = AuditRecommendationModel.fromEntity(entity);

        // assert
        expect(result.elementId, equals('entity-button'));
        expect(result.type, equals('add_accessibility_label'));
        expect(result.description, equals('Button needs semantic label'));
        expect(result.priority, equals(2));
        expect(
            result.suggestedFix, equals('Add meaningful accessibility label'));
      });

      test('should handle null suggestedFix in entity conversion', () {
        // arrange
        const entityWithoutFix = AuditRecommendation(
          elementId: 'no-fix-element',
          type: RecommendationType.improveContrast,
          description: 'Contrast issues detected',
          priority: 1,
        );

        // act
        final model = AuditRecommendationModel.fromEntity(entityWithoutFix);
        final backToEntity = model.toEntity();

        // assert
        expect(model.suggestedFix, isNull);
        expect(backToEntity.suggestedFix, isNull);
      });
    });

    group('Equality and copying', () {
      test('should support equality comparison', () {
        // arrange
        final model2 = AuditRecommendationModel.fromJson(json);

        // act & assert
        expect(model == model2, isTrue);
        expect(model.hashCode, equals(model2.hashCode));
      });

      test('should support copyWith', () {
        // act
        final updated = model.copyWith(
          priority: 3,
          suggestedFix: 'Updated suggested fix',
        );

        // assert
        expect(updated.priority, equals(3));
        expect(updated.suggestedFix, equals('Updated suggested fix'));
        expect(updated.elementId, equals(model.elementId)); // unchanged
        expect(updated.type, equals(model.type)); // unchanged
      });

      test('should support copyWith with null suggestedFix', () {
        // act
        final updated = model.copyWith(suggestedFix: null);

        // assert
        expect(updated.suggestedFix, isNull);
        expect(updated.elementId, equals(model.elementId)); // unchanged
      });

      test('should support copyWith for all properties', () {
        // act
        final updated = model.copyWith(
          elementId: 'new-element',
          type: 'move_to_easy_reach',
          description: 'New description',
          priority: 2,
          suggestedFix: 'New fix',
        );

        // assert
        expect(updated.elementId, equals('new-element'));
        expect(updated.type, equals('move_to_easy_reach'));
        expect(updated.description, equals('New description'));
        expect(updated.priority, equals(2));
        expect(updated.suggestedFix, equals('New fix'));
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // act
        final jsonData = model.toJson();
        final reconstructed = AuditRecommendationModel.fromJson(jsonData);

        // assert
        expect(reconstructed.elementId, equals(model.elementId));
        expect(reconstructed.type, equals(model.type));
        expect(reconstructed.description, equals(model.description));
        expect(reconstructed.priority, equals(model.priority));
        expect(reconstructed.suggestedFix, equals(model.suggestedFix));
      });

      test('should maintain data integrity through entity round-trip', () {
        // act
        final entity = model.toEntity();
        final reconstructed = AuditRecommendationModel.fromEntity(entity);

        // assert
        expect(reconstructed.elementId, equals(model.elementId));
        expect(reconstructed.type, equals(model.type));
        expect(reconstructed.description, equals(model.description));
        expect(reconstructed.priority, equals(model.priority));
        expect(reconstructed.suggestedFix, equals(model.suggestedFix));
      });

      test('should handle round-trip with null suggestedFix', () {
        // arrange
        const modelWithoutFix = AuditRecommendationModel(
          elementId: 'test-element',
          type: 'improve_contrast',
          description: 'Contrast needs improvement',
          priority: 1,
        );

        // act
        final json = modelWithoutFix.toJson();
        final fromJson = AuditRecommendationModel.fromJson(json);
        final entity = modelWithoutFix.toEntity();
        final fromEntity = AuditRecommendationModel.fromEntity(entity);

        // assert
        expect(fromJson.suggestedFix, isNull);
        expect(fromEntity.suggestedFix, isNull);
      });
    });

    group('Priority handling', () {
      test('should handle all priority levels', () {
        final priorities = [1, 2, 3, 4, 5];

        for (final priority in priorities) {
          // arrange
          final testModel = AuditRecommendationModel(
            elementId: 'priority-test',
            type: 'increase_touch_target',
            description: 'Priority $priority test',
            priority: priority,
          );

          // act
          final json = testModel.toJson();
          final reconstructed = AuditRecommendationModel.fromJson(json);

          // assert
          expect(reconstructed.priority, equals(priority));
        }
      });

      test('should handle edge case priorities', () {
        final edgeCases = [0, 10, 100];

        for (final priority in edgeCases) {
          // arrange
          final testModel = AuditRecommendationModel(
            elementId: 'edge-case-test',
            type: 'add_accessibility_label',
            description: 'Edge case priority test',
            priority: priority,
          );

          // act - should not throw
          final json = testModel.toJson();
          final reconstructed = AuditRecommendationModel.fromJson(json);

          // assert
          expect(reconstructed.priority, equals(priority));
        }
      });
    });
  });
}
