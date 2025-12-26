/// Web-compatible models without Isar dependencies
/// These are simple data classes that can be serialized to/from JSON

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
  final String profileId;
  final String eventType;
  final DateTime eventAt;
  final double? value;
  final String? unit;
  final String? note;
  final List<String> tags;
  final String? sessionId;
  final bool isDirty;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebLogRecord({
    required this.id,
    required this.accountId,
    required this.profileId,
    required this.eventType,
    required this.eventAt,
    this.value,
    this.unit,
    this.note,
    required this.tags,
    this.sessionId,
    required this.isDirty,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'accountId': accountId,
    'profileId': profileId,
    'eventType': eventType,
    'eventAt': eventAt.toIso8601String(),
    'value': value,
    'unit': unit,
    'note': note,
    'tags': tags,
    'sessionId': sessionId,
    'isDirty': isDirty,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WebLogRecord.fromJson(Map<String, dynamic> json) => WebLogRecord(
    id: json['id'],
    accountId: json['accountId'],
    profileId: json['profileId'],
    eventType: json['eventType'],
    eventAt: DateTime.parse(json['eventAt']),
    value: json['value']?.toDouble(),
    unit: json['unit'],
    note: json['note'],
    tags: List<String>.from(json['tags'] ?? []),
    sessionId: json['sessionId'],
    isDirty: json['isDirty'] ?? false,
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

class WebProfile {
  final String id;
  final String name;
  final String userAccountId;
  final DateTime createdAt;

  WebProfile({
    required this.id,
    required this.name,
    required this.userAccountId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userAccountId': userAccountId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WebProfile.fromJson(Map<String, dynamic> json) => WebProfile(
    id: json['id'],
    name: json['name'],
    userAccountId: json['userAccountId'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class WebSession {
  final String id;
  final String sessionId;
  final String accountId;
  final String? profileId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String? name;
  final String? notes;
  final List<String> tags;
  final String? location;
  final int entryCount;
  final double? totalValue;
  final double? averageValue;
  final double? minValue;
  final double? maxValue;
  final double? averageIntervalSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deviceId;
  final String? appVersion;
  final bool isActive;
  final bool isDeleted;
  final DateTime? deletedAt;

  WebSession({
    required this.id,
    required this.sessionId,
    required this.accountId,
    this.profileId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.name,
    this.notes,
    required this.tags,
    this.location,
    required this.entryCount,
    this.totalValue,
    this.averageValue,
    this.minValue,
    this.maxValue,
    this.averageIntervalSeconds,
    required this.createdAt,
    required this.updatedAt,
    this.deviceId,
    this.appVersion,
    required this.isActive,
    required this.isDeleted,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
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

  factory WebSession.fromJson(Map<String, dynamic> json) => WebSession(
    id: json['id'],
    sessionId: json['sessionId'],
    accountId: json['accountId'],
    profileId: json['profileId'],
    startedAt: DateTime.parse(json['startedAt']),
    endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
    durationSeconds: json['durationSeconds'],
    name: json['name'],
    notes: json['notes'],
    tags: List<String>.from(json['tags'] ?? []),
    location: json['location'],
    entryCount: json['entryCount'] ?? 0,
    totalValue: json['totalValue']?.toDouble(),
    averageValue: json['averageValue']?.toDouble(),
    minValue: json['minValue']?.toDouble(),
    maxValue: json['maxValue']?.toDouble(),
    averageIntervalSeconds: json['averageIntervalSeconds']?.toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    deviceId: json['deviceId'],
    appVersion: json['appVersion'],
    isActive: json['isActive'] ?? true,
    isDeleted: json['isDeleted'] ?? false,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
  );
}

class WebLogTemplate {
  final String id;
  final String templateId;
  final String accountId;
  final String? profileId;
  final String name;
  final String? description;
  final String eventType;
  final double? defaultValue;
  final String unit;
  final String? noteTemplate;
  final List<String> defaultTags;
  final String? defaultLocation;
  final String? icon;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool isDeleted;
  final DateTime? deletedAt;
  final int usageCount;
  final DateTime? lastUsedAt;
  final bool isFavorite;

  WebLogTemplate({
    required this.id,
    required this.templateId,
    required this.accountId,
    this.profileId,
    required this.name,
    this.description,
    required this.eventType,
    this.defaultValue,
    required this.unit,
    this.noteTemplate,
    required this.defaultTags,
    this.defaultLocation,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.isDeleted,
    this.deletedAt,
    required this.usageCount,
    this.lastUsedAt,
    required this.isFavorite,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'templateId': templateId,
    'accountId': accountId,
    'profileId': profileId,
    'name': name,
    'description': description,
    'eventType': eventType,
    'defaultValue': defaultValue,
    'unit': unit,
    'noteTemplate': noteTemplate,
    'defaultTags': defaultTags,
    'defaultLocation': defaultLocation,
    'icon': icon,
    'color': color,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isActive': isActive,
    'isDeleted': isDeleted,
    'deletedAt': deletedAt?.toIso8601String(),
    'usageCount': usageCount,
    'lastUsedAt': lastUsedAt?.toIso8601String(),
    'isFavorite': isFavorite,
  };

  factory WebLogTemplate.fromJson(Map<String, dynamic> json) => WebLogTemplate(
    id: json['id'],
    templateId: json['templateId'],
    accountId: json['accountId'],
    profileId: json['profileId'],
    name: json['name'],
    description: json['description'],
    eventType: json['eventType'],
    defaultValue: json['defaultValue']?.toDouble(),
    unit: json['unit'] ?? 'none',
    noteTemplate: json['noteTemplate'],
    defaultTags: List<String>.from(json['defaultTags'] ?? []),
    defaultLocation: json['defaultLocation'],
    icon: json['icon'],
    color: json['color'],
    sortOrder: json['sortOrder'] ?? 0,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    isActive: json['isActive'] ?? true,
    isDeleted: json['isDeleted'] ?? false,
    deletedAt:
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    usageCount: json['usageCount'] ?? 0,
    lastUsedAt:
        json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt']) : null,
    isFavorite: json['isFavorite'] ?? false,
  );
}
