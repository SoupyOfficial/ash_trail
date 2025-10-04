// Unit tests for UiElementModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:ash_trail/features/reachability/data/models/ui_element_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UiElementModel', () {
    late UiElementModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = const UiElementModel(
        id: 'button-test',
        label: 'Test Button',
        bounds: Rect.fromLTWH(50.0, 100.0, 120.0, 48.0),
        type: 'button',
        isInteractive: true,
        semanticLabel: 'Submit form button',
        hasAlternativeAccess: false,
      );

      json = {
        'id': 'button-test',
        'label': 'Test Button',
        'bounds': {
          'left': 50.0,
          'top': 100.0,
          'width': 120.0,
          'height': 48.0,
        },
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
        expect(result['type'], equals('button'));
        expect(result['isInteractive'], isTrue);
        expect(result['semanticLabel'], equals('Submit form button'));
        expect(result['hasAlternativeAccess'], isFalse);

        final bounds = result['bounds'] as Map<String, dynamic>;
        expect(bounds['left'], equals(50.0));
        expect(bounds['top'], equals(100.0));
        expect(bounds['width'], equals(120.0));
        expect(bounds['height'], equals(48.0));
      });

      test('should serialize with null optional fields', () {
        // arrange
        const modelWithNulls = UiElementModel(
          id: 'simple-button',
          label: 'Simple',
          bounds: Rect.fromLTWH(0.0, 0.0, 100.0, 40.0),
          type: 'button',
          isInteractive: true,
        );

        // act
        final result = modelWithNulls.toJson();

        // assert
        expect(result['semanticLabel'], isNull);
        expect(result['hasAlternativeAccess'], isNull);
        expect(result['id'], equals('simple-button'));

        final bounds = result['bounds'] as Map<String, dynamic>;
        expect(bounds['width'], equals(100.0));
        expect(bounds['height'], equals(40.0));
      });

      test('should serialize boolean fields correctly', () {
        // arrange
        const interactiveElement = UiElementModel(
          id: 'interactive',
          label: 'Button',
          bounds: Rect.fromLTWH(0.0, 0.0, 100.0, 40.0),
          type: 'button',
          isInteractive: true,
          hasAlternativeAccess: true,
        );

        const nonInteractiveElement = UiElementModel(
          id: 'text',
          label: 'Text',
          bounds: Rect.fromLTWH(0.0, 0.0, 100.0, 20.0),
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
        expect(result.bounds,
            equals(const Rect.fromLTWH(50.0, 100.0, 120.0, 48.0)));
        expect(result.type, equals('button'));
        expect(result.isInteractive, isTrue);
        expect(result.semanticLabel, equals('Submit form button'));
        expect(result.hasAlternativeAccess, isFalse);
      });

      test('should handle null optional fields in JSON', () {
        // arrange
        final jsonWithNulls = {
          'id': 'minimal-element',
          'label': 'Minimal',
          'bounds': {
            'left': 10.0,
            'top': 20.0,
            'width': 80.0,
            'height': 30.0,
          },
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
          'bounds': {
            'left': 100,
            'top': 200,
            'width': 150,
            'height': 50,
          },
          'type': 'button',
          'isInteractive': true,
        };

        // act
        final result = UiElementModel.fromJson(jsonWithInts);

        // assert
        expect(result.bounds.left, equals(100.0));
        expect(result.bounds.top, equals(200.0));
        expect(result.bounds.width, equals(150.0));
        expect(result.bounds.height, equals(50.0));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.id, equals('button-test'));
        expect(entity.label, equals('Test Button'));
        expect(entity.bounds,
            equals(const Rect.fromLTWH(50.0, 100.0, 120.0, 48.0)));
        expect(entity.type, equals(UiElementType.button));
        expect(entity.isInteractive, isTrue);
        expect(entity.semanticLabel, equals('Submit form button'));
        expect(entity.hasAlternativeAccess, isFalse);
      });

      test('should handle null fields in entity conversion', () {
        // arrange
        const modelWithNulls = UiElementModel(
          id: 'simple',
          label: 'Simple',
          bounds: Rect.fromLTWH(0.0, 0.0, 100.0, 40.0),
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
        const entity = UiElement(
          id: 'entity-button',
          label: 'From Entity',
          bounds: Rect.fromLTWH(25.0, 75.0, 100.0, 44.0),
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
        expect(result.bounds,
            equals(const Rect.fromLTWH(25.0, 75.0, 100.0, 44.0)));
        expect(result.type, equals('text_field'));
        expect(result.isInteractive, isTrue);
        expect(result.semanticLabel, equals('Input field'));
        expect(result.hasAlternativeAccess, isTrue);
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
          bounds: const Rect.fromLTWH(50.0, 100.0, 140.0, 48.0),
        );

        // assert
        expect(updated.label, equals('Updated Button'));
        expect(updated.bounds.width, equals(140.0));
        expect(updated.id, equals(model.id));
        expect(updated.bounds.top, equals(model.bounds.top));
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
        expect(updated.id, equals(model.id));
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // act
        final jsonData = model.toJson();
        final reconstructed = UiElementModel.fromJson(jsonData);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.label, equals(model.label));
        expect(reconstructed.bounds, equals(model.bounds));
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
        expect(reconstructed.bounds, equals(model.bounds));
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
            bounds: const Rect.fromLTWH(0.0, 0.0, 100.0, 40.0),
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
        const testModel = UiElementModel(
          id: 'unknown-type',
          label: 'Unknown Type',
          bounds: Rect.fromLTWH(0.0, 0.0, 100.0, 40.0),
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
