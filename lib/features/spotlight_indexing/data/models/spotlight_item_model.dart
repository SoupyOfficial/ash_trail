// Data model for spotlight items with JSON serialization.
// Handles conversion between domain entities and data transfer objects.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/spotlight_item_entity.dart';

part 'spotlight_item_model.freezed.dart';
part 'spotlight_item_model.g.dart';

@freezed
class SpotlightItemModel with _$SpotlightItemModel {
  const SpotlightItemModel._();

  const factory SpotlightItemModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'description') String? description,
    @JsonKey(name: 'keywords') List<String>? keywords,
    @JsonKey(name: 'deep_link') required String deepLink,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'content_id') required String contentId,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _SpotlightItemModel;

  factory SpotlightItemModel.fromJson(Map<String, dynamic> json) =>
      _$SpotlightItemModelFromJson(json);

  /// Convert from domain entity to data model
  factory SpotlightItemModel.fromEntity(SpotlightItemEntity entity) {
    return SpotlightItemModel(
      id: entity.id,
      type: entity.type.name,
      title: entity.title,
      description: entity.description,
      keywords: entity.keywords,
      deepLink: entity.deepLink,
      accountId: entity.accountId,
      contentId: entity.contentId,
      lastUpdated: entity.lastUpdated,
      isActive: entity.isActive,
    );
  }

  /// Convert to domain entity
  SpotlightItemEntity toEntity() {
    SpotlightItemType itemType;
    try {
      itemType = SpotlightItemType.values.firstWhere((e) => e.name == type);
    } catch (e) {
      // Fallback to tag type if unknown
      itemType = SpotlightItemType.tag;
    }

    return SpotlightItemEntity(
      id: id,
      type: itemType,
      title: title,
      description: description,
      keywords: keywords,
      deepLink: deepLink,
      accountId: accountId,
      contentId: contentId,
      lastUpdated: lastUpdated,
      isActive: isActive,
    );
  }
}