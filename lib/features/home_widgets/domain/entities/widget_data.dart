// Widget data entity containing display information for home screen widgets.
// Pure domain object with business logic and validation.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'widget_size.dart';
import 'widget_tap_action.dart';

part 'widget_data.freezed.dart';

@freezed
class WidgetData with _$WidgetData {
  const factory WidgetData({
    required String id,
    required String accountId,
    required WidgetSize size,
    required WidgetTapAction tapAction,
    required int todayHitCount,
    required int currentStreak,
    required DateTime lastSyncAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool? showStreak,
    bool? showLastSync,
  }) = _WidgetData;

  const WidgetData._();

  /// Business logic for determining if streak should be displayed
  bool get shouldShowStreak {
    // Show streak if explicitly enabled, or auto-show for larger widgets
    final explicitlySet = showStreak ?? false;
    final autoShow = size.canShowStreak && currentStreak > 0;
    return explicitlySet || autoShow;
  }

  /// Business logic for determining if last sync should be displayed
  bool get shouldShowLastSync {
    // Show last sync timestamp if enabled and widget is large enough
    return (showLastSync ?? true) && size.canShowDetails;
  }

  /// Returns formatted streak text
  String get streakText {
    if (currentStreak <= 0) return '';
    return currentStreak == 1 ? '1 day streak' : '$currentStreak day streak';
  }

  /// Returns formatted hit count text
  String get hitCountText {
    return todayHitCount == 1 ? '1 hit today' : '$todayHitCount hits today';
  }

  /// Returns time since last sync in human-readable format
  String get timeSinceSync {
    final now = DateTime.now();
    final difference = now.difference(lastSyncAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Business validation - checks if widget data is valid
  bool get isValid {
    return id.isNotEmpty &&
        accountId.isNotEmpty &&
        todayHitCount >= 0 &&
        currentStreak >= 0 &&
        lastSyncAt.isBefore(DateTime.now()
            .add(const Duration(minutes: 5))); // Allow 5min clock skew
  }

  /// Returns true if sync data is stale (older than 1 hour)
  bool get isSyncStale {
    final now = DateTime.now();
    return now.difference(lastSyncAt).inHours >= 1;
  }

  /// Creates updated widget data with new hit count and sync time
  WidgetData updateHitCount(int newHitCount) {
    return copyWith(
      todayHitCount: newHitCount,
      lastSyncAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Creates updated widget data with new streak
  WidgetData updateStreak(int newStreak) {
    return copyWith(
      currentStreak: newStreak,
      lastSyncAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
