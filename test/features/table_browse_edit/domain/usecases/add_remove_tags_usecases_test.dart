import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/add_tags_to_logs_batch_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/remove_tags_from_logs_batch_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class _RepoFake implements LogsTableRepository {
  int addCalls = 0;
  int removeCalls = 0;
  late String lastAccountId;
  late List<String> lastLogIds;
  late List<String> lastTagIds;
  int resultCount = 0;

  @override
  Future<Either<AppFailure, int>> addTagsToLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    addCalls++;
    lastAccountId = accountId;
    lastLogIds = List.of(smokeLogIds);
    lastTagIds = List.of(tagIds);
    return Right(resultCount);
  }

  @override
  Future<Either<AppFailure, int>> removeTagsFromLogsBatch({
    required String accountId,
    required List<String> smokeLogIds,
    required List<String> tagIds,
  }) async {
    removeCalls++;
    lastAccountId = accountId;
    lastLogIds = List.of(smokeLogIds);
    lastTagIds = List.of(tagIds);
    return Right(resultCount);
  }

  // Unused for these tests
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AddTagsToLogsBatchUseCase', () {
    test('validates inputs and deduplicates before delegating', () async {
      final repo = _RepoFake()..resultCount = 3;
      final usecase = AddTagsToLogsBatchUseCase(repository: repo);

      final result = await usecase(
        accountId: 'acct',
        smokeLogIds: ['a', 'b', 'a', ''],
        tagIds: ['t1', 't2', 't1', ''],
      );

      expect(result.isRight(), true);
      expect(repo.addCalls, 1);
      expect(repo.lastAccountId, 'acct');
      expect(repo.lastLogIds, ['a', 'b']);
      expect(repo.lastTagIds, ['t1', 't2']);
    });

    test('fails when inputs invalid (empty account)', () async {
      final repo = _RepoFake();
      final usecase = AddTagsToLogsBatchUseCase(repository: repo);

      final result = await usecase(
        accountId: '',
        smokeLogIds: ['a'],
        tagIds: ['t'],
      );

      expect(result.isLeft(), true);
    });

    test('fails when too many ids', () async {
      final repo = _RepoFake();
      final usecase = AddTagsToLogsBatchUseCase(repository: repo);

      final tooManyLogs = List<String>.generate(1001, (i) => 'l$i');
      final resultLogs = await usecase(
        accountId: 'acct',
        smokeLogIds: tooManyLogs,
        tagIds: ['t'],
      );
      expect(resultLogs.isLeft(), true);

      final tooManyTags = List<String>.generate(101, (i) => 't$i');
      final resultTags = await usecase(
        accountId: 'acct',
        smokeLogIds: ['a'],
        tagIds: tooManyTags,
      );
      expect(resultTags.isLeft(), true);
    });
  });

  group('RemoveTagsFromLogsBatchUseCase', () {
    test('validates inputs and deduplicates before delegating', () async {
      final repo = _RepoFake()..resultCount = 2;
      final usecase = RemoveTagsFromLogsBatchUseCase(repository: repo);

      final result = await usecase(
        accountId: 'acct',
        smokeLogIds: ['x', 'x', 'y', ''],
        tagIds: ['t1', 't1', 't2', ''],
      );

      expect(result.isRight(), true);
      expect(repo.removeCalls, 1);
      expect(repo.lastAccountId, 'acct');
      expect(repo.lastLogIds, ['x', 'y']);
      expect(repo.lastTagIds, ['t1', 't2']);
    });

    test('fails when inputs invalid (empty collections)', () async {
      final repo = _RepoFake();
      final usecase = RemoveTagsFromLogsBatchUseCase(repository: repo);

      final res1 = await usecase(
        accountId: 'acct',
        smokeLogIds: [],
        tagIds: ['t'],
      );
      final res2 = await usecase(
        accountId: 'acct',
        smokeLogIds: ['x'],
        tagIds: [],
      );

      expect(res1.isLeft(), true);
      expect(res2.isLeft(), true);
    });
  });
}
