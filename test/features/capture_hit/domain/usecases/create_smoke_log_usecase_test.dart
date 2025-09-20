// Unit tests for CreateSmokeLogUseCase
// Validates business logic and error handling for smoke log creation

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/create_smoke_log_usecase.dart';

class MockSmokeLogRepository extends Mock implements SmokeLogRepository {}

class SmokeLogFake extends Fake implements SmokeLog {}

void main() {
  group('CreateSmokeLogUseCase', () {
    late CreateSmokeLogUseCase useCase;
    late MockSmokeLogRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(SmokeLogFake());
    });

    setUp(() {
      mockRepository = MockSmokeLogRepository();
      useCase = CreateSmokeLogUseCase(repository: mockRepository);
    });

    group('Validation', () {
      test('should return validation error for empty account ID', () async {
        // Act
        final result = await useCase(
          accountId: '',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message, contains('Account ID is required'));
          },
          (_) => fail('Expected validation error'),
        );

        // Verify repository not called
        verifyNever(() => mockRepository.createSmokeLog(any()));
      });

      test('should return validation error for zero duration', () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 0,
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('Duration must be greater than 0'));
          },
          (_) => fail('Expected validation error'),
        );

        verifyNever(() => mockRepository.createSmokeLog(any()));
      });

      test('should return validation error for negative duration', () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: -1000,
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('Duration must be greater than 0'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for duration exceeding 30 minutes',
          () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 1800001, // 30 minutes + 1ms
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('Duration cannot exceed 30 minutes'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for mood score below 1', () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 0,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message,
                contains('Mood score must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for mood score above 10', () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 11,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message,
                contains('Mood score must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for physical score below 1',
          () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 0,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message,
                contains('Physical score must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for physical score above 10',
          () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 11,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message,
                contains('Physical score must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for potency below 1 when provided',
          () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          potency: 0,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('Potency must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });

      test('should return validation error for potency above 10 when provided',
          () async {
        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          potency: 11,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('Potency must be between 1 and 10'));
          },
          (_) => fail('Expected validation error'),
        );
      });
    });

    group('Success Cases', () {
      test('should create smoke log with valid minimum parameters', () async {
        // Arrange
        const accountId = 'test_account';
        const durationMs = 5000;
        const moodScore = 5;
        const physicalScore = 7;

        final expectedSmokeLog = SmokeLog(
          id: 'test_id',
          accountId: accountId,
          ts: DateTime(2023, 10, 15, 14, 30),
          durationMs: durationMs,
          moodScore: moodScore,
          physicalScore: physicalScore,
          deviceLocalId: null,
          createdAt: DateTime(2023, 10, 15, 14, 30),
          updatedAt: DateTime(2023, 10, 15, 14, 30),
        );

        when(() => mockRepository.createSmokeLog(any()))
            .thenAnswer((_) async => Right(expectedSmokeLog));

        // Act
        final result = await useCase(
          accountId: accountId,
          durationMs: durationMs,
          moodScore: moodScore,
          physicalScore: physicalScore,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (smokeLog) {
            expect(smokeLog.accountId, accountId);
            expect(smokeLog.durationMs, durationMs);
            expect(smokeLog.moodScore, moodScore);
            expect(smokeLog.physicalScore, physicalScore);
          },
        );

        // Verify repository called with correct parameters
        final captured =
            verify(() => mockRepository.createSmokeLog(captureAny())).captured;
        final capturedLog = captured.first as SmokeLog;
        expect(capturedLog.accountId, accountId);
        expect(capturedLog.durationMs, durationMs);
        expect(capturedLog.moodScore, moodScore);
        expect(capturedLog.physicalScore, physicalScore);
      });

      test('should create smoke log with all optional parameters', () async {
        // Arrange
        const accountId = 'test_account';
        const durationMs = 12000;
        const moodScore = 8;
        const physicalScore = 6;
        const methodId = 'vape';
        const potency = 9;
        const notes = 'Great session after work';

        final expectedSmokeLog = SmokeLog(
          id: 'test_id',
          accountId: accountId,
          ts: DateTime(2023, 10, 15, 14, 30),
          durationMs: durationMs,
          methodId: methodId,
          potency: potency,
          moodScore: moodScore,
          physicalScore: physicalScore,
          notes: notes,
          deviceLocalId: null,
          createdAt: DateTime(2023, 10, 15, 14, 30),
          updatedAt: DateTime(2023, 10, 15, 14, 30),
        );

        when(() => mockRepository.createSmokeLog(any()))
            .thenAnswer((_) async => Right(expectedSmokeLog));

        // Act
        final result = await useCase(
          accountId: accountId,
          durationMs: durationMs,
          moodScore: moodScore,
          physicalScore: physicalScore,
          methodId: methodId,
          potency: potency,
          notes: notes,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (smokeLog) {
            expect(smokeLog.accountId, accountId);
            expect(smokeLog.durationMs, durationMs);
            expect(smokeLog.methodId, methodId);
            expect(smokeLog.potency, potency);
            expect(smokeLog.notes, notes);
          },
        );
      });

      test('should handle maximum valid duration (30 minutes)', () async {
        // Arrange
        const durationMs = 1800000; // Exactly 30 minutes

        when(() => mockRepository.createSmokeLog(any()))
            .thenAnswer((_) async => Right(SmokeLog(
                  id: 'test_id',
                  accountId: 'test_account',
                  ts: DateTime(2023, 10, 15),
                  durationMs: durationMs,
                  moodScore: 5,
                  physicalScore: 5,
                  deviceLocalId: null,
                  createdAt: DateTime(2023, 10, 15),
                  updatedAt: DateTime(2023, 10, 15),
                )));

        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: durationMs,
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isRight(), true);
      });

      test('should filter out empty notes', () async {
        // Arrange
        when(() => mockRepository.createSmokeLog(any()))
            .thenAnswer((_) async => Right(SmokeLog(
                  id: 'test_id',
                  accountId: 'test_account',
                  ts: DateTime(2023, 10, 15),
                  durationMs: 5000,
                  moodScore: 5,
                  physicalScore: 5,
                  notes: null, // Should be null for empty string
                  deviceLocalId: null,
                  createdAt: DateTime(2023, 10, 15),
                  updatedAt: DateTime(2023, 10, 15),
                )));

        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          notes: '', // Empty string should become null
        );

        // Assert
        expect(result.isRight(), true);

        final captured =
            verify(() => mockRepository.createSmokeLog(captureAny())).captured;
        final capturedLog = captured.first as SmokeLog;
        expect(capturedLog.notes, isNull);
      });
    });

    group('Repository Errors', () {
      test('should forward repository errors', () async {
        // Arrange
        const failure = AppFailure.cache(message: 'Database error');
        when(() => mockRepository.createSmokeLog(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          accountId: 'test_account',
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, failure),
          (_) => fail('Expected error'),
        );
      });
    });
  });
}
