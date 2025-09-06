/// Primary application tabs (adaptive navigation). Order defines display order.
enum AppTab { home, logs, charts, settings }

extension AppTabX on AppTab {
  String get id => name;
  static AppTab fromId(String id) => switch (id) {
        'home' => AppTab.home,
        'logs' => AppTab.logs,
        'charts' => AppTab.charts,
        'settings' => AppTab.settings,
        _ => AppTab.home,
      };
}
