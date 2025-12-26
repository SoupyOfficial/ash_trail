import 'package:isar/isar.dart';
import 'enums.dart';

part 'log_template.g.dart';

/// LogTemplate represents a preset/template for quick logging
/// Templates allow users to create common logging patterns with default values
@collection
class LogTemplate {
  Id id = Isar.autoIncrement;

  // ===== IDENTITY =====

  /// Unique identifier for this template (UUID)
  @Index(unique: true, composite: [CompositeIndex('accountId')])
  late String templateId;

  /// Account that owns this template
  @Index()
  late String accountId;

  /// Optional profile this template is associated with
  @Index()
  String? profileId;

  // ===== TEMPLATE DEFINITION =====

  /// Display name for this template (e.g., "Morning", "After work", "Before bed")
  late String name;

  /// Optional description
  String? description;

  /// Default event type for this template
  @Enumerated(EnumType.name)
  late EventType eventType;

  /// Default value
  double? defaultValue;

  /// Default unit
  @Enumerated(EnumType.name)
  late Unit unit;

  /// Default note template/stub
  String? noteTemplate;

  /// Default tags (comma-separated)
  String? defaultTagsString;

  /// Default location
  String? defaultLocation;

  /// Icon name/emoji for display
  String? icon;

  /// Color for display (hex string)
  String? color;

  /// Sort order for display
  late int sortOrder;

  // ===== LIFECYCLE =====

  /// When this template was created
  late DateTime createdAt;

  /// When this template was last updated
  DateTime? updatedAt;

  /// Whether this template is active/enabled
  late bool isActive;

  /// Soft delete flag
  late bool isDeleted;

  /// When this template was deleted
  DateTime? deletedAt;

  /// Usage count (how many times this template has been used)
  late int usageCount;

  /// Last time this template was used
  DateTime? lastUsedAt;

  LogTemplate()
    : sortOrder = 0,
      isActive = true,
      isDeleted = false,
      usageCount = 0;

  LogTemplate.create({
    required this.templateId,
    required this.accountId,
    this.profileId,
    required this.name,
    this.description,
    required this.eventType,
    this.defaultValue,
    this.unit = Unit.none,
    this.noteTemplate,
    this.defaultTagsString,
    this.defaultLocation,
    this.icon,
    this.color,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
    this.isDeleted = false,
    this.deletedAt,
    this.usageCount = 0,
    this.lastUsedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  // ===== HELPER METHODS =====

  /// Get tags as a list
  List<String> get defaultTags {
    if (defaultTagsString == null || defaultTagsString!.isEmpty) {
      return [];
    }
    return defaultTagsString!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Set tags from a list
  set defaultTags(List<String> tagList) {
    defaultTagsString = tagList.join(',');
  }

  /// Record template usage
  void recordUsage() {
    usageCount++;
    lastUsedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Soft delete
  void softDelete() {
    isDeleted = true;
    deletedAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Copy with method
  LogTemplate copyWith({
    String? templateId,
    String? accountId,
    String? profileId,
    String? name,
    String? description,
    EventType? eventType,
    double? defaultValue,
    Unit? unit,
    String? noteTemplate,
    String? defaultTagsString,
    String? defaultLocation,
    String? icon,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
    int? usageCount,
    DateTime? lastUsedAt,
  }) {
    return LogTemplate.create(
      templateId: templateId ?? this.templateId,
      accountId: accountId ?? this.accountId,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      eventType: eventType ?? this.eventType,
      defaultValue: defaultValue ?? this.defaultValue,
      unit: unit ?? this.unit,
      noteTemplate: noteTemplate ?? this.noteTemplate,
      defaultTagsString: defaultTagsString ?? this.defaultTagsString,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    )..id = id;
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'templateId': templateId,
      'accountId': accountId,
      'profileId': profileId,
      'name': name,
      'description': description,
      'eventType': eventType.name,
      'defaultValue': defaultValue,
      'unit': unit.name,
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
    };
  }

  /// Create from Firestore map
  static LogTemplate fromFirestore(Map<String, dynamic> data) {
    return LogTemplate.create(
      templateId: data['templateId'] as String,
      accountId: data['accountId'] as String,
      profileId: data['profileId'] as String?,
      name: data['name'] as String,
      description: data['description'] as String?,
      eventType: EventType.values.firstWhere(
        (e) => e.name == data['eventType'],
        orElse: () => EventType.custom,
      ),
      defaultValue: (data['defaultValue'] as num?)?.toDouble(),
      unit: Unit.values.firstWhere(
        (u) => u.name == data['unit'],
        orElse: () => Unit.none,
      ),
      noteTemplate: data['noteTemplate'] as String?,
      defaultTagsString: (data['defaultTags'] as List<dynamic>?)?.join(','),
      defaultLocation: data['defaultLocation'] as String?,
      icon: data['icon'] as String?,
      color: data['color'] as String?,
      sortOrder: data['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt:
          data['updatedAt'] != null
              ? DateTime.parse(data['updatedAt'] as String)
              : null,
      isActive: data['isActive'] as bool? ?? true,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt:
          data['deletedAt'] != null
              ? DateTime.parse(data['deletedAt'] as String)
              : null,
      usageCount: data['usageCount'] as int? ?? 0,
      lastUsedAt:
          data['lastUsedAt'] != null
              ? DateTime.parse(data['lastUsedAt'] as String)
              : null,
    );
  }
}
