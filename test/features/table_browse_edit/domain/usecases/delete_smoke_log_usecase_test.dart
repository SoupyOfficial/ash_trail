import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/delete_smoke_log_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLogsTableRepository extends Mock implements LogsTableRepository {}

void main() {
  late MockLogsTableRepository repository;
  late DeleteSmokeLogUseCase single;
  late DeleteSmokeLogsBatchUseCase batch;

  setUp(() {
    repository = MockLogsTableRepository();
    single = DeleteSmokeLogUseCase(repository: repository);
    batch = DeleteSmokeLogsBatchUseCase(repository: repository);
  });

  group('DeleteSmokeLogUseCase (single)', () {
    test('success', () async {
      when(() => repository.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => const Right(null));
      final res = await single(smokeLogId: 'log1', accountId: 'acct-1');
      expect(res.isRight(), true);
      verify(() => repository.deleteSmokeLog(
          smokeLogId: 'log1', accountId: 'acct-1')).called(1);
    });

    test('validates empty accountId', () async {
      final res = await single(smokeLogId: 'log1', accountId: '');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'Account ID is required'));
    });

    test('validates empty log id', () async {
      final res = await single(smokeLogId: '', accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'Smoke log ID is required'));
    });

    test('propagates repo failure', () async {
      when(() => repository.deleteSmokeLog(
              smokeLogId: any(named: 'smokeLogId'),
              accountId: any(named: 'accountId')))
          .thenAnswer((_) async => const Left(AppFailure.cache(message: 'db')));
      final res = await single(smokeLogId: 'log1', accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'db'));
    });
  });

  group('DeleteSmokeLogsBatchUseCase (batch)', () {
    test('success deduplicates and returns count', () async {
      when(() => repository.deleteSmokeLogsBatch(
          smokeLogIds: any(named: 'smokeLogIds'),
          accountId: any(named: 'accountId'))).thenAnswer((invocation) async {
        final ids = invocation.namedArguments[#smokeLogIds] as List<String>;
        expect(ids.toSet().length, ids.length); // deduplicated
        return const Right(2);
      });
      final res =
          await batch(smokeLogIds: ['a', 'a', 'b'], accountId: 'acct-1');
      expect(res.isRight(), true);
      res.map((count) => expect(count, 2));
    });

    test('validates empty accountId', () async {
      final res = await batch(smokeLogIds: ['a'], accountId: '');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'Account ID is required'));
    });

    test('requires at least one id', () async {
      final res = await batch(smokeLogIds: const [], accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'At least one smoke log ID is required'));
    });

    test('rejects empty ids', () async {
      final res =
          await batch(smokeLogIds: const ['a', ''], accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'All smoke log IDs must be non-empty'));
    });

    test('rejects excessive batch size', () async {
      final ids = List<String>.generate(1001, (i) => 'id$i');
      final res = await batch(smokeLogIds: ids, accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(
          f.displayMessage, 'Cannot delete more than 1000 logs at once'));
    });

    test('propagates repo failure', () async {
      when(() => repository.deleteSmokeLogsBatch(
              smokeLogIds: any(named: 'smokeLogIds'),
              accountId: any(named: 'accountId')))
          .thenAnswer(
              (_) async => const Left(AppFailure.network(message: 'offline')));
      final res =
          await batch(smokeLogIds: const ['a', 'b'], accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'offline'));
    });
  });
}
