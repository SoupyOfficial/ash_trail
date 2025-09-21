// Tests for LogDetailProviders
// Validates Riverpod provider state management and error handling

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/detail_view/presentation/providers/log_detail_providers.dart';
import 'package:ash_trail/features/detail_view/domain/repositories/log_detail_repository.dart';
import 'package:ash_trail/features/detail_view/domain/usecases/get_log_detail_usecase.dart';
import 'package:ash_trail/features/detail_view/domain/usecases/refresh_log_detail_usecase.dart';
import 'package:ash_trail/features/detail_view/domain/entities/log_detail_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';

class MockLogDetailRepository extends Mock implements LogDetailRepository {}

class MockGetLogDetailUseCase extends Mock implements GetLogDetailUseCase {}

class MockRefreshLogDetailUseCase extends Mock
    implements RefreshLogDetailUseCase {}

void main() {
  group('LogDetailProviders', () {
    late ProviderContainer container;
    late MockLogDetailRepository mockRepository;
    late MockGetLogDetailUseCase mockGetUseCase;
    late MockRefreshLogDetailUseCase mockRefreshUseCase;
    late LogDetailEntity testEntity;

    setUpAll(() {
      registerFallbackValue(const GetLogDetailParams(logId: 'any'));
      registerFallbackValue(const RefreshLogDetailParams(logId: 'any'));
    });

    setUp(() {
      mockRepository = MockLogDetailRepository();
      mockGetUseCase = MockGetLogDetailUseCase();
      mockRefreshUseCase = MockRefreshLogDetailUseCase();

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

      container = ProviderContainer(
        overrides: [
          logDetailRepositoryProvider.overrideWith((ref) => mockRepository),
          getLogDetailUseCaseProvider.overrideWith((ref) => mockGetUseCase),
          refreshLogDetailUseCaseProvider
              .overrideWith((ref) => mockRefreshUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('logDetailRepositoryProvider', () {
      test('should provide repository instance', () {
        final repository = container.read(logDetailRepositoryProvider);
        expect(repository, isA<LogDetailRepository>());
      });
    });

    group('getLogDetailUseCaseProvider', () {
      test('should provide use case instance', () {
        final useCase = container.read(getLogDetailUseCaseProvider);
        expect(useCase, isA<GetLogDetailUseCase>());
      });
    });

    group('refreshLogDetailUseCaseProvider', () {
      test('should provide use case instance', () {
        final useCase = container.read(refreshLogDetailUseCaseProvider);
        expect(useCase, isA<RefreshLogDetailUseCase>());
      });
    });

    group('LogDetailNotifier', () {
      const logId = 'log-123';

      test('should load log detail on build', () async {
        // Arrange
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Act
        final state =
            await container.read(logDetailNotifierProvider(logId).future);

        // Assert
        expect(state, equals(testEntity));
        verify(() =>
                mockGetUseCase.call(const GetLogDetailParams(logId: logId)))
            .called(1);
      });

      test('should throw AppFailure when use case fails', () async {
        // Arrange
        const failure = AppFailure.notFound(message: 'Log not found');
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act & Assert
        await expectLater(
          () => container.read(logDetailNotifierProvider(logId).future),
          throwsA(isA<AppFailure>()),
        );
      });

      test('should refresh log detail', () async {
        // Arrange - initial state
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));
        when(() => mockRefreshUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Load initial state
        await container.read(logDetailNotifierProvider(logId).future);

        // Act - refresh
        final notifier =
            container.read(logDetailNotifierProvider(logId).notifier);
        await notifier.refresh();

        // Assert
        verify(() => mockRefreshUseCase
            .call(const RefreshLogDetailParams(logId: logId))).called(1);
      });

      test('should handle refresh failure', () async {
        // Arrange - initial state
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Load initial state
        await container.read(logDetailNotifierProvider(logId).future);

        // Setup refresh failure
        const failure = AppFailure.network(message: 'Network error');
        when(() => mockRefreshUseCase.call(any()))
            .thenAnswer((_) async => const Left(failure));

        // Act - refresh
        final notifier =
            container.read(logDetailNotifierProvider(logId).notifier);
        await notifier.refresh();

        // Assert
        final state = container.read(logDetailNotifierProvider(logId));
        expect(state.hasError, isTrue);
        expect(state.error, equals(failure));
      });

      test('should check if log exists', () async {
        // Arrange
        when(() => mockRepository.logExists(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Load initial state
        await container.read(logDetailNotifierProvider(logId).future);

        // Act
        final notifier =
            container.read(logDetailNotifierProvider(logId).notifier);
        final exists = await notifier.logExists(logId);

        // Assert
        expect(exists, isTrue);
        verify(() => mockRepository.logExists(logId)).called(1);
      });

      test('should return false when log exists check fails', () async {
        // Arrange
        when(() => mockRepository.logExists(any()))
            .thenAnswer((_) async => const Left(AppFailure.network()));
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Load initial state
        await container.read(logDetailNotifierProvider(logId).future);

        // Act
        final notifier =
            container.read(logDetailNotifierProvider(logId).notifier);
        final exists = await notifier.logExists(logId);

        // Assert
        expect(exists, isFalse);
      });
    });

    group('logDetailErrorProvider', () {
      const logId = 'log-123';

      test('should return null when no error', () async {
        // Arrange
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => Right(testEntity));

        // Load state
        await container.read(logDetailNotifierProvider(logId).future);

        // Act
        final error = container.read(logDetailErrorProvider(logId));

        // Assert
        expect(error, isNull);
      });

      test('should return AppFailure display message when error exists',
          () async {
        // Arrange
        const failure = AppFailure.notFound(message: 'Log not found');
        when(() => mockGetUseCase.call(any()))
            .thenAnswer((_) async => const Left(failure));

        // Try to load state (will fail)
        try {
          await container.read(logDetailNotifierProvider(logId).future);
        } catch (e) {
          // Expected to fail
        }

        // Act
        final error = container.read(logDetailErrorProvider(logId));

        // Assert
        expect(error, equals('Log not found'));
      });

      test('should return generic error message for unexpected errors',
          () async {
        // Arrange
        when(() => mockGetUseCase.call(any()))
            .thenThrow(Exception('Unexpected error'));

        // Try to load state (will fail)
        try {
          await container.read(logDetailNotifierProvider(logId).future);
        } catch (e) {
          // Expected to fail
        }

        // Act
        final error = container.read(logDetailErrorProvider(logId));

        // Assert
        expect(error, equals('An unexpected error occurred'));
      });
    });
  });
}
