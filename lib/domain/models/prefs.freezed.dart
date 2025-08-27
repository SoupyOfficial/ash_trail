// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prefs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Prefs _$PrefsFromJson(Map<String, dynamic> json) {
  return _Prefs.fromJson(json);
}

/// @nodoc
mixin _$Prefs {
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get defaultRange =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get unit =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  bool get analyticsOptIn => throw _privateConstructorUsedError;
  List<DateTime>? get reminderTimes => throw _privateConstructorUsedError;
  String get preferredTheme =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String? get accentColor => throw _privateConstructorUsedError;

  /// Serializes this Prefs to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prefs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrefsCopyWith<Prefs> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrefsCopyWith<$Res> {
  factory $PrefsCopyWith(Prefs value, $Res Function(Prefs) then) =
      _$PrefsCopyWithImpl<$Res, Prefs>;
  @useResult
  $Res call(
      {String accountId,
      String defaultRange,
      String unit,
      bool analyticsOptIn,
      List<DateTime>? reminderTimes,
      String preferredTheme,
      String? accentColor});
}

/// @nodoc
class _$PrefsCopyWithImpl<$Res, $Val extends Prefs>
    implements $PrefsCopyWith<$Res> {
  _$PrefsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prefs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? defaultRange = null,
    Object? unit = null,
    Object? analyticsOptIn = null,
    Object? reminderTimes = freezed,
    Object? preferredTheme = null,
    Object? accentColor = freezed,
  }) {
    return _then(_value.copyWith(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      defaultRange: null == defaultRange
          ? _value.defaultRange
          : defaultRange // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      analyticsOptIn: null == analyticsOptIn
          ? _value.analyticsOptIn
          : analyticsOptIn // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTimes: freezed == reminderTimes
          ? _value.reminderTimes
          : reminderTimes // ignore: cast_nullable_to_non_nullable
              as List<DateTime>?,
      preferredTheme: null == preferredTheme
          ? _value.preferredTheme
          : preferredTheme // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrefsImplCopyWith<$Res> implements $PrefsCopyWith<$Res> {
  factory _$$PrefsImplCopyWith(
          _$PrefsImpl value, $Res Function(_$PrefsImpl) then) =
      __$$PrefsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accountId,
      String defaultRange,
      String unit,
      bool analyticsOptIn,
      List<DateTime>? reminderTimes,
      String preferredTheme,
      String? accentColor});
}

/// @nodoc
class __$$PrefsImplCopyWithImpl<$Res>
    extends _$PrefsCopyWithImpl<$Res, _$PrefsImpl>
    implements _$$PrefsImplCopyWith<$Res> {
  __$$PrefsImplCopyWithImpl(
      _$PrefsImpl _value, $Res Function(_$PrefsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Prefs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? defaultRange = null,
    Object? unit = null,
    Object? analyticsOptIn = null,
    Object? reminderTimes = freezed,
    Object? preferredTheme = null,
    Object? accentColor = freezed,
  }) {
    return _then(_$PrefsImpl(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      defaultRange: null == defaultRange
          ? _value.defaultRange
          : defaultRange // ignore: cast_nullable_to_non_nullable
              as String,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      analyticsOptIn: null == analyticsOptIn
          ? _value.analyticsOptIn
          : analyticsOptIn // ignore: cast_nullable_to_non_nullable
              as bool,
      reminderTimes: freezed == reminderTimes
          ? _value._reminderTimes
          : reminderTimes // ignore: cast_nullable_to_non_nullable
              as List<DateTime>?,
      preferredTheme: null == preferredTheme
          ? _value.preferredTheme
          : preferredTheme // ignore: cast_nullable_to_non_nullable
              as String,
      accentColor: freezed == accentColor
          ? _value.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PrefsImpl implements _Prefs {
  const _$PrefsImpl(
      {required this.accountId,
      required this.defaultRange,
      required this.unit,
      required this.analyticsOptIn,
      final List<DateTime>? reminderTimes,
      required this.preferredTheme,
      this.accentColor})
      : _reminderTimes = reminderTimes;

  factory _$PrefsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrefsImplFromJson(json);

  @override
  final String accountId;
// TODO: FK to Account
  @override
  final String defaultRange;
// TODO: constrain to enum values
  @override
  final String unit;
// TODO: constrain to enum values
  @override
  final bool analyticsOptIn;
  final List<DateTime>? _reminderTimes;
  @override
  List<DateTime>? get reminderTimes {
    final value = _reminderTimes;
    if (value == null) return null;
    if (_reminderTimes is EqualUnmodifiableListView) return _reminderTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String preferredTheme;
// TODO: constrain to enum values
  @override
  final String? accentColor;

  @override
  String toString() {
    return 'Prefs(accountId: $accountId, defaultRange: $defaultRange, unit: $unit, analyticsOptIn: $analyticsOptIn, reminderTimes: $reminderTimes, preferredTheme: $preferredTheme, accentColor: $accentColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrefsImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.defaultRange, defaultRange) ||
                other.defaultRange == defaultRange) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.analyticsOptIn, analyticsOptIn) ||
                other.analyticsOptIn == analyticsOptIn) &&
            const DeepCollectionEquality()
                .equals(other._reminderTimes, _reminderTimes) &&
            (identical(other.preferredTheme, preferredTheme) ||
                other.preferredTheme == preferredTheme) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      accountId,
      defaultRange,
      unit,
      analyticsOptIn,
      const DeepCollectionEquality().hash(_reminderTimes),
      preferredTheme,
      accentColor);

  /// Create a copy of Prefs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrefsImplCopyWith<_$PrefsImpl> get copyWith =>
      __$$PrefsImplCopyWithImpl<_$PrefsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrefsImplToJson(
      this,
    );
  }
}

abstract class _Prefs implements Prefs {
  const factory _Prefs(
      {required final String accountId,
      required final String defaultRange,
      required final String unit,
      required final bool analyticsOptIn,
      final List<DateTime>? reminderTimes,
      required final String preferredTheme,
      final String? accentColor}) = _$PrefsImpl;

  factory _Prefs.fromJson(Map<String, dynamic> json) = _$PrefsImpl.fromJson;

  @override
  String get accountId; // TODO: FK to Account
  @override
  String get defaultRange; // TODO: constrain to enum values
  @override
  String get unit; // TODO: constrain to enum values
  @override
  bool get analyticsOptIn;
  @override
  List<DateTime>? get reminderTimes;
  @override
  String get preferredTheme; // TODO: constrain to enum values
  @override
  String? get accentColor;

  /// Create a copy of Prefs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrefsImplCopyWith<_$PrefsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
