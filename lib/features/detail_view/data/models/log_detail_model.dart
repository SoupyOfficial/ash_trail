// Data model for log detail response
// Handles JSON serialization and conversion to domain entity

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../../domain/models/tag.dart';
import '../../../../domain/models/reason.dart';
import '../../../../domain/models/method.dart';
import '../../domain/entities/log_detail_entity.dart';

part 'log_detail_model.freezed.dart';
part 'log_detail_model.g.dart';

@freezed
class LogDetailModel with _$LogDetailModel {
  const factory LogDetailModel({
    required SmokeLog log,
    @Default([]) List<Tag> tags,
    @Default([]) List<Reason> reasons,
    Method? method,
  }) = _LogDetailModel;

  const LogDetailModel._();

  factory LogDetailModel.fromJson(Map<String, dynamic> json) => _$LogDetailModelFromJson(json);

  /// Convert to domain entity
  LogDetailEntity toEntity() {
    return LogDetailEntity(
      log: log,
      tags: tags,
      reasons: reasons,
      method: method,
    );
  }

  /// Create from domain entity
  static LogDetailModel fromEntity(LogDetailEntity entity) {
    return LogDetailModel(
      log: entity.log,
      tags: entity.tags,
      reasons: entity.reasons,
      method: entity.method,
    );
  }
}