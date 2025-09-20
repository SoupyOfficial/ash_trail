// Data model for live activity recording sessions.
// Handles JSON serialization for persistence.

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/live_activity_entity.dart';

part 'live_activity_model.freezed.dart';
part 'live_activity_model.g.dart';

@freezed
class LiveActivityModel with _$LiveActivityModel {
  const factory LiveActivityModel({
    required String id,
    required DateTime startedAt,
    DateTime? endedAt,
    required String status,
    String? cancelReason,
  }) = _LiveActivityModel;

  const LiveActivityModel._();

  factory LiveActivityModel.fromJson(Map<String, dynamic> json) =>
      _$LiveActivityModelFromJson(json);

  /// Convert to domain entity
  LiveActivityEntity toEntity() => LiveActivityEntity(
        id: id,
        startedAt: startedAt,
        endedAt: endedAt,
        status: LiveActivityStatus.fromString(status),
        cancelReason: cancelReason,
      );

  /// Create from domain entity
  factory LiveActivityModel.fromEntity(LiveActivityEntity entity) =>
      LiveActivityModel(
        id: entity.id,
        startedAt: entity.startedAt,
        endedAt: entity.endedAt,
        status: entity.status.toString(),
        cancelReason: entity.cancelReason,
      );
}
