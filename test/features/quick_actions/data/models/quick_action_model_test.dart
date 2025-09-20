// Unit tests for QuickActionModel
// Tests serialization and mapping functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/quick_actions/data/models/quick_action_model.dart';
import 'package:ash_trail/features/quick_actions/domain/entities/quick_action_entity.dart';

void main() {
  group('QuickActionModel', () {
    const testModel = QuickActionModel(
      type: 'log_hit',
      localizedTitle: 'Log Hit',
      localizedSubtitle: 'Quick record smoking session',
      icon: 'add',
    );

    const testEntity = QuickActionEntity(
      type: 'log_hit',
      localizedTitle: 'Log Hit',
      localizedSubtitle: 'Quick record smoking session',
      icon: 'add',
    );

    final testJson = {
      'type': 'log_hit',
      'localizedTitle': 'Log Hit',
      'localizedSubtitle': 'Quick record smoking session',
      'icon': 'add',
    };

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final json = testModel.toJson();

        // assert
        expect(json, equals(testJson));
      });

      test('should deserialize from JSON correctly', () {
        // act
        final model = QuickActionModel.fromJson(testJson);

        // assert
        expect(model, equals(testModel));
      });

      test('should handle null icon in JSON', () {
        // arrange
        final jsonWithoutIcon = {
          'type': 'log_hit',
          'localizedTitle': 'Log Hit',
          'localizedSubtitle': 'Quick record smoking session',
          'icon': null,
        };

        // act
        final model = QuickActionModel.fromJson(jsonWithoutIcon);

        // assert
        expect(model.icon, isNull);
        expect(model.type, equals('log_hit'));
      });

      test('should handle missing icon in JSON', () {
        // arrange
        final jsonWithoutIcon = {
          'type': 'log_hit',
          'localizedTitle': 'Log Hit',
          'localizedSubtitle': 'Quick record smoking session',
        };

        // act
        final model = QuickActionModel.fromJson(jsonWithoutIcon);

        // assert - our implementation handles missing keys gracefully
        expect(model.icon, isNull);
        expect(model.type, equals('log_hit'));
      });
    });

    group('entity mapping', () {
      test('should convert to entity correctly', () {
        // act
        final entity = testModel.toEntity();

        // assert
        expect(entity, equals(testEntity));
        expect(entity.type, equals(testModel.type));
        expect(entity.localizedTitle, equals(testModel.localizedTitle));
        expect(entity.localizedSubtitle, equals(testModel.localizedSubtitle));
        expect(entity.icon, equals(testModel.icon));
      });

      test('should convert from entity correctly', () {
        // act
        final model = QuickActionModel.fromEntity(testEntity);

        // assert
        expect(model, equals(testModel));
        expect(model.type, equals(testEntity.type));
        expect(model.localizedTitle, equals(testEntity.localizedTitle));
        expect(model.localizedSubtitle, equals(testEntity.localizedSubtitle));
        expect(model.icon, equals(testEntity.icon));
      });

      test('should handle null icon in entity mapping', () {
        // arrange
        const entityWithoutIcon = QuickActionEntity(
          type: 'log_hit',
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: null,
        );

        // act
        final model = QuickActionModel.fromEntity(entityWithoutIcon);

        // assert
        expect(model.icon, isNull);
        expect(model.type, equals(entityWithoutIcon.type));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when properties are the same', () {
        // arrange
        const model1 = QuickActionModel(
          type: 'log_hit',
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: 'add',
        );

        const model2 = QuickActionModel(
          type: 'log_hit',
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: 'add',
        );

        // assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        const model1 = QuickActionModel(
          type: 'log_hit',
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: 'add',
        );

        const model2 = QuickActionModel(
          type: 'view_logs',
          localizedTitle: 'View Logs',
          localizedSubtitle: 'See your smoking history',
          icon: 'list',
        );

        // assert
        expect(model1, isNot(equals(model2)));
        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // act
        final result = testModel.toString();

        // assert
        expect(result, contains('QuickActionModel'));
        expect(result, contains('log_hit'));
        expect(result, contains('Log Hit'));
        expect(result, contains('Quick record smoking session'));
        expect(result, contains('add'));
      });
    });
  });
}
