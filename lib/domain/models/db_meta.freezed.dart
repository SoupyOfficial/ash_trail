// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'db_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DbMeta _$DbMetaFromJson(Map<String, dynamic> json) {
  return _DbMeta.fromJson(json);
}

/// @nodoc
mixin _$DbMeta {
  String get id => throw _privateConstructorUsedError;
  int get schemaVersion => throw _privateConstructorUsedError;
  DateTime get migratedAt => throw _privateConstructorUsedError;

  /// Serializes this DbMeta to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DbMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DbMetaCopyWith<DbMeta> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DbMetaCopyWith<$Res> {
  factory $DbMetaCopyWith(DbMeta value, $Res Function(DbMeta) then) =
      _$DbMetaCopyWithImpl<$Res, DbMeta>;
  @useResult
  $Res call({String id, int schemaVersion, DateTime migratedAt});
}

/// @nodoc
class _$DbMetaCopyWithImpl<$Res, $Val extends DbMeta>
    implements $DbMetaCopyWith<$Res> {
  _$DbMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DbMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schemaVersion = null,
    Object? migratedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            schemaVersion:
                null == schemaVersion
                    ? _value.schemaVersion
                    : schemaVersion // ignore: cast_nullable_to_non_nullable
                        as int,
            migratedAt:
                null == migratedAt
                    ? _value.migratedAt
                    : migratedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DbMetaImplCopyWith<$Res> implements $DbMetaCopyWith<$Res> {
  factory _$$DbMetaImplCopyWith(
    _$DbMetaImpl value,
    $Res Function(_$DbMetaImpl) then,
  ) = __$$DbMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int schemaVersion, DateTime migratedAt});
}

/// @nodoc
class __$$DbMetaImplCopyWithImpl<$Res>
    extends _$DbMetaCopyWithImpl<$Res, _$DbMetaImpl>
    implements _$$DbMetaImplCopyWith<$Res> {
  __$$DbMetaImplCopyWithImpl(
    _$DbMetaImpl _value,
    $Res Function(_$DbMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DbMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? schemaVersion = null,
    Object? migratedAt = null,
  }) {
    return _then(
      _$DbMetaImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        schemaVersion:
            null == schemaVersion
                ? _value.schemaVersion
                : schemaVersion // ignore: cast_nullable_to_non_nullable
                    as int,
        migratedAt:
            null == migratedAt
                ? _value.migratedAt
                : migratedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$DbMetaImpl implements _DbMeta {
  const _$DbMetaImpl({
    required this.id,
    required this.schemaVersion,
    required this.migratedAt,
  });

  factory _$DbMetaImpl.fromJson(Map<String, dynamic> json) =>
      _$$DbMetaImplFromJson(json);

  @override
  final String id;
  @override
  final int schemaVersion;
  @override
  final DateTime migratedAt;

  @override
  String toString() {
    return 'DbMeta(id: $id, schemaVersion: $schemaVersion, migratedAt: $migratedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DbMetaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.schemaVersion, schemaVersion) ||
                other.schemaVersion == schemaVersion) &&
            (identical(other.migratedAt, migratedAt) ||
                other.migratedAt == migratedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, schemaVersion, migratedAt);

  /// Create a copy of DbMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DbMetaImplCopyWith<_$DbMetaImpl> get copyWith =>
      __$$DbMetaImplCopyWithImpl<_$DbMetaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DbMetaImplToJson(this);
  }
}

abstract class _DbMeta implements DbMeta {
  const factory _DbMeta({
    required final String id,
    required final int schemaVersion,
    required final DateTime migratedAt,
  }) = _$DbMetaImpl;

  factory _DbMeta.fromJson(Map<String, dynamic> json) = _$DbMetaImpl.fromJson;

  @override
  String get id;
  @override
  int get schemaVersion;
  @override
  DateTime get migratedAt;

  /// Create a copy of DbMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DbMetaImplCopyWith<_$DbMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
