// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime get time => throw _privateConstructorUsedError;
  List<String> get days =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  bool get enabled => throw _privateConstructorUsedError;
  DateTime? get lastTriggeredAt => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call({
    String id,
    String accountId,
    DateTime time,
    List<String> days,
    bool enabled,
    DateTime? lastTriggeredAt,
  });
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? time = null,
    Object? days = null,
    Object? enabled = null,
    Object? lastTriggeredAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            time:
                null == time
                    ? _value.time
                    : time // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            days:
                null == days
                    ? _value.days
                    : days // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            enabled:
                null == enabled
                    ? _value.enabled
                    : enabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            lastTriggeredAt:
                freezed == lastTriggeredAt
                    ? _value.lastTriggeredAt
                    : lastTriggeredAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
    _$ReminderImpl value,
    $Res Function(_$ReminderImpl) then,
  ) = __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    DateTime time,
    List<String> days,
    bool enabled,
    DateTime? lastTriggeredAt,
  });
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
    _$ReminderImpl _value,
    $Res Function(_$ReminderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? time = null,
    Object? days = null,
    Object? enabled = null,
    Object? lastTriggeredAt = freezed,
  }) {
    return _then(
      _$ReminderImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        time:
            null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        days:
            null == days
                ? _value._days
                : days // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        enabled:
            null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        lastTriggeredAt:
            freezed == lastTriggeredAt
                ? _value.lastTriggeredAt
                : lastTriggeredAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl({
    required this.id,
    required this.accountId,
    required this.time,
    required final List<String> days,
    required this.enabled,
    this.lastTriggeredAt,
  }) : _days = days;

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final DateTime time;
  final List<String> _days;
  @override
  List<String> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  // TODO: constrain to enum values
  @override
  final bool enabled;
  @override
  final DateTime? lastTriggeredAt;

  @override
  String toString() {
    return 'Reminder(id: $id, accountId: $accountId, time: $time, days: $days, enabled: $enabled, lastTriggeredAt: $lastTriggeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.lastTriggeredAt, lastTriggeredAt) ||
                other.lastTriggeredAt == lastTriggeredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    time,
    const DeepCollectionEquality().hash(_days),
    enabled,
    lastTriggeredAt,
  );

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(this);
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder({
    required final String id,
    required final String accountId,
    required final DateTime time,
    required final List<String> days,
    required final bool enabled,
    final DateTime? lastTriggeredAt,
  }) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  DateTime get time;
  @override
  List<String> get days; // TODO: constrain to enum values
  @override
  bool get enabled;
  @override
  DateTime? get lastTriggeredAt;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
