// Tests for MockLogDetailLocalDataSource and MockLogDetailRemoteDataSource
// Validates mock implementations for development and testing

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/detail_view/data/datasources/mock_log_detail_datasource.dart';
import 'package:ash_trail/features/detail_view/data/models/log_detail_model.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/domain/models/reason.dart';
import 'package:ash_trail/domain/models/method.dart';

void main() {
  group('MockLogDetailLocalDataSource', () {
    late MockLogDetailLocalDataSource dataSource;

    setUp(() {
      dataSource = MockLogDetailLocalDataSource();
    });

    group('getLogDetail', () {
      test('should generate mock log for test IDs', () async {
        // arrange
        const logId = 'test-log-123';

        // act
        final result = await dataSource.getLogDetail(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (model) {
            expect(model.log.id, equals(logId));
            expect(model.log.accountId, equals('test-account-1'));
            expect(model.tags, isNotEmpty);
            expect(model.reasons, isNotEmpty);
            expect(model.method, isNotNull);
            expect(model.method?.id, equals('vape-pen'));
            expect(model.tags, hasLength(2));
            expect(model.reasons, hasLength(1));
          },
        );
      });

      test('should generate mock log for known development IDs', () async {
        const knownIds = ['abc', 'first', 'demo', 'second'];

        for (final logId in knownIds) {
          // act
          final result = await dataSource.getLogDetail(logId);

          // assert
          expect(result.isRight(), isTrue);
          result.fold(
            (failure) =>
                fail('Expected success but got failure for $logId: $failure'),
            (model) {
              expect(model.log.id, equals(logId));
              expect(model.log.accountId, equals('test-account-1'));
              expect(model.log.methodId, equals('vape-pen'));
              expect(model.method?.id, equals('vape-pen'));
              expect(model.tags, hasLength(2));
              expect(model.reasons, hasLength(1));
            },
          );
        }
      });

      test('should return not found failure for unknown log ID', () async {
        // arrange
        const logId = 'unknown-log-id';

        // act
        final result = await dataSource.getLogDetail(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure,
              equals(const AppFailure.notFound(message: 'Log not found'))),
          (model) => fail('Expected failure but got success: $model'),
        );
      });

      test('should generate different data for different log IDs', () async {
        // arrange
        const logId1 = 'test-different-1';
        const logId2 = 'test-different-2';

        // act
        final result1 = await dataSource.getLogDetail(logId1);
        final result2 = await dataSource.getLogDetail(logId2);

        // assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final model1 = result1
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));
        final model2 = result2
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));

        expect(model1.log.id, equals(logId1));
        expect(model2.log.id, equals(logId2));
        // Duration should vary based on hash
        expect(model1.log.durationMs, isNot(equals(model2.log.durationMs)));
        // Timestamp should vary based on hash
        expect(model1.log.ts, isNot(equals(model2.log.ts)));
      });

      test('should cache data - subsequent calls return same data', () async {
        // arrange
        const logId = 'test-cache-behavior';

        // act - call twice
        final result1 = await dataSource.getLogDetail(logId);
        final result2 = await dataSource.getLogDetail(logId);

        // assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);

        final model1 = result1
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));
        final model2 = result2
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));

        // Should be identical (cached)
        expect(model1, equals(model2));
        expect(model1.log.ts, equals(model2.log.ts));
        expect(model1.log.durationMs, equals(model2.log.durationMs));
      });
    });

    group('logExists', () {
      test('should return true for mock-generatable IDs', () async {
        const testIds = ['test-123', 'abc', 'first', 'demo', 'second'];

        for (final logId in testIds) {
          // act
          final result = await dataSource.logExists(logId);

          // assert
          expect(result.isRight(), isTrue, reason: 'Failed for ID: $logId');
          result.fold(
            (failure) =>
                fail('Expected success but got failure for $logId: $failure'),
            (exists) =>
                expect(exists, isTrue, reason: 'Should exist for ID: $logId'),
          );
        }
      });

      test('should return false for unknown log IDs', () async {
        // arrange
        const logId = 'completely-unknown-id';

        // act
        final result = await dataSource.logExists(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (exists) => expect(exists, isFalse),
        );
      });
    });

    group('cacheLogDetail', () {
      test('should cache log detail successfully', () async {
        // arrange
        const logId = 'cache-test-log';
        final now = DateTime.now();
        final model = LogDetailModel(
          log: SmokeLog(
            id: logId,
            accountId: 'test-account',
            ts: now,
            durationMs: 5000,
            moodScore: 5,
            physicalScore: 5,
            createdAt: now,
            updatedAt: now,
          ),
          tags: [],
          reasons: [],
          method: null,
        );

        // act
        final result = await dataSource.cacheLogDetail(model);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (_) {
            // Verify caching worked by getting the log and checking it returns the cached version
          },
        );
      });

      test('should affect subsequent getLogDetail calls', () async {
        // arrange
        const logId = 'cache-interaction-test';
        final now = DateTime.now();
        final cachedModel = LogDetailModel(
          log: SmokeLog(
            id: logId,
            accountId: 'custom-account',
            ts: now,
            durationMs: 12345,
            moodScore: 9,
            physicalScore: 8,
            createdAt: now,
            updatedAt: now,
          ),
          tags: [],
          reasons: [],
          method: null,
        );

        // act
        await dataSource.cacheLogDetail(cachedModel);
        final retrieveResult = await dataSource.getLogDetail(logId);

        // assert
        expect(retrieveResult.isRight(), isTrue);
        retrieveResult.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (retrievedModel) {
            expect(retrievedModel.log.id, equals(logId));
            expect(retrievedModel.log.accountId, equals('custom-account'));
            expect(retrievedModel.log.durationMs, equals(12345));
          },
        );
      });
    });
  });

  group('MockLogDetailRemoteDataSource', () {
    late MockLogDetailRemoteDataSource dataSource;

    setUp(() {
      dataSource = MockLogDetailRemoteDataSource();
    });

    group('getLogDetail', () {
      test('should return mock data for test IDs', () async {
        // arrange
        const logId = 'test-remote-123';

        // act
        final result = await dataSource.getLogDetail(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (model) {
            expect(model.log.id, equals(logId));
            expect(model.log.accountId, equals('test-account-1'));
            expect(model.tags, isNotEmpty);
            expect(model.reasons, isNotEmpty);
            expect(model.method, isNotNull);
          },
        );
      });

      test('should return not found for unknown IDs', () async {
        // arrange
        const logId = 'unknown-remote-id';

        // act
        final result = await dataSource.getLogDetail(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure,
              equals(const AppFailure.notFound(message: 'Log not found'))),
          (model) => fail('Expected failure but got success: $model'),
        );
      });
    });

    group('refreshLogDetail', () {
      test('should return same data as getLogDetail', () async {
        // arrange
        const logId = 'test-refresh';

        // act
        final getResult = await dataSource.getLogDetail(logId);
        final refreshResult = await dataSource.refreshLogDetail(logId);

        // assert
        expect(getResult.isRight(), isTrue);
        expect(refreshResult.isRight(), isTrue);

        final getModel = getResult
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));
        final refreshModel = refreshResult
            .getRight()
            .getOrElse(() => throw StateError('Expected right'));

        expect(refreshModel.log.id, equals(getModel.log.id));
        expect(refreshModel.log.accountId, equals(getModel.log.accountId));
        expect(refreshModel.tags.length, equals(getModel.tags.length));
        expect(refreshModel.reasons.length, equals(getModel.reasons.length));
        expect(refreshModel.method?.id, equals(getModel.method?.id));
      });

      test('should fail for unknown IDs', () async {
        // arrange
        const logId = 'unknown-refresh-id';

        // act
        final result = await dataSource.refreshLogDetail(logId);

        // assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure,
              equals(const AppFailure.notFound(message: 'Log not found'))),
          (model) => fail('Expected failure but got success: $model'),
        );
      });
    });

    group('logExists', () {
      test('should return true for mock-generatable IDs', () async {
        const testIds = ['test-456', 'abc', 'first', 'demo', 'second'];

        for (final logId in testIds) {
          // act
          final result = await dataSource.logExists(logId);

          // assert
          expect(result.isRight(), isTrue, reason: 'Failed for ID: $logId');
          result.fold(
            (failure) =>
                fail('Expected success but got failure for $logId: $failure'),
            (exists) =>
                expect(exists, isTrue, reason: 'Should exist for ID: $logId'),
          );
        }
      });

      test('should return false for unknown IDs', () async {
        // arrange
        const logId = 'unknown-exists-id';

        // act
        final result = await dataSource.logExists(logId);

        // assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (exists) => expect(exists, isFalse),
        );
      });
    });
  });
}
