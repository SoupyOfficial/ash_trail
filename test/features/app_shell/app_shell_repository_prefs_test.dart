import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/app_shell/data/app_shell_repository_prefs.dart';
import 'package:ash_trail/features/app_shell/domain/entities/app_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppShellRepositoryPrefs', () {
    test('returns home when no value stored', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = AppShellRepositoryPrefs(prefs);
      final result = await repo.readLastActiveTab();
      expect(result.isRight(), true);
      result.match((_) {}, (tab) => expect(tab, AppTab.home));
    });

    test('persists and reads back logs tab', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = AppShellRepositoryPrefs(prefs);
      final save = await repo.saveLastActiveTab(AppTab.logs);
      expect(save.isRight(), true);
      final read = await repo.readLastActiveTab();
      read.match((_) {}, (tab) => expect(tab, AppTab.logs));
    });
  });
}
