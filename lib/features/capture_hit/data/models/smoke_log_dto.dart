// Data Transfer Object for SmokeLog persistence and remote sync
// Maps between domain entities and storage/network representation

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/smoke_log.dart';

part 'smoke_log_dto.freezed.dart';
part 'smoke_log_dto.g.dart';

/// DTO for SmokeLog serialization and storage operations
/// Used for both Isar local storage and Firestore remote sync
@freezed
class SmokeLogDto with _$SmokeLogDto {
  const factory SmokeLogDto({
    required String id,
    required String accountId,
    required DateTime ts,
    required int durationMs,
    String? methodId,
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
    String? deviceLocalId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
    @Default(false) bool isPendingSync,
  }) = _SmokeLogDto;

  factory SmokeLogDto.fromJson(Map<String, dynamic> json) =>
      _$SmokeLogDtoFromJson(json);
}

/// Extension methods for converting between DTO and domain entity
extension SmokeLogDtoMapper on SmokeLogDto {
  /// Convert DTO to domain entity
  SmokeLog toEntity() {
    return SmokeLog(
      id: id,
      accountId: accountId,
      ts: ts,
      durationMs: durationMs,
      methodId: methodId,
      potency: potency,
      moodScore: moodScore,
      physicalScore: physicalScore,
      notes: notes,
      deviceLocalId: deviceLocalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension SmokeLogEntityMapper on SmokeLog {
  /// Convert domain entity to DTO
  /// Used for local storage and remote sync operations
  SmokeLogDto toDto({
    bool isDeleted = false,
    bool isPendingSync = false,
  }) {
    return SmokeLogDto(
      id: id,
      accountId: accountId,
      ts: ts,
      durationMs: durationMs,
      methodId: methodId,
      potency: potency,
      moodScore: moodScore,
      physicalScore: physicalScore,
      notes: notes,
      deviceLocalId: deviceLocalId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      isPendingSync: isPendingSync,
    );
  }
}
