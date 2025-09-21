// Tests for LogDetailRepositoryImpl
// Validates repository implementation with local/remote data sources coordination

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/detail_view/data/repositories/log_detail_repository_impl.dart';
import 'package:ash_trail/features/detail_view/data/datasources/log_detail_datasource.dart';
import 'package:ash_trail/features/detail_view/data/models/log_detail_model.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/domain/models/reason.dart';
import 'package:ash_trail/domain/models/method.dart';

// Mocks
class MockLogDetailLocalDataSource extends Mock
    implements LogDetailLocalDataSource {}

class MockLogDetailRemoteDataSource extends Mock
    implements LogDetailRemoteDataSource {}

// Fakes for registerFallbackValue
class LogDetailModelFake extends Fake implements LogDetailModel {}

void main() {
  group('LogDetailRepositoryImpl', () {
    late LogDetailRepositoryImpl repository;
    late MockLogDetailLocalDataSource mockLocalDataSource;
    late MockLogDetailRemoteDataSource mockRemoteDataSource;
    late LogDetailModel testModel;
    late LogDetailEntity testEntity;

    setUpAll(() {
      registerFallbackValue(LogDetailModelFake());
    });

    setUp(() {
      mockLocalDataSource = MockLogDetailLocalDataSource();
      mockRemoteDataSource = MockLogDetailRemoteDataSource();
      repository = LogDetailRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
      );

      final now = DateTime.now();
      final testLog = SmokeLog(
        id: 'log-123',
        accountId: 'acc-456',
        ts: now,
        durationMs: 5000,
        moodScore: 7,
        physicalScore: 8,
        createdAt: now,
        updatedAt: now,
      );

      final testTag = Tag(
        id: 'tag-1',
        accountId: 'acc-456',
        name: 'Test Tag',
        color: '#FF0000',
        createdAt: now,
        updatedAt: now,
      );

      final testReason = Reason(
        id: 'reason-1',
        accountId: 'acc-456',
        name: 'Test Reason',
        enabled: true,
        orderIndex: 1,
        createdAt: now,
        updatedAt: now,
      );

      final testMethod = Method(
        id: 'method-1',
        accountId: 'acc-456',
        name: 'Test Method',
        category: 'test-category',
        createdAt: now,
        updatedAt: now,
      );

      testModel = LogDetailModel(
        log: testLog,
        tags: [testTag],
        reasons: [testReason],
        method: testMethod,
      );

      testEntity = testModel.toEntity();
    });

    group('getLogDetail', () {
      test('should return local data when available', () async {
        // arrange
        const logId = 'log-123';
        when(() => mockLocalDataSource.getLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));

        // act
        final result = await repository.getLogDetail(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (entity) {
            expect(entity.log.id, equals(testEntity.log.id));
            expect(entity.tags.length, equals(testEntity.tags.length));
            expect(entity.reasons.length, equals(testEntity.reasons.length));
            expect(entity.method?.id, equals(testEntity.method?.id));
          },
        );

        verify(() => mockLocalDataSource.getLogDetail(logId)).called(1);
        verifyNever(() => mockRemoteDataSource.getLogDetail(any()));
      });

      test('should fallback to remote when local fails', () async {
        // arrange
        const logId = 'log-123';
        const localFailure = AppFailure.notFound(message: 'Local not found');

        when(() => mockLocalDataSource.getLogDetail(any()))
            .thenAnswer((_) async => const Left(localFailure));
        when(() => mockRemoteDataSource.getLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));
        when(() => mockLocalDataSource.cacheLogDetail(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await repository.getLogDetail(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (entity) {
            expect(entity.log.id, equals(testEntity.log.id));
            expect(entity.tags.length, equals(testEntity.tags.length));
          },
        );

        verify(() => mockLocalDataSource.getLogDetail(logId)).called(1);
        verify(() => mockRemoteDataSource.getLogDetail(logId)).called(1);
        verify(() => mockLocalDataSource.cacheLogDetail(testModel)).called(1);
      });

      test('should return remote failure when both local and remote fail',
          () async {
        // arrange
        const logId = 'log-123';
        const localFailure = AppFailure.notFound(message: 'Local not found');
        const remoteFailure = AppFailure.network(message: 'Remote not found');

        when(() => mockLocalDataSource.getLogDetail(any()))
            .thenAnswer((_) async => const Left(localFailure));
        when(() => mockRemoteDataSource.getLogDetail(any()))
            .thenAnswer((_) async => const Left(remoteFailure));

        // act
        final result = await repository.getLogDetail(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(remoteFailure)),
          (entity) => fail('Expected failure but got success: $entity'),
        );

        verify(() => mockLocalDataSource.getLogDetail(logId)).called(1);
        verify(() => mockRemoteDataSource.getLogDetail(logId)).called(1);
        verifyNever(() => mockLocalDataSource.cacheLogDetail(any()));
      });

      test('should pass correct logId to both data sources when needed',
          () async {
        // arrange
        const logId = 'specific-log-id';
        const localFailure = AppFailure.notFound(message: 'Local not found');

        when(() => mockLocalDataSource.getLogDetail(any()))
            .thenAnswer((_) async => const Left(localFailure));
        when(() => mockRemoteDataSource.getLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));
        when(() => mockLocalDataSource.cacheLogDetail(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await repository.getLogDetail(logId);

        // assert
        verify(() => mockLocalDataSource.getLogDetail(logId)).called(1);
        verify(() => mockRemoteDataSource.getLogDetail(logId)).called(1);
      });
    });

    group('logExists', () {
      test('should return true when local data source confirms existence',
          () async {
        // arrange
        const logId = 'existing-log';
        when(() => mockLocalDataSource.logExists(any()))
            .thenAnswer((_) async => const Right(true));

        // act
        final result = await repository.logExists(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (exists) => expect(exists, isTrue),
        );

        verify(() => mockLocalDataSource.logExists(logId)).called(1);
        verifyNever(() => mockRemoteDataSource.logExists(any()));
      });

      test('should check remote when local says false', () async {
        // arrange
        const logId = 'maybe-remote-log';
        when(() => mockLocalDataSource.logExists(any()))
            .thenAnswer((_) async => const Right(false));
        when(() => mockRemoteDataSource.logExists(any()))
            .thenAnswer((_) async => const Right(true));

        // act
        final result = await repository.logExists(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (exists) => expect(exists, isTrue),
        );

        verify(() => mockLocalDataSource.logExists(logId)).called(1);
        verify(() => mockRemoteDataSource.logExists(logId)).called(1);
      });

      test('should check remote when local fails', () async {
        // arrange
        const logId = 'problematic-log';
        const localFailure = AppFailure.cache(message: 'Local check failed');
        when(() => mockLocalDataSource.logExists(any()))
            .thenAnswer((_) async => const Left(localFailure));
        when(() => mockRemoteDataSource.logExists(any()))
            .thenAnswer((_) async => const Right(false));

        // act
        final result = await repository.logExists(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (exists) => expect(exists, isFalse),
        );

        verify(() => mockLocalDataSource.logExists(logId)).called(1);
        verify(() => mockRemoteDataSource.logExists(logId)).called(1);
      });

      test('should return remote failure when remote also fails', () async {
        // arrange
        const logId = 'failing-log';
        const localFailure = AppFailure.notFound(message: 'Local failure');
        const remoteFailure = AppFailure.network(message: 'Remote failure');
        when(() => mockLocalDataSource.logExists(any()))
            .thenAnswer((_) async => const Left(localFailure));
        when(() => mockRemoteDataSource.logExists(any()))
            .thenAnswer((_) async => const Left(remoteFailure));

        // act
        final result = await repository.logExists(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(remoteFailure)),
          (exists) => fail('Expected failure but got success: $exists'),
        );

        verify(() => mockLocalDataSource.logExists(logId)).called(1);
        verify(() => mockRemoteDataSource.logExists(logId)).called(1);
      });
    });

    group('refreshLogDetail', () {
      test('should fetch from remote and cache locally', () async {
        // arrange
        const logId = 'refresh-log';
        when(() => mockRemoteDataSource.refreshLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));
        when(() => mockLocalDataSource.cacheLogDetail(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await repository.refreshLogDetail(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (entity) {
            expect(entity.log.id, equals(testEntity.log.id));
            expect(entity.tags.length, equals(testEntity.tags.length));
            expect(entity.reasons.length, equals(testEntity.reasons.length));
            expect(entity.method?.id, equals(testEntity.method?.id));
          },
        );

        verify(() => mockRemoteDataSource.refreshLogDetail(logId)).called(1);
        verify(() => mockLocalDataSource.cacheLogDetail(testModel)).called(1);
        verifyNever(() => mockLocalDataSource.getLogDetail(any()));
      });

      test('should return failure when remote fails', () async {
        // arrange
        const logId = 'failing-refresh-log';
        const remoteFailure = AppFailure.network(message: 'Refresh failed');
        when(() => mockRemoteDataSource.refreshLogDetail(any()))
            .thenAnswer((_) async => const Left(remoteFailure));

        // act
        final result = await repository.refreshLogDetail(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(remoteFailure)),
          (entity) => fail('Expected failure but got success: $entity'),
        );

        verify(() => mockRemoteDataSource.refreshLogDetail(logId)).called(1);
        verifyNever(() => mockLocalDataSource.cacheLogDetail(any()));
      });

      test('should cache data even if caching fails - success takes priority',
          () async {
        // arrange
        const logId = 'cache-fail-refresh';
        const cacheFailure = AppFailure.cache(message: 'Cache failed');
        when(() => mockRemoteDataSource.refreshLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));
        when(() => mockLocalDataSource.cacheLogDetail(any()))
            .thenAnswer((_) async => const Left(cacheFailure));

        // act
        final result = await repository.refreshLogDetail(logId);

        // assert - Should still return success even if caching fails
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (entity) => expect(entity.log.id, equals(testEntity.log.id)),
        );

        verify(() => mockRemoteDataSource.refreshLogDetail(logId)).called(1);
        verify(() => mockLocalDataSource.cacheLogDetail(testModel)).called(1);
      });

      test('should pass correct logId to remote data source', () async {
        // arrange
        const logId = 'specific-refresh-id';
        when(() => mockRemoteDataSource.refreshLogDetail(any()))
            .thenAnswer((_) async => Right(testModel));
        when(() => mockLocalDataSource.cacheLogDetail(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await repository.refreshLogDetail(logId);

        // assert
        verify(() => mockRemoteDataSource.refreshLogDetail(logId)).called(1);
      });
    });
  });
}
