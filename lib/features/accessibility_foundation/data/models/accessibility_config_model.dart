// Data model for persisting accessibility configuration preferences.
// Provides conversion between domain entities and serialized storage format.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/accessibility_config.dart';

part 'accessibility_config_model.freezed.dart';
part 'accessibility_config_model.g.dart';

@freezed
class AccessibilityConfigModel with _$AccessibilityConfigModel {
  const AccessibilityConfigModel._();

  const factory AccessibilityConfigModel({
    required String userId,
    required DateTime createdAt,
    DateTime? updatedAt,
    required bool isScreenReaderEnabled,
    required bool isBoldTextEnabled,
    required bool isReduceMotionEnabled,
    required bool isHighContrastEnabled,
    required double textScaleFactor,
    required bool enableHapticFeedback,
    required bool enableSemanticLabels,
    required double minTapTargetSize,
    required bool enableFocusIndicators,
    required bool enableCustomFocusOrder,
  }) = _AccessibilityConfigModel;

  factory AccessibilityConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityConfigModelFromJson(json);

  factory AccessibilityConfigModel.fromEntity(AccessibilityConfig entity) =>
      AccessibilityConfigModel(
        userId: entity.userId,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        isScreenReaderEnabled: entity.isScreenReaderEnabled,
        isBoldTextEnabled: entity.isBoldTextEnabled,
        isReduceMotionEnabled: entity.isReduceMotionEnabled,
        isHighContrastEnabled: entity.isHighContrastEnabled,
        textScaleFactor: entity.textScaleFactor,
        enableHapticFeedback: entity.enableHapticFeedback,
        enableSemanticLabels: entity.enableSemanticLabels,
        minTapTargetSize: entity.minTapTargetSize,
        enableFocusIndicators: entity.enableFocusIndicators,
        enableCustomFocusOrder: entity.enableCustomFocusOrder,
      );

  AccessibilityConfig toEntity() => AccessibilityConfig(
        userId: userId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isScreenReaderEnabled: isScreenReaderEnabled,
        isBoldTextEnabled: isBoldTextEnabled,
        isReduceMotionEnabled: isReduceMotionEnabled,
        isHighContrastEnabled: isHighContrastEnabled,
        textScaleFactor: textScaleFactor,
        enableHapticFeedback: enableHapticFeedback,
        enableSemanticLabels: enableSemanticLabels,
        minTapTargetSize: minTapTargetSize,
        enableFocusIndicators: enableFocusIndicators,
        enableCustomFocusOrder: enableCustomFocusOrder,
      );
}
