import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/app_shell/presentation/app_shell.dart';
import 'package:ash_trail/features/app_shell/domain/entities/app_tab.dart';
import 'package:ash_trail/features/app_shell/domain/repositories/app_shell_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/app_shell/data/app_shell_repository_prefs.dart';

class _MemoryRepo implements AppShellRepository {
  AppTab _tab = AppTab.home;
  @override
  Future<Either<AppFailure, AppTab>> readLastActiveTab() async => right(_tab);
  @override
  Future<Either<AppFailure, Unit>> saveLastActiveTab(AppTab tab) async {
    _tab = tab;
    return right(unit);
  }
}

void main() {
  test('active tab persists via repository', () async {
    final container = ProviderContainer(overrides: [
      appShellRepositoryProvider.overrideWithValue(_MemoryRepo()),
    ]);
    final controller = container.read(activeTabProvider.notifier);
    await controller.set(AppTab.logs);
    expect(container.read(activeTabProvider).id, 'logs');
  });
}
