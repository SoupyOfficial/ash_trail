// Unit tests for SpotlightItemEntity

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/entities/spotlight_item_entity.dart';

void main() {
  group('SpotlightItemEntity', () {
    late SpotlightItemEntity testEntity;

    setUp(() {
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

    test('should create entity with all required fields', () {
      expect(testEntity.id, equals('test_id'));
      expect(testEntity.type, equals(SpotlightItemType.tag));
      expect(testEntity.title, equals('Test Tag'));
      expect(testEntity.description, equals('Test description'));
      expect(testEntity.keywords, equals(['test', 'tag']));
      expect(testEntity.deepLink, equals('ashtrail://test'));
      expect(testEntity.accountId, equals('account_123'));
      expect(testEntity.contentId, equals('content_123'));
      expect(testEntity.lastUpdated, equals(DateTime(2023, 1, 1)));
      expect(testEntity.isActive, equals(true));
    });

    group('needsUpdate', () {
      test('should return true when lastIndexedAt is null', () {
        expect(testEntity.needsUpdate(null), isTrue);
      });

      test('should return true when lastUpdated is after lastIndexedAt', () {
        final lastIndexedAt = DateTime(2022, 12, 31);
        expect(testEntity.needsUpdate(lastIndexedAt), isTrue);
      });

      test('should return false when lastUpdated is before lastIndexedAt', () {
        final lastIndexedAt = DateTime(2023, 1, 2);
        expect(testEntity.needsUpdate(lastIndexedAt), isFalse);
      });

      test('should return false when lastUpdated equals lastIndexedAt', () {
        final lastIndexedAt = DateTime(2023, 1, 1);
        expect(testEntity.needsUpdate(lastIndexedAt), isFalse);
      });
    });

    group('searchableContent', () {
      test('should combine title, description, and keywords', () {
        final content = testEntity.searchableContent;
        expect(content, contains('Test Tag'));
        expect(content, contains('Test description'));
        expect(content, contains('test'));
        expect(content, contains('tag'));
      });

      test('should handle missing description', () {
        final entityWithoutDesc = testEntity.copyWith(description: null);
        final content = entityWithoutDesc.searchableContent;
        expect(content, contains('Test Tag'));
        expect(content, contains('test'));
        expect(content, contains('tag'));
        expect(content, isNot(contains('Test description')));
      });

      test('should handle missing keywords', () {
        final entityWithoutKeywords = testEntity.copyWith(keywords: null);
        final content = entityWithoutKeywords.searchableContent;
        expect(content, contains('Test Tag'));
        expect(content, contains('Test description'));
        expect(content, isNot(contains('test')));
      });
    });

    group('isValidForIndexing', () {
      test('should return true for valid entity', () {
        expect(testEntity.isValidForIndexing, isTrue);
      });

      test('should return false when not active', () {
        final inactiveEntity = testEntity.copyWith(isActive: false);
        expect(inactiveEntity.isValidForIndexing, isFalse);
      });

      test('should return false when title is empty', () {
        final emptyTitleEntity = testEntity.copyWith(title: '');
        expect(emptyTitleEntity.isValidForIndexing, isFalse);
      });

      test('should return false when deepLink is empty', () {
        final emptyDeepLinkEntity = testEntity.copyWith(deepLink: '');
        expect(emptyDeepLinkEntity.isValidForIndexing, isFalse);
      });
    });

    group('SpotlightItemType', () {
      test('should have correct display names', () {
        expect(SpotlightItemType.tag.displayName, equals('Tag'));
        expect(SpotlightItemType.chartView.displayName, equals('Chart View'));
      });

      test('should have correct content types', () {
        expect(SpotlightItemType.tag.contentType, equals('com.ashtrail.tag'));
        expect(SpotlightItemType.chartView.contentType,
            equals('com.ashtrail.chartview'));
      });

      test('should have correct default keywords', () {
        expect(SpotlightItemType.tag.defaultKeywords,
            equals(['tag', 'label', 'category']));
        expect(SpotlightItemType.chartView.defaultKeywords,
            equals(['chart', 'view', 'graph', 'analysis']));
      });
    });
  });
}
