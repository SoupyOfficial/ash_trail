# result

> **Source:** `lib/models/result.dart`

## Purpose

A typed Result monad for operations that can succeed or fail, per design doc §25.4.3.1. Prefer `Result` types over exceptions for domain logic, validation, and expected failure modes. Use exceptions only for truly unexpected system failures.

## Dependencies

- `app_error.dart` — `AppError` type used in `Failure`

## Pseudo-Code

### Sealed Class: Result\<T\>

```
SEALED CLASS Result<T>

  // ── Factories ──

  FACTORY Result.success(T value) → Success<T>
  FACTORY Result.failure(AppError error) → Failure<T>

  // ── Computed Properties ──

  GETTER isSuccess → bool    // true when this IS Success<T>
  GETTER isFailure → bool    // true when this IS Failure<T>

  GETTER valueOrNull → T?
    Success → value
    Failure → null

  GETTER errorOrNull → AppError?
    Success → null
    Failure → error

  GETTER valueOrThrow → T
    Success → value
    Failure → THROW error

  // ── Pattern Matching ──

  FUNCTION when<R>({success: (T) → R, failure: (AppError) → R}) → R
    Success → success(value)
    Failure → failure(error)

  // ── Functor / Monad ──

  FUNCTION map<R>(transform: (T) → R) → Result<R>
    Success → Result.success(transform(value))
    Failure → Result.failure(error)    // error passes through

  FUNCTION flatMap<R>(transform: (T) → Result<R>) → Result<R>
    Success → transform(value)
    Failure → Result.failure(error)    // error passes through

END
```

### Final Class: Success\<T\> (extends Result\<T\>)

```
FIELDS:
  value: T

toString() → 'Success($value)'
```

### Final Class: Failure\<T\> (extends Result\<T\>)

```
FIELDS:
  error: AppError

toString() → 'Failure(${error.toLogString()})'
```

## Usage Example

```
// Producing:
Future<Result<LogRecord>> createLog(...) async {
  try {
    final record = await repo.save(data);
    return Result.success(record);
  } catch (e, st) {
    return Result.failure(AppError.from(e, st));
  }
}

// Consuming:
final result = await service.createLog(...);
result.when(
  success: (record) => showSuccess(),
  failure: (error) => showError(error.message),
);
```
