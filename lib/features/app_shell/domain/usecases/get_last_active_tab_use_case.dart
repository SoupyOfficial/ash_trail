import 'package:fpdart/fpdart.dart';
import '../entities/app_tab.dart';
import '../repositories/app_shell_repository.dart';
import '../../../../core/failures/app_failure.dart';

/// Returns last persisted active tab or default (home) if none.
class GetLastActiveTabUseCase {
  const GetLastActiveTabUseCase(this._repo);
  final AppShellRepository _repo;
  Future<Either<AppFailure, AppTab>> call() => _repo.readLastActiveTab();
}
