// Unit tests for ReachabilityZoneModel
// Tests JSON serialization, deserialization, and entity conversion

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_zone_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityZoneModel', () {
    late ReachabilityZoneModel model;
    late Map<String, dynamic> json;

    setUp(() {
      model = ReachabilityZoneModel(
        id: 'zone-easy-thumb',
        name: 'Easy Reach Zone',
        left: 0.0,
        top: 500.0,
        width: 375.0,
        height: 312.0,
        level: 'easy',
        description: 'Area easily reachable by thumb',
      );

      json = {
        'id': 'zone-easy-thumb',
        'name': 'Easy Reach Zone',
        'left': 0.0,
        'top': 500.0,
        'width': 375.0,
        'height': 312.0,
        'level': 'easy',
        'description': 'Area easily reachable by thumb',
      };
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final result = model.toJson();

        // assert
        expect(result['id'], equals('zone-easy-thumb'));
        expect(result['name'], equals('Easy Reach Zone'));
        expect(result['left'], equals(0.0));
        expect(result['top'], equals(500.0));
        expect(result['width'], equals(375.0));
        expect(result['height'], equals(312.0));
        expect(result['level'], equals('easy'));
        expect(result['description'], equals('Area easily reachable by thumb'));
      });

      test('should serialize different zone levels', () {
        final zones = [
          ('easy', 'Easy Reach'),
          ('moderate', 'Moderate Reach'),
          ('difficult', 'Difficult Reach'),
          ('unreachable', 'Unreachable'),
        ];

        for (final (level, name) in zones) {
          // arrange
          final testZone = ReachabilityZoneModel(
            id: 'zone-$level',
            name: name,
            left: 10.0,
            top: 100.0,
            width: 200.0,
            height: 150.0,
            level: level,
            description: 'Test zone for $level',
          );

          // act
          final result = testZone.toJson();

          // assert
          expect(result['level'], equals(level),
              reason: 'Failed for level $level');
          expect(result['name'], equals(name), reason: 'Failed for name $name');
        }
      });

      test('should serialize coordinates as doubles', () {
        // arrange
        final zoneWithInts = ReachabilityZoneModel(
          id: 'int-zone',
          name: 'Integer Zone',
          left: 100.0,
          top: 200.0,
          width: 300.0,
          height: 400.0,
          level: 'moderate',
          description: 'Zone with integer-like coordinates',
        );

        // act
        final result = zoneWithInts.toJson();

        // assert
        expect(result['left'], isA<double>());
        expect(result['top'], isA<double>());
        expect(result['width'], isA<double>());
        expect(result['height'], isA<double>());
      });
    });

    group('JSON deserialization', () {
      test('should deserialize from JSON correctly', () {
        // act
        final result = ReachabilityZoneModel.fromJson(json);

        // assert
        expect(result.id, equals('zone-easy-thumb'));
        expect(result.name, equals('Easy Reach Zone'));
        expect(result.left, equals(0.0));
        expect(result.top, equals(500.0));
        expect(result.width, equals(375.0));
        expect(result.height, equals(312.0));
        expect(result.level, equals('easy'));
        expect(result.description, equals('Area easily reachable by thumb'));
      });

      test('should handle different numeric types in JSON', () {
        // arrange
        final jsonWithInts = {
          'id': 'int-coordinates',
          'name': 'Integer Coords',
          'left': 50,
          'top': 100,
          'width': 200,
          'height': 150,
          'level': 'moderate',
          'description': 'Zone with integer coordinates',
        };

        // act
        final result = ReachabilityZoneModel.fromJson(jsonWithInts);

        // assert
        expect(result.left, equals(50.0));
        expect(result.top, equals(100.0));
        expect(result.width, equals(200.0));
        expect(result.height, equals(150.0));
      });

      test('should handle all zone levels in JSON', () {
        final levels = ['easy', 'moderate', 'difficult', 'unreachable'];

        for (final level in levels) {
          // arrange
          final testJson = {
            'id': 'test-$level',
            'name': 'Test $level',
            'left': 0.0,
            'top': 0.0,
            'width': 100.0,
            'height': 100.0,
            'level': level,
            'description': 'Test description for $level',
          };

          // act
          final result = ReachabilityZoneModel.fromJson(testJson);

          // assert
          expect(result.level, equals(level),
              reason: 'Failed for level $level');
        }
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = model.toEntity();

        // assert
        expect(entity.id, equals('zone-easy-thumb'));
        expect(entity.name, equals('Easy Reach Zone'));
        expect(entity.bounds.left, equals(0.0));
        expect(entity.bounds.top, equals(500.0));
        expect(entity.bounds.width, equals(375.0));
        expect(entity.bounds.height, equals(312.0));
        expect(entity.level, equals(ReachabilityLevel.easy));
        expect(entity.description, equals('Area easily reachable by thumb'));
      });

      test('should handle all reachability levels in entity conversion', () {
        final levelMappings = [
          ('easy', ReachabilityLevel.easy),
          ('moderate', ReachabilityLevel.moderate),
          ('difficult', ReachabilityLevel.difficult),
          ('unreachable', ReachabilityLevel.unreachable),
        ];

        for (final (stringLevel, enumLevel) in levelMappings) {
          // arrange
          final testModel = ReachabilityZoneModel(
            id: 'test-$stringLevel',
            name: 'Test $stringLevel',
            left: 0.0,
            top: 0.0,
            width: 100.0,
            height: 100.0,
            level: stringLevel,
            description: 'Test zone',
          );

          // act
          final entity = testModel.toEntity();

          // assert
          expect(entity.level, equals(enumLevel),
              reason: 'Failed for level $stringLevel');
        }
      });

      test('should create from entity correctly', () {
        // arrange
        final entity = ReachabilityZone(
          id: 'entity-zone',
          name: 'From Entity',
          bounds: const Rect.fromLTWH(25.0, 75.0, 150.0, 200.0),
          level: ReachabilityLevel.moderate,
          description: 'Zone created from entity',
        );

        // act
        final result = ReachabilityZoneModel.fromEntity(entity);

        // assert
        expect(result.id, equals('entity-zone'));
        expect(result.name, equals('From Entity'));
        expect(result.left, equals(25.0));
        expect(result.top, equals(75.0));
        expect(result.width, equals(150.0));
        expect(result.height, equals(200.0));
        expect(result.level, equals('moderate'));
        expect(result.description, equals('Zone created from entity'));
      });

      test('should handle unknown levels gracefully', () {
        // arrange
        final testModel = ReachabilityZoneModel(
          id: 'unknown-level',
          name: 'Unknown Level Zone',
          left: 0.0,
          top: 0.0,
          width: 100.0,
          height: 100.0,
          level: 'invalid-level',
          description: 'Zone with invalid level',
        );

        // act
        final entity = testModel.toEntity();

        // assert - should default to easy for unknown levels
        expect(entity.level, equals(ReachabilityLevel.easy));
      });
    });

    group('Equality and copying', () {
      test('should support equality comparison', () {
        // arrange
        final model2 = ReachabilityZoneModel.fromJson(json);

        // act & assert
        expect(model == model2, isTrue);
        expect(model.hashCode, equals(model2.hashCode));
      });

      test('should support copyWith', () {
        // act
        final updated = model.copyWith(
          name: 'Updated Zone',
          level: 'moderate',
        );

        // assert
        expect(updated.name, equals('Updated Zone'));
        expect(updated.level, equals('moderate'));
        expect(updated.id, equals(model.id)); // unchanged
        expect(updated.width, equals(model.width)); // unchanged
      });

      test('should support copyWith for all properties', () {
        // act
        final updated = model.copyWith(
          id: 'new-id',
          name: 'New Name',
          left: 10.0,
          top: 20.0,
          width: 300.0,
          height: 400.0,
          level: 'difficult',
          description: 'New description',
        );

        // assert
        expect(updated.id, equals('new-id'));
        expect(updated.name, equals('New Name'));
        expect(updated.left, equals(10.0));
        expect(updated.top, equals(20.0));
        expect(updated.width, equals(300.0));
        expect(updated.height, equals(400.0));
        expect(updated.level, equals('difficult'));
        expect(updated.description, equals('New description'));
      });
    });

    group('Round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // act
        final jsonData = model.toJson();
        final reconstructed = ReachabilityZoneModel.fromJson(jsonData);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.name, equals(model.name));
        expect(reconstructed.left, equals(model.left));
        expect(reconstructed.top, equals(model.top));
        expect(reconstructed.width, equals(model.width));
        expect(reconstructed.height, equals(model.height));
        expect(reconstructed.level, equals(model.level));
        expect(reconstructed.description, equals(model.description));
      });

      test('should maintain data integrity through entity round-trip', () {
        // act
        final entity = model.toEntity();
        final reconstructed = ReachabilityZoneModel.fromEntity(entity);

        // assert
        expect(reconstructed.id, equals(model.id));
        expect(reconstructed.name, equals(model.name));
        expect(reconstructed.left, equals(model.left));
        expect(reconstructed.top, equals(model.top));
        expect(reconstructed.width, equals(model.width));
        expect(reconstructed.height, equals(model.height));
        expect(reconstructed.level, equals(model.level));
        expect(reconstructed.description, equals(model.description));
      });
    });

    group('Level string conversion', () {
      test('should convert all level strings correctly', () {
        final conversions = [
          ('easy', ReachabilityLevel.easy, 'easy'),
          ('moderate', ReachabilityLevel.moderate, 'moderate'),
          ('difficult', ReachabilityLevel.difficult, 'difficult'),
          ('unreachable', ReachabilityLevel.unreachable, 'unreachable'),
        ];

        for (final (input, expectedEnum, expectedString) in conversions) {
          // arrange
          final testModel = ReachabilityZoneModel(
            id: 'test',
            name: 'Test',
            left: 0.0,
            top: 0.0,
            width: 100.0,
            height: 100.0,
            level: input,
            description: 'Test',
          );

          // act
          final entity = testModel.toEntity();
          final backToModel = ReachabilityZoneModel.fromEntity(entity);

          // assert
          expect(entity.level, equals(expectedEnum));
          expect(backToModel.level, equals(expectedString));
        }
      });
    });
  });
}
