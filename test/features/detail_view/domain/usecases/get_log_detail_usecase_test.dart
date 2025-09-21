// Tests for GetLogDetailUseCase
// Validates use case behavior with success and error scenarios

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/detail_view/domain/usecases/get_log_detail_usecase.dart';
import 'package:ash_trail/features/detail_view/domain/repositories/log_detail_repository.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';

class MockLogDetailRepository extends Mock implements LogDetailRepository {}

void main() {
  group('GetLogDetailUseCase', () {
    late GetLogDetailUseCase useCase;
    late MockLogDetailRepository mockRepository;
    late LogDetailEntity testEntity;

    setUp(() {
      mockRepository = MockLogDetailRepository();
      useCase = GetLogDetailUseCase(mockRepository);

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

    test('should return LogDetailEntity when repository succeeds', () async {
      // Arrange
      const logId = 'log-123';
      when(() => mockRepository.getLogDetail(any()))
          .thenAnswer((_) async => Right(testEntity));

      // Act
      final result = await useCase(const GetLogDetailParams(logId: logId));

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (entity) => expect(entity, equals(testEntity)),
      );

      verify(() => mockRepository.getLogDetail(logId)).called(1);
    });

    test('should return AppFailure when repository fails', () async {
      // Arrange
      const logId = 'log-123';
      const failure = AppFailure.notFound(message: 'Log not found');
      when(() => mockRepository.getLogDetail(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(const GetLogDetailParams(logId: logId));

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (entity) => fail('Expected failure but got success: $entity'),
      );

      verify(() => mockRepository.getLogDetail(logId)).called(1);
    });

    test('should pass correct logId to repository', () async {
      // Arrange
      const logId = 'specific-log-id';
      when(() => mockRepository.getLogDetail(any()))
          .thenAnswer((_) async => Right(testEntity));

      // Act
      await useCase(const GetLogDetailParams(logId: logId));

      // Assert
      verify(() => mockRepository.getLogDetail(logId)).called(1);
    });

    group('GetLogDetailParams', () {
      test('should create params with correct logId', () {
        const params = GetLogDetailParams(logId: 'test-id');
        expect(params.logId, equals('test-id'));
      });

      test('should support equality comparison', () {
        const params1 = GetLogDetailParams(logId: 'test-id');
        const params2 = GetLogDetailParams(logId: 'test-id');
        const params3 = GetLogDetailParams(logId: 'different-id');

        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
      });
    });
  });
}
