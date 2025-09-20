// Unit tests for SpotlightIndexingRepositoryImpl - Simplified

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/entities/spotlight_item_entity.dart';
import 'package:ash_trail/features/spotlight_indexing/data/models/spotlight_item_model.dart';
import 'package:ash_trail/features/spotlight_indexing/data/datasources/spotlight_service.dart';
import 'package:ash_trail/features/spotlight_indexing/data/datasources/content_data_source.dart';
import 'package:ash_trail/features/spotlight_indexing/data/repositories/spotlight_indexing_repository_impl.dart';

class MockSpotlightService extends Mock implements SpotlightService {}

class MockContentDataSource extends Mock implements ContentDataSource {}

// Fallback values for mocktail
class FakeSpotlightItemModel extends Fake implements SpotlightItemModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSpotlightItemModel());
  });

  group('SpotlightIndexingRepositoryImpl', () {
    late SpotlightIndexingRepositoryImpl repository;
    late MockSpotlightService mockSpotlightService;
    late MockContentDataSource mockContentDataSource;
    late SpotlightItemEntity testEntity;

    setUp(() {
      mockSpotlightService = MockSpotlightService();
      mockContentDataSource = MockContentDataSource();
      repository = SpotlightIndexingRepositoryImpl(
        contentDataSource: mockContentDataSource,
        spotlightService: mockSpotlightService,
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

    group('indexItem', () {
      test(
          'should return success when spotlight is available and service succeeds',
          () async {
        // Arrange
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => true);
        when(() => mockSpotlightService.indexItem(any()))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.indexItem(testEntity);

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.isSpotlightAvailable()).called(1);
        verify(() => mockSpotlightService.indexItem(any())).called(1);
      });

      test('should return failure when spotlight is not available', () async {
        // Arrange
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.indexItem(testEntity);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure when spotlight not available'),
        );
        verify(() => mockSpotlightService.isSpotlightAvailable()).called(1);
        verifyNever(() => mockSpotlightService.indexItem(any()));
      });

      test('should return failure when service fails', () async {
        // Arrange
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => true);
        when(() => mockSpotlightService.indexItem(any())).thenAnswer(
            (_) async => const Left(AppFailure.network(message: 'Test error')));

        // Act
        final result = await repository.indexItem(testEntity);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure when service fails'),
        );
      });
    });

    group('indexItems', () {
      test(
          'should return success when spotlight is available and service succeeds',
          () async {
        // Arrange
        final entities = [testEntity, testEntity.copyWith(id: 'test_id_2')];
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => true);
        when(() => mockSpotlightService.indexItems(any()))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.indexItems(entities);

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.isSpotlightAvailable()).called(1);
        verify(() => mockSpotlightService.indexItems(any())).called(1);
      });

      test('should return failure when spotlight is not available', () async {
        // Arrange
        final entities = [testEntity];
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.indexItems(entities);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure when spotlight not available'),
        );
        verifyNever(() => mockSpotlightService.indexItems(any()));
      });
    });

    group('deindexItem', () {
      test('should return success when service succeeds', () async {
        // Arrange
        const itemId = 'test_item_id';
        when(() => mockSpotlightService.deindexItem(any()))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.deindexItem(itemId);

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.deindexItem(itemId)).called(1);
      });

      test('should return failure when service fails', () async {
        // Arrange
        const itemId = 'test_item_id';
        when(() => mockSpotlightService.deindexItem(any())).thenAnswer(
            (_) async =>
                const Left(AppFailure.network(message: 'Deindex error')));

        // Act
        final result = await repository.deindexItem(itemId);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure when service fails'),
        );
      });
    });

    group('clearAllItems', () {
      test('should return success when service succeeds', () async {
        // Arrange
        when(() => mockSpotlightService.clearAllItems())
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.clearAllItems();

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.clearAllItems()).called(1);
      });

      test('should return failure when service fails', () async {
        // Arrange
        when(() => mockSpotlightService.clearAllItems()).thenAnswer((_) async =>
            const Left(AppFailure.network(message: 'Clear error')));

        // Act
        final result = await repository.clearAllItems();

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure when service fails'),
        );
      });
    });

    group('syncIndex', () {
      test(
          'should return success when spotlight is available and content exists',
          () async {
        // Arrange
        final contentModels = [
          SpotlightItemModel(
            id: 'content_1',
            type: 'tag',
            title: 'Test Content',
            description: 'Test Description',
            keywords: ['test'],
            deepLink: 'ashtrail://test',
            accountId: 'current_account',
            contentId: 'content_123',
            lastUpdated: DateTime(2023, 1, 1),
            isActive: true,
          ),
        ];

        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => true);
        when(() => mockContentDataSource.getAllIndexableContent(any()))
            .thenAnswer((_) async => Right(contentModels));
        when(() => mockSpotlightService.indexItems(any()))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.syncIndex();

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.isSpotlightAvailable())
            .called(2); // Called twice: once in syncIndex, once in indexItems
        verify(() =>
                mockContentDataSource.getAllIndexableContent('current_account'))
            .called(1);
        verify(() => mockSpotlightService.indexItems(any())).called(1);
      });

      test('should return success when spotlight is not available', () async {
        // Arrange
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.syncIndex();

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.isSpotlightAvailable()).called(1);
        verifyNever(() => mockContentDataSource.getAllIndexableContent(any()));
        verifyNever(() => mockSpotlightService.indexItems(any()));
      });

      test('should return success when no content to index', () async {
        // Arrange
        when(() => mockSpotlightService.isSpotlightAvailable())
            .thenAnswer((_) async => true);
        when(() => mockContentDataSource.getAllIndexableContent(any()))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await repository.syncIndex();

        // Assert
        expect(result, isA<Right>());
        verify(() => mockSpotlightService.isSpotlightAvailable()).called(1);
        verify(() =>
                mockContentDataSource.getAllIndexableContent('current_account'))
            .called(1);
        verifyNever(() => mockSpotlightService.indexItems(any()));
      });
    });
  });
}
