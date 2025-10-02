import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/create_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/undo_last_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/get_last_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/delete_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/presentation/providers/smoke_log_providers.dart';

// Mock classes
class MockSmokeLogRepository extends Mock implements SmokeLogRepository {}

class MockCreateSmokeLogUseCase extends Mock implements CreateSmokeLogUseCase {}

class MockUndoLastSmokeLogUseCase extends Mock
    implements UndoLastSmokeLogUseCase {}

class MockGetLastSmokeLogUseCase extends Mock
    implements GetLastSmokeLogUseCase {}

class MockDeleteSmokeLogUseCase extends Mock implements DeleteSmokeLogUseCase {}

void main() {
  late MockSmokeLogRepository mockRepository;
  late MockCreateSmokeLogUseCase mockCreateUseCase;
  late MockUndoLastSmokeLogUseCase mockUndoUseCase;
  late MockGetLastSmokeLogUseCase mockGetLastUseCase;
  late MockDeleteSmokeLogUseCase mockDeleteUseCase;
  late ProviderContainer container;

  // Test data
  final testDateTime = DateTime.now();
  final testSmokeLog = SmokeLog(
    id: 'test-id',
    accountId: 'test-account',
    ts: testDateTime,
    durationMs: 30000,
    methodId: 'test-method',
    potency: 7,
    moodScore: 8,
    physicalScore: 6,
    notes: 'Test notes',
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  const testAccountId = 'test-account-id';
  const testFailure = AppFailure.unexpected(message: 'Test error');

  setUp(() {
    mockRepository = MockSmokeLogRepository();
    mockCreateUseCase = MockCreateSmokeLogUseCase();
    mockUndoUseCase = MockUndoLastSmokeLogUseCase();
    mockGetLastUseCase = MockGetLastSmokeLogUseCase();
    mockDeleteUseCase = MockDeleteSmokeLogUseCase();

    container = ProviderContainer(
      overrides: [
        smokeLogRepositoryProvider
            .overrideWith((ref) => Future.value(mockRepository)),
        createSmokeLogUseCaseProvider
            .overrideWith((ref) => Future.value(mockCreateUseCase)),
        undoLastSmokeLogUseCaseProvider
            .overrideWith((ref) => Future.value(mockUndoUseCase)),
        getLastSmokeLogUseCaseProvider
            .overrideWith((ref) => Future.value(mockGetLastUseCase)),
        deleteSmokeLogUseCaseProvider
            .overrideWith((ref) => Future.value(mockDeleteUseCase)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('smokeLogRepositoryProvider', () {
    test('creates repository with correct data sources', () async {
      final repository =
          await container.read(smokeLogRepositoryProvider.future);
      expect(repository, equals(mockRepository));
    });
  });

  group('Use case providers', () {
    test('createSmokeLogUseCaseProvider returns correct use case', () async {
      final useCase =
          await container.read(createSmokeLogUseCaseProvider.future);
      expect(useCase, equals(mockCreateUseCase));
    });

    test('undoLastSmokeLogUseCaseProvider returns correct use case', () async {
      final useCase =
          await container.read(undoLastSmokeLogUseCaseProvider.future);
      expect(useCase, equals(mockUndoUseCase));
    });

    test('getLastSmokeLogUseCaseProvider returns correct use case', () async {
      final useCase =
          await container.read(getLastSmokeLogUseCaseProvider.future);
      expect(useCase, equals(mockGetLastUseCase));
    });

    test('deleteSmokeLogUseCaseProvider returns correct use case', () async {
      final useCase =
          await container.read(deleteSmokeLogUseCaseProvider.future);
      expect(useCase, equals(mockDeleteUseCase));
    });
  });

  group('lastSmokeLogProvider', () {
    test('returns smoke log when use case succeeds', () async {
      // Arrange
      when(() => mockGetLastUseCase.call(accountId: testAccountId))
          .thenAnswer((_) async => Right(testSmokeLog));

      // Act
      final result =
          await container.read(lastSmokeLogProvider(testAccountId).future);

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockGetLastUseCase.call(accountId: testAccountId)).called(1);
    });

    test('throws failure when use case fails', () async {
      // Arrange
      when(() => mockGetLastUseCase.call(accountId: testAccountId))
          .thenAnswer((_) async => const Left(testFailure));

      // Act & Assert
      expect(
        () => container.read(lastSmokeLogProvider(testAccountId).future),
        throwsA(equals(testFailure)),
      );

      // Try to read the provider to trigger the call, then verify
      try {
        await container.read(lastSmokeLogProvider(testAccountId).future);
      } catch (_) {
        // Expected to throw
      }
      verify(() => mockGetLastUseCase.call(accountId: testAccountId)).called(1);
    });

    test('returns null when no smoke log exists', () async {
      // Arrange
      when(() => mockGetLastUseCase.call(accountId: testAccountId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result =
          await container.read(lastSmokeLogProvider(testAccountId).future);

      // Assert
      expect(result, isNull);
      verify(() => mockGetLastUseCase.call(accountId: testAccountId)).called(1);
    });
  });

  group('CreateSmokeLogNotifier', () {
    test('build method throws UnimplementedError', () async {
      // Arrange
      final notifier = container.read(createSmokeLogProvider({}).notifier);

      // Act & Assert
      expect(
        () => notifier.build({}),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('createSmokeLog succeeds and returns smoke log', () async {
      // Arrange
      when(() => mockCreateUseCase.call(
            accountId: testAccountId,
            durationMs: 30000,
            methodId: 'test-method',
            potency: 7,
            moodScore: 8,
            physicalScore: 6,
            notes: 'Test notes',
          )).thenAnswer((_) async => Right(testSmokeLog));

      final notifier = container.read(createSmokeLogProvider({}).notifier);

      // Act
      final result = await notifier.createSmokeLog(
        accountId: testAccountId,
        durationMs: 30000,
        methodId: 'test-method',
        potency: 7,
        moodScore: 8,
        physicalScore: 6,
        notes: 'Test notes',
      );

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockCreateUseCase.call(
            accountId: testAccountId,
            durationMs: 30000,
            methodId: 'test-method',
            potency: 7,
            moodScore: 8,
            physicalScore: 6,
            notes: 'Test notes',
          )).called(1);
    });

    test('createSmokeLog fails and throws failure', () async {
      // Arrange
      when(() => mockCreateUseCase.call(
            accountId: testAccountId,
            durationMs: 30000,
            moodScore: 8,
            physicalScore: 6,
          )).thenAnswer((_) async => const Left(testFailure));

      final notifier = container.read(createSmokeLogProvider({}).notifier);

      // Act & Assert - Try to call the method and expect it to throw
      try {
        await notifier.createSmokeLog(
          accountId: testAccountId,
          durationMs: 30000,
          moodScore: 8,
          physicalScore: 6,
        );
        fail('Expected createSmokeLog to throw');
      } catch (e) {
        expect(e, equals(testFailure));
      }

      verify(() => mockCreateUseCase.call(
            accountId: testAccountId,
            durationMs: 30000,
            moodScore: 8,
            physicalScore: 6,
          )).called(1);
    });
  });

  group('UndoSmokeLogNotifier', () {
    test('build method throws UnimplementedError', () async {
      // Arrange
      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act & Assert
      expect(
        () => notifier.build(testAccountId),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('undoLast succeeds and returns smoke log', () async {
      // Arrange
      when(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).thenAnswer((_) async => Right(testSmokeLog));

      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act
      final result = await notifier.undoLast(accountId: testAccountId);

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).called(1);
    });

    test('undoLast with custom undo window succeeds', () async {
      // Arrange
      const customUndoWindow = 10;
      when(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: customUndoWindow,
          )).thenAnswer((_) async => Right(testSmokeLog));

      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act
      final result = await notifier.undoLast(
        accountId: testAccountId,
        undoWindowSeconds: customUndoWindow,
      );

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: customUndoWindow,
          )).called(1);
    });

    test('undoLast fails and throws failure', () async {
      // Arrange
      when(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).thenAnswer((_) async => const Left(testFailure));

      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act & Assert - Try to call the method and expect it to throw
      try {
        await notifier.undoLast(accountId: testAccountId);
        fail('Expected undoLast to throw');
      } catch (e) {
        expect(e, equals(testFailure));
      }

      verify(() => mockUndoUseCase.call(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).called(1);
    });
  });

  group('Provider integration', () {
    test('all providers can be read without throwing', () async {
      expect(() => container.read(smokeLogRepositoryProvider), returnsNormally);
      expect(
          () => container.read(createSmokeLogUseCaseProvider), returnsNormally);
      expect(() => container.read(undoLastSmokeLogUseCaseProvider),
          returnsNormally);
      expect(() => container.read(getLastSmokeLogUseCaseProvider),
          returnsNormally);
      expect(
          () => container.read(deleteSmokeLogUseCaseProvider), returnsNormally);
    });

    test('family providers work with different parameters', () {
      // Test with different account IDs
      final provider1 = lastSmokeLogProvider('account1');
      final provider2 = lastSmokeLogProvider('account2');

      expect(provider1, isNot(equals(provider2)));
    });
  });
}
