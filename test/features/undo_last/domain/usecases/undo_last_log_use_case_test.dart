// Unit tests for UndoLastLogUseCase
// Validates business logic, error handling, and timeout constraints

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/undo_last/domain/usecases/undo_last_log_use_case.dart';

class MockSmokeLogRepository extends Mock implements SmokeLogRepository {}

void main() {
  group('UndoLastLogUseCase', () {
    late UndoLastLogUseCase useCase;
    late MockSmokeLogRepository mockRepository;

    setUp(() {
      mockRepository = MockSmokeLogRepository();
      useCase = UndoLastLogUseCase(smokeLogRepository: mockRepository);
    });

    group('call', () {
      const testAccountId = 'test-account-123';
      final testDateTime = DateTime(2023, 9, 18, 10, 0, 0);
      final testSmokeLog = SmokeLog(
        id: 'test-log-id',
        accountId: testAccountId,
        ts: testDateTime,
        durationMs: 5000,
        moodScore: 5,
        physicalScore: 5,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      test('should successfully undo log when within timeout', () async {
        // Arrange
        final recentLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 2)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog(recentLog.id))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, void>>());
        verify(() => mockRepository.getLastSmokeLog(testAccountId)).called(1);
        verify(() => mockRepository.deleteSmokeLog(recentLog.id)).called(1);
      });

      test('should fail when no logs exist', () async {
        // Arrange
        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Left<AppFailure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage, contains('No smoke logs found'));
          },
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockRepository.getLastSmokeLog(testAccountId)).called(1);
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });

      test('should fail when log is beyond timeout', () async {
        // Arrange
        final oldLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(oldLog));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Left<AppFailure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage, contains('timeout'));
          },
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockRepository.getLastSmokeLog(testAccountId)).called(1);
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });

      test('should fail when repository getLastSmokeLog fails', () async {
        // Arrange
        const testFailure = AppFailure.cache(message: 'Database error');
        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Left<AppFailure, void>>());
        result.fold(
          (failure) => expect(failure, equals(testFailure)),
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockRepository.getLastSmokeLog(testAccountId)).called(1);
        verifyNever(() => mockRepository.deleteSmokeLog(any()));
      });

      test('should fail when repository deleteSmokeLog fails', () async {
        // Arrange
        final recentLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 2)),
        );
        const deleteFailure = AppFailure.cache(message: 'Delete failed');

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(recentLog));
        when(() => mockRepository.deleteSmokeLog(recentLog.id))
            .thenAnswer((_) async => const Left(deleteFailure));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Left<AppFailure, void>>());
        result.fold(
          (failure) => expect(failure, equals(deleteFailure)),
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockRepository.getLastSmokeLog(testAccountId)).called(1);
        verify(() => mockRepository.deleteSmokeLog(recentLog.id)).called(1);
      });

      test('should handle unexpected exceptions', () async {
        // Arrange
        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await useCase.call(testAccountId);

        // Assert
        expect(result, isA<Left<AppFailure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage, contains('Unexpected'));
          },
          (_) => fail('Expected Left but got Right'),
        );
      });
    });

    group('canUndo', () {
      const testAccountId = 'test-account-123';
      final testDateTime = DateTime(2023, 9, 18, 10, 0, 0);
      final testSmokeLog = SmokeLog(
        id: 'test-log-id',
        accountId: testAccountId,
        ts: testDateTime,
        durationMs: 5000,
        moodScore: 5,
        physicalScore: 5,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      test('should return true when recent log exists', () async {
        // Arrange
        final recentLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 2)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(recentLog));

        // Act
        final result = await useCase.canUndo(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, bool>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (canUndo) => expect(canUndo, isTrue),
        );
      });

      test('should return false when no logs exist', () async {
        // Arrange
        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.canUndo(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, bool>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (canUndo) => expect(canUndo, isFalse),
        );
      });

      test('should return false when log is beyond timeout', () async {
        // Arrange
        final oldLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(oldLog));

        // Act
        final result = await useCase.canUndo(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, bool>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (canUndo) => expect(canUndo, isFalse),
        );
      });
    });

    group('getUndoTimeRemaining', () {
      const testAccountId = 'test-account-123';
      final testDateTime = DateTime(2023, 9, 18, 10, 0, 0);
      final testSmokeLog = SmokeLog(
        id: 'test-log-id',
        accountId: testAccountId,
        ts: testDateTime,
        durationMs: 5000,
        moodScore: 5,
        physicalScore: 5,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      test('should return correct remaining time', () async {
        // Arrange
        final recentLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 2)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(recentLog));

        // Act
        final result = await useCase.getUndoTimeRemaining(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, int>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (timeRemaining) {
            expect(timeRemaining, greaterThan(0));
            expect(timeRemaining, lessThanOrEqualTo(6));
          },
        );
      });

      test('should return 0 when no logs exist', () async {
        // Arrange
        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.getUndoTimeRemaining(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, int>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (timeRemaining) => expect(timeRemaining, equals(0)),
        );
      });

      test('should return 0 when timeout expired', () async {
        // Arrange
        final expiredLog = testSmokeLog.copyWith(
          createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
        );

        when(() => mockRepository.getLastSmokeLog(testAccountId))
            .thenAnswer((_) async => Right(expiredLog));

        // Act
        final result = await useCase.getUndoTimeRemaining(testAccountId);

        // Assert
        expect(result, isA<Right<AppFailure, int>>());
        result.fold(
          (_) => fail('Expected Right but got Left'),
          (timeRemaining) => expect(timeRemaining, equals(0)),
        );
      });
    });
  });
}
