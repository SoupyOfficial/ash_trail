# account_repository

> **Source:** `lib/repositories/account_repository.dart`

## Purpose

Abstract repository interface defining the data access contract for `Account` entities. Uses the repository pattern to decouple business logic from storage implementation. Provides a factory function that returns the Hive-backed implementation.

## Dependencies

- `../logging/app_logger.dart` — Structured logging
- `../models/account.dart` — Account model
- `account_repository_hive.dart` — Hive implementation

## Pseudo-Code

### Abstract Class: AccountRepository

```
ABSTRACT CLASS AccountRepository

  // ── Query Methods ──

  ASYNC FUNCTION getAll() -> List<Account>
  ASYNC FUNCTION getByUserId(userId: String) -> Account?
  ASYNC FUNCTION getActive() -> Account?

  // ── Mutation Methods ──

  ASYNC FUNCTION save(account: Account) -> Account        // create or update
  ASYNC FUNCTION delete(userId: String) -> void
  ASYNC FUNCTION setActive(userId: String) -> void        // deactivates all others
  ASYNC FUNCTION clearActive() -> void                    // deactivate all

  // ── Stream Methods ──

  FUNCTION watchActive() -> Stream<Account?>
  FUNCTION watchAll() -> Stream<List<Account>>

END ABSTRACT CLASS
```

### Factory Function: createAccountRepository

```
FUNCTION createAccountRepository(context?) -> AccountRepository
  IF context IS null THEN
    LOG warning "Context is NULL - this may cause issues"
  END IF
  RETURN new AccountRepositoryHive(context as Map<String, dynamic>)
END FUNCTION
```
