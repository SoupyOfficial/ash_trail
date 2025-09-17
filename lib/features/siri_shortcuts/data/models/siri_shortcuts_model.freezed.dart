// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'siri_shortcuts_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SiriShortcutsModel _$SiriShortcutsModelFromJson(Map<String, dynamic> json) {
  return _SiriShortcutsModel.fromJson(json);
}

/// @nodoc
mixin _$SiriShortcutsModel {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'type')
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_donated_at')
  DateTime? get lastDonatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'invocation_count')
  int get invocationCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_donated')
  bool get isDonated => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_phrase')
  String? get customPhrase => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_invoked_at')
  DateTime? get lastInvokedAt => throw _privateConstructorUsedError;

  /// Serializes this SiriShortcutsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SiriShortcutsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SiriShortcutsModelCopyWith<SiriShortcutsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SiriShortcutsModelCopyWith<$Res> {
  factory $SiriShortcutsModelCopyWith(
          SiriShortcutsModel value, $Res Function(SiriShortcutsModel) then) =
      _$SiriShortcutsModelCopyWithImpl<$Res, SiriShortcutsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'last_donated_at') DateTime? lastDonatedAt,
      @JsonKey(name: 'invocation_count') int invocationCount,
      @JsonKey(name: 'is_donated') bool isDonated,
      @JsonKey(name: 'custom_phrase') String? customPhrase,
      @JsonKey(name: 'last_invoked_at') DateTime? lastInvokedAt});
}

/// @nodoc
class _$SiriShortcutsModelCopyWithImpl<$Res, $Val extends SiriShortcutsModel>
    implements $SiriShortcutsModelCopyWith<$Res> {
  _$SiriShortcutsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SiriShortcutsModel
  /// with the given fields replaced by the non-null parameter values.
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
              as String,
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
}

/// @nodoc
abstract class _$$SiriShortcutsModelImplCopyWith<$Res>
    implements $SiriShortcutsModelCopyWith<$Res> {
  factory _$$SiriShortcutsModelImplCopyWith(_$SiriShortcutsModelImpl value,
          $Res Function(_$SiriShortcutsModelImpl) then) =
      __$$SiriShortcutsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') String id,
      @JsonKey(name: 'type') String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'last_donated_at') DateTime? lastDonatedAt,
      @JsonKey(name: 'invocation_count') int invocationCount,
      @JsonKey(name: 'is_donated') bool isDonated,
      @JsonKey(name: 'custom_phrase') String? customPhrase,
      @JsonKey(name: 'last_invoked_at') DateTime? lastInvokedAt});
}

/// @nodoc
class __$$SiriShortcutsModelImplCopyWithImpl<$Res>
    extends _$SiriShortcutsModelCopyWithImpl<$Res, _$SiriShortcutsModelImpl>
    implements _$$SiriShortcutsModelImplCopyWith<$Res> {
  __$$SiriShortcutsModelImplCopyWithImpl(_$SiriShortcutsModelImpl _value,
      $Res Function(_$SiriShortcutsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SiriShortcutsModel
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(_$SiriShortcutsModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
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
@JsonSerializable()
class _$SiriShortcutsModelImpl extends _SiriShortcutsModel {
  const _$SiriShortcutsModelImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'type') required this.type,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'last_donated_at') this.lastDonatedAt,
      @JsonKey(name: 'invocation_count') this.invocationCount = 0,
      @JsonKey(name: 'is_donated') this.isDonated = false,
      @JsonKey(name: 'custom_phrase') this.customPhrase,
      @JsonKey(name: 'last_invoked_at') this.lastInvokedAt})
      : super._();

  factory _$SiriShortcutsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SiriShortcutsModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'type')
  final String type;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'last_donated_at')
  final DateTime? lastDonatedAt;
  @override
  @JsonKey(name: 'invocation_count')
  final int invocationCount;
  @override
  @JsonKey(name: 'is_donated')
  final bool isDonated;
  @override
  @JsonKey(name: 'custom_phrase')
  final String? customPhrase;
  @override
  @JsonKey(name: 'last_invoked_at')
  final DateTime? lastInvokedAt;

  @override
  String toString() {
    return 'SiriShortcutsModel(id: $id, type: $type, createdAt: $createdAt, lastDonatedAt: $lastDonatedAt, invocationCount: $invocationCount, isDonated: $isDonated, customPhrase: $customPhrase, lastInvokedAt: $lastInvokedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SiriShortcutsModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, createdAt,
      lastDonatedAt, invocationCount, isDonated, customPhrase, lastInvokedAt);

  /// Create a copy of SiriShortcutsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SiriShortcutsModelImplCopyWith<_$SiriShortcutsModelImpl> get copyWith =>
      __$$SiriShortcutsModelImplCopyWithImpl<_$SiriShortcutsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SiriShortcutsModelImplToJson(
      this,
    );
  }
}

abstract class _SiriShortcutsModel extends SiriShortcutsModel {
  const factory _SiriShortcutsModel(
          {@JsonKey(name: 'id') required final String id,
          @JsonKey(name: 'type') required final String type,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'last_donated_at') final DateTime? lastDonatedAt,
          @JsonKey(name: 'invocation_count') final int invocationCount,
          @JsonKey(name: 'is_donated') final bool isDonated,
          @JsonKey(name: 'custom_phrase') final String? customPhrase,
          @JsonKey(name: 'last_invoked_at') final DateTime? lastInvokedAt}) =
      _$SiriShortcutsModelImpl;
  const _SiriShortcutsModel._() : super._();

  factory _SiriShortcutsModel.fromJson(Map<String, dynamic> json) =
      _$SiriShortcutsModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'type')
  String get type;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'last_donated_at')
  DateTime? get lastDonatedAt;
  @override
  @JsonKey(name: 'invocation_count')
  int get invocationCount;
  @override
  @JsonKey(name: 'is_donated')
  bool get isDonated;
  @override
  @JsonKey(name: 'custom_phrase')
  String? get customPhrase;
  @override
  @JsonKey(name: 'last_invoked_at')
  DateTime? get lastInvokedAt;

  /// Create a copy of SiriShortcutsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SiriShortcutsModelImplCopyWith<_$SiriShortcutsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
