import '../models/account.dart';
import '../models/log_record.dart';
import '../models/session.dart';
import '../models/log_template.dart';
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
      createdAt: createdAt,
      updatedAt: lastSyncedAt ?? createdAt,
    );
  }

  static Account fromWebModel(WebAccount web, {int? id}) {
    return Account.create(
      userId: web.userId,
      email: web.email,
      displayName: web.displayName,
      photoUrl: web.photoUrl,
      isActive: web.isActive,
      createdAt: web.createdAt,
      lastSyncedAt: web.updatedAt,
    )..id = id ?? 0;
  }
}

extension LogRecordWebConversion on LogRecord {
  WebLogRecord toWebModel() {
    return WebLogRecord(
      id: logId, // Use logId (UUID) not internal id
      accountId: accountId,
      profileId: profileId ?? '',
      eventType: eventType.name,
      eventAt: eventAt,
      value: value,
      unit: unit.name,
      note: note,
      tags: tags,
      sessionId: sessionId,
      isDirty: dirtyFields != null && dirtyFields!.isNotEmpty,
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
        profileId: web.profileId.isEmpty ? null : web.profileId,
        eventType: EventType.values.firstWhere(
          (e) => e.name == web.eventType,
          orElse: () => EventType.inhale,
        ),
        eventAt: web.eventAt,
        createdAt: web.createdAt,
        updatedAt: web.updatedAt,
        value: web.value,
        unit: Unit.values.firstWhere(
          (u) => u.name == web.unit,
          orElse: () => Unit.none,
        ),
        note: web.note,
        tagsString: web.tags.join(','),
        sessionId: web.sessionId,
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
      ..dirtyFields = extraFields?['dirtyFields'] as String?
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

extension SessionWebConversion on Session {
  WebSession toWebModel() {
    return WebSession(
      id: id.toString(),
      sessionId: sessionId,
      accountId: accountId,
      profileId: profileId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      name: name,
      notes: notes,
      tags: tags,
      location: location,
      entryCount: entryCount,
      totalValue: totalValue,
      averageValue: averageValue,
      minValue: minValue,
      maxValue: maxValue,
      averageIntervalSeconds: averageIntervalSeconds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deviceId: deviceId,
      appVersion: appVersion,
      isActive: isActive,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  static Session fromWebModel(WebSession web, {int? id}) {
    return Session.create(
      sessionId: web.sessionId,
      accountId: web.accountId,
      profileId: web.profileId,
      startedAt: web.startedAt,
      endedAt: web.endedAt,
      durationSeconds: web.durationSeconds,
      name: web.name,
      notes: web.notes,
      tagsString: web.tags.join(','),
      location: web.location,
      entryCount: web.entryCount,
      totalValue: web.totalValue,
      averageValue: web.averageValue,
      minValue: web.minValue,
      maxValue: web.maxValue,
      averageIntervalSeconds: web.averageIntervalSeconds,
      createdAt: web.createdAt,
      updatedAt: web.updatedAt,
      deviceId: web.deviceId,
      appVersion: web.appVersion,
      isActive: web.isActive,
      isDeleted: web.isDeleted,
      deletedAt: web.deletedAt,
    )..id = id ?? 0;
  }
}

extension LogTemplateWebConversion on LogTemplate {
  WebLogTemplate toWebModel() {
    return WebLogTemplate(
      id: id.toString(),
      templateId: templateId,
      accountId: accountId,
      profileId: profileId,
      name: name,
      description: description,
      eventType: eventType.name,
      defaultValue: defaultValue,
      unit: unit.name,
      noteTemplate: noteTemplate,
      defaultTags: defaultTags,
      defaultLocation: defaultLocation,
      icon: icon,
      color: color,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      usageCount: usageCount,
      lastUsedAt: lastUsedAt,
      isFavorite: false, // LogTemplate doesn't have this field in native model
    );
  }

  static LogTemplate fromWebModel(WebLogTemplate web, {int? id}) {
    return LogTemplate.create(
        templateId: web.templateId,
        accountId: web.accountId,
        profileId: web.profileId,
        name: web.name,
        description: web.description,
        eventType: EventType.values.firstWhere(
          (e) => e.name == web.eventType,
          orElse: () => EventType.inhale,
        ),
        defaultValue: web.defaultValue,
        unit: Unit.values.firstWhere(
          (u) => u.name == web.unit,
          orElse: () => Unit.none,
        ),
        noteTemplate: web.noteTemplate,
        defaultTagsString: web.defaultTags.join(','),
        defaultLocation: web.defaultLocation,
        icon: web.icon,
        color: web.color,
        sortOrder: web.sortOrder,
        createdAt: web.createdAt,
      )
      ..id = id ?? 0
      ..updatedAt = web.updatedAt
      ..isActive = web.isActive
      ..isDeleted = web.isDeleted
      ..deletedAt = web.deletedAt
      ..usageCount = web.usageCount
      ..lastUsedAt = web.lastUsedAt;
  }
}
