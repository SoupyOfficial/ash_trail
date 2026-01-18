import '../models/account.dart';
import '../models/log_record.dart';
import '../models/web_models.dart';
import '../models/enums.dart';

/// Extensions to convert between Isar models and web models

extension AccountWebConversion on Account {
  WebAccount toWebModel() {
    return WebAccount(
      id: id.toString(),
      userId: userId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      isActive: isActive,
      isLoggedIn: isLoggedIn,
      authProvider: authProvider.name,
      createdAt: createdAt,
      updatedAt: lastSyncedAt ?? createdAt,
      lastAccessedAt: lastAccessedAt,
      refreshToken: refreshToken,
      accessToken: accessToken,
      tokenExpiresAt: tokenExpiresAt,
    );
  }

  static Account fromWebModel(WebAccount web, {int? id}) {
    return Account.create(
      userId: web.userId,
      email: web.email,
      displayName: web.displayName,
      photoUrl: web.photoUrl,
      isActive: web.isActive,
      isLoggedIn: web.isLoggedIn,
      authProvider: AuthProvider.values.firstWhere(
        (p) => p.name == web.authProvider,
        orElse: () => AuthProvider.anonymous,
      ),
      createdAt: web.createdAt,
      lastSyncedAt: web.updatedAt,
      lastAccessedAt: web.lastAccessedAt,
      refreshToken: web.refreshToken,
      accessToken: web.accessToken,
      tokenExpiresAt: web.tokenExpiresAt,
    )..id = id ?? 0;
  }
}

extension LogRecordWebConversion on LogRecord {
  WebLogRecord toWebModel() {
    return WebLogRecord(
      id: logId,
      accountId: accountId,
      eventType: eventType.name,
      eventAt: eventAt,
      duration: duration,
      unit: unit.name,
      note: note,
      reasons: reasons?.map((r) => r.name).toList(),
      moodRating: moodRating,
      physicalRating: physicalRating,
      latitude: latitude,
      longitude: longitude,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static LogRecord fromWebModel(
    WebLogRecord web, {
    int? id,
    Map<String, dynamic>? extraFields,
  }) {
    return LogRecord.create(
        logId: web.id,
        accountId: web.accountId,
        eventType: EventType.values.firstWhere(
          (e) => e.name == web.eventType,
          orElse: () => EventType.inhale,
        ),
        eventAt: web.eventAt,
        createdAt: web.createdAt,
        updatedAt: web.updatedAt,
        duration: web.duration,
        unit: Unit.values.firstWhere(
          (u) => u.name == web.unit,
          orElse: () => Unit.seconds,
        ),
        note: web.note,
        reasons:
            web.reasons
                ?.map(
                  (r) => LogReason.values.firstWhere(
                    (reason) => reason.name == r,
                    orElse: () => LogReason.other,
                  ),
                )
                .toList(),
        moodRating: web.moodRating,
        physicalRating: web.physicalRating,
        latitude: web.latitude,
        longitude: web.longitude,
        source: Source.manual,
        deviceId: null,
        appVersion: null,
        syncState: SyncState.values.firstWhere(
          (s) => s.name == (extraFields?['syncState'] ?? 'pending'),
          orElse: () => SyncState.pending,
        ),
      )
      ..id = id ?? 0
      ..isDeleted = web.isDeleted
      ..deletedAt =
          extraFields?['deletedAt'] != null
              ? DateTime.parse(extraFields!['deletedAt'])
              : null
      ..revision = extraFields?['revision'] ?? 0
      ..syncedAt =
          extraFields?['syncedAt'] != null
              ? DateTime.parse(extraFields!['syncedAt'])
              : null
      ..syncError = extraFields?['syncError'] as String?
      ..lastRemoteUpdateAt =
          extraFields?['lastRemoteUpdateAt'] != null
              ? DateTime.parse(extraFields!['lastRemoteUpdateAt'])
              : null;
  }
}
