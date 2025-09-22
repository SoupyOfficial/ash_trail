import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_smoke_log_by_id_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';

class _MockRepo extends Mock implements LogsTableRepository {}

void main() {
  late _MockRepo repo;
  final sample = SmokeLog(
    id: 'id1',
    accountId: 'a1',
    ts: DateTime(2024, 1, 1),
    durationMs: 1000,
    methodId: 'vape',
    moodScore: 5,
    physicalScore: 5,
    potency: 5,
    notes: 'n',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    repo = _MockRepo();
  });

  test('validates params', () async {
    final uc = GetSmokeLogByIdUseCase(repository: repo);
    expect((await uc(smokeLogId: '', accountId: 'a')).isLeft(), isTrue);
    expect((await uc(smokeLogId: 'x', accountId: '')).isLeft(), isTrue);
  });

  test('delegates to repository', () async {
    when(() => repo.getSmokeLogById(
            smokeLogId: any(named: 'smokeLogId'),
            accountId: any(named: 'accountId')))
        .thenAnswer((_) async => right(sample));

    final uc = GetSmokeLogByIdUseCase(repository: repo);
    final res = await uc(smokeLogId: 'id1', accountId: 'a1');
    expect(res.getRight().toNullable(), equals(sample));
  });
}
