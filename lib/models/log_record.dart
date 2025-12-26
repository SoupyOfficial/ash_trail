import 'package:isar/isar.dart';
import 'enums.dart';

part 'log_record.g.dart';

/// LogRecord is the main logging entity that captures all events
/// Designed for offline-first with full sync capability
@collection
class LogRecord {
  Id id = Isar.autoIncrement;

  // ===== IDENTITY =====

  /// Stable identifier across local and Firestore (UUID/ULID)
  @Index(unique: true, composite: [CompositeIndex('accountId')])
  late String logId;

  /// Account that owns this log
  @Index()
  late String accountId;

  /// Optional profile within the account
  @Index()
  String? profileId;

  // ===== TIME =====

  /// When the event actually happened (used for charts and analytics)
  @Index()
  late DateTime eventAt;

  /// When this record was created locally
  late DateTime createdAt;

  /// When this record was last updated
  late DateTime updatedAt;

  // ===== EVENT PAYLOAD =====

  /// Type of event being logged
  @Enumerated(EnumType.name)
  @Index()
  late EventType eventType;

  /// Numeric value (e.g., duration in seconds, number of hits)
  double? value;

  /// Unit of measurement for the value
  @Enumerated(EnumType.name)
  late Unit unit;

  /// Optional notes/description
  String? note;

  /// Tags for categorization (stored as comma-separated string)
  String? tagsString;

  // ===== QUALITY / METADATA =====

  /// Source of this record
  @Enumerated(EnumType.name)
  late Source source;

  /// Device identifier where this was created
  String? deviceId;

  /// App version that created this record
  String? appVersion;

  // ===== LIFECYCLE =====

  /// Soft delete flag
  @Index()
  late bool isDeleted;

  /// When this record was deleted (if applicable)
  DateTime? deletedAt;

  // ===== SYNC =====

  /// Current sync state
  @Enumerated(EnumType.name)
  @Index()
  late SyncState syncState;

  /// Error message from last sync attempt
  String? syncError;

  /// When this record was successfully synced to Firestore
  DateTime? syncedAt;

  /// Last update time from Firestore (for conflict resolution)
  DateTime? lastRemoteUpdateAt;

  /// Session ID for grouping related logs
  String? sessionId;

  /// Dirty fields tracking (comma-separated list of changed fields)
  String? dirtyFields;

  /// Revision counter for conflict resolution
  int revision;

  // ===== RICH METADATA =====

  /// Location context (e.g., home, work, other)
  String? location;

  /// Mood scale (0-10, nullable)
  double? mood;

  /// Craving scale (0-10, nullable)
  double? craving;

  /// Time confidence level (for clock skew handling)
  @Enumerated(EnumType.name)
  late TimeConfidence timeConfidence;

  /// Edit history (JSON string storing revision history)
  String? editHistory;

  /// Flag to mark this as a template
  late bool isTemplate;

  /// Template name if this is a template
  String? templateName;

  LogRecord()
    : revision = 0,
      timeConfidence = TimeConfidence.high,
      isTemplate = false;

  LogRecord.create({
    required this.logId,
    required this.accountId,
    this.profileId,
    DateTime? eventAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.eventType,
    this.value,
    this.unit = Unit.none,
    this.note,
    this.tagsString,
    this.source = Source.manual,
    this.deviceId,
    this.appVersion,
    this.isDeleted = false,
    this.deletedAt,
    this.syncState = SyncState.pending,
    this.syncError,
    this.syncedAt,
    this.lastRemoteUpdateAt,
    this.sessionId,
    this.dirtyFields,
    this.revision = 0,
    this.location,
    this.mood,
    this.craving,
    this.timeConfidence = TimeConfidence.high,
    this.editHistory,
    this.isTemplate = false,
    this.templateName,
  }) {
    this.eventAt = eventAt ?? DateTime.now();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // ===== HELPER METHODS =====

  /// Get tags as a list
  List<String> get tags {
    if (tagsString == null || tagsString!.isEmpty) {
      return [];
    }
    return tagsString!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Set tags from a list
  set tags(List<String> tagList) {
    tagsString = tagList.join(',');
  }

  /// Mark this record as needing sync
  void markDirty([List<String>? changedFields]) {
    updatedAt = DateTime.now();
    syncState = SyncState.pending;
    revision++;

    if (changedFields != null && changedFields.isNotEmpty) {
      final currentDirty = dirtyFields?.split(',').toSet() ?? <String>{};
      currentDirty.addAll(changedFields);
      dirtyFields = currentDirty.join(',');
    }
  }

  /// Mark as synced
  void markSynced(DateTime remoteUpdateTime) {
    syncState = SyncState.synced;
    syncedAt = DateTime.now();
    lastRemoteUpdateAt = remoteUpdateTime;
    syncError = null;
    dirtyFields = null;
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
    markDirty(['isDeleted', 'deletedAt']);
  }

  /// Copy with method for updates
  LogRecord copyWith({
    String? logId,
    String? accountId,
    String? profileId,
    DateTime? eventAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    EventType? eventType,
    double? value,
    Unit? unit,
    String? note,
    String? tagsString,
    Source? source,
    String? deviceId,
    String? appVersion,
    bool? isDeleted,
    DateTime? deletedAt,
    SyncState? syncState,
    String? syncError,
    DateTime? syncedAt,
    DateTime? lastRemoteUpdateAt,
    String? sessionId,
    String? dirtyFields,
    int? revision,
    String? location,
    double? mood,
    double? craving,
    TimeConfidence? timeConfidence,
    String? editHistory,
    bool? isTemplate,
    String? templateName,
  }) {
    return LogRecord.create(
      logId: logId ?? this.logId,
      accountId: accountId ?? this.accountId,
      profileId: profileId ?? this.profileId,
      eventAt: eventAt ?? this.eventAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventType: eventType ?? this.eventType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      tagsString: tagsString ?? this.tagsString,
      source: source ?? this.source,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      syncError: syncError ?? this.syncError,
      syncedAt: syncedAt ?? this.syncedAt,
      lastRemoteUpdateAt: lastRemoteUpdateAt ?? this.lastRemoteUpdateAt,
      sessionId: sessionId ?? this.sessionId,
      dirtyFields: dirtyFields ?? this.dirtyFields,
      revision: revision ?? this.revision,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      craving: craving ?? this.craving,
      timeConfidence: timeConfidence ?? this.timeConfidence,
      editHistory: editHistory ?? this.editHistory,
      isTemplate: isTemplate ?? this.isTemplate,
      templateName: templateName ?? this.templateName,
    )..id = id;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'logId': logId,
      'accountId': accountId,
      'profileId': profileId,
      'eventAt': eventAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'eventType': eventType.name,
      'value': value,
      'unit': unit.name,
      'note': note,
      'tags': tags,
      'source': source.name,
      'deviceId': deviceId,
      'appVersion': appVersion,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'sessionId': sessionId,
      'revision': revision,
      'location': location,
      'mood': mood,
      'craving': craving,
      'timeConfidence': timeConfidence.name,
      'editHistory': editHistory,
      'isTemplate': isTemplate,
      'templateName': templateName,
    };
  }

  /// Create from Firestore map
  static LogRecord fromFirestore(Map<String, dynamic> data) {
    return LogRecord.create(
      logId: data['logId'] as String,
      accountId: data['accountId'] as String,
      profileId: data['profileId'] as String?,
      eventAt: DateTime.parse(data['eventAt'] as String),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      eventType: EventType.values.firstWhere(
        (e) => e.name == data['eventType'],
        orElse: () => EventType.custom,
      ),
      value: (data['value'] as num?)?.toDouble(),
      unit: Unit.values.firstWhere(
        (u) => u.name == data['unit'],
        orElse: () => Unit.none,
      ),
      note: data['note'] as String?,
      tagsString: (data['tags'] as List<dynamic>?)?.join(','),
      source: Source.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => Source.manual,
      ),
      deviceId: data['deviceId'] as String?,
      appVersion: data['appVersion'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
      sessionId: data['sessionId'] as String?,
      revision: data['revision'] as int? ?? 0,
      syncState: SyncState.synced,
      lastRemoteUpdateAt: DateTime.parse(data['updatedAt'] as String),
      location: data['location'] as String?,
      mood: (data['mood'] as num?)?.toDouble(),
      craving: (data['craving'] as num?)?.toDouble(),
      timeConfidence: TimeConfidence.values.firstWhere(
        (tc) => tc.name == data['timeConfidence'],
        orElse: () => TimeConfidence.high,
      ),
      editHistory: data['editHistory'] as String?,
      isTemplate: data['isTemplate'] as bool? ?? false,
      templateName: data['templateName'] as String?,
    );
  }
}
