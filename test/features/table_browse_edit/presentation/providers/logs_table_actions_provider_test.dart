// Unit tests for logs table actions provider
// Tests CRUD operations, batch operations, refresh functionality with Riverpod patterns

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_actions_provider.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_providers.dart';
import 'package:ash_trail/features/table_browse_edit/presentation/providers/logs_table_state_provider.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/update_smoke_log_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/delete_smoke_log_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_filtered_sorted_logs_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_logs_count_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_filter_options_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/add_tags_to_logs_batch_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/remove_tags_from_logs_batch_usecase.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Mock use cases
class MockUpdateSmokeLogUseCase extends Mock implements UpdateSmokeLogUseCase {}

class MockDeleteSmokeLogUseCase extends Mock implements DeleteSmokeLogUseCase {}

class MockDeleteSmokeLogsBatchUseCase extends Mock
    implements DeleteSmokeLogsBatchUseCase {}

class MockGetFilteredSortedLogsUseCase extends Mock
    implements GetFilteredSortedLogsUseCase {}

class MockGetLogsCountUseCase extends Mock implements GetLogsCountUseCase {}

class MockGetUsedMethodIdsUseCase extends Mock
    implements GetUsedMethodIdsUseCase {}

class MockGetUsedTagIdsUseCase extends Mock implements GetUsedTagIdsUseCase {}

class MockAddTagsToLogsBatchUseCase extends Mock
    implements AddTagsToLogsBatchUseCase {}

class MockRemoveTagsFromLogsBatchUseCase extends Mock
    implements RemoveTagsFromLogsBatchUseCase {}

// Fake classes for fallback values
class SmokeLogFake extends Fake implements SmokeLog {}

void main() {
  late MockUpdateSmokeLogUseCase mockUpdateUseCase;
  late MockDeleteSmokeLogUseCase mockDeleteUseCase;
  late MockDeleteSmokeLogsBatchUseCase mockDeleteBatchUseCase;
  late MockGetFilteredSortedLogsUseCase mockGetLogsUseCase;
  late MockGetLogsCountUseCase mockGetCountUseCase;
  late MockGetUsedMethodIdsUseCase mockGetMethodsUseCase;
  late MockGetUsedTagIdsUseCase mockGetTagsUseCase;
  late MockAddTagsToLogsBatchUseCase mockAddTagsUseCase;
  late MockRemoveTagsFromLogsBatchUseCase mockRemoveTagsUseCase;

  setUpAll(() {
    registerFallbackValue(SmokeLogFake());
  });

  setUp(() {
    mockUpdateUseCase = MockUpdateSmokeLogUseCase();
    mockDeleteUseCase = MockDeleteSmokeLogUseCase();
    mockDeleteBatchUseCase = MockDeleteSmokeLogsBatchUseCase();
    mockGetLogsUseCase = MockGetFilteredSortedLogsUseCase();
    mockGetCountUseCase = MockGetLogsCountUseCase();
    mockGetMethodsUseCase = MockGetUsedMethodIdsUseCase();
    mockGetTagsUseCase = MockGetUsedTagIdsUseCase();
    mockAddTagsUseCase = MockAddTagsToLogsBatchUseCase();
    mockRemoveTagsUseCase = MockRemoveTagsFromLogsBatchUseCase();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        updateSmokeLogUseCaseProvider.overrideWithValue(mockUpdateUseCase),
        deleteSmokeLogUseCaseProvider.overrideWithValue(mockDeleteUseCase),
        deleteSmokeLogsBatchUseCaseProvider
            .overrideWithValue(mockDeleteBatchUseCase),
        getFilteredSortedLogsUseCaseProvider
            .overrideWithValue(mockGetLogsUseCase),
        getLogsCountUseCaseProvider.overrideWithValue(mockGetCountUseCase),
        getUsedMethodIdsUseCaseProvider
            .overrideWithValue(mockGetMethodsUseCase),
        getUsedTagIdsUseCaseProvider.overrideWithValue(mockGetTagsUseCase),
        addTagsToLogsBatchUseCaseProvider.overrideWithValue(mockAddTagsUseCase),
        removeTagsFromLogsBatchUseCaseProvider
            .overrideWithValue(mockRemoveTagsUseCase),
      ],
    );
  }

  group('UpdateSmokeLogNotifier', () {
    const accountId = 'test-account-id';
    final testLog = SmokeLog(
      id: 'log1',
      accountId: accountId,
      ts: DateTime.parse('2024-01-01T10:00:00Z'),
      durationMs: 300000,
      moodScore: 8,
      physicalScore: 7,
      createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
    );

    test('should successfully update smoke log', () async {
      // Arrange
      final container = createContainer();
      when(() => mockUpdateUseCase.call(
            smokeLog: any(named: 'smokeLog'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Right(testLog));

      // Act
      final notifier =
          container.read(updateSmokeLogProvider(accountId).notifier);
      final result = await notifier.updateSmokeLog(
        smokeLog: testLog,
        accountId: accountId,
      );

      // Assert
      expect(result, equals(testLog));
      expect(container.read(updateSmokeLogProvider(accountId)).value,
          equals(testLog));

      verify(() => mockUpdateUseCase.call(
            smokeLog: testLog,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should handle update failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.validation(message: 'Update failed');
      when(() => mockUpdateUseCase.call(
            smokeLog: any(named: 'smokeLog'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(updateSmokeLogProvider(accountId).notifier);

      try {
        await notifier.updateSmokeLog(
          smokeLog: testLog,
          accountId: accountId,
        );
        fail('Should have thrown AppFailure');
      } catch (e) {
        expect(e, isA<AppFailure>());
        expect(e, equals(failure));
      }

      // Check that state is in error
      expect(container.read(updateSmokeLogProvider(accountId)).hasError, true);

      container.dispose();
    });

    test('should successfully complete update and have result', () async {
      // Arrange
      final container = createContainer();
      when(() => mockUpdateUseCase.call(
            smokeLog: any(named: 'smokeLog'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Right(testLog));

      // Act
      final notifier =
          container.read(updateSmokeLogProvider(accountId).notifier);
      final result = await notifier.updateSmokeLog(
        smokeLog: testLog,
        accountId: accountId,
      );

      // Assert - should return the updated log
      expect(result, equals(testLog));
      verify(() => mockUpdateUseCase.call(
            smokeLog: testLog,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });
  });

  group('DeleteSmokeLogNotifier', () {
    const accountId = 'test-account-id';
    const smokeLogId = 'log1';

    test('should successfully delete smoke log', () async {
      // Arrange
      final container = createContainer();
      when(() => mockDeleteUseCase.call(
            smokeLogId: any(named: 'smokeLogId'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final notifier =
          container.read(deleteSmokeLogProvider(accountId).notifier);
      await notifier.deleteSmokeLog(
        smokeLogId: smokeLogId,
        accountId: accountId,
      );

      // Assert
      expect(container.read(deleteSmokeLogProvider(accountId)).hasValue, true);

      verify(() => mockDeleteUseCase.call(
            smokeLogId: smokeLogId,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should handle delete failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.notFound(message: 'Log not found');
      when(() => mockDeleteUseCase.call(
            smokeLogId: any(named: 'smokeLogId'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(deleteSmokeLogProvider(accountId).notifier);

      try {
        await notifier.deleteSmokeLog(
          smokeLogId: smokeLogId,
          accountId: accountId,
        );
        fail('Expected AppFailure to be thrown');
      } catch (e) {
        expect(e, isA<AppFailure>());
        expect((e as AppFailure).displayMessage, 'Log not found');
      }

      expect(container.read(deleteSmokeLogProvider(accountId)).hasError, true);

      container.dispose();
    });

    test('should invalidate providers after successful delete', () async {
      // Arrange
      final container = createContainer();
      when(() => mockDeleteUseCase.call(
            smokeLogId: any(named: 'smokeLogId'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(null));

      // Mock provider invalidation
      when(() => mockGetLogsUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockGetCountUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => const Right(0));

      // Act
      final notifier =
          container.read(deleteSmokeLogProvider(accountId).notifier);
      await notifier.deleteSmokeLog(
        smokeLogId: smokeLogId,
        accountId: accountId,
      );

      // Assert
      expect(container.read(deleteSmokeLogProvider(accountId)).hasValue, true);

      container.dispose();
    });
  });

  group('DeleteSmokeLogsBatchNotifier', () {
    const accountId = 'test-account-id';
    const smokeLogIds = ['log1', 'log2', 'log3'];

    test('should successfully delete logs batch', () async {
      // Arrange
      final container = createContainer();
      const deletedCount = 3;
      when(() => mockDeleteBatchUseCase.call(
            smokeLogIds: any(named: 'smokeLogIds'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(deletedCount));

      // Act
      final notifier =
          container.read(deleteSmokeLogsBatchProvider(accountId).notifier);
      final result = await notifier.deleteSmokeLogsBatch(
        smokeLogIds: smokeLogIds,
        accountId: accountId,
      );

      // Assert
      expect(result, equals(deletedCount));
      expect(container.read(deleteSmokeLogsBatchProvider(accountId)).value,
          equals(deletedCount));

      verify(() => mockDeleteBatchUseCase.call(
            smokeLogIds: smokeLogIds,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should handle batch delete failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.validation(message: 'Batch delete failed');
      when(() => mockDeleteBatchUseCase.call(
            smokeLogIds: any(named: 'smokeLogIds'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(deleteSmokeLogsBatchProvider(accountId).notifier);

      try {
        await notifier.deleteSmokeLogsBatch(
          smokeLogIds: smokeLogIds,
          accountId: accountId,
        );
        fail('Expected AppFailure to be thrown');
      } catch (e) {
        expect(e, isA<AppFailure>());
        expect((e as AppFailure).displayMessage, 'Batch delete failed');
      }

      expect(container.read(deleteSmokeLogsBatchProvider(accountId)).hasError,
          true);

      container.dispose();
    });

    test('should delete selected logs from table state', () async {
      // Arrange
      final container = createContainer();
      const deletedCount = 2;

      // Setup table state with selections
      final tableStateNotifier =
          container.read(logsTableStateProvider(accountId).notifier);
      tableStateNotifier.toggleLogSelection('log1');
      tableStateNotifier.toggleLogSelection('log2');

      when(() => mockDeleteBatchUseCase.call(
            smokeLogIds: any(named: 'smokeLogIds'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(deletedCount));

      // Act
      final notifier =
          container.read(deleteSmokeLogsBatchProvider(accountId).notifier);
      final result = await notifier.deleteSelectedLogs(accountId: accountId);

      // Assert
      expect(result, equals(deletedCount));

      verify(() => mockDeleteBatchUseCase.call(
            smokeLogIds: ['log1', 'log2'],
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should throw exception when no logs are selected for deletion',
        () async {
      // Arrange
      final container = createContainer();

      // Act & Assert
      final notifier =
          container.read(deleteSmokeLogsBatchProvider(accountId).notifier);

      expect(() => notifier.deleteSelectedLogs(accountId: accountId),
          throwsA(isA<Exception>()));

      container.dispose();
    });
  });

  group('RefreshLogsTableNotifier', () {
    const accountId = 'test-account-id';

    test('should successfully refresh table data', () async {
      // Arrange
      final container = createContainer();

      // Mock the data providers
      when(() => mockGetLogsUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockGetCountUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => const Right(0));

      when(() => mockGetMethodsUseCase.call(
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockGetTagsUseCase.call(
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right([]));

      // Act
      final notifier =
          container.read(refreshLogsTableProvider(accountId).notifier);
      await notifier.refresh(accountId: accountId);

      // Assert
      expect(
          container.read(refreshLogsTableProvider(accountId)).hasValue, true);

      // Verify refreshing state was managed
      final tableState = container.read(logsTableStateProvider(accountId));
      expect(tableState.isRefreshing, false);

      container.dispose();
    });

    test('should handle refresh failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.network(message: 'Network error');

      when(() => mockGetLogsUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(refreshLogsTableProvider(accountId).notifier);

      try {
        await notifier.refresh(accountId: accountId);
        fail('Expected AppFailure to be thrown');
      } catch (e) {
        expect(e, isA<AppFailure>());
        expect((e as AppFailure).displayMessage, 'Network error');
      }

      expect(
          container.read(refreshLogsTableProvider(accountId)).hasError, true);

      container.dispose();
    });

    test('should set and clear refreshing state', () async {
      // Arrange
      final container = createContainer();

      when(() => mockGetLogsUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return const Right([]);
      });

      when(() => mockGetCountUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => const Right(0));

      // Act
      final notifier =
          container.read(refreshLogsTableProvider(accountId).notifier);
      final future = notifier.refresh(accountId: accountId);

      // Assert - check refreshing state during operation
      await Future.delayed(const Duration(milliseconds: 10));
      expect(
          container.read(logsTableStateProvider(accountId)).isRefreshing, true);

      await future;
      expect(container.read(logsTableStateProvider(accountId)).isRefreshing,
          false);

      container.dispose();
    });
  });

  group('TableActions helper class', () {
    const accountId = 'test-account-id';
    final testLog = SmokeLog(
      id: 'log1',
      accountId: accountId,
      ts: DateTime.parse('2024-01-01T10:00:00Z'),
      durationMs: 300000,
      moodScore: 8,
      physicalScore: 7,
      createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
    );

    test('should provide convenient update method', () async {
      // Arrange
      final container = createContainer();
      when(() => mockUpdateUseCase.call(
            smokeLog: any(named: 'smokeLog'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => Right(testLog));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      final result = await tableActions.updateLog(testLog);

      // Assert
      expect(result, equals(testLog));

      verify(() => mockUpdateUseCase.call(
            smokeLog: testLog,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should provide convenient delete method', () async {
      // Arrange
      final container = createContainer();
      const smokeLogId = 'log1';
      when(() => mockDeleteUseCase.call(
            smokeLogId: any(named: 'smokeLogId'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(null));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      await tableActions.deleteLog(smokeLogId);

      // Assert
      verify(() => mockDeleteUseCase.call(
            smokeLogId: smokeLogId,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should provide convenient batch delete method', () async {
      // Arrange
      final container = createContainer();
      const smokeLogIds = ['log1', 'log2'];
      const deletedCount = 2;
      when(() => mockDeleteBatchUseCase.call(
            smokeLogIds: any(named: 'smokeLogIds'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(deletedCount));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      final result = await tableActions.deleteLogs(smokeLogIds);

      // Assert
      expect(result, equals(deletedCount));

      verify(() => mockDeleteBatchUseCase.call(
            smokeLogIds: smokeLogIds,
            accountId: accountId,
          )).called(1);

      container.dispose();
    });

    test('should provide convenient delete selected method', () async {
      // Arrange
      final container = createContainer();
      const deletedCount = 2;

      // Setup table state with selections
      final tableStateNotifier =
          container.read(logsTableStateProvider(accountId).notifier);
      tableStateNotifier.toggleLogSelection('log1');
      tableStateNotifier.toggleLogSelection('log2');

      when(() => mockDeleteBatchUseCase.call(
            smokeLogIds: any(named: 'smokeLogIds'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((_) async => const Right(deletedCount));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      final result = await tableActions.deleteSelectedLogs();

      // Assert
      expect(result, equals(deletedCount));

      container.dispose();
    });

    test('should provide convenient refresh method', () async {
      // Arrange
      final container = createContainer();

      when(() => mockGetLogsUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockGetCountUseCase.call(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => const Right(0));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      await tableActions.refresh();

      // Assert - no exceptions thrown, state properly updated
      expect(container.read(logsTableStateProvider(accountId)).isRefreshing,
          false);

      container.dispose();
    });

    test('should provide convenient add tags method', () async {
      // Arrange
      final container = createContainer();
      const accountId = 'test-account-id';
      const smokeLogIds = ['log1', 'log2'];
      const tagIds = ['tag1', 'tag2'];
      const updatedCount = 2;

      when(() => mockAddTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Right(updatedCount));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      final result = await tableActions.addTagsToLogs(
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      // Assert
      expect(result, equals(updatedCount));
      verify(() => mockAddTagsUseCase.call(
            accountId: accountId,
            smokeLogIds: smokeLogIds,
            tagIds: tagIds,
          )).called(1);

      container.dispose();
    });

    test('should provide convenient remove tags method', () async {
      // Arrange
      final container = createContainer();
      const accountId = 'test-account-id';
      const smokeLogIds = ['log1', 'log2'];
      const tagIds = ['tag1'];
      const updatedCount = 2;

      when(() => mockRemoveTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Right(updatedCount));

      // Act
      final tableActions = container.read(tableActionsProvider(accountId));
      final result = await tableActions.removeTagsFromLogs(
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      // Assert
      expect(result, equals(updatedCount));
      verify(() => mockRemoveTagsUseCase.call(
            accountId: accountId,
            smokeLogIds: smokeLogIds,
            tagIds: tagIds,
          )).called(1);

      container.dispose();
    });
  });

  group('AddTagsToLogsBatchNotifier', () {
    const accountId = 'test-account-id';
    const smokeLogIds = ['log1', 'log2'];
    const tagIds = ['tag1', 'tag2'];

    test('should successfully add tags to logs', () async {
      // Arrange
      final container = createContainer();
      const updatedCount = 2;

      when(() => mockAddTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Right(updatedCount));

      // Act
      final notifier =
          container.read(addTagsToLogsBatchProvider(accountId).notifier);
      final result = await notifier.addTagsToLogs(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      // Assert
      expect(result, equals(updatedCount));
      expect(container.read(addTagsToLogsBatchProvider(accountId)).value,
          equals(updatedCount));

      container.dispose();
    });

    test('should handle add tags failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.validation(message: 'Invalid tags');
      when(() => mockAddTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(addTagsToLogsBatchProvider(accountId).notifier);
      await expectLater(
        notifier.addTagsToLogs(
          accountId: accountId,
          smokeLogIds: smokeLogIds,
          tagIds: tagIds,
        ),
        throwsA(isA<AppFailure>()),
      );

      expect(
          container.read(addTagsToLogsBatchProvider(accountId)).hasError, true);

      container.dispose();
    });
  });

  group('RemoveTagsFromLogsBatchNotifier', () {
    const accountId = 'test-account-id';
    const smokeLogIds = ['log1'];
    const tagIds = ['tag1'];

    test('should successfully remove tags from logs', () async {
      // Arrange
      final container = createContainer();
      const updatedCount = 1;

      when(() => mockRemoveTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Right(updatedCount));

      // Act
      final notifier =
          container.read(removeTagsFromLogsBatchProvider(accountId).notifier);
      final result = await notifier.removeTagsFromLogs(
        accountId: accountId,
        smokeLogIds: smokeLogIds,
        tagIds: tagIds,
      );

      // Assert
      expect(result, equals(updatedCount));
      expect(
        container.read(removeTagsFromLogsBatchProvider(accountId)).value,
        equals(updatedCount),
      );

      container.dispose();
    });

    test('should handle remove tags failure', () async {
      // Arrange
      final container = createContainer();
      const failure = AppFailure.validation(message: 'Cannot remove tags');
      when(() => mockRemoveTagsUseCase.call(
            accountId: any(named: 'accountId'),
            smokeLogIds: any(named: 'smokeLogIds'),
            tagIds: any(named: 'tagIds'),
          )).thenAnswer((_) async => const Left(failure));

      // Act & Assert
      final notifier =
          container.read(removeTagsFromLogsBatchProvider(accountId).notifier);

      await expectLater(
        notifier.removeTagsFromLogs(
          accountId: accountId,
          smokeLogIds: smokeLogIds,
          tagIds: tagIds,
        ),
        throwsA(isA<AppFailure>()),
      );

      expect(
        container.read(removeTagsFromLogsBatchProvider(accountId)).hasError,
        true,
      );

      container.dispose();
    });
  });

  group('Provider integration', () {
    test('should create unique provider instances per account', () {
      // Arrange
      final container = createContainer();

      // Act
      final actions1 = container.read(tableActionsProvider('account1'));
      final actions2 = container.read(tableActionsProvider('account2'));

      // Assert
      expect(actions1, isNot(same(actions2)));

      container.dispose();
    });

    test('should maintain provider state independence per account', () async {
      // Arrange
      final container = createContainer();
      const account1 = 'account1';
      const account2 = 'account2';

      when(() => mockUpdateUseCase.call(
            smokeLog: any(named: 'smokeLog'),
            accountId: any(named: 'accountId'),
          )).thenAnswer((invocation) async {
        final testLog = SmokeLog(
          id: 'log1',
          accountId: invocation.namedArguments[#accountId],
          ts: DateTime.parse('2024-01-01T10:00:00Z'),
          durationMs: 300000,
          moodScore: 8,
          physicalScore: 7,
          createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
          updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
        );
        return Right(testLog);
      });

      // Act
      final notifier1 =
          container.read(updateSmokeLogProvider(account1).notifier);
      container.read(updateSmokeLogProvider(account2)
          .notifier); // Ensure second provider is initialized

      await notifier1.updateSmokeLog(
        smokeLog: SmokeLog(
          id: 'log1',
          accountId: account1,
          ts: DateTime.parse('2024-01-01T10:00:00Z'),
          durationMs: 300000,
          moodScore: 8,
          physicalScore: 7,
          createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
          updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
        ),
        accountId: account1,
      );

      // Assert
      expect(container.read(updateSmokeLogProvider(account1)).hasValue, true);
      expect(container.read(updateSmokeLogProvider(account2)).hasValue, false);

      container.dispose();
    });
  });
}
