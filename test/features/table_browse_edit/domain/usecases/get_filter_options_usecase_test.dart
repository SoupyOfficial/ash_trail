import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/get_filter_options_usecase.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class _MockRepo extends Mock implements LogsTableRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  group('GetUsedMethodIdsUseCase', () {
    test('validates accountId required', () async {
      final uc = GetUsedMethodIdsUseCase(repository: repo);
      final res = await uc(accountId: '');
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<AppFailure>()),
        (_) => fail('Expected validation failure'),
      );
    });

    test('delegates to repository', () async {
      when(() => repo.getUsedMethodIds(accountId: any(named: 'accountId')))
          .thenAnswer((_) async => right(<String>['vape', 'joint']));
      final uc = GetUsedMethodIdsUseCase(repository: repo);
      final res = await uc(accountId: 'a1');
      expect(res.getRight().toNullable(), ['vape', 'joint']);
    });
  });

  group('GetUsedTagIdsUseCase', () {
    test('validates accountId required', () async {
      final uc = GetUsedTagIdsUseCase(repository: repo);
      final res = await uc(accountId: '');
      expect(res.isLeft(), isTrue);
    });

    test('delegates to repository', () async {
      when(() => repo.getUsedTagIds(accountId: any(named: 'accountId')))
          .thenAnswer((_) async => right(<String>['sleep', 'focus']));
      final uc = GetUsedTagIdsUseCase(repository: repo);
      final res = await uc(accountId: 'a1');
      expect(res.getRight().toNullable(), ['sleep', 'focus']);
    });
  });
}
