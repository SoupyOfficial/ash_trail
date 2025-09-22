// Goal Progress View Entity
// Represents the computed progress state for displaying goals with progress bars
// Separates presentation concerns from raw Goal data

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/goal.dart';

part 'goal_progress_view.freezed.dart';

@freezed
class GoalProgressView with _$GoalProgressView {
  const GoalProgressView._();

  const factory GoalProgressView({
    required Goal goal,
    required double progressPercentage,
    required bool isCompleted,
    required String displayText,
  }) = _GoalProgressView;

  /// Create a progress view from a Goal entity
  factory GoalProgressView.fromGoal(Goal goal, {int? currentProgress}) {
    final progress = currentProgress ?? goal.progress ?? 0;
    final target = goal.target;
    final percentage = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final isCompleted = goal.achievedAt != null || progress >= target;
    
    final displayText = isCompleted 
      ? 'Completed on ${_formatDate(goal.achievedAt ?? DateTime.now())}'
      : '$progress / $target ${_getUnitText(goal.type)}';

    return GoalProgressView(
      goal: goal,
      progressPercentage: percentage,
      isCompleted: isCompleted,
      displayText: displayText,
    );
  }

  /// Helper method to format date
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final goalDate = DateTime(date.year, date.month, date.day);
    
    if (goalDate == today) return 'Today';
    if (goalDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Helper method to get unit text based on goal type
  static String _getUnitText(String goalType) {
    return switch (goalType.toLowerCase()) {
      'smoke_free_days' => 'days',
      'reduction_count' => 'sessions',
      'duration_limit' => 'minutes',
      _ => 'units',
    };
  }

  /// Check if goal is overdue (past end date but not completed)
  bool get isOverdue {
    if (isCompleted) return false;
    final endDate = goal.endDate;
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate);
  }

  /// Get progress color based on state
  String get progressColor {
    if (isCompleted) return 'success';
    if (isOverdue) return 'error';
    if (progressPercentage >= 0.8) return 'warning';
    return 'primary';
  }

  /// Get descriptive status text
  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (progressPercentage >= 0.8) return 'Almost there!';
    if (progressPercentage >= 0.5) return 'Making progress';
    return 'Just started';
  }
}