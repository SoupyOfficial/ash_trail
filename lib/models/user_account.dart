
import 'enums.dart';


/// UserAccount represents a user identity in the system
/// This is the top-level identity that can have multiple profiles

class UserAccount {
  int id = 0;

  /// Unique identifier for the account (UUID/Firebase UID)
  
  late String accountId;

  /// Display name for the user
  late String displayName;

  /// Email address (if applicable)
  String? email;

  /// Authentication provider used
  
  late AuthProvider authProvider;

  /// URL to user's profile photo
  String? photoUrl;

  /// When this account was created
  late DateTime createdAt;

  /// Last time this account was updated
  DateTime? updatedAt;

  /// Currently active profile ID (if using multiple profiles)
  String? activeProfileId;

  /// Whether this is the currently selected account for logging
  
  late bool isActive;

  /// Last successful sync time with Firestore
  DateTime? lastSyncedAt;

  /// Session management fields
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiresAt;

  UserAccount();

  UserAccount.create({
    required this.accountId,
    required this.displayName,
    required this.authProvider,
    this.email,
    this.photoUrl,
    DateTime? createdAt,
    this.updatedAt,
    this.activeProfileId,
    this.isActive = false,
    this.lastSyncedAt,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  /// Copy with method for updates
  UserAccount copyWith({
    String? accountId,
    String? displayName,
    String? email,
    AuthProvider? authProvider,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? activeProfileId,
    bool? isActive,
    DateTime? lastSyncedAt,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return UserAccount.create(
      accountId: accountId ?? this.accountId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      authProvider: authProvider ?? this.authProvider,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    )..id = id;
  }
}
