



class Account {
  int id = 0;

  
  late String userId; // Firebase UID or custom user identifier

  late String email;

  String? displayName;

  String? photoUrl;

  
  late bool isActive; // Currently selected account for logging

  late DateTime createdAt;

  DateTime? lastSyncedAt;

  // Session management fields
  String? accessToken;
  String? refreshToken;
  DateTime? tokenExpiresAt;

  Account();

  Account.create({
    required this.userId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isActive = false,
    DateTime? createdAt,
    this.lastSyncedAt,
    this.accessToken,
    this.refreshToken,
    this.tokenExpiresAt,
  }) {
    this.createdAt = createdAt ?? DateTime.now();
  }
}
