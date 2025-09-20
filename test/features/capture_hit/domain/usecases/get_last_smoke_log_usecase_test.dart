import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/get_last_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';

class _MockRepo extends Mock implements SmokeLogRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('validates accountId required', () async {
    final uc = GetLastSmokeLogUseCase(repository: repo);
    final res = await uc(accountId: '');
    expect(res.isLeft(), isTrue);
    res.match(
        (l) => expect(l, isA<AppFailure>()), (_) => fail('expected failure'));
  });

  test('delegates to repository', () async {
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

    when(() => repo.getLastSmokeLog(any()))
        .thenAnswer((_) async => right<AppFailure, SmokeLog?>(sample));

    final uc = GetLastSmokeLogUseCase(repository: repo);
    final res = await uc(accountId: 'a1');
    expect(res.getRight().toNullable(), equals(sample));
  });
}
