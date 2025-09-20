// Unit tests for GetFilteredSortedLogsUseCase
// Tests business logic and validation for table browse operations

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_filter.dart';
import 'package:ash_trail/features/table_browse_edit/domain/entities/log_sort.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_filtered_sorted_logs_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLogsTableRepository extends Mock implements LogsTableRepository {}

void main() {
  late MockLogsTableRepository repository;
  late GetFilteredSortedLogsUseCase useCase;

  setUp(() {
    repository = MockLogsTableRepository();
    useCase = GetFilteredSortedLogsUseCase(repository: repository);
  });

  group('GetFilteredSortedLogsUseCase', () {
    const accountId = 'acct-1';
    final baseFilter = LogFilter();

    final sampleLog = SmokeLog(
      id: 'log1',
      accountId: accountId,
      ts: DateTime.parse('2024-01-01T10:00:00Z'),
      durationMs: 5 * 60000,
      methodId: 'method1',
      potency: 5,
      moodScore: 8,
      physicalScore: 7,
      notes: 'ok',
      deviceLocalId: 'dev-1',
      createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
    );

    test('returns logs from repository on success (defaults limit/offset)',
        () async {
      when(() => repository.getFilteredSortedLogs(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Right([sampleLog]));

      final result = await useCase(
        accountId: accountId,
        filter: baseFilter,
        // sort omitted to exercise default
      );

      expect(result.isRight(), true);
      result.map((logs) => expect(logs, [sampleLog]));
      verify(() => repository.getFilteredSortedLogs(
            accountId: accountId,
            filter: baseFilter,
            sort: LogSort.defaultSort,
            limit: 50,
            offset: 0,
          )).called(1);
    });

    test('validates empty accountId', () async {
      final result = await useCase(accountId: '');
      expect(result.isLeft(), true);
      result.mapLeft((f) => expect(f.displayMessage, 'Account ID is required'));
    });

    test('validates excessive limit (>500)', () async {
      final result = await useCase(accountId: accountId, limit: 501);
      expect(result.isLeft(), true);
      result.mapLeft(
          (f) => expect(f.displayMessage, 'Limit must be between 1 and 500'));
    });

    test('validates negative offset', () async {
      final result = await useCase(accountId: accountId, offset: -1);
      expect(result.isLeft(), true);
      result.mapLeft(
          (f) => expect(f.displayMessage, 'Offset must be non-negative'));
    });

    test('validates filter date range (start after end)', () async {
      final filter = LogFilter(
        startDate: DateTime(2025, 1, 2),
        endDate: DateTime(2025, 1, 1),
      );
      final result = await useCase(accountId: accountId, filter: filter);
      expect(result.isLeft(), true);
      result.mapLeft((f) =>
          expect(f.displayMessage, 'Start date must be before end date'));
    });

    test('passes through repository failure', () async {
      final failure = AppFailure.cache(message: 'db down');
      when(() => repository.getFilteredSortedLogs(
            accountId: any(named: 'accountId'),
            filter: any(named: 'filter'),
            sort: any(named: 'sort'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => Left(failure));

      final result = await useCase(accountId: accountId);
      expect(result.isLeft(), true);
      result.mapLeft((f) => expect(f.displayMessage, 'db down'));
    });
  });
}
