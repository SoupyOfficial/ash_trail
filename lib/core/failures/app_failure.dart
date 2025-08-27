// Spec Header:
// Core Failure Model
// Provides a sealed hierarchy for surfacing domain/data layer failures to presentation.
// Assumption: Will be extended as features are added; keep constructors const & data minimal.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure {
  const AppFailure._();

  const factory AppFailure.unexpected(
      {String? message, Object? cause, StackTrace? stackTrace}) = _Unexpected;
  const factory AppFailure.network({String? message, int? statusCode}) =
      _Network;
  const factory AppFailure.cache({String? message}) = _Cache;
  const factory AppFailure.validation(
      {required String message, String? field}) = _Validation;
  const factory AppFailure.notFound({String? message, String? resourceId}) =
      _NotFound;
  const factory AppFailure.conflict({String? message}) = _Conflict;

  String get displayMessage => switch (this) {
        _Network() => message ?? 'Network error, please retry.',
        _Cache() => message ?? 'Local storage error.',
        _Validation(message: final m) => m,
        _NotFound() => message ?? 'Requested resource not found.',
        _Conflict() => message ?? 'Update conflict occurred.',
        _Unexpected(message: final m) => m ?? 'Something went wrong.'
      };
}
