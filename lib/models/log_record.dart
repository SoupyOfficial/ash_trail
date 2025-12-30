import 'enums.dart';

/// LogRecord is the main logging entity that captures all events
/// Designed for offline-first with full sync capability
///
/// Based on Domain Model 4.2.2 - Log Entry
class LogRecord {
  int id = 0;

  // ===== IDENTITY =====

  /// Stable identifier across local and Firestore (UUID/ULID)
  late String logId;

  /// Account that owns this log
  late String accountId;

  // ===== TIME =====

  /// When the event actually happened (used for charts and analytics)
  late DateTime eventAt;

  /// When this record was created locally
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  // ===== EVENT PAYLOAD =====

  /// Type of event being logged
  late EventType eventType;

  /// Duration value in seconds (required per domain model)
  late double duration;

  /// Unit of measurement for the value
  late Unit unit;

  /// Optional notes/description
  String? note;

  /// Reason for this log entry (optional context)
  LogReason? reason;

  /// Mood rating scale (0-10, nullable) - maps to moodRating in domain model
  double? moodRating;

  /// Physical rating scale (0-10, nullable) - maps to physicalRating in domain model
  double? physicalRating;

  // ===== LOCATION =====

  /// Latitude coordinate (WGS84 decimal degrees, -90 to 90)
  double? latitude;

  /// Longitude coordinate (WGS84 decimal degrees, -180 to 180)
  double? longitude;

  // ===== QUALITY / METADATA =====

  /// Source of this record
  late Source source;

  /// Device identifier where this was created
  String? deviceId;

  /// App version that created this record
  String? appVersion;

  /// Time confidence level (for clock skew handling)
  late TimeConfidence timeConfidence;

  // ===== LIFECYCLE =====

  /// Soft delete flag
  late bool isDeleted;

  /// When this record was deleted (if applicable)
  DateTime? deletedAt;

  // ===== SYNC =====

  /// Current sync state
  late SyncState syncState;

  /// Error message from last sync attempt
  String? syncError;

  /// When this record was successfully synced to Firestore
  DateTime? syncedAt;

  /// Last update time from Firestore (for conflict resolution)
  DateTime? lastRemoteUpdateAt;

  /// Revision counter for conflict resolution
  int revision;

  LogRecord()
    : duration = 0,
      revision = 0,
      timeConfidence = TimeConfidence.high,
      isDeleted = false;

  LogRecord.create({
    required this.logId,
    required this.accountId,
    DateTime? eventAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.eventType,
    this.duration = 0,
    this.unit = Unit.seconds,
    this.note,
    this.reason,
    this.moodRating,
    this.physicalRating,
    this.latitude,
    this.longitude,
    this.source = Source.manual,
    this.deviceId,
    this.appVersion,
    this.timeConfidence = TimeConfidence.high,
    this.isDeleted = false,
    this.deletedAt,
    this.syncState = SyncState.pending,
    this.syncError,
    this.syncedAt,
    this.lastRemoteUpdateAt,
    this.revision = 0,
  }) {
    this.eventAt = eventAt ?? DateTime.now();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // ===== HELPER METHODS =====

  /// Check if location is set (both coordinates must be present)
  bool get hasLocation => latitude != null && longitude != null;

  /// Mark this record as needing sync
  void markDirty() {
    updatedAt = DateTime.now();
    syncState = SyncState.pending;
    revision++;
  }

  /// Mark as synced
  void markSynced(DateTime remoteUpdateTime) {
    syncState = SyncState.synced;
    syncedAt = DateTime.now();
    lastRemoteUpdateAt = remoteUpdateTime;
    syncError = null;
  }

  /// Mark sync error
  void markSyncError(String error) {
    syncState = SyncState.error;
    syncError = error;
  }

  /// Soft delete
  void softDelete() {
    isDeleted = true;
    deletedAt = DateTime.now();
    markDirty();
  }

  /// Copy with method for updates
  LogRecord copyWith({
    String? logId,
    String? accountId,
    DateTime? eventAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    EventType? eventType,
    double? duration,
    Unit? unit,
    String? note,
    LogReason? reason,
    double? moodRating,
    double? physicalRating,
    double? latitude,
    double? longitude,
    Source? source,
    String? deviceId,
    String? appVersion,
    TimeConfidence? timeConfidence,
    bool? isDeleted,
    DateTime? deletedAt,
    SyncState? syncState,
    String? syncError,
    DateTime? syncedAt,
    DateTime? lastRemoteUpdateAt,
    int? revision,
  }) {
    return LogRecord.create(
      logId: logId ?? this.logId,
      accountId: accountId ?? this.accountId,
      eventAt: eventAt ?? this.eventAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventType: eventType ?? this.eventType,
      duration: duration ?? this.duration,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      reason: reason ?? this.reason,
      moodRating: moodRating ?? this.moodRating,
      physicalRating: physicalRating ?? this.physicalRating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      timeConfidence: timeConfidence ?? this.timeConfidence,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      syncError: syncError ?? this.syncError,
      syncedAt: syncedAt ?? this.syncedAt,
      lastRemoteUpdateAt: lastRemoteUpdateAt ?? this.lastRemoteUpdateAt,
      revision: revision ?? this.revision,
    )..id = id;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'logId': logId,
      'accountId': accountId,
      'eventAt': eventAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'eventType': eventType.name,
      'duration': duration,
      'unit': unit.name,
      'note': note,
      'reason': reason?.name,
      'moodRating': moodRating,
      'physicalRating': physicalRating,
      'latitude': latitude,
      'longitude': longitude,
      'source': source.name,
      'deviceId': deviceId,
      'appVersion': appVersion,
      'timeConfidence': timeConfidence.name,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'revision': revision,
    };
  }

  /// Create from Firestore map
  static LogRecord fromFirestore(Map<String, dynamic> data) {
    return LogRecord.create(
      logId: data['logId'] as String,
      accountId: data['accountId'] as String,
      eventAt: DateTime.parse(data['eventAt'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      eventType: EventType.values.firstWhere(
        (e) => e.name == data['eventType'],
        orElse: () => EventType.custom,
      ),
      duration: (data['duration'] as num?)?.toDouble() ?? 0,
      unit: Unit.values.firstWhere(
        (u) => u.name == data['unit'],
        orElse: () => Unit.seconds,
      ),
      note: data['note'] as String?,
      reason:
          data['reason'] != null
              ? LogReason.values.firstWhere(
                (r) => r.name == data['reason'],
                orElse: () => LogReason.other,
              )
              : null,
      moodRating: (data['moodRating'] as num?)?.toDouble(),
      physicalRating: (data['physicalRating'] as num?)?.toDouble(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      source: Source.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => Source.manual,
      ),
      deviceId: data['deviceId'] as String?,
      appVersion: data['appVersion'] as String?,
      timeConfidence: TimeConfidence.values.firstWhere(
        (tc) => tc.name == data['timeConfidence'],
        orElse: () => TimeConfidence.high,
      ),
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
      revision: data['revision'] as int? ?? 0,
      syncState: SyncState.synced,
      lastRemoteUpdateAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
