// Unit tests for all Spotlight Indexing use cases

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/entities/spotlight_item_entity.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/repositories/spotlight_indexing_repository.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/usecases/deindex_spotlight_item.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/usecases/batch_index_spotlight_items.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/usecases/sync_spotlight_index.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/usecases/clear_spotlight_index.dart';

class MockSpotlightIndexingRepository extends Mock
    implements SpotlightIndexingRepository {}

// Fallback values for mocktail
class FakeSpotlightItemEntity extends Fake implements SpotlightItemEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSpotlightItemEntity());
  });

  late MockSpotlightIndexingRepository mockRepository;

  setUp(() {
    mockRepository = MockSpotlightIndexingRepository();
  });

  group('DeindexSpotlightItemUseCase', () {
    late DeindexSpotlightItemUseCase useCase;

    setUp(() {
      useCase = DeindexSpotlightItemUseCase(mockRepository);
    });

    test('should return success when repository succeeds', () async {
      // Arrange
      const itemId = 'test_item_id';
      when(() => mockRepository.deindexItem(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(itemId);

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.deindexItem(itemId)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const itemId = 'test_item_id';
      const failure = AppFailure.network(message: 'Test error');
      when(() => mockRepository.deindexItem(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(itemId);

      // Assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.deindexItem(itemId)).called(1);
    });

    test('should return validation error when itemId is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected validation failure for empty itemId'),
      );
      verifyNever(() => mockRepository.deindexItem(any()));
    });

    test('should return validation error when itemId is whitespace', () async {
      // Act
      final result = await useCase('   ');

      // Assert
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected validation failure for whitespace itemId'),
      );
      verifyNever(() => mockRepository.deindexItem(any()));
    });
  });

  group('BatchIndexSpotlightItemsUseCase', () {
    late BatchIndexSpotlightItemsUseCase useCase;
    late List<SpotlightItemEntity> testItems;

    setUp(() {
      useCase = BatchIndexSpotlightItemsUseCase(mockRepository);
      testItems = [
        SpotlightItemEntity(
          id: 'item1',
          type: SpotlightItemType.tag,
          title: 'Tag 1',
          description: 'Description 1',
          keywords: ['tag1'],
          deepLink: 'ashtrail://tag1',
          accountId: 'account_123',
          contentId: 'content_123',
          lastUpdated: DateTime(2023, 1, 1),
          isActive: true,
        ),
        SpotlightItemEntity(
          id: 'item2',
          type: SpotlightItemType.chartView,
          title: 'Chart 1',
          description: 'Chart Description',
          keywords: ['chart1'],
          deepLink: 'ashtrail://chart1',
          accountId: 'account_123',
          contentId: 'content_456',
          lastUpdated: DateTime(2023, 1, 2),
          isActive: true,
        ),
      ];
    });

    test('should return success when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.indexItems(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testItems);

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.indexItems(testItems)).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = AppFailure.network(message: 'Batch index failed');
      when(() => mockRepository.indexItems(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(testItems);

      // Assert
      expect(result, equals(const Left(failure)));
    });

    test('should return validation error when items list is empty', () async {
      // Act
      final result = await useCase([]);

      // Assert
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected validation failure for empty items list'),
      );
      verifyNever(() => mockRepository.indexItems(any()));
    });

    test('should filter out invalid items and index valid ones', () async {
      // Arrange
      final mixedItems = [
        testItems[0], // Valid
        testItems[1].copyWith(title: ''), // Invalid - empty title
        testItems[0]
            .copyWith(id: 'item3', isActive: false), // Invalid - inactive
      ];

      when(() => mockRepository.indexItems(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(mixedItems);

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.indexItems([testItems[0]])).called(1);
    });

    test('should return validation error when no valid items exist', () async {
      // Arrange
      final invalidItems = [
        testItems[0].copyWith(title: ''),
        testItems[1].copyWith(isActive: false),
      ];

      // Act
      final result = await useCase(invalidItems);

      // Assert
      result.fold(
        (failure) => expect(failure, isA<AppFailure>()),
        (_) => fail('Expected validation failure when no valid items'),
      );
      verifyNever(() => mockRepository.indexItems(any()));
    });
  });

  group('SyncSpotlightIndexUseCase', () {
    late SyncSpotlightIndexUseCase useCase;

    setUp(() {
      useCase = SyncSpotlightIndexUseCase(mockRepository);
    });

    test('should return success when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.syncIndex())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.syncIndex()).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = AppFailure.network(message: 'Sync failed');
      when(() => mockRepository.syncIndex())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(const Left(failure)));
      verify(() => mockRepository.syncIndex()).called(1);
    });
  });

  group('ClearSpotlightIndexUseCase', () {
    late ClearSpotlightIndexUseCase useCase;

    setUp(() {
      useCase = ClearSpotlightIndexUseCase(mockRepository);
    });

    test('should clear all items when no accountId provided', () async {
      // Arrange
      when(() => mockRepository.clearAllItems())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.clearAllItems()).called(1);
      verifyNever(() => mockRepository.deindexAccountItems(any()));
    });

    test('should clear account items when accountId provided', () async {
      // Arrange
      const accountId = 'account_123';
      when(() => mockRepository.deindexAccountItems(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(accountId: accountId);

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.deindexAccountItems(accountId)).called(1);
      verifyNever(() => mockRepository.clearAllItems());
    });

    test('should clear all items when accountId is empty', () async {
      // Arrange
      when(() => mockRepository.clearAllItems())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(accountId: '');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRepository.clearAllItems()).called(1);
      verifyNever(() => mockRepository.deindexAccountItems(any()));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = AppFailure.network(message: 'Clear failed');
      when(() => mockRepository.clearAllItems())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(const Left(failure)));
    });
  });
}
