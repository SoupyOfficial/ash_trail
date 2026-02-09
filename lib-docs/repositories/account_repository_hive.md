# account_repository_hive

> **Source:** `lib/repositories/account_repository_hive.dart`

## Purpose

Hive-backed implementation of `AccountRepository`. Uses a singleton pattern with an internal Hive `Box` for persistent storage. Converts between `Account` and `WebAccount` for JSON serialization. Maintains a broadcast `StreamController` for reactive updates triggered by Hive box changes.

## Dependencies

- `dart:async` — StreamController, StreamSubscription
- `package:hive/hive.dart` — Hive Box for local storage
- `../logging/app_logger.dart` — Structured logging
- `../models/account.dart` — Account model
- `../models/web_models.dart` — WebAccount for JSON serialization
- `../models/model_converters.dart` — AccountWebConversion extension
- `account_repository.dart` — AccountRepository interface

## Pseudo-Code

### Class: AccountRepositoryHive (implements AccountRepository)

```
CLASS AccountRepositoryHive IMPLEMENTS AccountRepository

  STATIC _instance: AccountRepositoryHive? (singleton)
  _box: Hive Box (late)
  _controller: StreamController<List<Account>> (broadcast)
  _initialEmitted: bool = false

  // ── Factory Constructor (singleton) ──

  FACTORY AccountRepositoryHive(boxes: Map)
    IF _instance IS null THEN
      _instance = AccountRepositoryHive._internal(boxes)
    RETURN _instance
  END FACTORY

  // ── Internal Constructor ──

  CONSTRUCTOR _internal(boxes: Map)
    SET _box = boxes['accounts'] as Box
    CREATE _controller as broadcast StreamController:
      onListen: emit initial data if not already emitted
      onCancel: log
    SUBSCRIBE to _box.watch() → call _emitChanges on every change
    CALL _emitChanges()                  // initial emission
    SCHEDULE delayed re-emission after 100ms (ensures listeners receive data)
  END CONSTRUCTOR

  // ── Change Notification ──

  PRIVATE FUNCTION _emitChanges() -> void
    IF _controller is closed THEN RETURN
    CALL getAll() with 5-second timeout
      ON TIMEOUT: return empty list
    THEN add accounts to _controller
    CATCH: add error to _controller
  END FUNCTION

  // ── CRUD Operations ──

  ASYNC FUNCTION getAll() -> List<Account>
    FOR EACH key IN _box.keys
      TRY
        PARSE json from _box.get(key)
        CONVERT WebAccount.fromJson(json) → Account via AccountWebConversion
        ADD to accounts list
      CATCH
        LOG error for key, skip corrupt entry
      END TRY
    END FOR
    RETURN accounts
  END FUNCTION

  ASYNC FUNCTION getByUserId(userId: String) -> Account?
    FOR EACH key IN _box.keys
      PARSE json → WebAccount
      IF webAccount.userId == userId THEN
        CONVERT and RETURN Account
      END IF
    END FOR
    RETURN null
  END FUNCTION

  ASYNC FUNCTION getActive() -> Account?
    FOR EACH key IN _box.keys
      PARSE json → WebAccount
      IF webAccount.isActive THEN
        CONVERT and RETURN Account
      END IF
    END FOR
    RETURN null
  END FUNCTION

  ASYNC FUNCTION save(account: Account) -> Account
    CONVERT account → WebAccount → JSON
    PUT json into _box using account.userId as key
    CALL _emitChanges()    // immediate notification
    RETURN account
  END FUNCTION

  ASYNC FUNCTION delete(userId: String) -> void
    DELETE from _box using userId as key
    CALL _emitChanges()
  END FUNCTION

  ASYNC FUNCTION setActive(userId: String) -> void
    COLLECT all box keys
    FOR EACH key:
      PARSE existing WebAccount
      SET isActive = (userId matches this account)
      IF is target account THEN SET lastAccessedAt = now
      SET updatedAt = now
      PUT updated JSON back
    END FOR
    CALL _emitChanges()
  END FUNCTION

  ASYNC FUNCTION clearActive() -> void
    FOR EACH key:
      PARSE existing WebAccount
      SET isActive = false
      PRESERVE isLoggedIn state (for multi-account)
      SET updatedAt = now
      PUT updated JSON back
    END FOR
    CALL _emitChanges()
  END FUNCTION

  // ── Stream Methods ──

  FUNCTION watchActive() -> Stream<Account?>
    MAP _controller.stream:
      TRY find first account WHERE isActive
      CATCH: return null
    RETURN mapped stream
  END FUNCTION

  FUNCTION watchAll() -> Stream<List<Account>>
    RETURN _controller.stream with error handling
  END FUNCTION

END CLASS
```
