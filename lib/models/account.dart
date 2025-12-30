import 'enums.dart';

/// Account represents a user identity in the system per design doc 4.2.1
/// Fields: id, remoteId?, email, displayName, firstName?, lastName?,
/// createdAt, lastModifiedAt
class Account {
  int id = 0;

  /// Unique identifier for the account (Firebase UID or custom identifier)
  late String userId;

  /// Remote ID for cloud sync (Firestore document ID)
  String? remoteId;

  late String email;

  String? displayName;

  /// First name per design doc 4.2.1
  String? firstName;

  /// Last name per design doc 4.2.1
  String? lastName;

  String? photoUrl;

  /// Authentication provider used
  late AuthProvider authProvider;

  /// Currently selected account for logging
  late bool isActive;

  late DateTime createdAt;

  /// Last modified timestamp per design doc 4.2.1
  DateTime? lastModifiedAt;

  DateTime? lastSyncedAt;

  /// Currently active profile ID (if using multiple profiles)
  String? activeProfileId;

  // Session management fields
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiresAt;

  Account();

  Account.create({
    required this.userId,
    required this.email,
    this.remoteId,
    this.displayName,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.authProvider = AuthProvider.anonymous,
    this.isActive = false,
    DateTime? createdAt,
    this.lastModifiedAt,
    this.lastSyncedAt,
    this.activeProfileId,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }

  /// Copy with method for immutable updates
  Account copyWith({
    String? userId,
    String? remoteId,
    String? email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    AuthProvider? authProvider,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastSyncedAt,
    String? activeProfileId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    return Account.create(
      userId: userId ?? this.userId,
      remoteId: remoteId ?? this.remoteId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    )..id = id;
  }

  /// Check if this is an anonymous account
  bool get isAnonymous => authProvider == AuthProvider.anonymous;

  /// Get full name from firstName and lastName
  String? get fullName {
    if (firstName == null && lastName == null) return null;
    return [firstName, lastName].whereType<String>().join(' ').trim();
  }
}
