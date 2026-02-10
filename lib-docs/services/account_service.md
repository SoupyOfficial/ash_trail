# account_service

> **Source:** `lib/services/account_service.dart`

## Purpose

Provides CRUD operations for local Account records via AccountRepository. Serves as the business-logic layer between the UI/integration services and the underlying Hive-based persistence. Supports watching account changes in real-time via streams.

## Dependencies

- `../logging/app_logger.dart` — Structured logging via `AppLogger`
- `../models/account.dart` — Account model
- `../repositories/account_repository.dart` — Repository interface and factory
- `database_service.dart` — Singleton database service for Hive boxes
- `log_record_service.dart` — Used to delete log records when deleting an account

## Pseudo-Code

### Class: AccountService

#### Fields
- `_log` — static logger tagged `'AccountService'`
- `_repository` — `AccountRepository` instance (injected or default)
- `_logRecordService` — `LogRecordService` instance (injected or default)

#### Constructor

```
AccountService({repository?, logRecordService?}):
  _repository = repository ?? _createDefaultRepository()
  _logRecordService = logRecordService ?? new LogRecordService()
  LOG 'Initialized at {now}'
```

#### `_createDefaultRepository() → AccountRepository` (static)

```
dbService = DatabaseService.instance
dbBoxes = dbService.boxes
repo = createAccountRepository(dbBoxes if Map<String,dynamic> else null)
RETURN repo
```

---

#### `getAllAccounts() → Future<List<Account>>`

```
RETURN AWAIT _repository.getAll()
```

---

#### `getActiveAccount() → Future<Account?>`

```
RETURN AWAIT _repository.getActive()
```

---

#### `getAccountByUserId(String userId) → Future<Account?>`

```
RETURN AWAIT _repository.getByUserId(userId)
```

---

#### `saveAccount(Account account) → Future<Account>`

```
RETURN AWAIT _repository.save(account)
```

---

#### `setActiveAccount(String userId) → Future<void>`

```
AWAIT _repository.setActive(userId)
// Deactivates all other accounts, activates this one
```

---

#### `deactivateAllAccounts() → Future<void>`

```
AWAIT _repository.clearActive()
```

---

#### `deleteAccount(String userId) → Future<void>`

```
// Delete all log entries for this account first
AWAIT _logRecordService.deleteAllByAccount(userId)
// Then delete the account
AWAIT _repository.delete(userId)
```

---

#### `watchActiveAccount() → Stream<Account?>`

```
LOG 'watchActiveAccount called'
RETURN _repository.watchActive()
```

---

#### `watchAllAccounts() → Stream<List<Account>>`

```
LOG 'watchAllAccounts called'
RETURN _repository.watchAll()
```

---

#### `accountExists(String userId) → Future<bool>`

```
account = AWAIT _repository.getByUserId(userId)
RETURN account != null
```

---

#### `getAllAccountIds() → Future<Set<String>>`

```
accounts = AWAIT _repository.getAll()
RETURN accounts.map(a → a.userId).toSet()
```
