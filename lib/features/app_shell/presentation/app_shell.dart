import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/entities/app_tab.dart';
import '../domain/usecases/get_last_active_tab_use_case.dart';
import '../domain/usecases/set_last_active_tab_use_case.dart';
import '../data/app_shell_repository_prefs.dart';
import '../../responsive/presentation/widgets/min_tap_target.dart';

// Providers wiring use cases
final getLastActiveTabUseCaseProvider =
    Provider<GetLastActiveTabUseCase>((ref) {
  return GetLastActiveTabUseCase(ref.watch(appShellRepositoryProvider));
});
final setLastActiveTabUseCaseProvider =
    Provider<SetLastActiveTabUseCase>((ref) {
  return SetLastActiveTabUseCase(ref.watch(appShellRepositoryProvider));
});

final activeTabProvider =
    StateNotifierProvider<ActiveTabController, AppTab>((ref) {
  return ActiveTabController(ref);
});

class ActiveTabController extends StateNotifier<AppTab> {
  ActiveTabController(this._ref) : super(AppTab.home) {
    // Kick off async load; for tests overriding repo with synchronous impl this completes quickly.
    _load();
  }
  final Ref _ref;
  Future<void> _load() async {
    final prev = state; // capture to detect user changes before load completes
    final result = await _ref.read(getLastActiveTabUseCaseProvider).call();
    result.match(
      (_) => null,
      (tab) {
        if (state == prev) {
          state = tab;
        }
      },
    );
  }

  Future<void> set(AppTab tab) async {
    state = tab;
    await _ref.read(setLastActiveTabUseCaseProvider).call(tab);
  }
}

/// Adaptive App Shell deciding between bottom nav and navigation rail.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFromTab(AppTab tab) {
    if (tab.toString().contains('home')) return 0; // Fallback before codegen
    if (tab.toString().contains('logs')) return 1;
    if (tab.toString().contains('charts')) return 2;
    if (tab.toString().contains('settings')) return 3;
    return 0;
  }

  AppTab _tabFromIndex(int i) => switch (i) {
        0 => AppTab.home,
        1 => AppTab.logs,
        2 => AppTab.charts,
        3 => AppTab.settings,
        _ => AppTab.home,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    final items = <_NavItem>[
      _NavItem(label: 'Home', icon: Icons.home_outlined, active: Icons.home),
      _NavItem(
          label: 'Logs', icon: Icons.list_alt_outlined, active: Icons.list),
      _NavItem(
          label: 'Charts',
          icon: Icons.show_chart,
          active: Icons.show_chart,
          disabled: true),
      _NavItem(
          label: 'Settings',
          icon: Icons.settings_outlined,
          active: Icons.settings),
    ];

    void onSelect(int i) {
      final newTab = _tabFromIndex(i);
      ref.read(activeTabProvider.notifier).set(newTab);
      // Navigate root of selected tab
      GoRouter? router;
      try {
        router = GoRouter.of(context);
      } catch (_) {
        // Absent router (e.g., in isolated widget tests). State already updated; bail out.
        return;
      }
      final id = newTab.id;
      switch (id) {
        case 'home':
          router.go('/');
          break;
        case 'logs':
          router.go('/logs');
          break;
        case 'charts':
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Charts coming soon')));
          break;
        case 'settings':
          router.go('/settings');
          break;
      }
    }

    final currentIndex = _indexFromTab(tab);

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.active),
                    label: Text(item.label),
                    disabled: item.disabled,
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onSelect,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.active),
                label: item.label,
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Launch record flow (placeholder haptic event could be triggered here)
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Record action')));
        },
        icon: const Icon(Icons.add),
        label: const Text('Log'),
      ).withMinTapTarget(
          minSize: 56.0), // Enhanced tap target for accessibility
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    this.disabled = false,
  });
  final String label;
  final IconData icon;
  final IconData active;
  final bool disabled;
}
