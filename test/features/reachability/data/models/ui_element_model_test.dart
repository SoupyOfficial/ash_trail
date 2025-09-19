// Unit tests for UiElementModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:ash_trail/features/reachability/data/models/ui_element_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';

void main() {
  group('UiElementModel', () {
    late UiElementModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = const UiElementModel(
        id: 'button-test',
        label: 'Test Button',
        left: 50.0,
        top: 100.0,
        width: 120.0,
        height: 48.0,
        type: 'button',
        isInteractive: true,
        semanticLabel: 'Submit form button',
        hasAlternativeAccess: false,
      );

      json = {
        'id': 'button-test',
        'label': 'Test Button',
        'left': 50.0,
        'top': 100.0,
        'width': 120.0,
        'height': 48.0,
        'type': 'button',
        'isInteractive': true,
        'semanticLabel': 'Submit form button',
        'hasAlternativeAccess': false,
      };
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['id'], equals('button-test'));
        expect(result['label'], equals('Test Button'));
        expect(result['left'], equals(50.0));
        expect(result['top'], equals(100.0));
        expect(result['width'], equals(120.0));
        expect(result['height'], equals(48.0));
        expect(result['type'], equals('button'));
        expect(result['isInteractive'], equals(true));
        expect(result['semanticLabel'], equals('Submit form button'));
        expect(result['hasAlternativeAccess'], equals(false));
      });

      test('should serialize with null optional fields', () {
        // arrange
        const modelWithNulls = UiElementModel(
          id: 'simple-button',
          label: 'Simple',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 40.0,
          type: 'button',
          isInteractive: true,
        );

        // act
        final result = modelWithNulls.toJson();

        // assert
        expect(result['semanticLabel'], isNull);
        expect(result['hasAlternativeAccess'], isNull);
        expect(result['id'], equals('simple-button'));
      });

      test('should serialize boolean fields correctly', () {
        // arrange
        const interactiveElement = UiElementModel(
          id: 'interactive',
          label: 'Button',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 40.0,
          type: 'button',
          isInteractive: true,
          hasAlternativeAccess: true,
        );

        const nonInteractiveElement = UiElementModel(
          id: 'text',
          label: 'Text',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 20.0,
          type: 'text',
          isInteractive: false,
          hasAlternativeAccess: false,
        );

        // act
        final interactiveJson = interactiveElement.toJson();
        final nonInteractiveJson = nonInteractiveElement.toJson();

        // assert
        expect(interactiveJson['isInteractive'], isTrue);
        expect(interactiveJson['hasAlternativeAccess'], isTrue);
        expect(nonInteractiveJson['isInteractive'], isFalse);
        expect(nonInteractiveJson['hasAlternativeAccess'], isFalse);
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        // act
        final result = UiElementModel.fromJson(json);

        // assert
        expect(result.id, equals('button-test'));
        expect(result.label, equals('Test Button'));
        expect(result.left, equals(50.0));
        expect(result.top, equals(100.0));
        expect(result.width, equals(120.0));
        expect(result.height, equals(48.0));
        expect(result.type, equals('button'));
        expect(result.isInteractive, equals(true));
        expect(result.semanticLabel, equals('Submit form button'));
        expect(result.hasAlternativeAccess, equals(false));
      });

      test('should handle null optional fields in JSON', () {
        // arrange
        final jsonWithNulls = {
          'id': 'minimal-element',
          'label': 'Minimal',
          'left': 10.0,
          'top': 20.0,
          'width': 80.0,
          'height': 30.0,
          'type': 'text',
          'isInteractive': false,
          'semanticLabel': null,
          'hasAlternativeAccess': null,
        };

        // act
        final result = UiElementModel.fromJson(jsonWithNulls);

        // assert
        expect(result.semanticLabel, isNull);
        expect(result.hasAlternativeAccess, isNull);
        expect(result.id, equals('minimal-element'));
        expect(result.isInteractive, isFalse);
      });

      test('should handle different numeric types', () {
        // arrange
        final jsonWithInts = {
          'id': 'int-coords',
          'label': 'Integer Coordinates',
          'left': 100,
          'top': 200,
          'width': 150,
          'height': 50,
          'type': 'button',
          'isInteractive': true,
        };

        // act
        final result = UiElementModel.fromJson(jsonWithInts);

        // assert
        expect(result.left, equals(100.0));
        expect(result.top, equals(200.0));
        expect(result.width, equals(150.0));
        expect(result.height, equals(50.0));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.id, equals('button-test'));
        expect(entity.label, equals('Test Button'));
        expect(entity.bounds.left, equals(50.0));
        expect(entity.bounds.top, equals(100.0));
        expect(entity.bounds.width, equals(120.0));
        expect(entity.bounds.height, equals(48.0));
        expect(entity.type, equals(UiElementType.button));
        expect(entity.isInteractive, equals(true));
        expect(entity.semanticLabel, equals('Submit form button'));
        expect(entity.hasAlternativeAccess, equals(false));
      });

      test('should handle null fields in entity conversion', () {
        // arrange
        const modelWithNulls = UiElementModel(
          id: 'simple',
          label: 'Simple',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 40.0,
          type: 'text',
          isInteractive: false,
        );

        // act
        final entity = modelWithNulls.toEntity();

        // assert
        expect(entity.semanticLabel, isNull);
        expect(entity.hasAlternativeAccess, isNull);
        expect(entity.type, equals(UiElementType.other));
      });

      test('should create from entity correctly', () {
        // arrange
        final entity = UiElement(
          id: 'entity-button',
          label: 'From Entity',
          bounds: const Rect.fromLTWH(25.0, 75.0, 100.0, 44.0),
          type: UiElementType.textField,
          isInteractive: true,
          semanticLabel: 'Input field',
          hasAlternativeAccess: true,
        );

        // act
        final result = UiElementModel.fromEntity(entity);

        // assert
        expect(result.id, equals('entity-button'));
        expect(result.label, equals('From Entity'));
        expect(result.left, equals(25.0));
        expect(result.top, equals(75.0));
        expect(result.width, equals(100.0));
        expect(result.height, equals(44.0));
        expect(result.type, equals('text_field'));
        expect(result.isInteractive, equals(true));
        expect(result.semanticLabel, equals('Input field'));
        expect(result.hasAlternativeAccess, equals(true));
      });
    });

    group('Equality and copying', () {
      test('should support equality comparison', () {
        // arrange
        final model2 = UiElementModel.fromJson(json);

        // act & assert
        expect(model == model2, isTrue);
        expect(model.hashCode, equals(model2.hashCode));
      });

      test('should support copyWith', () {
        // act
        final updated = model.copyWith(
          label: 'Updated Button',
          width: 140.0,
        );

        // assert
        expect(updated.label, equals('Updated Button'));
        expect(updated.width, equals(140.0));
        expect(updated.id, equals(model.id)); // unchanged
        expect(updated.height, equals(model.height)); // unchanged
      });

      test('should support copyWith with null values', () {
        // act
        final updated = model.copyWith(
          semanticLabel: null,
          hasAlternativeAccess: null,
        );

        // assert
        expect(updated.semanticLabel, isNull);
        expect(updated.hasAlternativeAccess, isNull);
        expect(updated.id, equals(model.id)); // unchanged
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // act
        final json = model.toJson();
        final reconstructed = UiElementModel.fromJson(json);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.label, equals(model.label));
        expect(reconstructed.left, equals(model.left));
        expect(reconstructed.top, equals(model.top));
        expect(reconstructed.width, equals(model.width));
        expect(reconstructed.height, equals(model.height));
        expect(reconstructed.type, equals(model.type));
        expect(reconstructed.isInteractive, equals(model.isInteractive));
        expect(reconstructed.semanticLabel, equals(model.semanticLabel));
        expect(reconstructed.hasAlternativeAccess,
            equals(model.hasAlternativeAccess));
      });

      test('should maintain data integrity through entity round-trip', () {
        // act
        final entity = model.toEntity();
        final reconstructed = UiElementModel.fromEntity(entity);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.label, equals(model.label));
        expect(reconstructed.left, equals(model.left));
        expect(reconstructed.top, equals(model.top));
        expect(reconstructed.width, equals(model.width));
        expect(reconstructed.height, equals(model.height));
        expect(reconstructed.type, equals(model.type));
        expect(reconstructed.isInteractive, equals(model.isInteractive));
      });
    });

    group('Type conversion', () {
      test('should handle all UI element types', () {
        final types = [
          ('button', UiElementType.button),
          ('text_field', UiElementType.textField),
          ('slider', UiElementType.slider),
          ('toggle', UiElementType.toggle),
          ('other', UiElementType.other),
        ];

        for (final (stringType, enumType) in types) {
          // arrange
          final testModel = UiElementModel(
            id: 'test-$stringType',
            label: 'Test $stringType',
            left: 0.0,
            top: 0.0,
            width: 100.0,
            height: 40.0,
            type: stringType,
            isInteractive: true,
          );

          // act
          final entity = testModel.toEntity();
          final backToModel = UiElementModel.fromEntity(entity);

          // assert
          expect(entity.type, equals(enumType),
              reason: 'Failed for type $stringType');
          expect(backToModel.type, equals(stringType),
              reason: 'Failed round-trip for type $stringType');
        }
      });

      test('should default unknown types correctly', () {
        // arrange
        final testModel = UiElementModel(
          id: 'unknown-type',
          label: 'Unknown Type',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 40.0,
          type: 'invalid-type',
          isInteractive: false,
        );

        // act
        final entity = testModel.toEntity();

        // assert
        expect(entity.type, equals(UiElementType.other));
      });
    });
  });
}
