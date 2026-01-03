// Web-compatible models without Isar dependencies
// These are simple data classes that can be serialized to/from JSON

class WebAccount {
  final String id;
  final String userId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebAccount({
    required this.id,
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WebAccount.fromJson(Map<String, dynamic> json) => WebAccount(
    id: json['id'],
    userId: json['userId'],
    email: json['email'],
    displayName: json['displayName'],
    photoUrl: json['photoUrl'],
    isActive: json['isActive'] ?? true,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class WebLogRecord {
  final String id;
  final String accountId;
  final String eventType;
  final DateTime eventAt;
  final double duration;
  final String? unit;
  final String? note;
  final List<String>? reasons;
  final double? moodRating;
  final double? physicalRating;
  final double? latitude;
  final double? longitude;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebLogRecord({
    required this.id,
    required this.accountId,
    required this.eventType,
    required this.eventAt,
    required this.duration,
    this.unit,
    this.note,
    this.reasons,
    this.moodRating,
    this.physicalRating,
    this.latitude,
    this.longitude,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'eventType': eventType,
    'eventAt': eventAt.toIso8601String(),
    'duration': duration,
    'unit': unit,
    'note': note,
    'reasons': reasons,
    'moodRating': moodRating,
    'physicalRating': physicalRating,
    'latitude': latitude,
    'longitude': longitude,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WebLogRecord.fromJson(Map<String, dynamic> json) => WebLogRecord(
    id: json['id'],
    accountId: json['accountId'],
    eventType: json['eventType'],
    eventAt: DateTime.parse(json['eventAt']),
    duration: (json['duration'] as num?)?.toDouble() ?? 0,
    unit: json['unit'],
    note: json['note'],
    reasons: (json['reasons'] as List?)?.map((e) => e as String).toList(),
    moodRating: (json['moodRating'] as num?)?.toDouble(),
    physicalRating: (json['physicalRating'] as num?)?.toDouble(),
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    isDeleted: json['isDeleted'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class WebUserAccount {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  WebUserAccount({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WebUserAccount.fromJson(Map<String, dynamic> json) => WebUserAccount(
    id: json['id'],
    userId: json['userId'],
    displayName: json['displayName'],
    avatarUrl: json['avatarUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
