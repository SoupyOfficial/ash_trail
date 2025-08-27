// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'method.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Method _$MethodFromJson(Map<String, dynamic> json) {
  return _Method.fromJson(json);
}

/// @nodoc
mixin _$Method {
  String get id => throw _privateConstructorUsedError;
  String? get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get name => throw _privateConstructorUsedError;
  String get category =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Method to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Method
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MethodCopyWith<Method> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MethodCopyWith<$Res> {
  factory $MethodCopyWith(Method value, $Res Function(Method) then) =
      _$MethodCopyWithImpl<$Res, Method>;
  @useResult
  $Res call({
    String id,
    String? accountId,
    String name,
    String category,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$MethodCopyWithImpl<$Res, $Val extends Method>
    implements $MethodCopyWith<$Res> {
  _$MethodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Method
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = freezed,
    Object? name = null,
    Object? category = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            accountId:
                freezed == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MethodImplCopyWith<$Res> implements $MethodCopyWith<$Res> {
  factory _$$MethodImplCopyWith(
    _$MethodImpl value,
    $Res Function(_$MethodImpl) then,
  ) = __$$MethodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? accountId,
    String name,
    String category,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$MethodImplCopyWithImpl<$Res>
    extends _$MethodCopyWithImpl<$Res, _$MethodImpl>
    implements _$$MethodImplCopyWith<$Res> {
  __$$MethodImplCopyWithImpl(
    _$MethodImpl _value,
    $Res Function(_$MethodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Method
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = freezed,
    Object? name = null,
    Object? category = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$MethodImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        accountId:
            freezed == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MethodImpl implements _Method {
  const _$MethodImpl({
    required this.id,
    this.accountId,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$MethodImpl.fromJson(Map<String, dynamic> json) =>
      _$$MethodImplFromJson(json);

  @override
  final String id;
  @override
  final String? accountId;
  // TODO: FK to Account
  @override
  final String name;
  @override
  final String category;
  // TODO: constrain to enum values
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Method(id: $id, accountId: $accountId, name: $name, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MethodImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    name,
    category,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Method
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MethodImplCopyWith<_$MethodImpl> get copyWith =>
      __$$MethodImplCopyWithImpl<_$MethodImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MethodImplToJson(this);
  }
}

abstract class _Method implements Method {
  const factory _Method({
    required final String id,
    final String? accountId,
    required final String name,
    required final String category,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$MethodImpl;

  factory _Method.fromJson(Map<String, dynamic> json) = _$MethodImpl.fromJson;

  @override
  String get id;
  @override
  String? get accountId; // TODO: FK to Account
  @override
  String get name;
  @override
  String get category; // TODO: constrain to enum values
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Method
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MethodImplCopyWith<_$MethodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
