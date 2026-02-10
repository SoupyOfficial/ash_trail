# hive_database_service

> **Source:** `lib/services/hive_database_service.dart`

## Purpose

Concrete Hive-based implementation of `DatabaseService`. Manages initialization and lifecycle of all Hive boxes used across the application. Singleton pattern ensures a single database instance. Supports all platforms (web via IndexedDB, mobile/desktop via native storage).

## Dependencies

- `database_service.dart` — Abstract `DatabaseService` interface
- `package:hive_flutter/hive_flutter.dart` — Hive database with Flutter initialization
- `../logging/app_logger.dart` — Structured logging via `AppLogger`

## Pseudo-Code

### Class: HiveDatabaseService implements DatabaseService

#### Fields
- `_log` — static logger tagged `'HiveDatabaseService'`
- `_instance` — static singleton (private constructor + factory)
- `_initialized` — bool flag (starts `false`)
- Hive box references (all nullable `Box?`):
  - `_accountsBox`, `_logEntriesBox`, `_logRecordsBox`
  - `_profilesBox`, `_userAccountsBox`, `_dailyRollupsBox`
  - `_sessionsBox`, `_templatesBox`

#### Constructor (Singleton)

```
HiveDatabaseService._internal()   // private constructor

static instance → _instance
factory HiveDatabaseService() → _instance
```

---

#### `initialize() → Future<void>`

```
IF _initialized:
  LOG 'Already initialized, skipping'
  RETURN

LOG 'Initializing Hive database'
AWAIT Hive.initFlutter()

_accountsBox     = AWAIT Hive.openBox('accounts')
_logEntriesBox   = AWAIT Hive.openBox('log_entries')
_logRecordsBox   = AWAIT Hive.openBox('log_records')
_profilesBox     = AWAIT Hive.openBox('profiles')
_userAccountsBox = AWAIT Hive.openBox('user_accounts')
_dailyRollupsBox = AWAIT Hive.openBox('daily_rollups')
_sessionsBox     = AWAIT Hive.openBox('sessions')
_templatesBox    = AWAIT Hive.openBox('templates')

_initialized = true
LOG 'All Hive boxes opened successfully'
```

---

#### `isInitialized → bool`

```
RETURN _initialized
```

---

#### `boxes → dynamic`

```
IF NOT _initialized:
  LOG ERROR 'Database not initialized - call initialize() first'
  THROW Exception('Database not initialized')

RETURN {
  'accounts':     _accountsBox,
  'logEntries':   _logEntriesBox,
  'logRecords':   _logRecordsBox,
  'profiles':     _profilesBox,
  'userAccounts': _userAccountsBox,
  'dailyRollups': _dailyRollupsBox,
  'sessions':     _sessionsBox,
  'templates':    _templatesBox,
}
```

---

#### `close() → Future<void>`

```
AWAIT _accountsBox?.close()
AWAIT _logEntriesBox?.close()
AWAIT _logRecordsBox?.close()
AWAIT _profilesBox?.close()
AWAIT _userAccountsBox?.close()
AWAIT _dailyRollupsBox?.close()
AWAIT _sessionsBox?.close()
AWAIT _templatesBox?.close()

_initialized = false
```
