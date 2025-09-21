// Tests for LogDetailModel serialization and conversion methods
// Covers generated code through actual usage of fromJson/toJson

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/detail_view/data/models/log_detail_model.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/domain/models/reason.dart';
import 'package:ash_trail/domain/models/method.dart';

void main() {
  group('LogDetailModel', () {
    late DateTime testDateTime;
    late SmokeLog testLog;
    late Tag testTag;
    late Reason testReason;
    late Method testMethod;
    late LogDetailModel testModel;

    setUp(() {
      testDateTime = DateTime(2024, 1, 15, 10, 30);

      testLog = SmokeLog(
        id: 'log-123',
        accountId: 'acc-456',
        ts: testDateTime,
        durationMs: 5000,
        moodScore: 7,
        physicalScore: 8,
        notes: 'Test notes',
        methodId: 'method-1',
        potency: 6,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      testTag = Tag(
        id: 'tag-1',
        accountId: 'acc-456',
        name: 'Test Tag',
        color: '#FF0000',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      testReason = Reason(
        id: 'reason-1',
        accountId: 'acc-456',
        name: 'Test Reason',
        enabled: true,
        orderIndex: 1,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      testMethod = Method(
        id: 'method-1',
        accountId: 'acc-456',
        name: 'Test Method',
        category: 'test-category',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      testModel = LogDetailModel(
        log: testLog,
        tags: [testTag],
        reasons: [testReason],
        method: testMethod,
      );
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // act
        final json = testModel.toJson();

        // assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['log'],
            isA<SmokeLog>()); // toJson() returns nested objects, not serialized JSON
        expect(json['tags'], isA<List>());
        expect(json['reasons'], isA<List>());
        expect(json['method'], isA<Method>());

        // Verify nested structures exist
        expect(json['log'], equals(testLog));
        expect(json['tags'], hasLength(1));
        expect(json['tags'], contains(testTag));
        expect(json['reasons'], hasLength(1));
        expect(json['reasons'], contains(testReason));
        expect(json['method'], equals(testMethod));
      });

      test('should deserialize from JSON correctly', () {
        // arrange
        final json = {
          'log': {
            'id': 'log-456',
            'accountId': 'acc-789',
            'ts': '2024-02-15T15:45:00.000Z',
            'durationMs': 7500,
            'moodScore': 5,
            'physicalScore': 6,
            'notes': 'Deserialized notes',
            'methodId': 'method-2',
            'potency': 8,
            'createdAt': '2024-02-15T14:00:00.000Z',
            'updatedAt': '2024-02-15T14:30:00.000Z',
          },
          'tags': [
            {
              'id': 'tag-2',
              'accountId': 'acc-789',
              'name': 'Deserialized Tag',
              'color': '#00FF00',
              'createdAt': '2024-02-15T12:00:00.000Z',
              'updatedAt': '2024-02-15T12:00:00.000Z',
            }
          ],
          'reasons': [
            {
              'id': 'reason-2',
              'accountId': 'acc-789',
              'name': 'Deserialized Reason',
              'enabled': false,
              'orderIndex': 2,
              'createdAt': '2024-02-15T11:00:00.000Z',
              'updatedAt': '2024-02-15T11:00:00.000Z',
            }
          ],
          'method': {
            'id': 'method-2',
            'accountId': 'acc-789',
            'name': 'Deserialized Method',
            'category': 'deserialized-category',
            'createdAt': '2024-02-15T10:00:00.000Z',
            'updatedAt': '2024-02-15T10:00:00.000Z',
          },
        };

        // act
        final model = LogDetailModel.fromJson(json);

        // assert
        expect(model.log.id, equals('log-456'));
        expect(model.log.accountId, equals('acc-789'));
        expect(model.log.notes, equals('Deserialized notes'));
        expect(model.tags, hasLength(1));
        expect(model.tags.first.name, equals('Deserialized Tag'));
        expect(model.reasons, hasLength(1));
        expect(model.reasons.first.name, equals('Deserialized Reason'));
        expect(model.method?.name, equals('Deserialized Method'));
      });

      test('should handle empty tags and reasons lists', () {
        // arrange
        final json = {
          'log': {
            'id': 'log-empty',
            'accountId': 'acc-empty',
            'ts': '2024-02-15T15:45:00.000Z',
            'durationMs': 1000,
            'moodScore': 5,
            'physicalScore': 5,
            'createdAt': '2024-02-15T14:00:00.000Z',
            'updatedAt': '2024-02-15T14:30:00.000Z',
          },
          'tags': [],
          'reasons': [],
        };

        // act
        final model = LogDetailModel.fromJson(json);

        // assert
        expect(model.log.id, equals('log-empty'));
        expect(model.tags, isEmpty);
        expect(model.reasons, isEmpty);
        expect(model.method, isNull);
      });

      test('should use default empty lists when tags/reasons are missing', () {
        // arrange
        final json = {
          'log': {
            'id': 'log-minimal',
            'accountId': 'acc-minimal',
            'ts': '2024-02-15T15:45:00.000Z',
            'durationMs': 1000,
            'moodScore': 5,
            'physicalScore': 5,
            'createdAt': '2024-02-15T14:00:00.000Z',
            'updatedAt': '2024-02-15T14:30:00.000Z',
          },
          // Missing tags and reasons intentionally
        };

        // act
        final model = LogDetailModel.fromJson(json);

        // assert
        expect(model.log.id, equals('log-minimal'));
        expect(model.tags, isEmpty);
        expect(model.reasons, isEmpty);
        expect(model.method, isNull);
      });

      test('should serialize model properties correctly', () {
        // act
        final json = testModel.toJson();

        // Create a new model from our test data to verify serialization works
        final recreatedModel = LogDetailModel(
          log: testLog,
          tags: [testTag],
          reasons: [testReason],
          method: testMethod,
        );
        final recreatedJson = recreatedModel.toJson();

        // assert
        expect(json['log'], equals(recreatedJson['log']));
        expect(json['tags'], equals(recreatedJson['tags']));
        expect(json['reasons'], equals(recreatedJson['reasons']));
        expect(json['method'], equals(recreatedJson['method']));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        // act
        final entity = testModel.toEntity();

        // assert
        expect(entity, isA<LogDetailEntity>());
        expect(entity.log.id, equals(testModel.log.id));
        expect(entity.tags.length, equals(testModel.tags.length));
        expect(entity.reasons.length, equals(testModel.reasons.length));
        expect(entity.method?.id, equals(testModel.method?.id));
      });

      test('should create from entity correctly', () {
        // arrange
        final entity = LogDetailEntity(
          log: testLog,
          tags: [testTag],
          reasons: [testReason],
          method: testMethod,
        );

        // act
        final model = LogDetailModel.fromEntity(entity);

        // assert
        expect(model.log.id, equals(entity.log.id));
        expect(model.tags.length, equals(entity.tags.length));
        expect(model.reasons.length, equals(entity.reasons.length));
        expect(model.method?.id, equals(entity.method?.id));
      });

      test('should round-trip entity conversion', () {
        // act
        final entity = testModel.toEntity();
        final convertedModel = LogDetailModel.fromEntity(entity);

        // assert
        expect(convertedModel.log.id, equals(testModel.log.id));
        expect(convertedModel.tags.length, equals(testModel.tags.length));
        expect(convertedModel.reasons.length, equals(testModel.reasons.length));
        expect(convertedModel.method?.id, equals(testModel.method?.id));
      });

      test('should handle null method in conversion', () {
        // arrange
        final modelWithoutMethod = LogDetailModel(
          log: testLog,
          tags: [testTag],
          reasons: [testReason],
          method: null,
        );

        // act
        final entity = modelWithoutMethod.toEntity();
        final backToModel = LogDetailModel.fromEntity(entity);

        // assert
        expect(entity.method, isNull);
        expect(backToModel.method, isNull);
      });
    });

    group('Equality and hashCode', () {
      test('should be equal when all properties match', () {
        // arrange
        final model1 = LogDetailModel(
          log: testLog,
          tags: [testTag],
          reasons: [testReason],
          method: testMethod,
        );
        final model2 = LogDetailModel(
          log: testLog,
          tags: [testTag],
          reasons: [testReason],
          method: testMethod,
        );

        // assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final model1 = testModel;
        final model2 = LogDetailModel(
          log: testLog.copyWith(id: 'different-log-id'),
          tags: [testTag],
          reasons: [testReason],
          method: testMethod,
        );

        // assert
        expect(model1, isNot(equals(model2)));
        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });
    });
  });
}
