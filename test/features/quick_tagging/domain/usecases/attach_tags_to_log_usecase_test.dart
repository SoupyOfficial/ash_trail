// Tests for AttachTagsToLogUseCase
// Validates use case behavior with validation and repository integration

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/quick_tagging/domain/usecases/attach_tags_to_log_usecase.dart';
import 'package:ash_trail/features/quick_tagging/domain/repositories/quick_tagging_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Mock
class MockQuickTaggingRepository extends Mock
    implements QuickTaggingRepository {}

void main() {
  group('AttachTagsToLogUseCase', () {
    late AttachTagsToLogUseCase useCase;
    late MockQuickTaggingRepository mockRepository;

    setUp(() {
      mockRepository = MockQuickTaggingRepository();
      useCase = AttachTagsToLogUseCase(repository: mockRepository);
    });

    group('validation', () {
      test('should return validation error when accountId is empty', () async {
        // arrange
        final params = {
          'accountId': '',
          'smokeLogId': 'log-123',
          'ts': DateTime.now(),
          'tagIds': ['tag-1', 'tag-2'],
        };

        // act
        final result = await useCase.call(
          accountId: params['accountId'] as String,
          smokeLogId: params['smokeLogId'] as String,
          ts: params['ts'] as DateTime,
          tagIds: params['tagIds'] as List<String>,
        );

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

        verifyNever(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            ));
      });

      test('should return validation error when smokeLogId is empty', () async {
        // arrange
        final params = {
          'accountId': 'acc-123',
          'smokeLogId': '',
          'ts': DateTime.now(),
          'tagIds': ['tag-1', 'tag-2'],
        };

        // act
        final result = await useCase.call(
          accountId: params['accountId'] as String,
          smokeLogId: params['smokeLogId'] as String,
          ts: params['ts'] as DateTime,
          tagIds: params['tagIds'] as List<String>,
        );

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure,
                equals(const AppFailure.validation(
                  message: 'SmokeLog ID is required',
                  field: 'smokeLogId',
                )));
          },
          (_) => fail('Expected validation failure'),
        );

        verifyNever(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            ));
      });

      test('should return validation error when tagIds is empty', () async {
        // arrange
        final params = {
          'accountId': 'acc-123',
          'smokeLogId': 'log-456',
          'ts': DateTime.now(),
          'tagIds': <String>[],
        };

        // act
        final result = await useCase.call(
          accountId: params['accountId'] as String,
          smokeLogId: params['smokeLogId'] as String,
          ts: params['ts'] as DateTime,
          tagIds: params['tagIds'] as List<String>,
        );

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure,
                equals(const AppFailure.validation(
                  message: 'At least one tag is required',
                  field: 'tagIds',
                )));
          },
          (_) => fail('Expected validation failure'),
        );

        verifyNever(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            ));
      });
    });

    group('repository integration', () {
      test(
          'should call repository with correct parameters when validation passes',
          () async {
        // arrange
        const accountId = 'acc-123';
        const smokeLogId = 'log-456';
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        const tagIds = ['tag-1', 'tag-2', 'tag-3'];

        when(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            )).thenAnswer((_) async => const Right(null));

        // act
        await useCase.call(
          accountId: accountId,
          smokeLogId: smokeLogId,
          ts: timestamp,
          tagIds: tagIds,
        );

        // assert
        verify(() => mockRepository.attachTagsToSmokeLog(
              accountId: accountId,
              smokeLogId: smokeLogId,
              ts: timestamp,
              tagIds: tagIds,
            )).called(1);
      });

      test('should return success when repository succeeds', () async {
        // arrange
        const accountId = 'acc-123';
        const smokeLogId = 'log-456';
        final timestamp = DateTime.now();
        const tagIds = ['tag-1'];

        when(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            )).thenAnswer((_) async => const Right(null));

        // act
        final result = await useCase.call(
          accountId: accountId,
          smokeLogId: smokeLogId,
          ts: timestamp,
          tagIds: tagIds,
        );

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) => {
            // Success - void return type
          },
        );
      });

      test('should return repository failure when repository fails', () async {
        // arrange
        const accountId = 'acc-123';
        const smokeLogId = 'log-456';
        final timestamp = DateTime.now();
        const tagIds = ['tag-1'];
        const repositoryFailure = AppFailure.network(message: 'Network error');

        when(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            )).thenAnswer((_) async => const Left(repositoryFailure));

        // act
        final result = await useCase.call(
          accountId: accountId,
          smokeLogId: smokeLogId,
          ts: timestamp,
          tagIds: tagIds,
        );

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(repositoryFailure)),
          (_) => fail('Expected failure but got success'),
        );
      });

      test('should handle multiple tag IDs correctly', () async {
        // arrange
        const accountId = 'acc-multi';
        const smokeLogId = 'log-multi';
        final timestamp = DateTime.now();
        const tagIds = ['tag-1', 'tag-2', 'tag-3', 'tag-4', 'tag-5'];

        when(() => mockRepository.attachTagsToSmokeLog(
              accountId: any(named: 'accountId'),
              smokeLogId: any(named: 'smokeLogId'),
              ts: any(named: 'ts'),
              tagIds: any(named: 'tagIds'),
            )).thenAnswer((_) async => const Right(null));

        // act
        final result = await useCase.call(
          accountId: accountId,
          smokeLogId: smokeLogId,
          ts: timestamp,
          tagIds: tagIds,
        );

        // assert
        expect(result.isRight(), isTrue);
        verify(() => mockRepository.attachTagsToSmokeLog(
              accountId: accountId,
              smokeLogId: smokeLogId,
              ts: timestamp,
              tagIds: tagIds,
            )).called(1);
      });
    });
  });
}
