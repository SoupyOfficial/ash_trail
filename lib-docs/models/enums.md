# enums

> **Source:** `lib/models/enums.dart`

## Purpose

Central enum definitions for all domain concepts in the app: event types, units of measurement, data sources, sync states, auth providers, time confidence, analytics range/grouping, and log reasons. Includes a `LogReasonExtension` providing display names and Material icons for each reason.

## Dependencies

- `package:flutter/material.dart` — IconData for LogReason icons

## Pseudo-Code

### Enum: EventType

```
ENUM EventType
  vape           — vaping session
  inhale         — single inhale/hit
  sessionStart   — start of a session
  sessionEnd     — end of a session
  note           — general observation
  purchase       — purchase tracking
  tolerance      — tolerance note
  symptomRelief  — medical symptom tracking
  custom         — user-defined event
END ENUM
```

### Enum: Unit

```
ENUM Unit
  seconds, minutes   — duration
  hits               — number of inhales
  mg, grams, ml      — weight/volume
  count              — generic count
  none               — no unit
END ENUM
```

### Enum: Source

```
ENUM Source
  manual      — manually entered
  imported    — imported from external source
  automation  — auto-generated
  migration   — migrated from old system
END ENUM
```

### Enum: SyncState

```
ENUM SyncState
  pending   — waiting to sync
  syncing   — currently syncing
  synced    — successfully synced
  error     — sync error
  conflict  — conflict detected
END ENUM
```

### Enum: AuthProvider

```
ENUM AuthProvider
  gmail      — Google Sign-In
  apple      — Apple Sign-In
  email      — Email/password
  devStatic  — Development static account
END ENUM
```

### Enum: TimeConfidence

```
ENUM TimeConfidence
  high    — device time trusted
  medium  — minor discrepancy detected
  low     — significant clock skew or manual backdate
END ENUM
```

### Enum: RangeType

```
ENUM RangeType
  today, yesterday, week, month, quarter, year, ytd, custom, all
END ENUM
```

### Enum: GroupBy

```
ENUM GroupBy
  hour, day, week, month, quarter, year
END ENUM
```

### Enum: LogReason

```
ENUM LogReason
  medical, recreational, social, stress, habit, sleep, pain, other
END ENUM
```

### Extension: LogReasonExtension on LogReason

```
EXTENSION LogReasonExtension ON LogReason

  GETTER displayName -> String
    SWITCH this:
      medical      -> "Medical"
      recreational -> "Recreational"
      social       -> "Social"
      stress       -> "Stress Relief"
      habit        -> "Habit"
      sleep        -> "Sleep Aid"
      pain         -> "Pain Management"
      other        -> "Other"
    END SWITCH
  END GETTER

  GETTER icon -> IconData
    SWITCH this:
      medical      -> Icons.medical_services
      recreational -> Icons.celebration
      social       -> Icons.people
      stress       -> Icons.spa
      habit        -> Icons.repeat
      sleep        -> Icons.bedtime
      pain         -> Icons.healing
      other        -> Icons.more_horiz
    END SWITCH
  END GETTER

END EXTENSION
```
