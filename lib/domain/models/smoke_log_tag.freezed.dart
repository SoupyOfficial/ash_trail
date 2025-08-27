// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smoke_log_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmokeLogTag _$SmokeLogTagFromJson(Map<String, dynamic> json) {
  return _SmokeLogTag.fromJson(json);
}

/// @nodoc
mixin _$SmokeLogTag {
  String get id => throw _privateConstructorUsedError;
  String get smokeLogId =>
      throw _privateConstructorUsedError; // TODO: FK to SmokeLog
  String get tagId => throw _privateConstructorUsedError; // TODO: FK to Tag
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  DateTime get ts => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SmokeLogTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmokeLogTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmokeLogTagCopyWith<SmokeLogTag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmokeLogTagCopyWith<$Res> {
  factory $SmokeLogTagCopyWith(
    SmokeLogTag value,
    $Res Function(SmokeLogTag) then,
  ) = _$SmokeLogTagCopyWithImpl<$Res, SmokeLogTag>;
  @useResult
  $Res call({
    String id,
    String smokeLogId,
    String tagId,
    String accountId,
    DateTime ts,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SmokeLogTagCopyWithImpl<$Res, $Val extends SmokeLogTag>
    implements $SmokeLogTagCopyWith<$Res> {
  _$SmokeLogTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmokeLogTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smokeLogId = null,
    Object? tagId = null,
    Object? accountId = null,
    Object? ts = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            smokeLogId:
                null == smokeLogId
                    ? _value.smokeLogId
                    : smokeLogId // ignore: cast_nullable_to_non_nullable
                        as String,
            tagId:
                null == tagId
                    ? _value.tagId
                    : tagId // ignore: cast_nullable_to_non_nullable
                        as String,
            accountId:
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            ts:
                null == ts
                    ? _value.ts
                    : ts // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmokeLogTagImplCopyWith<$Res>
    implements $SmokeLogTagCopyWith<$Res> {
  factory _$$SmokeLogTagImplCopyWith(
    _$SmokeLogTagImpl value,
    $Res Function(_$SmokeLogTagImpl) then,
  ) = __$$SmokeLogTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String smokeLogId,
    String tagId,
    String accountId,
    DateTime ts,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SmokeLogTagImplCopyWithImpl<$Res>
    extends _$SmokeLogTagCopyWithImpl<$Res, _$SmokeLogTagImpl>
    implements _$$SmokeLogTagImplCopyWith<$Res> {
  __$$SmokeLogTagImplCopyWithImpl(
    _$SmokeLogTagImpl _value,
    $Res Function(_$SmokeLogTagImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmokeLogTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smokeLogId = null,
    Object? tagId = null,
    Object? accountId = null,
    Object? ts = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SmokeLogTagImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        smokeLogId:
            null == smokeLogId
                ? _value.smokeLogId
                : smokeLogId // ignore: cast_nullable_to_non_nullable
                    as String,
        tagId:
            null == tagId
                ? _value.tagId
                : tagId // ignore: cast_nullable_to_non_nullable
                    as String,
        accountId:
            null == accountId
                ? _value.accountId
                : accountId // ignore: cast_nullable_to_non_nullable
                    as String,
        ts:
            null == ts
                ? _value.ts
                : ts // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SmokeLogTagImpl implements _SmokeLogTag {
  const _$SmokeLogTagImpl({
    required this.id,
    required this.smokeLogId,
    required this.tagId,
    required this.accountId,
    required this.ts,
    required this.createdAt,
  });

  factory _$SmokeLogTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmokeLogTagImplFromJson(json);

  @override
  final String id;
  @override
  final String smokeLogId;
  // TODO: FK to SmokeLog
  @override
  final String tagId;
  // TODO: FK to Tag
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final DateTime ts;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SmokeLogTag(id: $id, smokeLogId: $smokeLogId, tagId: $tagId, accountId: $accountId, ts: $ts, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmokeLogTagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smokeLogId, smokeLogId) ||
                other.smokeLogId == smokeLogId) &&
            (identical(other.tagId, tagId) || other.tagId == tagId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.ts, ts) || other.ts == ts) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, smokeLogId, tagId, accountId, ts, createdAt);

  /// Create a copy of SmokeLogTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmokeLogTagImplCopyWith<_$SmokeLogTagImpl> get copyWith =>
      __$$SmokeLogTagImplCopyWithImpl<_$SmokeLogTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmokeLogTagImplToJson(this);
  }
}

abstract class _SmokeLogTag implements SmokeLogTag {
  const factory _SmokeLogTag({
    required final String id,
    required final String smokeLogId,
    required final String tagId,
    required final String accountId,
    required final DateTime ts,
    required final DateTime createdAt,
  }) = _$SmokeLogTagImpl;

  factory _SmokeLogTag.fromJson(Map<String, dynamic> json) =
      _$SmokeLogTagImpl.fromJson;

  @override
  String get id;
  @override
  String get smokeLogId; // TODO: FK to SmokeLog
  @override
  String get tagId; // TODO: FK to Tag
  @override
  String get accountId; // TODO: FK to Account
  @override
  DateTime get ts;
  @override
  DateTime get createdAt;

  /// Create a copy of SmokeLogTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmokeLogTagImplCopyWith<_$SmokeLogTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
