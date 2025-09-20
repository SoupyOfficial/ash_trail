import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/app_shell/domain/usecases/get_last_active_tab_use_case.dart';
import 'package:ash_trail/features/app_shell/domain/usecases/set_last_active_tab_use_case.dart';
import 'package:ash_trail/features/app_shell/domain/entities/app_tab.dart';
import 'package:ash_trail/features/app_shell/domain/repositories/app_shell_repository.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:fpdart/fpdart.dart';

class _MockRepository implements AppShellRepository {
  AppTab _tab = AppTab.home;
  bool _shouldFail = false;

  void setFailure(bool fail) => _shouldFail = fail;

  @override
  Future<Either<AppFailure, AppTab>> readLastActiveTab() async {
    if (_shouldFail) {
      return left(const AppFailure.cache(message: 'Mock read failure'));
    }
    return right(_tab);
  }

  @override
  Future<Either<AppFailure, Unit>> saveLastActiveTab(AppTab tab) async {
    if (_shouldFail) {
      return left(const AppFailure.cache(message: 'Mock save failure'));
    }
    _tab = tab;
    return right(unit);
  }
}

void main() {
  group('GetLastActiveTabUseCase', () {
    test('returns tab from repository', () async {
      final repo = _MockRepository();
      final useCase = GetLastActiveTabUseCase(repo);

      final result = await useCase();
      expect(result.isRight(), true);
      result.match((_) {}, (tab) => expect(tab, AppTab.home));
    });

    test('propagates repository failure', () async {
      final repo = _MockRepository()..setFailure(true);
      final useCase = GetLastActiveTabUseCase(repo);

      final result = await useCase();
      expect(result.isLeft(), true);
    });
  });

  group('SetLastActiveTabUseCase', () {
    test('saves tab to repository', () async {
      final repo = _MockRepository();
      final useCase = SetLastActiveTabUseCase(repo);

      final result = await useCase(AppTab.logs);
      expect(result.isRight(), true);
    });

    test('propagates repository failure', () async {
      final repo = _MockRepository()..setFailure(true);
      final useCase = SetLastActiveTabUseCase(repo);

      final result = await useCase(AppTab.logs);
      expect(result.isLeft(), true);
    });
  });
}
