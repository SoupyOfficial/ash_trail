# web_models

> **Source:** `lib/models/web_models.dart`

## Purpose

Web-compatible data classes without Isar dependencies. Simple serializable models (`WebAccount`, `WebLogRecord`, `WebUserAccount`) for JSON transport and web platform support. Each class has `toJson()` and `fromJson()` factory methods.

## Dependencies

None (standalone model — no external packages)

## Pseudo-Code

### Class: WebAccount

```
CLASS WebAccount

  FIELDS (final):
    id: String
    userId: String
    email: String
    displayName: String?
    photoUrl: String?
    isActive: bool
    isLoggedIn: bool = false
    authProvider: String = "email"
    createdAt: DateTime
    updatedAt: DateTime
    lastAccessedAt: DateTime?
    refreshToken: String?
    accessToken: String?
    tokenExpiresAt: DateTime?

  FUNCTION toJson() -> Map<String, dynamic>
    RETURN {
      all fields mapped directly,
      DateTime fields → ISO8601 strings,
      nullable DateTime fields → ISO8601 or null
    }
  END FUNCTION

  FACTORY WebAccount.fromJson(json: Map)
    PARSE all fields:
      isActive default true
      isLoggedIn default false
      authProvider default "email"
      DateTime fields via DateTime.parse()
      Nullable DateTime fields → parse if not null
    RETURN WebAccount(...)
  END FACTORY

END CLASS
```

### Class: WebLogRecord

```
CLASS WebLogRecord

  FIELDS (final):
    id: String
    accountId: String
    eventType: String
    eventAt: DateTime
    duration: double
    unit: String?
    note: String?
    reasons: List<String>?
    moodRating: double?
    physicalRating: double?
    latitude: double?
    longitude: double?
    isDeleted: bool
    createdAt: DateTime
    updatedAt: DateTime

  FUNCTION toJson() -> Map<String, dynamic>
    RETURN { all fields, DateTime → ISO8601 }
  END FUNCTION

  FACTORY WebLogRecord.fromJson(json: Map)
    PARSE all fields:
      duration: cast num to double, default 0
      moodRating, physicalRating: cast num to double or null
      latitude, longitude: cast num to double or null
      reasons: cast List to List<String> or null
      isDeleted default false
    RETURN WebLogRecord(...)
  END FACTORY

END CLASS
```

### Class: WebUserAccount

```
CLASS WebUserAccount

  FIELDS (final):
    id: String
    userId: String
    displayName: String
    avatarUrl: String?
    createdAt: DateTime

  FUNCTION toJson() -> Map<String, dynamic>
    RETURN { id, userId, displayName, avatarUrl, createdAt ISO8601 }
  END FUNCTION

  FACTORY WebUserAccount.fromJson(json: Map)
    PARSE all fields, DateTime.parse for createdAt
    RETURN WebUserAccount(...)
  END FACTORY

END CLASS
```
