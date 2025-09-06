import 'package:fpdart/fpdart.dart';
import '../entities/app_tab.dart';
import '../repositories/app_shell_repository.dart';
import '../../../../core/failures/app_failure.dart';

class SetLastActiveTabUseCase {
  const SetLastActiveTabUseCase(this._repo);
  final AppShellRepository _repo;
  Future<Either<AppFailure, Unit>> call(AppTab tab) =>
      _repo.saveLastActiveTab(tab);
}
