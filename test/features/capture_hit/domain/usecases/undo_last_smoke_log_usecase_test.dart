// Unit tests for UndoLastSmokeLogUseCase
// Validates undo functionality and time window enforcement

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/undo_last_smoke_log_usecase.dart';

class MockSmokeLogRepository extends Mock implements SmokeLogRepository {}

class SmokeLogFake extends Fake implements SmokeLog {}

void main() {
  group('UndoLastSmokeLogUseCase', () {
    late UndoLastSmokeLogUseCase useCase;
    late MockSmokeLogRepository mockRepository;

    setUpAll(() {
      registerFallbackValue(SmokeLogFake());
    });

    setUp(() {
      mockRepository = MockSmokeLogRepository();
      useCase = UndoLastSmokeLogUseCase(repository: mockRepository);
    });

    group('Validation', () {
      test('should return validation error for empty account ID', () async {
        // Act
        final result = await useCase(accountId: '');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message, contains('Account ID is required'));
          },
          (_) => fail('Expected validation error'),
        );

        verifyNever(() => mockRepository.getLastSmokeLog(any()));
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });
    });

    group('No Recent Log', () {
      test('should return not found error when no logs exist', () async {
        // Arrange
        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(
                failure.message, contains('No recent smoke log found to undo'));
          },
          (_) => fail('Expected not found error'),
        );

        verify(() => mockRepository.getLastSmokeLog('test_account')).called(1);
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });

      test('should forward repository error when getting last log fails',
          () async {
        // Arrange
        const failure = AppFailure.cache(message: 'Database error');
        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, failure),
          (_) => fail('Expected repository error'),
        );

        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });
    });

    group('Time Window Enforcement', () {
      test('should allow undo within default 6-second window', () async {
        // Arrange
        final now = DateTime.now();
        final recentLog = SmokeLog(
          id: 'test_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 3)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt:
              now.subtract(const Duration(seconds: 3)), // Created 3 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 3)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog('test_log'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (undoneLog) {
            expect(undoneLog.id, 'test_log');
            expect(undoneLog.accountId, 'test_account');
          },
        );

        verify(() => mockRepository.getLastSmokeLog('test_account')).called(1);
        verify(() => mockRepository.deleteSmokeLog('test_log')).called(1);
      });

      test('should reject undo outside default 6-second window', () async {
        // Arrange
        final now = DateTime.now();
        final oldLog = SmokeLog(
          id: 'test_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 10)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt:
              now.subtract(const Duration(seconds: 7)), // Created 7 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 7)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(oldLog));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message, contains('Undo window has expired'));
            expect(failure.message, contains('6 seconds'));
          },
          (_) => fail('Expected validation error'),
        );

        verify(() => mockRepository.getLastSmokeLog('test_account')).called(1);
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });

      test('should allow custom undo window duration', () async {
        // Arrange
        final now = DateTime.now();
        final recentLog = SmokeLog(
          id: 'test_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 8)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt:
              now.subtract(const Duration(seconds: 8)), // Created 8 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 8)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog('test_log'))
            .thenAnswer((_) async => const Right(null));

        // Act - Custom 10-second window should allow 8-second old log
        final result = await useCase(
          accountId: 'test_account',
          undoWindowSeconds: 10,
        );

        // Assert
        expect(result.isRight(), true);
        verify(() => mockRepository.deleteSmokeLog('test_log')).called(1);
      });

      test('should reject undo outside custom window', () async {
        // Arrange
        final now = DateTime.now();
        final oldLog = SmokeLog(
          id: 'test_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 2)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt:
              now.subtract(const Duration(seconds: 4)), // Created 4 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 4)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(oldLog));

        // Act - Custom 3-second window should reject 4-second old log
        final result = await useCase(
          accountId: 'test_account',
          undoWindowSeconds: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message, contains('Undo window has expired'));
            expect(failure.message, contains('3 seconds'));
          },
          (_) => fail('Expected validation error'),
        );

        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });
    });

    group('Delete Operation', () {
      test('should forward delete errors', () async {
        // Arrange
        final now = DateTime.now();
        final recentLog = SmokeLog(
          id: 'test_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 2)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt: now.subtract(const Duration(seconds: 2)),
          updatedAt: now.subtract(const Duration(seconds: 2)),
        );

        const deleteFailure = AppFailure.cache(message: 'Delete failed');

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog('test_log'))
            .thenAnswer((_) async => const Left(deleteFailure));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error, deleteFailure),
          (_) => fail('Expected delete error'),
        );

        verify(() => mockRepository.deleteSmokeLog('test_log')).called(1);
      });

      test('should return the deleted log on successful undo', () async {
        // Arrange
        final now = DateTime.now();
        final recentLog = SmokeLog(
          id: 'unique_log_id',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 1)),
          durationMs: 12500,
          methodId: 'vape',
          potency: 8,
          moodScore: 7,
          physicalScore: 6,
          notes: 'Test session',
          deviceLocalId: 'device123',
          createdAt: now.subtract(const Duration(seconds: 1)),
          updatedAt: now.subtract(const Duration(seconds: 1)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog('unique_log_id'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected success'),
          (undoneLog) {
            // Should return the exact log that was deleted
            expect(undoneLog.id, 'unique_log_id');
            expect(undoneLog.accountId, 'test_account');
            expect(undoneLog.durationMs, 12500);
            expect(undoneLog.methodId, 'vape');
            expect(undoneLog.potency, 8);
            expect(undoneLog.moodScore, 7);
            expect(undoneLog.physicalScore, 6);
            expect(undoneLog.notes, 'Test session');
            expect(undoneLog.deviceLocalId, 'device123');
          },
        );

        verify(() => mockRepository.getLastSmokeLog('test_account')).called(1);
        verify(() => mockRepository.deleteSmokeLog('unique_log_id')).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle logs created exactly at window boundary', () async {
        // Arrange
        final now = DateTime.now();
        final boundaryLog = SmokeLog(
          id: 'boundary_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 5)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt:
              now.subtract(const Duration(seconds: 6)), // Exactly 6 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 6)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(boundaryLog));
        when(() => mockRepository.deleteSmokeLog('boundary_log'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert - Should still allow undo at exactly 6 seconds
        expect(result.isRight(), true);
        verify(() => mockRepository.deleteSmokeLog('boundary_log')).called(1);
      });

      test('should reject logs created just over window boundary', () async {
        // Arrange
        final now = DateTime.now();
        final expiredLog = SmokeLog(
          id: 'expired_log',
          accountId: 'test_account',
          ts: now.subtract(const Duration(seconds: 5)),
          durationMs: 5000,
          moodScore: 5,
          physicalScore: 5,
          deviceLocalId: null,
          createdAt: now.subtract(
              const Duration(seconds: 10)), // Clearly expired - 10 seconds ago
          updatedAt: now.subtract(const Duration(seconds: 10)),
        );

        when(() => mockRepository.getLastSmokeLog('test_account'))
            .thenAnswer((_) async => Right(expiredLog));

        // Act
        final result = await useCase(accountId: 'test_account');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.message, contains('Undo window has expired'));
          },
          (_) => fail('Expected validation error'),
        );

        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });
    });
  });
}
