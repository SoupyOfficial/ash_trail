// Factory for creating reachability zones based on screen dimensions
// Generates thumb zone definitions for ergonomic analysis

import 'package:flutter/painting.dart';
import '../../domain/entities/reachability_zone.dart';

class ReachabilityZoneFactory {
  const ReachabilityZoneFactory();

  /// Generate reachability zones for a given screen size
  /// Based on thumb reach ergonomics research and mobile UI guidelines
  List<ReachabilityZone> createZonesForScreen(Size screenSize) {
    final width = screenSize.width;
    final height = screenSize.height;

    // Define zone boundaries based on ergonomics research
    // Easy reach: lower 60% of screen (thumb natural position)
    // Moderate: 60-80% (requires slight stretch)
    // Difficult: 80-95% (requires significant stretch)
    // Unreachable: top 5% (requires two hands or device repositioning)

    const easyReachPercent = 0.6;
    const moderateReachPercent = 0.8;
    const difficultReachPercent = 0.95;

    final easyReachTop = height * (1 - easyReachPercent);
    final moderateReachTop = height * (1 - moderateReachPercent);
    final difficultReachTop = height * (1 - difficultReachPercent);

    return [
      // Easy reach zone (bottom 60% of screen)
      ReachabilityZone(
        id: 'easy_reach_zone',
        name: 'Easy Reach Zone',
        bounds: Rect.fromLTWH(
          0,
          easyReachTop,
          width,
          height - easyReachTop,
        ),
        level: ReachabilityLevel.easy,
        description: 'Comfortable thumb zone for primary actions. '
            'Most frequently used controls should be placed here.',
      ),

      // Moderate reach zone (60-80% of screen height)
      ReachabilityZone(
        id: 'moderate_reach_zone',
        name: 'Moderate Reach Zone',
        bounds: Rect.fromLTWH(
          0,
          moderateReachTop,
          width,
          easyReachTop - moderateReachTop,
        ),
        level: ReachabilityLevel.moderate,
        description: 'Reachable with slight thumb stretch. '
            'Secondary actions can be placed here.',
      ),

      // Difficult reach zone (80-95% of screen height)
      ReachabilityZone(
        id: 'difficult_reach_zone',
        name: 'Difficult Reach Zone',
        bounds: Rect.fromLTWH(
          0,
          difficultReachTop,
          width,
          moderateReachTop - difficultReachTop,
        ),
        level: ReachabilityLevel.difficult,
        description: 'Requires thumb extension or device repositioning. '
            'Less frequently used controls only.',
      ),

      // Unreachable zone (top 5% of screen)
      ReachabilityZone(
        id: 'unreachable_zone',
        name: 'Unreachable Zone',
        bounds: Rect.fromLTWH(
          0,
          0,
          width,
          difficultReachTop,
        ),
        level: ReachabilityLevel.unreachable,
        description: 'Outside natural thumb reach. '
            'Avoid interactive elements or provide alternative access.',
      ),
    ];
  }

  /// Create custom zones based on specific device characteristics
  List<ReachabilityZone> createCustomZones({
    required Size screenSize,
    required DeviceType deviceType,
    required HandPreference handPreference,
  }) {
    final width = screenSize.width;
    final height = screenSize.height;

    // Adjust percentages based on device type
    final (easyPercent, moderatePercent, difficultPercent) = switch (deviceType) {
      DeviceType.phone => (0.6, 0.8, 0.95),
      DeviceType.phablet => (0.55, 0.75, 0.9), // Slightly harder reach on larger phones
      DeviceType.tablet => (0.7, 0.85, 0.95), // Different ergonomics for tablets
      DeviceType.foldable => (0.65, 0.8, 0.9), // Account for folding mechanics
    };

    final easyReachTop = height * (1 - easyPercent);
    final moderateReachTop = height * (1 - moderatePercent);  
    final difficultReachTop = height * (1 - difficultPercent);

    final zones = <ReachabilityZone>[];

    if (handPreference == HandPreference.both || handPreference == HandPreference.right) {
      // Right-hand optimized zones (slightly favor right side)
      zones.addAll(_createHandOptimizedZones(
        screenSize: screenSize,
        handSide: 'right',
        easyReachTop: easyReachTop,
        moderateReachTop: moderateReachTop,
        difficultReachTop: difficultReachTop,
      ));
    }

    if (handPreference == HandPreference.both || handPreference == HandPreference.left) {
      // Left-hand optimized zones (slightly favor left side)
      zones.addAll(_createHandOptimizedZones(
        screenSize: screenSize,
        handSide: 'left',
        easyReachTop: easyReachTop,
        moderateReachTop: moderateReachTop,
        difficultReachTop: difficultReachTop,
      ));
    }

    // If both hands, merge overlapping zones and create general zones
    if (handPreference == HandPreference.both) {
      return _mergeHandZones(zones, screenSize);
    }

    return zones;
  }

  List<ReachabilityZone> _createHandOptimizedZones({
    required Size screenSize,
    required String handSide,
    required double easyReachTop,
    required double moderateReachTop,
    required double difficultReachTop,
  }) {
    final width = screenSize.width;
    final height = screenSize.height;
    final isRight = handSide == 'right';

    // Thumb naturally reaches in an arc - account for this
    final thumbArcOffset = width * 0.15; // 15% of screen width
    final favoredSideWidth = width * 0.7; // 70% of width on favored side

    return [
      ReachabilityZone(
        id: '${handSide}_easy_reach_zone',
        name: '${handSide.capitalize()} Hand Easy Reach',
        bounds: Rect.fromLTWH(
          isRight ? width - favoredSideWidth : 0,
          easyReachTop,
          favoredSideWidth,
          height - easyReachTop,
        ),
        level: ReachabilityLevel.easy,
        description: 'Optimal reach zone for $handSide hand usage.',
      ),

      ReachabilityZone(
        id: '${handSide}_moderate_reach_zone', 
        name: '${handSide.capitalize()} Hand Moderate Reach',
        bounds: Rect.fromLTWH(
          isRight ? width - favoredSideWidth - thumbArcOffset : favoredSideWidth,
          moderateReachTop,
          favoredSideWidth + thumbArcOffset,
          easyReachTop - moderateReachTop,
        ),
        level: ReachabilityLevel.moderate,
        description: 'Reachable with slight stretch for $handSide hand.',
      ),
    ];
  }

  List<ReachabilityZone> _mergeHandZones(List<ReachabilityZone> zones, Size screenSize) {
    // Simplified merge - just return general zones for both-handed use
    return createZonesForScreen(screenSize);
  }
}

enum DeviceType {
  phone,
  phablet,
  tablet,
  foldable,
}

enum HandPreference {
  left,
  right,
  both,
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}