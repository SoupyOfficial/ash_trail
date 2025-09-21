// Tests for RefreshLogDetailUseCase
// Validates refresh functionality with success and error scenarios

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/detail_view/domain/usecases/refresh_log_detail_usecase.dart';
import 'package:ash_trail/features/detail_view/domain/repositories/log_detail_repository.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';

class MockLogDetailRepository extends Mock implements LogDetailRepository {}

void main() {
  group('RefreshLogDetailUseCase', () {
    late RefreshLogDetailUseCase useCase;
    late MockLogDetailRepository mockRepository;
    late LogDetailEntity testEntity;

    setUp(() {
      mockRepository = MockLogDetailRepository();
      useCase = RefreshLogDetailUseCase(mockRepository);

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

      testEntity = LogDetailEntity(log: testLog);
    });

    test('should return refreshed LogDetailEntity when repository succeeds',
        () async {
      // Arrange
      const logId = 'log-123';
      when(() => mockRepository.refreshLogDetail(any()))
          .thenAnswer((_) async => Right(testEntity));

      // Act
      final result = await useCase(const RefreshLogDetailParams(logId: logId));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (entity) => expect(entity, equals(testEntity)),
      );

      verify(() => mockRepository.refreshLogDetail(logId)).called(1);
    });

    test('should return AppFailure when repository fails', () async {
      // Arrange
      const logId = 'log-123';
      const failure = AppFailure.network(message: 'Failed to refresh');
      when(() => mockRepository.refreshLogDetail(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const RefreshLogDetailParams(logId: logId));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (entity) => fail('Expected failure but got success: $entity'),
      );

      verify(() => mockRepository.refreshLogDetail(logId)).called(1);
    });

    test('should pass correct logId to repository', () async {
      // Arrange
      const logId = 'specific-refresh-id';
      when(() => mockRepository.refreshLogDetail(any()))
          .thenAnswer((_) async => Right(testEntity));

      // Act
      await useCase(const RefreshLogDetailParams(logId: logId));

      // Assert
      verify(() => mockRepository.refreshLogDetail(logId)).called(1);
    });

    group('RefreshLogDetailParams', () {
      test('should create params with correct logId', () {
        const params = RefreshLogDetailParams(logId: 'test-id');
        expect(params.logId, equals('test-id'));
      });

      test('should support equality comparison', () {
        const params1 = RefreshLogDetailParams(logId: 'test-id');
        const params2 = RefreshLogDetailParams(logId: 'test-id');
        const params3 = RefreshLogDetailParams(logId: 'different-id');

        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
      });
    });
  });
}
