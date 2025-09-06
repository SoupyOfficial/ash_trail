import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';
import '../domain/repositories/app_shell_repository.dart';
import '../domain/entities/app_tab.dart';
import '../../../core/failures/app_failure.dart';

const _kLastActiveTabKey = 'last_active_tab';

class AppShellRepositoryPrefs implements AppShellRepository {
  AppShellRepositoryPrefs(this._prefs);
  final SharedPreferences _prefs;
  @override
  Future<Either<AppFailure, AppTab>> readLastActiveTab() async {
    try {
      final id = _prefs.getString(_kLastActiveTabKey);
      if (id == null) return right(AppTab.home);
      return right(AppTabX.fromId(id));
    } catch (e) {
      return left(AppFailure.cache(message: 'Failed read last tab ($e)'));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> saveLastActiveTab(AppTab tab) async {
    try {
      await _prefs.setString(_kLastActiveTabKey, tab.id);
      return right(unit);
    } catch (e) {
      return left(AppFailure.cache(message: 'Failed save last tab ($e)'));
    }
  }
}

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final appShellRepositoryProvider = Provider<AppShellRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).maybeWhen(
        data: (v) => v,
        orElse: () => null,
      );
  // Provide a late binding fallback until prefs loaded.
  if (prefs == null) {
    // Temporary in-memory stub; not persisted.
    return _InMemoryAppShellRepository();
  }
  return AppShellRepositoryPrefs(prefs);
});

class _InMemoryAppShellRepository implements AppShellRepository {
  AppTab _tab = AppTab.home;
  @override
  Future<Either<AppFailure, AppTab>> readLastActiveTab() async => right(_tab);
  @override
  Future<Either<AppFailure, Unit>> saveLastActiveTab(AppTab tab) async {
    _tab = tab;
    return right(unit);
  }
}
