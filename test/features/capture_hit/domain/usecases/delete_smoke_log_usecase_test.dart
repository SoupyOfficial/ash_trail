import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/capture_hit/domain/usecases/delete_smoke_log_usecase.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class _MockRepo extends Mock implements SmokeLogRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('validates smokeLogId required', () async {
    final uc = DeleteSmokeLogUseCase(repository: repo);
    final res = await uc(smokeLogId: '');
    expect(res.isLeft(), isTrue);
    res.match(
        (l) => expect(l, isA<AppFailure>()), (_) => fail('expected failure'));
  });

  test('delegates to repository', () async {
    when(() => repo.deleteSmokeLog(any())).thenAnswer((_) async => right(null));
    final uc = DeleteSmokeLogUseCase(repository: repo);
    final res = await uc(smokeLogId: 'id1');
    expect(res.isRight(), isTrue);
  });
}
