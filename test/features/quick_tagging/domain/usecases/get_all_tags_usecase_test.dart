// Tests for GetAllTagsUseCase
// Validates use case behavior with validation and repository integration

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/quick_tagging/domain/usecases/get_all_tags_usecase.dart';
import 'package:ash_trail/features/quick_tagging/domain/repositories/quick_tagging_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/tag.dart';

// Mock
class MockQuickTaggingRepository extends Mock
    implements QuickTaggingRepository {}

void main() {
  group('GetAllTagsUseCase', () {
    late GetAllTagsUseCase useCase;
    late MockQuickTaggingRepository mockRepository;
    late List<Tag> testTags;

    setUp(() {
      mockRepository = MockQuickTaggingRepository();
      useCase = GetAllTagsUseCase(repository: mockRepository);

      final now = DateTime.now();
      testTags = [
        Tag(
          id: 'tag-1',
          accountId: 'acc-123',
          name: 'Test Tag 1',
          color: '#FF0000',
          createdAt: now,
          updatedAt: now,
        ),
        Tag(
          id: 'tag-2',
          accountId: 'acc-123',
          name: 'Test Tag 2',
          color: '#00FF00',
          createdAt: now,
          updatedAt: now,
        ),
      ];
    });

    group('validation', () {
      test('should return validation error when accountId is empty', () async {
        // arrange
        const accountId = '';

        // act
        final result = await useCase.call(accountId: accountId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure,
                equals(const AppFailure.validation(
                  message: 'Account ID is required',
                  field: 'accountId',
                )));
          },
          (_) => fail('Expected validation failure'),
        );

        verifyNever(() =>
            mockRepository.getAllTags(accountId: any(named: 'accountId')));
      });
    });

    group('repository integration', () {
      test(
          'should call repository with correct accountId when validation passes',
          () async {
        // arrange
        const accountId = 'acc-123';

        when(() =>
                mockRepository.getAllTags(accountId: any(named: 'accountId')))
            .thenAnswer((_) async => Right(testTags));

        // act
        await useCase.call(accountId: accountId);

        // assert
        verify(() => mockRepository.getAllTags(accountId: accountId)).called(1);
      });

      test('should return tags when repository succeeds', () async {
        // arrange
        const accountId = 'acc-123';

        when(() =>
                mockRepository.getAllTags(accountId: any(named: 'accountId')))
            .thenAnswer((_) async => Right(testTags));

        // act
        final result = await useCase.call(accountId: accountId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (tags) {
            expect(tags, equals(testTags));
            expect(tags, hasLength(2));
            expect(tags.first.name, equals('Test Tag 1'));
            expect(tags.last.name, equals('Test Tag 2'));
          },
        );
      });

      test('should return empty list when repository returns empty list',
          () async {
        // arrange
        const accountId = 'acc-empty';
        final emptyTags = <Tag>[];

        when(() =>
                mockRepository.getAllTags(accountId: any(named: 'accountId')))
            .thenAnswer((_) async => Right(emptyTags));

        // act
        final result = await useCase.call(accountId: accountId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (tags) {
            expect(tags, isEmpty);
            expect(tags, equals(emptyTags));
          },
        );
      });

      test('should return repository failure when repository fails', () async {
        // arrange
        const accountId = 'acc-123';
        const repositoryFailure = AppFailure.network(message: 'Network error');

        when(() =>
                mockRepository.getAllTags(accountId: any(named: 'accountId')))
            .thenAnswer((_) async => const Left(repositoryFailure));

        // act
        final result = await useCase.call(accountId: accountId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(repositoryFailure)),
          (_) => fail('Expected failure but got success'),
        );
      });

      test('should handle different account IDs correctly', () async {
        // arrange
        const accountId1 = 'acc-first';
        const accountId2 = 'acc-second';

        final tags1 = [testTags.first];
        final tags2 = [testTags.last];

        when(() => mockRepository.getAllTags(accountId: accountId1))
            .thenAnswer((_) async => Right(tags1));
        when(() => mockRepository.getAllTags(accountId: accountId2))
            .thenAnswer((_) async => Right(tags2));

        // act
        final result1 = await useCase.call(accountId: accountId1);
        final result2 = await useCase.call(accountId: accountId2);

        // assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        result1.fold(
          (failure) => fail('Expected success for first account'),
          (tags) => expect(tags, hasLength(1)),
        );

        result2.fold(
          (failure) => fail('Expected success for second account'),
          (tags) => expect(tags, hasLength(1)),
        );

        verify(() => mockRepository.getAllTags(accountId: accountId1))
            .called(1);
        verify(() => mockRepository.getAllTags(accountId: accountId2))
            .called(1);
      });

      test('should handle large number of tags correctly', () async {
        // arrange
        const accountId = 'acc-many-tags';
        final now = DateTime.now();
        final manyTags = List.generate(
            100,
            (index) => Tag(
                  id: 'tag-$index',
                  accountId: accountId,
                  name: 'Tag $index',
                  color: '#${index.toRadixString(16).padLeft(6, '0')}',
                  createdAt: now,
                  updatedAt: now,
                ));

        when(() =>
                mockRepository.getAllTags(accountId: any(named: 'accountId')))
            .thenAnswer((_) async => Right(manyTags));

        // act
        final result = await useCase.call(accountId: accountId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (tags) {
            expect(tags, hasLength(100));
            expect(tags.first.name, equals('Tag 0'));
            expect(tags.last.name, equals('Tag 99'));
          },
        );
      });
    });
  });
}
