// Reachability zone representing areas of the screen that are easily accessible by thumb
// Used for ergonomics analysis and accessibility auditing

import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reachability_zone.freezed.dart';

@freezed
class ReachabilityZone with _$ReachabilityZone {
  const ReachabilityZone._();

  const factory ReachabilityZone({
    required String id,
    required String name,
    required Rect bounds,
    required ReachabilityLevel level,
    required String description,
  }) = _ReachabilityZone;

  /// Whether a given point is within this zone
  bool containsPoint(Offset point) => bounds.contains(point);

  /// Whether a given rect overlaps with this zone
  bool overlapsRect(Rect rect) => bounds.overlaps(rect);

  /// Percentage of given rect that falls within this zone
  double coveragePercentage(Rect rect) {
    if (!bounds.overlaps(rect)) return 0.0;
    
    final intersection = bounds.intersect(rect);
    final rectArea = rect.width * rect.height;
    if (rectArea == 0) return 0.0;
    
    final intersectionArea = intersection.width * intersection.height;
    return (intersectionArea / rectArea).clamp(0.0, 1.0);
  }
}

enum ReachabilityLevel {
  /// Easy to reach with thumb (lower 60% of screen in portrait)
  easy,
  /// Moderate difficulty (60-80% of screen height)
  moderate,
  /// Difficult to reach (upper 20% of screen)
  difficult,
  /// Outside the natural thumb zone
  unreachable,
}

extension ReachabilityLevelX on ReachabilityLevel {
  String get displayName => switch (this) {
    ReachabilityLevel.easy => 'Easy to Reach',
    ReachabilityLevel.moderate => 'Moderate',
    ReachabilityLevel.difficult => 'Difficult',
    ReachabilityLevel.unreachable => 'Unreachable',
  };

  String get description => switch (this) {
    ReachabilityLevel.easy => 'Comfortable thumb zone for primary actions',
    ReachabilityLevel.moderate => 'Reachable with slight thumb stretch',
    ReachabilityLevel.difficult => 'Requires thumb extension or two-handed use',
    ReachabilityLevel.unreachable => 'Outside natural thumb reach',
  };

  /// Color coding for visualization
  int get colorValue => switch (this) {
    ReachabilityLevel.easy => 0xFF4CAF50, // Green
    ReachabilityLevel.moderate => 0xFFFF9800, // Orange  
    ReachabilityLevel.difficult => 0xFFFF5722, // Deep Orange
    ReachabilityLevel.unreachable => 0xFFF44336, // Red
  };
}