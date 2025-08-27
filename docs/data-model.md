# Data Model

This document summarizes the current canonical data model as defined in `feature_matrix.yaml`.

## Key entities (summary)

| Entity           | Important fields (summary)                                                                                          |
| ---------------- | ------------------------------------------------------------------------------------------------------------------ |
| SmokeLog         | id, accountId, ts, durationMs, methodId?, potency?, moodScore (int 1..10), physicalScore (int 1..10), notes?      |
| SmokeLogTag      | id, smokeLogId (fk), tagId (fk), accountId (denorm), ts, createdAt                                               |
| Reason           | id, accountId? (null = global seed), name, enabled, orderIndex, createdAt                                         |
| SmokeLogReason   | id, smokeLogId (fk), reasonId (fk), accountId, ts, createdAt                                                      |
| Tag              | id, accountId, name, color                                                                                         |
| Method           | id, accountId?, name, category                                                                                     |
| SyncOp           | id, accountId, entity (SmokeLog,Prefs,Account,Tag,SmokeLogTag,Method,Reason,SmokeLogReason), op, payload, status  |

Notes:
- Tags are now represented by the `SmokeLogTag` edge table (many-to-many). Do not store tag arrays on `SmokeLog`.
- Reasons are seeded globally with `accountId == null` and can be overridden/extended per account; `SmokeLogReason` implements multi-select reasons per log.
- `mood` enum was replaced with numeric `moodScore` and a new `physicalScore` to allow richer scoring (1..10).
- `method` enum moved to `Method` with `SmokeLog.methodId` as a nullable foreign key.
- `SyncOp.entity` was expanded to track tag- and reason-edge mutations.

## Example Isar/Dart models

SmokeLog (Isar example):

```dart
import 'package:isar/isar.dart';

@collection
class SmokeLog {
  Id id = Isar.autoIncrement;
  late String remoteId; // remote document id
  late String accountId;
  late DateTime ts;
  late int durationMs;
  int? methodId; // FK to Method
  int? potency;
  late int moodScore; // 1..10
  late int physicalScore; // 1..10
  String? notes;
  String? deviceLocalId;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

SmokeLogTag (edge table):

```dart
@collection
class SmokeLogTag {
  Id id = Isar.autoIncrement;
  late String smokeLogId;
  late String tagId;
  late String accountId; // denormalized for partitioned queries
  late DateTime ts; // denorm to filter by date without fetching logs
  late DateTime createdAt;
}
```

SmokeLogReason (multi-select join):

```dart
@collection
class SmokeLogReason {
  Id id = Isar.autoIncrement;
  late String smokeLogId;
  late String reasonId;
  late String accountId;
  late DateTime ts;
  late DateTime createdAt;
}
```

## Sync considerations

- The sync queue (`SyncOp`) now tracks changes for `Tag`, `SmokeLogTag`, `Method`, `Reason`, and `SmokeLogReason` so edges can be reconciled across devices and accounts.
- When migrating from the older schema, migrate any `SmokeLog.tags[]` arrays into `SmokeLogTag` rows and map `mood` enums to numeric `moodScore` values (mapping strategy depends on desired granularity).

---

If you want, I can also generate a small migration script (SQL or pseudo-migration) and a suggested mapping from the old `mood` enum to `moodScore` integers.
