// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'siri_shortcuts_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SiriShortcutsEntity {
  /// Unique identifier for this shortcut configuration
  String get id => throw _privateConstructorUsedError;

  /// The type of shortcut (add log, start timed log, etc.)
  SiriShortcutType get type => throw _privateConstructorUsedError;

  /// When this shortcut configuration was created
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// When this shortcut was last donated to Siri
  DateTime? get lastDonatedAt => throw _privateConstructorUsedError;

  /// Number of times this shortcut has been invoked
  int get invocationCount => throw _privateConstructorUsedError;

  /// Whether this shortcut is currently active/donated
  bool get isDonated => throw _privateConstructorUsedError;

  /// Custom user phrase for this shortcut (optional)
  String? get customPhrase => throw _privateConstructorUsedError;

  /// When this shortcut was last successfully invoked
  DateTime? get lastInvokedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SiriShortcutsEntityCopyWith<SiriShortcutsEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SiriShortcutsEntityCopyWith<$Res> {
  factory $SiriShortcutsEntityCopyWith(
          SiriShortcutsEntity value, $Res Function(SiriShortcutsEntity) then) =
      _$SiriShortcutsEntityCopyWithImpl<$Res, SiriShortcutsEntity>;
  @useResult
  $Res call(
      {String id,
      SiriShortcutType type,
      DateTime createdAt,
      DateTime? lastDonatedAt,
      int invocationCount,
      bool isDonated,
      String? customPhrase,
      DateTime? lastInvokedAt});

  $SiriShortcutTypeCopyWith<$Res> get type;
}

/// @nodoc
class _$SiriShortcutsEntityCopyWithImpl<$Res, $Val extends SiriShortcutsEntity>
    implements $SiriShortcutsEntityCopyWith<$Res> {
  _$SiriShortcutsEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? lastDonatedAt = freezed,
    Object? invocationCount = null,
    Object? isDonated = null,
    Object? customPhrase = freezed,
    Object? lastInvokedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SiriShortcutType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastDonatedAt: freezed == lastDonatedAt
          ? _value.lastDonatedAt
          : lastDonatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      invocationCount: null == invocationCount
          ? _value.invocationCount
          : invocationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isDonated: null == isDonated
          ? _value.isDonated
          : isDonated // ignore: cast_nullable_to_non_nullable
              as bool,
      customPhrase: freezed == customPhrase
          ? _value.customPhrase
          : customPhrase // ignore: cast_nullable_to_non_nullable
              as String?,
      lastInvokedAt: freezed == lastInvokedAt
          ? _value.lastInvokedAt
          : lastInvokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SiriShortcutTypeCopyWith<$Res> get type {
    return $SiriShortcutTypeCopyWith<$Res>(_value.type, (value) {
      return _then(_value.copyWith(type: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SiriShortcutsEntityImplCopyWith<$Res>
    implements $SiriShortcutsEntityCopyWith<$Res> {
  factory _$$SiriShortcutsEntityImplCopyWith(_$SiriShortcutsEntityImpl value,
          $Res Function(_$SiriShortcutsEntityImpl) then) =
      __$$SiriShortcutsEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SiriShortcutType type,
      DateTime createdAt,
      DateTime? lastDonatedAt,
      int invocationCount,
      bool isDonated,
      String? customPhrase,
      DateTime? lastInvokedAt});

  @override
  $SiriShortcutTypeCopyWith<$Res> get type;
}

/// @nodoc
class __$$SiriShortcutsEntityImplCopyWithImpl<$Res>
    extends _$SiriShortcutsEntityCopyWithImpl<$Res, _$SiriShortcutsEntityImpl>
    implements _$$SiriShortcutsEntityImplCopyWith<$Res> {
  __$$SiriShortcutsEntityImplCopyWithImpl(_$SiriShortcutsEntityImpl _value,
      $Res Function(_$SiriShortcutsEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? createdAt = null,
    Object? lastDonatedAt = freezed,
    Object? invocationCount = null,
    Object? isDonated = null,
    Object? customPhrase = freezed,
    Object? lastInvokedAt = freezed,
  }) {
    return _then(_$SiriShortcutsEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SiriShortcutType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastDonatedAt: freezed == lastDonatedAt
          ? _value.lastDonatedAt
          : lastDonatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      invocationCount: null == invocationCount
          ? _value.invocationCount
          : invocationCount // ignore: cast_nullable_to_non_nullable
              as int,
      isDonated: null == isDonated
          ? _value.isDonated
          : isDonated // ignore: cast_nullable_to_non_nullable
              as bool,
      customPhrase: freezed == customPhrase
          ? _value.customPhrase
          : customPhrase // ignore: cast_nullable_to_non_nullable
              as String?,
      lastInvokedAt: freezed == lastInvokedAt
          ? _value.lastInvokedAt
          : lastInvokedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$SiriShortcutsEntityImpl extends _SiriShortcutsEntity {
  const _$SiriShortcutsEntityImpl(
      {required this.id,
      required this.type,
      required this.createdAt,
      this.lastDonatedAt,
      this.invocationCount = 0,
      this.isDonated = false,
      this.customPhrase,
      this.lastInvokedAt})
      : super._();

  /// Unique identifier for this shortcut configuration
  @override
  final String id;

  /// The type of shortcut (add log, start timed log, etc.)
  @override
  final SiriShortcutType type;

  /// When this shortcut configuration was created
  @override
  final DateTime createdAt;

  /// When this shortcut was last donated to Siri
  @override
  final DateTime? lastDonatedAt;

  /// Number of times this shortcut has been invoked
  @override
  @JsonKey()
  final int invocationCount;

  /// Whether this shortcut is currently active/donated
  @override
  @JsonKey()
  final bool isDonated;

  /// Custom user phrase for this shortcut (optional)
  @override
  final String? customPhrase;

  /// When this shortcut was last successfully invoked
  @override
  final DateTime? lastInvokedAt;

  @override
  String toString() {
    return 'SiriShortcutsEntity(id: $id, type: $type, createdAt: $createdAt, lastDonatedAt: $lastDonatedAt, invocationCount: $invocationCount, isDonated: $isDonated, customPhrase: $customPhrase, lastInvokedAt: $lastInvokedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SiriShortcutsEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastDonatedAt, lastDonatedAt) ||
                other.lastDonatedAt == lastDonatedAt) &&
            (identical(other.invocationCount, invocationCount) ||
                other.invocationCount == invocationCount) &&
            (identical(other.isDonated, isDonated) ||
                other.isDonated == isDonated) &&
            (identical(other.customPhrase, customPhrase) ||
                other.customPhrase == customPhrase) &&
            (identical(other.lastInvokedAt, lastInvokedAt) ||
                other.lastInvokedAt == lastInvokedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, type, createdAt,
      lastDonatedAt, invocationCount, isDonated, customPhrase, lastInvokedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SiriShortcutsEntityImplCopyWith<_$SiriShortcutsEntityImpl> get copyWith =>
      __$$SiriShortcutsEntityImplCopyWithImpl<_$SiriShortcutsEntityImpl>(
          this, _$identity);
}

abstract class _SiriShortcutsEntity extends SiriShortcutsEntity {
  const factory _SiriShortcutsEntity(
      {required final String id,
      required final SiriShortcutType type,
      required final DateTime createdAt,
      final DateTime? lastDonatedAt,
      final int invocationCount,
      final bool isDonated,
      final String? customPhrase,
      final DateTime? lastInvokedAt}) = _$SiriShortcutsEntityImpl;
  const _SiriShortcutsEntity._() : super._();

  @override

  /// Unique identifier for this shortcut configuration
  String get id;
  @override

  /// The type of shortcut (add log, start timed log, etc.)
  SiriShortcutType get type;
  @override

  /// When this shortcut configuration was created
  DateTime get createdAt;
  @override

  /// When this shortcut was last donated to Siri
  DateTime? get lastDonatedAt;
  @override

  /// Number of times this shortcut has been invoked
  int get invocationCount;
  @override

  /// Whether this shortcut is currently active/donated
  bool get isDonated;
  @override

  /// Custom user phrase for this shortcut (optional)
  String? get customPhrase;
  @override

  /// When this shortcut was last successfully invoked
  DateTime? get lastInvokedAt;
  @override
  @JsonKey(ignore: true)
  _$$SiriShortcutsEntityImplCopyWith<_$SiriShortcutsEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
