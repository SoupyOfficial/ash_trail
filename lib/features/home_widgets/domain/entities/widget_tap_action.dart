// Widget tap action configuration for deep linking.
// Defines what happens when user taps the widget.

enum WidgetTapAction {
  openApp('Open App'),
  recordOverlay('Record Overlay'),
  viewLogs('View Logs'),
  quickRecord('Quick Record');

  const WidgetTapAction(this.displayName);

  final String displayName;

  /// Default action for new widgets
  static const WidgetTapAction defaultAction = WidgetTapAction.openApp;

  /// Returns deep link path for this action
  String get deepLinkPath => switch (this) {
        WidgetTapAction.openApp => '/',
        WidgetTapAction.recordOverlay => '/record',
        WidgetTapAction.viewLogs => '/logs',
        WidgetTapAction.quickRecord => '/record?quick=true',
      };

  /// Returns true if this action requires authentication
  bool get requiresAuth => this != WidgetTapAction.openApp;
}
