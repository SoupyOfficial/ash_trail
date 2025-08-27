// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';
part 'sync_state.g.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    required String accountId, // TODO: FK to Account
    DateTime? lastPulledAt,
    DateTime? lastPushedAt,
    String? remoteVersion,
    String? tombstoneWatermark,
    DateTime? backoffUntil,
  }) = _SyncState;

  factory SyncState.fromJson(Map<String, dynamic> json) => _$SyncStateFromJson(json);
}
