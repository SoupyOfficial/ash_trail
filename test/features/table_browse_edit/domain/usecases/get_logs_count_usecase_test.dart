import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_logs_count_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class _MockRepo extends Mock implements LogsTableRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('validates accountId required', () async {
    final uc = GetLogsCountUseCase(repository: repo);
    final res = await uc(accountId: '');
    expect(res.isLeft(), isTrue);
    res.match(
        (l) => expect(l, isA<AppFailure>()), (_) => fail('expected failure'));
  });

  test('delegates to repository', () async {
    when(() => repo.getLogsCount(
        accountId: any(named: 'accountId'),
        filter: any(named: 'filter'))).thenAnswer((_) async => right(42));
    final uc = GetLogsCountUseCase(repository: repo);
    final res = await uc(accountId: 'a1');
    expect(res.getRight().toNullable(), 42);
  });
}
