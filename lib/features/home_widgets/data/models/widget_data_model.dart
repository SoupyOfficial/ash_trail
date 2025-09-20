// Data model for widget configuration with JSON serialization.
// Maps between domain entities and external storage/API formats.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/widget_data.dart';
import '../../domain/entities/widget_size.dart';
import '../../domain/entities/widget_tap_action.dart';

part 'widget_data_model.freezed.dart';
part 'widget_data_model.g.dart';

@freezed
class WidgetDataModel with _$WidgetDataModel {
  const factory WidgetDataModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'size') required String size,
    @JsonKey(name: 'tap_action') required String tapAction,
    @JsonKey(name: 'today_hit_count') required int todayHitCount,
    @JsonKey(name: 'current_streak') required int currentStreak,
    @JsonKey(name: 'last_sync_at') required DateTime lastSyncAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'show_streak') bool? showStreak,
    @JsonKey(name: 'show_last_sync') bool? showLastSync,
  }) = _WidgetDataModel;

  const WidgetDataModel._();

  factory WidgetDataModel.fromJson(Map<String, dynamic> json) =>
      _$WidgetDataModelFromJson(json);

  /// Converts from domain entity to data model
  factory WidgetDataModel.fromEntity(WidgetData entity) {
    return WidgetDataModel(
      id: entity.id,
      accountId: entity.accountId,
      size: entity.size.name,
      tapAction: entity.tapAction.name,
      todayHitCount: entity.todayHitCount,
      currentStreak: entity.currentStreak,
      lastSyncAt: entity.lastSyncAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      showStreak: entity.showStreak,
      showLastSync: entity.showLastSync,
    );
  }

  /// Converts to domain entity
  WidgetData toEntity() {
    return WidgetData(
      id: id,
      accountId: accountId,
      size: _parseWidgetSize(size),
      tapAction: _parseWidgetTapAction(tapAction),
      todayHitCount: todayHitCount,
      currentStreak: currentStreak,
      lastSyncAt: lastSyncAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      showStreak: showStreak,
      showLastSync: showLastSync,
    );
  }

  /// Helper method to parse widget size from string
  WidgetSize _parseWidgetSize(String sizeString) {
    return WidgetSize.values.firstWhere(
      (size) => size.name == sizeString,
      orElse: () => WidgetSize.medium,
    );
  }

  /// Helper method to parse widget tap action from string
  WidgetTapAction _parseWidgetTapAction(String actionString) {
    return WidgetTapAction.values.firstWhere(
      (action) => action.name == actionString,
      orElse: () => WidgetTapAction.defaultAction,
    );
  }
}
