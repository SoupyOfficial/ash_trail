// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccessibilityConfigModelImpl _$$AccessibilityConfigModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AccessibilityConfigModelImpl(
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isScreenReaderEnabled: json['isScreenReaderEnabled'] as bool,
      isBoldTextEnabled: json['isBoldTextEnabled'] as bool,
      isReduceMotionEnabled: json['isReduceMotionEnabled'] as bool,
      isHighContrastEnabled: json['isHighContrastEnabled'] as bool,
      textScaleFactor: (json['textScaleFactor'] as num).toDouble(),
      enableHapticFeedback: json['enableHapticFeedback'] as bool,
      enableSemanticLabels: json['enableSemanticLabels'] as bool,
      minTapTargetSize: (json['minTapTargetSize'] as num).toDouble(),
      enableFocusIndicators: json['enableFocusIndicators'] as bool,
      enableCustomFocusOrder: json['enableCustomFocusOrder'] as bool,
    );

Map<String, dynamic> _$$AccessibilityConfigModelImplToJson(
        _$AccessibilityConfigModelImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isScreenReaderEnabled': instance.isScreenReaderEnabled,
      'isBoldTextEnabled': instance.isBoldTextEnabled,
      'isReduceMotionEnabled': instance.isReduceMotionEnabled,
      'isHighContrastEnabled': instance.isHighContrastEnabled,
      'textScaleFactor': instance.textScaleFactor,
      'enableHapticFeedback': instance.enableHapticFeedback,
      'enableSemanticLabels': instance.enableSemanticLabels,
      'minTapTargetSize': instance.minTapTargetSize,
      'enableFocusIndicators': instance.enableFocusIndicators,
      'enableCustomFocusOrder': instance.enableCustomFocusOrder,
    };
