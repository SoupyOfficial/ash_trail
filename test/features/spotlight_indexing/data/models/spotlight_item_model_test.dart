// Unit tests for SpotlightItemModel

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/entities/spotlight_item_entity.dart';
import 'package:ash_trail/features/spotlight_indexing/data/models/spotlight_item_model.dart';

void main() {
  group('SpotlightItemModel', () {
    late SpotlightItemModel testModel;
    late SpotlightItemEntity testEntity;

    setUp(() {
      testModel = SpotlightItemModel(
        id: 'test_id',
        type: 'tag',
        title: 'Test Tag',
        description: 'Test description',
        keywords: ['test', 'tag'],
        deepLink: 'ashtrail://test',
        accountId: 'account_123',
        contentId: 'content_123',
        lastUpdated: DateTime(2023, 1, 1),
        isActive: true,
      );

      testEntity = SpotlightItemEntity(
        id: 'test_id',
        type: SpotlightItemType.tag,
        title: 'Test Tag',
        description: 'Test description',
        keywords: ['test', 'tag'],
        deepLink: 'ashtrail://test',
        accountId: 'account_123',
        contentId: 'content_123',
        lastUpdated: DateTime(2023, 1, 1),
        isActive: true,
      );
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testModel.toJson();

        expect(json['id'], equals('test_id'));
        expect(json['type'], equals('tag'));
        expect(json['title'], equals('Test Tag'));
        expect(json['description'], equals('Test description'));
        expect(json['keywords'], equals(['test', 'tag']));
        expect(json['deep_link'], equals('ashtrail://test'));
        expect(json['account_id'], equals('account_123'));
        expect(json['content_id'], equals('content_123'));
        expect(json['last_updated'], equals('2023-01-01T00:00:00.000'));
        expect(json['is_active'], equals(true));
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'test_id',
          'type': 'tag',
          'title': 'Test Tag',
          'description': 'Test description',
          'keywords': ['test', 'tag'],
          'deep_link': 'ashtrail://test',
          'account_id': 'account_123',
          'content_id': 'content_123',
          'last_updated': '2023-01-01T00:00:00.000',
          'is_active': true,
        };

        final model = SpotlightItemModel.fromJson(json);

        expect(model.id, equals('test_id'));
        expect(model.type, equals('tag'));
        expect(model.title, equals('Test Tag'));
        expect(model.description, equals('Test description'));
        expect(model.keywords, equals(['test', 'tag']));
        expect(model.deepLink, equals('ashtrail://test'));
        expect(model.accountId, equals('account_123'));
        expect(model.contentId, equals('content_123'));
        expect(model.lastUpdated, equals(DateTime(2023, 1, 1)));
        expect(model.isActive, equals(true));
      });

      test('should handle null description', () {
        final modelWithNullDesc = testModel.copyWith(description: null);
        final json = modelWithNullDesc.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.description, isNull);
      });

      test('should handle null keywords', () {
        final modelWithNullKeywords = testModel.copyWith(keywords: null);
        final json = modelWithNullKeywords.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.keywords, isNull);
      });

      test('should handle chartView type', () {
        final chartModel = testModel.copyWith(type: 'chartView');
        final json = chartModel.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.type, equals('chartView'));
      });
    });

    group('Entity conversion', () {
      test('should convert to entity correctly', () {
        final entity = testModel.toEntity();

        expect(entity.id, equals(testModel.id));
        expect(
            entity.type, equals(SpotlightItemType.tag)); // Entity has enum type
        expect(entity.title, equals(testModel.title));
        expect(entity.description, equals(testModel.description));
        expect(entity.keywords, equals(testModel.keywords));
        expect(entity.deepLink, equals(testModel.deepLink));
        expect(entity.accountId, equals(testModel.accountId));
        expect(entity.contentId, equals(testModel.contentId));
        expect(entity.lastUpdated, equals(testModel.lastUpdated));
        expect(entity.isActive, equals(testModel.isActive));
      });

      test('should create from entity correctly', () {
        final model = SpotlightItemModel.fromEntity(testEntity);

        expect(model.id, equals(testEntity.id));
        expect(model.type, equals('tag')); // Model stores type as string
        expect(model.title, equals(testEntity.title));
        expect(model.description, equals(testEntity.description));
        expect(model.keywords, equals(testEntity.keywords));
        expect(model.deepLink, equals(testEntity.deepLink));
        expect(model.accountId, equals(testEntity.accountId));
        expect(model.contentId, equals(testEntity.contentId));
        expect(model.lastUpdated, equals(testEntity.lastUpdated));
        expect(model.isActive, equals(testEntity.isActive));
      });

      test('should maintain data integrity through entity conversion', () {
        final converted = SpotlightItemModel.fromEntity(testEntity).toEntity();

        expect(converted.id, equals(testEntity.id));
        expect(converted.type, equals(testEntity.type));
        expect(converted.title, equals(testEntity.title));
        expect(converted.description, equals(testEntity.description));
        expect(converted.keywords, equals(testEntity.keywords));
        expect(converted.deepLink, equals(testEntity.deepLink));
        expect(converted.accountId, equals(testEntity.accountId));
        expect(converted.contentId, equals(testEntity.contentId));
        expect(converted.lastUpdated, equals(testEntity.lastUpdated));
        expect(converted.isActive, equals(testEntity.isActive));
      });
    });

    group('Edge cases', () {
      test('should handle empty string fields', () {
        final modelWithEmptyFields = testModel.copyWith(
          title: '',
          deepLink: '',
        );

        final json = modelWithEmptyFields.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.title, equals(''));
        expect(restored.deepLink, equals(''));
      });

      test('should handle empty keywords list', () {
        final modelWithEmptyKeywords = testModel.copyWith(keywords: []);
        final json = modelWithEmptyKeywords.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.keywords, equals([]));
      });

      test('should handle inactive item', () {
        final inactiveModel = testModel.copyWith(isActive: false);
        final json = inactiveModel.toJson();
        final restored = SpotlightItemModel.fromJson(json);

        expect(restored.isActive, equals(false));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through JSON round-trip', () {
        final jsonString = jsonEncode(testModel.toJson());
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = SpotlightItemModel.fromJson(decoded);

        expect(restored.id, equals(testModel.id));
        expect(restored.type, equals(testModel.type));
        expect(restored.title, equals(testModel.title));
        expect(restored.description, equals(testModel.description));
        expect(restored.keywords, equals(testModel.keywords));
        expect(restored.deepLink, equals(testModel.deepLink));
        expect(restored.accountId, equals(testModel.accountId));
        expect(restored.contentId, equals(testModel.contentId));
        expect(restored.lastUpdated, equals(testModel.lastUpdated));
        expect(restored.isActive, equals(testModel.isActive));
      });
    });
  });
}
