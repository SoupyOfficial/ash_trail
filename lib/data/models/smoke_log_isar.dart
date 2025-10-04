import 'package:isar/isar.dart';
import '../../domain/models/smoke_log.dart';

part 'smoke_log_isar.g.dart';

@collection
class SmokeLogIsar {
  Id id = Isar.autoIncrement;

  @Index(name: 'logIdIdx', type: IndexType.hash, caseSensitive: true)
  late String logId; // UUID from domain model

  @Index(name: 'accountIdx', type: IndexType.hash, caseSensitive: true)
  late String accountId;

  @Index(name: 'tsIdx')
  late DateTime ts;

  late int durationMs;

  String? methodId;

  int? potency;

  late int moodScore;

  late int physicalScore;

  String? notes;

  String? deviceLocalId;

  late DateTime createdAt;

  late DateTime updatedAt;

  // Sync metadata
  @Index(name: 'dirtyIdx')
  late bool isDirty; // Needs sync to remote

  DateTime? lastSyncAt;

  String? syncError; // Last sync error if any

  // Composite index for efficient queries
  @Index(
    name: 'accountTsIdx',
    composite: [CompositeIndex('accountId'), CompositeIndex('ts')],
  )
  String get accountTsIndex => '$accountId-${ts.millisecondsSinceEpoch}';

  /// Convert from domain model to Isar model
  static SmokeLogIsar fromDomain(SmokeLog smokeLog) {
    return SmokeLogIsar()
      ..logId = smokeLog.id
      ..accountId = smokeLog.accountId
      ..ts = smokeLog.ts
      ..durationMs = smokeLog.durationMs
      ..methodId = smokeLog.methodId
      ..potency = smokeLog.potency
      ..moodScore = smokeLog.moodScore
      ..physicalScore = smokeLog.physicalScore
      ..notes = smokeLog.notes
      ..deviceLocalId = smokeLog.deviceLocalId
      ..createdAt = smokeLog.createdAt
      ..updatedAt = smokeLog.updatedAt
      ..isDirty = true // Mark as needing sync
      ..lastSyncAt = null
      ..syncError = null;
  }

  /// Convert to domain model
  SmokeLog toDomain() {
    return SmokeLog(
      id: logId,
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

  /// Create a copy with sync metadata updated
  SmokeLogIsar copyWithSyncStatus({
    bool? isDirty,
    DateTime? lastSyncAt,
    String? syncError,
  }) {
    return SmokeLogIsar()
      ..id = id
      ..logId = logId
      ..accountId = accountId
      ..ts = ts
      ..durationMs = durationMs
      ..methodId = methodId
      ..potency = potency
      ..moodScore = moodScore
      ..physicalScore = physicalScore
      ..notes = notes
      ..deviceLocalId = deviceLocalId
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..isDirty = isDirty ?? this.isDirty
      ..lastSyncAt = lastSyncAt ?? this.lastSyncAt
      ..syncError = syncError ?? this.syncError;
  }
}
