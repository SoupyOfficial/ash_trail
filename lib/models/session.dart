import 'package:isar/isar.dart';

part 'session.g.dart';

/// Session represents a logging session that groups related log entries
/// Sessions track start/end times and compute aggregate metrics
@collection
class Session {
  Id id = Isar.autoIncrement;

  // ===== IDENTITY =====

  /// Unique identifier for this session (UUID)
  @Index(unique: true, composite: [CompositeIndex('accountId')])
  late String sessionId;

  /// Account that owns this session
  @Index()
  late String accountId;

  /// Optional profile this session is associated with
  @Index()
  String? profileId;

  // ===== TIME =====

  /// When the session started
  @Index()
  late DateTime startedAt;

  /// When the session ended (null if ongoing)
  DateTime? endedAt;

  /// Duration in seconds (computed when session ends)
  int? durationSeconds;

  // ===== CONTENT =====

  /// Session name/title (optional)
  String? name;

  /// Session notes
  String? notes;

  /// Tags for this session (comma-separated)
  String? tagsString;

  /// Location for this session
  String? location;

  // ===== METRICS =====

  /// Number of log entries in this session
  late int entryCount;

  /// Total value summed across all entries
  double? totalValue;

  /// Average value across all entries
  double? averageValue;

  /// Minimum value in session
  double? minValue;

  /// Maximum value in session
  double? maxValue;

  /// Average time between entries (in seconds)
  double? averageIntervalSeconds;

  // ===== LIFECYCLE =====

  /// When this session was created locally
  late DateTime createdAt;

  /// When this session was last updated
  late DateTime updatedAt;

  /// Device identifier where this was created
  String? deviceId;

  /// App version that created this session
  String? appVersion;

  /// Whether this session is currently active
  @Index()
  late bool isActive;

  /// Soft delete flag
  @Index()
  late bool isDeleted;

  /// When this session was deleted
  DateTime? deletedAt;

  Session() : entryCount = 0, isActive = true, isDeleted = false;

  Session.create({
    required this.sessionId,
    required this.accountId,
    this.profileId,
    DateTime? startedAt,
    this.endedAt,
    this.durationSeconds,
    this.name,
    this.notes,
    this.tagsString,
    this.location,
    this.entryCount = 0,
    this.totalValue,
    this.averageValue,
    this.minValue,
    this.maxValue,
    this.averageIntervalSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deviceId,
    this.appVersion,
    this.isActive = true,
    this.isDeleted = false,
    this.deletedAt,
  }) {
    this.startedAt = startedAt ?? DateTime.now();
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

  /// Get current duration (for active sessions)
  @ignore
  Duration get currentDuration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Check if session is ongoing
  @ignore
  bool get isOngoing => isActive && endedAt == null;

  /// End the session
  void end() {
    if (endedAt == null) {
      endedAt = DateTime.now();
      durationSeconds = currentDuration.inSeconds;
      isActive = false;
      updatedAt = DateTime.now();
    }
  }

  /// Update session metrics based on log entries
  void updateMetrics({
    required int count,
    required double? total,
    required double? average,
    required double? min,
    required double? max,
    required double? avgInterval,
  }) {
    entryCount = count;
    totalValue = total;
    averageValue = average;
    minValue = min;
    maxValue = max;
    averageIntervalSeconds = avgInterval;
    updatedAt = DateTime.now();
  }

  /// Soft delete
  void softDelete() {
    isDeleted = true;
    deletedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Copy with method
  Session copyWith({
    String? sessionId,
    String? accountId,
    String? profileId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? name,
    String? notes,
    String? tagsString,
    String? location,
    int? entryCount,
    double? totalValue,
    double? averageValue,
    double? minValue,
    double? maxValue,
    double? averageIntervalSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    String? appVersion,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Session.create(
      sessionId: sessionId ?? this.sessionId,
      accountId: accountId ?? this.accountId,
      profileId: profileId ?? this.profileId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      tagsString: tagsString ?? this.tagsString,
      location: location ?? this.location,
      entryCount: entryCount ?? this.entryCount,
      totalValue: totalValue ?? this.totalValue,
      averageValue: averageValue ?? this.averageValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      averageIntervalSeconds:
          averageIntervalSeconds ?? this.averageIntervalSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    )..id = id;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'accountId': accountId,
      'profileId': profileId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'name': name,
      'notes': notes,
      'tags': tags,
      'location': location,
      'entryCount': entryCount,
      'totalValue': totalValue,
      'averageValue': averageValue,
      'minValue': minValue,
      'maxValue': maxValue,
      'averageIntervalSeconds': averageIntervalSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      'appVersion': appVersion,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore map
  static Session fromFirestore(Map<String, dynamic> data) {
    return Session.create(
      sessionId: data['sessionId'] as String,
      accountId: data['accountId'] as String,
      profileId: data['profileId'] as String?,
      startedAt: DateTime.parse(data['startedAt'] as String),
      endedAt:
          data['endedAt'] != null
              ? DateTime.parse(data['endedAt'] as String)
              : null,
      durationSeconds: data['durationSeconds'] as int?,
      name: data['name'] as String?,
      notes: data['notes'] as String?,
      tagsString: (data['tags'] as List<dynamic>?)?.join(','),
      location: data['location'] as String?,
      entryCount: data['entryCount'] as int? ?? 0,
      totalValue: (data['totalValue'] as num?)?.toDouble(),
      averageValue: (data['averageValue'] as num?)?.toDouble(),
      minValue: (data['minValue'] as num?)?.toDouble(),
      maxValue: (data['maxValue'] as num?)?.toDouble(),
      averageIntervalSeconds:
          (data['averageIntervalSeconds'] as num?)?.toDouble(),
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      deviceId: data['deviceId'] as String?,
      appVersion: data['appVersion'] as String?,
      isActive: data['isActive'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
    );
  }
}
