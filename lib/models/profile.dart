import 'package:isar/isar.dart';
import 'enums.dart';

part 'profile.g.dart';

/// Profile represents a persona within a user account
/// Allows one account to have multiple "tracking identities" with different settings
@collection
class Profile {
  Id id = Isar.autoIncrement;

  /// Unique identifier for this profile (UUID)
  @Index(unique: true)
  late String profileId;

  /// Account this profile belongs to
  @Index()
  late String accountId;

  /// Display name for this profile
  late String name;

  /// Optional description
  String? description;

  /// When this profile was created
  late DateTime createdAt;

  /// Last time this profile was updated
  DateTime? updatedAt;

  /// Settings stored as JSON string
  /// Can include: units, default event values, chart preferences, etc.
  String? settingsJson;

  // ===== DEFAULT LOGGING VALUES =====

  /// Default event type for quick logging
  @Enumerated(EnumType.name)
  EventType? defaultEventType;

  /// Default value for quick logging
  double? defaultValue;

  /// Default unit for quick logging
  @Enumerated(EnumType.name)
  Unit? defaultUnit;

  /// Default tags for quick logging (comma-separated)
  String? defaultTagsString;

  /// Default location for quick logging
  String? defaultLocation;

  /// Whether this profile is currently active
  @Index()
  late bool isActive;

  /// Soft delete flag
  late bool isDeleted;

  /// When this profile was deleted (if applicable)
  DateTime? deletedAt;

  Profile();

  Profile.create({
    required this.profileId,
    required this.accountId,
    required this.name,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
    this.settingsJson,
    this.defaultEventType,
    this.defaultValue,
    this.defaultUnit,
    this.defaultTagsString,
    this.defaultLocation,
    this.isActive = false,
    this.isDeleted = false,
    this.deletedAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  // ===== HELPER METHODS =====

  /// Get default tags as a list
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

  /// Set default tags from a list
  set defaultTags(List<String> tagList) {
    defaultTagsString = tagList.join(',');
  }

  /// Copy with method for updates
  Profile copyWith({
    String? profileId,
    String? accountId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? settingsJson,
    EventType? defaultEventType,
    double? defaultValue,
    Unit? defaultUnit,
    String? defaultTagsString,
    String? defaultLocation,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Profile.create(
      profileId: profileId ?? this.profileId,
      accountId: accountId ?? this.accountId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settingsJson: settingsJson ?? this.settingsJson,
      defaultEventType: defaultEventType ?? this.defaultEventType,
      defaultValue: defaultValue ?? this.defaultValue,
      defaultUnit: defaultUnit ?? this.defaultUnit,
      defaultTagsString: defaultTagsString ?? this.defaultTagsString,
      defaultLocation: defaultLocation ?? this.defaultLocation,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    )..id = id;
  }
}
