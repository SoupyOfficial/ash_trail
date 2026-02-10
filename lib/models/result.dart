/// A typed Result monad for operations that can succeed or fail.
///
/// Per design doc 25.4.3.1, prefer Result types over exceptions for domain
/// logic, validation, and expected failure modes. Use exceptions only for
/// truly unexpected system failures.
///
/// Usage:
/// ```dart
/// Future<Result<LogRecord>> createLog(...) async {
///   try {
///     final record = await repo.save(data);
///     return Result.success(record);
///   } catch (e, st) {
///     return Result.failure(AppError.from(e, st));
///   }
/// }
///
/// // Consuming:
/// final result = await service.createLog(...);
/// result.when(
///   success: (record) => showSuccess(),
///   failure: (error) => showError(error.message),
/// );
/// ```
library;

import 'app_error.dart';

/// Sealed result type – every operation returns either [Success] or [Failure].
sealed class Result<T> {
  const Result();

  /// Create a successful result.
  const factory Result.success(T value) = Success<T>;

  /// Create a failure result.
  const factory Result.failure(AppError error) = Failure<T>;

  /// True when the operation succeeded.
  bool get isSuccess => this is Success<T>;

  /// True when the operation failed.
  bool get isFailure => this is Failure<T>;

  /// Get the value if success, else `null`.
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  /// Get the error if failure, else `null`.
  AppError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  /// Get the value or throw the [AppError].
  T get valueOrThrow => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>(:final error) => throw error,
  };

  /// Pattern-match on success / failure.
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) => switch (this) {
    Success<T>(:final value) => success(value),
    Failure<T>(:final error) => failure(error),
  };

  /// Map the success value while keeping failures unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final value) => Result.success(transform(value)),
    Failure<T>(:final error) => Result.failure(error),
  };

  /// FlatMap (bind) – chain dependent Result operations.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Success<T>(:final value) => transform(value),
    Failure<T>(:final error) => Result.failure(error),
  };
}

/// Successful result.
final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Failed result.
final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  String toString() => 'Failure(${error.toLogString()})';
}
