// Domain entity for log detail view
// Aggregates SmokeLog with its related data (tags, reasons, method)

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../../domain/models/tag.dart';
import '../../../../domain/models/reason.dart';
import '../../../../domain/models/method.dart';

part 'log_detail_entity.freezed.dart';

@freezed
class LogDetailEntity with _$LogDetailEntity {
  const factory LogDetailEntity({
    required SmokeLog log,
    @Default([]) List<Tag> tags,
    @Default([]) List<Reason> reasons,
    Method? method,
  }) = _LogDetailEntity;

  const LogDetailEntity._();

  /// Returns true if the log has any tags
  bool get hasTags => tags.isNotEmpty;

  /// Returns true if the log has any reasons
  bool get hasReasons => reasons.isNotEmpty;

  /// Returns true if the log has a method
  bool get hasMethod => method != null;

  /// Returns true if the log has notes
  bool get hasNotes => log.notes?.isNotEmpty ?? false;

  /// Returns the display name for the method or null if no method
  String? get methodName => method?.name;

  /// Returns formatted duration string
  String get formattedDuration {
    final duration = Duration(milliseconds: log.durationMs);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Returns formatted timestamp string
  String get formattedTimestamp {
    return '${log.ts.day.toString().padLeft(2, '0')}/'
        '${log.ts.month.toString().padLeft(2, '0')}/'
        '${log.ts.year} at '
        '${log.ts.hour.toString().padLeft(2, '0')}:'
        '${log.ts.minute.toString().padLeft(2, '0')}';
  }

  /// Returns mood score as a descriptive string
  String get moodScoreDescription {
    return switch (log.moodScore) {
      <= 2 => 'Very Low ($moodScore/10)',
      <= 4 => 'Low ($moodScore/10)',
      <= 6 => 'Moderate ($moodScore/10)',
      <= 8 => 'Good ($moodScore/10)',
      <= 10 => 'Excellent ($moodScore/10)',
      _ => 'Unknown ($moodScore/10)',
    };
  }

  /// Returns physical score as a descriptive string  
  String get physicalScoreDescription {
    return switch (log.physicalScore) {
      <= 2 => 'Very Low ($physicalScore/10)',
      <= 4 => 'Low ($physicalScore/10)',
      <= 6 => 'Moderate ($physicalScore/10)',
      <= 8 => 'Good ($physicalScore/10)',
      <= 10 => 'Excellent ($physicalScore/10)',
      _ => 'Unknown ($physicalScore/10)',
    };
  }

  /// Returns potency as a descriptive string if available
  String? get potencyDescription {
    final potency = log.potency;
    if (potency == null) return null;
    
    return switch (potency) {
      <= 2 => 'Very Low ($potency/10)',
      <= 4 => 'Low ($potency/10)',
      <= 6 => 'Moderate ($potency/10)',
      <= 8 => 'High ($potency/10)',
      <= 10 => 'Very High ($potency/10)',
      _ => 'Unknown ($potency/10)',
    };
  }

  int get moodScore => log.moodScore;
  int get physicalScore => log.physicalScore;
}