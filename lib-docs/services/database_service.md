# database_service

> **Source:** `lib/services/database_service.dart`

## Purpose

Defines the abstract database service interface used by the application. Acts as a façade over the concrete Hive implementation, allowing different database backends to be swapped in. Currently delegates entirely to `HiveDatabaseService`.

## Dependencies

- `hive_database_service.dart` — Concrete Hive-based implementation

## Pseudo-Code

### Abstract Class: DatabaseService

#### Static Property

```
instance → DatabaseService:
  RETURN HiveDatabaseService.instance
```

#### Abstract Methods

```
initialize() → Future<void>
  // Initialize the database and open all boxes/tables

isInitialized → bool
  // Whether the database has been initialized

close() → Future<void>
  // Close the database and release resources

boxes → dynamic
  // Get the underlying database boxes (Hive boxes map)
```
