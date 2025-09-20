import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_local_datasource.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_remote_datasource.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/create_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/undo_last_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/get_last_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/delete_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/presentation/providers/smoke_log_providers.dart';

// Mock classes
class MockSmokeLogLocalDataSource extends Mock
    implements SmokeLogLocalDataSource {}

class MockSmokeLogRemoteDataSource extends Mock
    implements SmokeLogRemoteDataSource {}

class MockSmokeLogRepository extends Mock implements SmokeLogRepository {}

class MockCreateSmokeLogUseCase extends Mock implements CreateSmokeLogUseCase {}

class MockUndoLastSmokeLogUseCase extends Mock
    implements UndoLastSmokeLogUseCase {}

class MockGetLastSmokeLogUseCase extends Mock
    implements GetLastSmokeLogUseCase {}

class MockDeleteSmokeLogUseCase extends Mock implements DeleteSmokeLogUseCase {}

void main() {
  late MockSmokeLogLocalDataSource mockLocalDataSource;
  late MockSmokeLogRemoteDataSource mockRemoteDataSource;
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
  final testFailure = AppFailure.unexpected(message: 'Test error');

  setUp(() {
    mockLocalDataSource = MockSmokeLogLocalDataSource();
    mockRemoteDataSource = MockSmokeLogRemoteDataSource();
    mockRepository = MockSmokeLogRepository();
    mockCreateUseCase = MockCreateSmokeLogUseCase();
    mockUndoUseCase = MockUndoLastSmokeLogUseCase();
    mockGetLastUseCase = MockGetLastSmokeLogUseCase();
    mockDeleteUseCase = MockDeleteSmokeLogUseCase();

    container = ProviderContainer(
      overrides: [
        smokeLogLocalDataSourceProvider.overrideWithValue(mockLocalDataSource),
        smokeLogRemoteDataSourceProvider
            .overrideWithValue(mockRemoteDataSource),
        smokeLogRepositoryProvider.overrideWithValue(mockRepository),
        createSmokeLogUseCaseProvider.overrideWithValue(mockCreateUseCase),
        undoLastSmokeLogUseCaseProvider.overrideWithValue(mockUndoUseCase),
        getLastSmokeLogUseCaseProvider.overrideWithValue(mockGetLastUseCase),
        deleteSmokeLogUseCaseProvider.overrideWithValue(mockDeleteUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('smokeLogLocalDataSourceProvider', () {
    test('throws UnimplementedError when not overridden', () {
      final container = ProviderContainer();
      expect(
        () => container.read(smokeLogLocalDataSourceProvider),
        throwsA(isA<UnimplementedError>()),
      );
      container.dispose();
    });

    test('returns correct implementation when overridden', () {
      final dataSource = container.read(smokeLogLocalDataSourceProvider);
      expect(dataSource, equals(mockLocalDataSource));
    });
  });

  group('smokeLogRemoteDataSourceProvider', () {
    test('throws UnimplementedError when not overridden', () {
      final container = ProviderContainer();
      expect(
        () => container.read(smokeLogRemoteDataSourceProvider),
        throwsA(isA<UnimplementedError>()),
      );
      container.dispose();
    });

    test('returns correct implementation when overridden', () {
      final dataSource = container.read(smokeLogRemoteDataSourceProvider);
      expect(dataSource, equals(mockRemoteDataSource));
    });
  });

  group('smokeLogRepositoryProvider', () {
    test('creates repository with correct data sources', () {
      final repository = container.read(smokeLogRepositoryProvider);
      expect(repository, equals(mockRepository));
    });
  });

  group('Use case providers', () {
    test('createSmokeLogUseCaseProvider returns correct use case', () {
      final useCase = container.read(createSmokeLogUseCaseProvider);
      expect(useCase, equals(mockCreateUseCase));
    });

    test('undoLastSmokeLogUseCaseProvider returns correct use case', () {
      final useCase = container.read(undoLastSmokeLogUseCaseProvider);
      expect(useCase, equals(mockUndoUseCase));
    });

    test('getLastSmokeLogUseCaseProvider returns correct use case', () {
      final useCase = container.read(getLastSmokeLogUseCaseProvider);
      expect(useCase, equals(mockGetLastUseCase));
    });

    test('deleteSmokeLogUseCaseProvider returns correct use case', () {
      final useCase = container.read(deleteSmokeLogUseCaseProvider);
      expect(useCase, equals(mockDeleteUseCase));
    });
  });

  group('lastSmokeLogProvider', () {
    test('returns smoke log when use case succeeds', () async {
      // Arrange
      when(() => mockGetLastUseCase(accountId: testAccountId))
          .thenAnswer((_) async => Right(testSmokeLog));

      // Act
      final result =
          await container.read(lastSmokeLogProvider(testAccountId).future);

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockGetLastUseCase(accountId: testAccountId)).called(1);
    });

    test('throws failure when use case fails', () async {
      // Arrange
      when(() => mockGetLastUseCase(accountId: testAccountId))
          .thenAnswer((_) async => Left(testFailure));

      // Act & Assert
      expect(
        () => container.read(lastSmokeLogProvider(testAccountId).future),
        throwsA(equals(testFailure)),
      );
      verify(() => mockGetLastUseCase(accountId: testAccountId)).called(1);
    });

    test('returns null when no smoke log exists', () async {
      // Arrange
      when(() => mockGetLastUseCase(accountId: testAccountId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result =
          await container.read(lastSmokeLogProvider(testAccountId).future);

      // Assert
      expect(result, isNull);
      verify(() => mockGetLastUseCase(accountId: testAccountId)).called(1);
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
      when(() => mockCreateUseCase(
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
      verify(() => mockCreateUseCase(
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
      when(() => mockCreateUseCase(
            accountId: testAccountId,
            durationMs: 30000,
            moodScore: 8,
            physicalScore: 6,
          )).thenAnswer((_) async => Left(testFailure));

      final notifier = container.read(createSmokeLogProvider({}).notifier);

      // Act & Assert
      expect(
        () => notifier.createSmokeLog(
          accountId: testAccountId,
          durationMs: 30000,
          moodScore: 8,
          physicalScore: 6,
        ),
        throwsA(equals(testFailure)),
      );

      verify(() => mockCreateUseCase(
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
      when(() => mockUndoUseCase(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).thenAnswer((_) async => Right(testSmokeLog));

      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act
      final result = await notifier.undoLast(accountId: testAccountId);

      // Assert
      expect(result, equals(testSmokeLog));
      verify(() => mockUndoUseCase(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).called(1);
    });

    test('undoLast with custom undo window succeeds', () async {
      // Arrange
      const customUndoWindow = 10;
      when(() => mockUndoUseCase(
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
      verify(() => mockUndoUseCase(
            accountId: testAccountId,
            undoWindowSeconds: customUndoWindow,
          )).called(1);
    });

    test('undoLast fails and throws failure', () async {
      // Arrange
      when(() => mockUndoUseCase(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).thenAnswer((_) async => Left(testFailure));

      final notifier =
          container.read(undoSmokeLogProvider(testAccountId).notifier);

      // Act & Assert
      expect(
        () => notifier.undoLast(accountId: testAccountId),
        throwsA(equals(testFailure)),
      );

      verify(() => mockUndoUseCase(
            accountId: testAccountId,
            undoWindowSeconds: 6,
          )).called(1);
    });
  });

  group('Provider integration', () {
    test('all providers can be read without throwing', () {
      expect(() => container.read(smokeLogLocalDataSourceProvider),
          returnsNormally);
      expect(() => container.read(smokeLogRemoteDataSourceProvider),
          returnsNormally);
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
