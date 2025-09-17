// Domain entity representing a quick action that can be invoked from the app icon
// Pure business logic with no external dependencies

class QuickActionEntity {
  const QuickActionEntity({
    required this.type,
    required this.localizedTitle,
    required this.localizedSubtitle,
    this.icon,
  });

  final String type;
  final String localizedTitle;
  final String localizedSubtitle;
  final String? icon;

  // Business logic methods
  bool get isValid => type.isNotEmpty && localizedTitle.isNotEmpty;

  bool get isLogHit => type == QuickActionTypes.logHit;
  bool get isViewLogs => type == QuickActionTypes.viewLogs;
  bool get isStartTimedLog => type == QuickActionTypes.startTimedLog;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickActionEntity &&
        other.type == type &&
        other.localizedTitle == localizedTitle &&
        other.localizedSubtitle == localizedSubtitle &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return Object.hash(type, localizedTitle, localizedSubtitle, icon);
  }

  @override
  String toString() {
    return 'QuickActionEntity(type: $type, localizedTitle: $localizedTitle, localizedSubtitle: $localizedSubtitle, icon: $icon)';
  }
}

// Predefined quick actions
class QuickActionTypes {
  static const String logHit = 'log_hit';
  static const String viewLogs = 'view_logs';
  static const String startTimedLog = 'start_timed_log';
}
