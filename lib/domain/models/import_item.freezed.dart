// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ImportItem _$ImportItemFromJson(Map<String, dynamic> json) {
  return _ImportItem.fromJson(json);
}

/// @nodoc
mixin _$ImportItem {
  String get id => throw _privateConstructorUsedError;
  String get batchId =>
      throw _privateConstructorUsedError; // TODO: FK to ImportBatch
  String get status =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  Map<String, dynamic> get raw => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this ImportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportItemCopyWith<ImportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportItemCopyWith<$Res> {
  factory $ImportItemCopyWith(
    ImportItem value,
    $Res Function(ImportItem) then,
  ) = _$ImportItemCopyWithImpl<$Res, ImportItem>;
  @useResult
  $Res call({
    String id,
    String batchId,
    String status,
    Map<String, dynamic> raw,
    String? error,
  });
}

/// @nodoc
class _$ImportItemCopyWithImpl<$Res, $Val extends ImportItem>
    implements $ImportItemCopyWith<$Res> {
  _$ImportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? batchId = null,
    Object? status = null,
    Object? raw = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            batchId:
                null == batchId
                    ? _value.batchId
                    : batchId // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            raw:
                null == raw
                    ? _value.raw
                    : raw // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImportItemImplCopyWith<$Res>
    implements $ImportItemCopyWith<$Res> {
  factory _$$ImportItemImplCopyWith(
    _$ImportItemImpl value,
    $Res Function(_$ImportItemImpl) then,
  ) = __$$ImportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String batchId,
    String status,
    Map<String, dynamic> raw,
    String? error,
  });
}

/// @nodoc
class __$$ImportItemImplCopyWithImpl<$Res>
    extends _$ImportItemCopyWithImpl<$Res, _$ImportItemImpl>
    implements _$$ImportItemImplCopyWith<$Res> {
  __$$ImportItemImplCopyWithImpl(
    _$ImportItemImpl _value,
    $Res Function(_$ImportItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? batchId = null,
    Object? status = null,
    Object? raw = null,
    Object? error = freezed,
  }) {
    return _then(
      _$ImportItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        batchId:
            null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        raw:
            null == raw
                ? _value._raw
                : raw // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ImportItemImpl implements _ImportItem {
  const _$ImportItemImpl({
    required this.id,
    required this.batchId,
    required this.status,
    required final Map<String, dynamic> raw,
    this.error,
  }) : _raw = raw;

  factory _$ImportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImportItemImplFromJson(json);

  @override
  final String id;
  @override
  final String batchId;
  // TODO: FK to ImportBatch
  @override
  final String status;
  // TODO: constrain to enum values
  final Map<String, dynamic> _raw;
  // TODO: constrain to enum values
  @override
  Map<String, dynamic> get raw {
    if (_raw is EqualUnmodifiableMapView) return _raw;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_raw);
  }

  @override
  final String? error;

  @override
  String toString() {
    return 'ImportItem(id: $id, batchId: $batchId, status: $status, raw: $raw, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._raw, _raw) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    batchId,
    status,
    const DeepCollectionEquality().hash(_raw),
    error,
  );

  /// Create a copy of ImportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportItemImplCopyWith<_$ImportItemImpl> get copyWith =>
      __$$ImportItemImplCopyWithImpl<_$ImportItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImportItemImplToJson(this);
  }
}

abstract class _ImportItem implements ImportItem {
  const factory _ImportItem({
    required final String id,
    required final String batchId,
    required final String status,
    required final Map<String, dynamic> raw,
    final String? error,
  }) = _$ImportItemImpl;

  factory _ImportItem.fromJson(Map<String, dynamic> json) =
      _$ImportItemImpl.fromJson;

  @override
  String get id;
  @override
  String get batchId; // TODO: FK to ImportBatch
  @override
  String get status; // TODO: constrain to enum values
  @override
  Map<String, dynamic> get raw;
  @override
  String? get error;

  /// Create a copy of ImportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportItemImplCopyWith<_$ImportItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
