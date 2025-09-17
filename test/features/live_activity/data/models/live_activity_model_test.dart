// Unit tests for LiveActivityModel serialization and entity conversion.

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/live_activity/data/models/live_activity_model.dart';
import 'package:ash_trail/features/live_activity/domain/entities/live_activity_entity.dart';

void main() {
  group('LiveActivityModel', () {
    late DateTime startedAt;
    late DateTime endedAt;

    setUp(() {
      startedAt = DateTime(2023, 9, 17, 12, 0, 0);
      endedAt = DateTime(2023, 9, 17, 12, 5, 0);
    });

    group('JSON serialization', () {
      test('serializes to JSON correctly', () {
        // Arrange
        final model = LiveActivityModel(
          id: 'test-id',
          startedAt: startedAt,
          endedAt: endedAt,
          status: 'completed',
          cancelReason: 'User cancelled',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['startedAt'], equals(startedAt.toIso8601String()));
        expect(json['endedAt'], equals(endedAt.toIso8601String()));
        expect(json['status'], equals('completed'));
        expect(json['cancelReason'], equals('User cancelled'));
      });

      test('serializes with null fields correctly', () {
        // Arrange
        final model = LiveActivityModel(
          id: 'test-id',
          startedAt: startedAt,
          status: 'active',
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], equals('test-id'));
        expect(json['startedAt'], equals(startedAt.toIso8601String()));
        expect(json['endedAt'], isNull);
        expect(json['status'], equals('active'));
        expect(json['cancelReason'], isNull);
      });

      test('deserializes from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'startedAt': startedAt.toIso8601String(),
          'endedAt': endedAt.toIso8601String(),
          'status': 'completed',
          'cancelReason': 'User cancelled',
        };

        // Act
        final model = LiveActivityModel.fromJson(json);

        // Assert
        expect(model.id, equals('test-id'));
        expect(model.startedAt, equals(startedAt));
        expect(model.endedAt, equals(endedAt));
        expect(model.status, equals('completed'));
        expect(model.cancelReason, equals('User cancelled'));
      });

      test('deserializes with null fields correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'startedAt': startedAt.toIso8601String(),
          'endedAt': null,
          'status': 'active',
          'cancelReason': null,
        };

        // Act
        final model = LiveActivityModel.fromJson(json);

        // Assert
        expect(model.id, equals('test-id'));
        expect(model.startedAt, equals(startedAt));
        expect(model.endedAt, isNull);
        expect(model.status, equals('active'));
        expect(model.cancelReason, isNull);
      });
    });

    group('Entity conversion', () {
      test('converts to entity correctly', () {
        // Arrange
        final model = LiveActivityModel(
          id: 'test-id',
          startedAt: startedAt,
          endedAt: endedAt,
          status: 'completed',
          cancelReason: 'User cancelled',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, equals('test-id'));
        expect(entity.startedAt, equals(startedAt));
        expect(entity.endedAt, equals(endedAt));
        expect(entity.status, equals(LiveActivityStatus.completed));
        expect(entity.cancelReason, equals('User cancelled'));
      });

      test('converts to entity with null fields correctly', () {
        // Arrange
        final model = LiveActivityModel(
          id: 'test-id',
          startedAt: startedAt,
          status: 'active',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, equals('test-id'));
        expect(entity.startedAt, equals(startedAt));
        expect(entity.endedAt, isNull);
        expect(entity.status, equals(LiveActivityStatus.active));
        expect(entity.cancelReason, isNull);
      });

      test('creates from entity correctly', () {
        // Arrange
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: startedAt,
          endedAt: endedAt,
          status: LiveActivityStatus.completed,
          cancelReason: 'User cancelled',
        );

        // Act
        final model = LiveActivityModel.fromEntity(entity);

        // Assert
        expect(model.id, equals('test-id'));
        expect(model.startedAt, equals(startedAt));
        expect(model.endedAt, equals(endedAt));
        expect(model.status, equals('completed'));
        expect(model.cancelReason, equals('User cancelled'));
      });

      test('creates from entity with null fields correctly', () {
        // Arrange
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: startedAt,
          status: LiveActivityStatus.active,
        );

        // Act
        final model = LiveActivityModel.fromEntity(entity);

        // Assert
        expect(model.id, equals('test-id'));
        expect(model.startedAt, equals(startedAt));
        expect(model.endedAt, isNull);
        expect(model.status, equals('active'));
        expect(model.cancelReason, isNull);
      });

      test('handles all status types correctly', () {
        // Test active status
        final activeEntity = LiveActivityEntity(
          id: 'test-id',
          startedAt: startedAt,
          status: LiveActivityStatus.active,
        );
        final activeModel = LiveActivityModel.fromEntity(activeEntity);
        expect(activeModel.status, equals('active'));
        expect(
            activeModel.toEntity().status, equals(LiveActivityStatus.active));

        // Test completed status
        final completedEntity = activeEntity.copyWith(
          status: LiveActivityStatus.completed,
          endedAt: endedAt,
        );
        final completedModel = LiveActivityModel.fromEntity(completedEntity);
        expect(completedModel.status, equals('completed'));
        expect(completedModel.toEntity().status,
            equals(LiveActivityStatus.completed));

        // Test cancelled status
        final cancelledEntity = activeEntity.copyWith(
          status: LiveActivityStatus.cancelled,
          endedAt: endedAt,
          cancelReason: 'Test cancel',
        );
        final cancelledModel = LiveActivityModel.fromEntity(cancelledEntity);
        expect(cancelledModel.status, equals('cancelled'));
        expect(cancelledModel.toEntity().status,
            equals(LiveActivityStatus.cancelled));
      });
    });

    group('Round-trip conversion', () {
      test('entity to model to entity preserves data', () {
        // Arrange
        final originalEntity = LiveActivityEntity(
          id: 'test-id',
          startedAt: startedAt,
          endedAt: endedAt,
          status: LiveActivityStatus.completed,
          cancelReason: 'User cancelled',
        );

        // Act
        final model = LiveActivityModel.fromEntity(originalEntity);
        final roundTripEntity = model.toEntity();

        // Assert
        expect(roundTripEntity.id, equals(originalEntity.id));
        expect(roundTripEntity.startedAt, equals(originalEntity.startedAt));
        expect(roundTripEntity.endedAt, equals(originalEntity.endedAt));
        expect(roundTripEntity.status, equals(originalEntity.status));
        expect(
            roundTripEntity.cancelReason, equals(originalEntity.cancelReason));
      });

      test('model to JSON to model preserves data', () {
        // Arrange
        final originalModel = LiveActivityModel(
          id: 'test-id',
          startedAt: startedAt,
          endedAt: endedAt,
          status: 'completed',
          cancelReason: 'User cancelled',
        );

        // Act
        final json = originalModel.toJson();
        final roundTripModel = LiveActivityModel.fromJson(json);

        // Assert
        expect(roundTripModel.id, equals(originalModel.id));
        expect(roundTripModel.startedAt, equals(originalModel.startedAt));
        expect(roundTripModel.endedAt, equals(originalModel.endedAt));
        expect(roundTripModel.status, equals(originalModel.status));
        expect(roundTripModel.cancelReason, equals(originalModel.cancelReason));
      });
    });
  });
}
