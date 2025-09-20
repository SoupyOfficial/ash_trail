// Unit tests for IndexSpotlightItemUseCase

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/entities/spotlight_item_entity.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/repositories/spotlight_indexing_repository.dart';
import 'package:ash_trail/features/spotlight_indexing/domain/usecases/index_spotlight_item.dart';

class MockSpotlightIndexingRepository extends Mock
    implements SpotlightIndexingRepository {}

// Fallback values for mocktail
class FakeSpotlightItemEntity extends Fake implements SpotlightItemEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSpotlightItemEntity());
  });

  group('IndexSpotlightItemUseCase', () {
    late IndexSpotlightItemUseCase useCase;
    late MockSpotlightIndexingRepository mockRepository;

    setUp(() {
      mockRepository = MockSpotlightIndexingRepository();
      useCase = IndexSpotlightItemUseCase(mockRepository);
    });

    group('call', () {
      late SpotlightItemEntity testItem;

      setUp(() {
        testItem = SpotlightItemEntity(
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

      test('should return success when repository succeeds', () async {
        // Arrange
        when(() => mockRepository.indexItem(any()))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(testItem);

        // Assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.indexItem(testItem)).called(1);
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const failure = AppFailure.network(message: 'Test error');
        when(() => mockRepository.indexItem(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(testItem);

        // Assert
        expect(result, equals(const Left(failure)));
        verify(() => mockRepository.indexItem(testItem)).called(1);
      });

      test('should return validation error when item is invalid', () async {
        // Arrange
        final invalidItem = testItem.copyWith(title: ''); // Invalid title

        // Act
        final result = await useCase(invalidItem);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure for invalid item'),
        );
        verifyNever(() => mockRepository.indexItem(any()));
      });

      test('should return validation error when item is inactive', () async {
        // Arrange
        final inactiveItem = testItem.copyWith(isActive: false);

        // Act
        final result = await useCase(inactiveItem);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure for inactive item'),
        );
        verifyNever(() => mockRepository.indexItem(any()));
      });

      test('should validate required parameters', () async {
        // Arrange
        final itemWithEmptyDeepLink = testItem.copyWith(deepLink: '');

        // Act
        final result = await useCase(itemWithEmptyDeepLink);

        // Assert
        result.fold(
          (failure) => expect(failure, isA<AppFailure>()),
          (_) => fail('Expected failure for empty deep link'),
        );
        verifyNever(() => mockRepository.indexItem(any()));
      });
    });
  });
}
