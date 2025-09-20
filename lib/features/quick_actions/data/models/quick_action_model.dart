// Data model for quick actions
// Maps to/from platform quick_actions package types

import '../../domain/entities/quick_action_entity.dart';

class QuickActionModel {
  const QuickActionModel({
    required this.type,
    required this.localizedTitle,
    required this.localizedSubtitle,
    this.icon,
  });

  final String type;
  final String localizedTitle;
  final String localizedSubtitle;
  final String? icon;

  factory QuickActionModel.fromJson(Map<String, dynamic> json) {
    return QuickActionModel(
      type: json['type'] as String,
      localizedTitle: json['localizedTitle'] as String,
      localizedSubtitle: json['localizedSubtitle'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'localizedTitle': localizedTitle,
      'localizedSubtitle': localizedSubtitle,
      'icon': icon,
    };
  }

  // Convert to domain entity
  QuickActionEntity toEntity() => QuickActionEntity(
        type: type,
        localizedTitle: localizedTitle,
        localizedSubtitle: localizedSubtitle,
        icon: icon,
      );

  // Convert from domain entity
  factory QuickActionModel.fromEntity(QuickActionEntity entity) =>
      QuickActionModel(
        type: entity.type,
        localizedTitle: entity.localizedTitle,
        localizedSubtitle: entity.localizedSubtitle,
        icon: entity.icon,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuickActionModel &&
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
    return 'QuickActionModel(type: $type, localizedTitle: $localizedTitle, localizedSubtitle: $localizedSubtitle, icon: $icon)';
  }
}
