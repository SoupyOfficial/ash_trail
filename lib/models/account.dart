import 'enums.dart';

/// Account represents a user identity in the system per design doc 4.2.1
/// Supports multi-account sessions - multiple accounts can be logged in simultaneously
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

  /// Currently selected account for viewing/logging data
  /// In multi-account mode, this indicates which account's data is displayed
  late bool isActive;

  /// Whether this account has a valid authenticated session
  /// Multiple accounts can be logged in (isLoggedIn=true) simultaneously
  /// but only one is active (isActive=true) for data viewing
  late bool isLoggedIn;

  late DateTime createdAt;

  /// Last modified timestamp per design doc 4.2.1
  DateTime? lastModifiedAt;

  DateTime? lastSyncedAt;

  /// Last time this account was actively used (for session ordering)
  DateTime? lastAccessedAt;

  /// Currently active profile ID (if using multiple profiles)
  String? activeProfileId;

  // Session management fields
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiresAt;

  /// Default constructor - initializes all late fields to safe defaults
  /// Use Account.create() for creating new accounts with proper values
  Account() {
    userId = '';
    email = '';
    authProvider = AuthProvider.anonymous;
    isActive = false;
    isLoggedIn = false;
    createdAt = DateTime.now();
  }

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
    this.isLoggedIn = false,
    DateTime? createdAt,
    this.lastModifiedAt,
    this.lastSyncedAt,
    this.lastAccessedAt,
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
    bool? isLoggedIn,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    DateTime? lastSyncedAt,
    DateTime? lastAccessedAt,
    String? activeProfileId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) {
    final account = Account.create(
      userId: userId ?? this.userId,
      remoteId: remoteId ?? this.remoteId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      isActive: isActive ?? this.isActive,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      activeProfileId: activeProfileId ?? this.activeProfileId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
    );
    account.id = id;
    return account;
  }

  /// Check if this is an anonymous account
  bool get isAnonymous => authProvider == AuthProvider.anonymous;

  /// Check if session is valid (has refresh token that hasn't expired)
  bool get hasValidSession {
    if (isAnonymous) return isLoggedIn;
    if (refreshToken == null) return false;
    // If no expiry set, assume valid
    if (tokenExpiresAt == null) return true;
    return tokenExpiresAt!.isAfter(DateTime.now());
  }

  /// Get full name from firstName and lastName
  String? get fullName {
    if (firstName == null && lastName == null) return null;
    return [firstName, lastName].whereType<String>().join(' ').trim();
  }
}
