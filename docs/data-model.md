# Data Model

## Entities

| Entity    | Fields                                                                                                                      | Source     | Persisted        | Indexes       |
| --------- | --------------------------------------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------------- |
| SmokeLog  | id: string, accountId: string, ts: DateTime, durationMs: int, method?: string, notes?: string, mood?: int, potency?: double | User input | Isar + Firestore | ts, accountId |
| Account   | id: string, displayName: string, photoUrl?: string, lastActiveAt: DateTime                                                  | Auth       | Isar + Firestore | lastActiveAt  |
| ThemePref | accountId: string, accentColor: int, darkMode: bool                                                                         | Local      | Isar             | accountId     |

## Isar Example

```dart
@collection
class SmokeLog {
  Id id = Isar.autoIncrement;
  late String remoteId; // Firestore doc id
  late String accountId;
  late DateTime ts;
  late int durationMs;
  String? method;
  String? notes;
  int? mood; // 1..5
  double? potency; // optional
}
```

---

## Isar Example

```dart
import 'package:isar/isar.dart';
part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;
  late String remoteId;
  late String name;
  DateTime updatedAt = DateTime.now();
}
```
