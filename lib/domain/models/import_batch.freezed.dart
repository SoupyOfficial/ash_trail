// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ImportBatch _$ImportBatchFromJson(Map<String, dynamic> json) {
  return _ImportBatch.fromJson(json);
}

/// @nodoc
mixin _$ImportBatch {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get source =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String? get fileName => throw _privateConstructorUsedError;
  int get countInserted => throw _privateConstructorUsedError;
  int get countFailed => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get finishedAt => throw _privateConstructorUsedError;
  String? get log => throw _privateConstructorUsedError;

  /// Serializes this ImportBatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImportBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportBatchCopyWith<ImportBatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportBatchCopyWith<$Res> {
  factory $ImportBatchCopyWith(
    ImportBatch value,
    $Res Function(ImportBatch) then,
  ) = _$ImportBatchCopyWithImpl<$Res, ImportBatch>;
  @useResult
  $Res call({
    String id,
    String accountId,
    String source,
    String? fileName,
    int countInserted,
    int countFailed,
    DateTime startedAt,
    DateTime? finishedAt,
    String? log,
  });
}

/// @nodoc
class _$ImportBatchCopyWithImpl<$Res, $Val extends ImportBatch>
    implements $ImportBatchCopyWith<$Res> {
  _$ImportBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? source = null,
    Object? fileName = freezed,
    Object? countInserted = null,
    Object? countFailed = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? log = freezed,
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
            source:
                null == source
                    ? _value.source
                    : source // ignore: cast_nullable_to_non_nullable
                        as String,
            fileName:
                freezed == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
                        as String?,
            countInserted:
                null == countInserted
                    ? _value.countInserted
                    : countInserted // ignore: cast_nullable_to_non_nullable
                        as int,
            countFailed:
                null == countFailed
                    ? _value.countFailed
                    : countFailed // ignore: cast_nullable_to_non_nullable
                        as int,
            startedAt:
                null == startedAt
                    ? _value.startedAt
                    : startedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            finishedAt:
                freezed == finishedAt
                    ? _value.finishedAt
                    : finishedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            log:
                freezed == log
                    ? _value.log
                    : log // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImportBatchImplCopyWith<$Res>
    implements $ImportBatchCopyWith<$Res> {
  factory _$$ImportBatchImplCopyWith(
    _$ImportBatchImpl value,
    $Res Function(_$ImportBatchImpl) then,
  ) = __$$ImportBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    String source,
    String? fileName,
    int countInserted,
    int countFailed,
    DateTime startedAt,
    DateTime? finishedAt,
    String? log,
  });
}

/// @nodoc
class __$$ImportBatchImplCopyWithImpl<$Res>
    extends _$ImportBatchCopyWithImpl<$Res, _$ImportBatchImpl>
    implements _$$ImportBatchImplCopyWith<$Res> {
  __$$ImportBatchImplCopyWithImpl(
    _$ImportBatchImpl _value,
    $Res Function(_$ImportBatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImportBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? source = null,
    Object? fileName = freezed,
    Object? countInserted = null,
    Object? countFailed = null,
    Object? startedAt = null,
    Object? finishedAt = freezed,
    Object? log = freezed,
  }) {
    return _then(
      _$ImportBatchImpl(
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
        source:
            null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                    as String,
        fileName:
            freezed == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                    as String?,
        countInserted:
            null == countInserted
                ? _value.countInserted
                : countInserted // ignore: cast_nullable_to_non_nullable
                    as int,
        countFailed:
            null == countFailed
                ? _value.countFailed
                : countFailed // ignore: cast_nullable_to_non_nullable
                    as int,
        startedAt:
            null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        finishedAt:
            freezed == finishedAt
                ? _value.finishedAt
                : finishedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        log:
            freezed == log
                ? _value.log
                : log // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImportBatchImpl implements _ImportBatch {
  const _$ImportBatchImpl({
    required this.id,
    required this.accountId,
    required this.source,
    this.fileName,
    required this.countInserted,
    required this.countFailed,
    required this.startedAt,
    this.finishedAt,
    this.log,
  });

  factory _$ImportBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImportBatchImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final String source;
  // TODO: constrain to enum values
  @override
  final String? fileName;
  @override
  final int countInserted;
  @override
  final int countFailed;
  @override
  final DateTime startedAt;
  @override
  final DateTime? finishedAt;
  @override
  final String? log;

  @override
  String toString() {
    return 'ImportBatch(id: $id, accountId: $accountId, source: $source, fileName: $fileName, countInserted: $countInserted, countFailed: $countFailed, startedAt: $startedAt, finishedAt: $finishedAt, log: $log)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportBatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.countInserted, countInserted) ||
                other.countInserted == countInserted) &&
            (identical(other.countFailed, countFailed) ||
                other.countFailed == countFailed) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.log, log) || other.log == log));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    accountId,
    source,
    fileName,
    countInserted,
    countFailed,
    startedAt,
    finishedAt,
    log,
  );

  /// Create a copy of ImportBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportBatchImplCopyWith<_$ImportBatchImpl> get copyWith =>
      __$$ImportBatchImplCopyWithImpl<_$ImportBatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImportBatchImplToJson(this);
  }
}

abstract class _ImportBatch implements ImportBatch {
  const factory _ImportBatch({
    required final String id,
    required final String accountId,
    required final String source,
    final String? fileName,
    required final int countInserted,
    required final int countFailed,
    required final DateTime startedAt,
    final DateTime? finishedAt,
    final String? log,
  }) = _$ImportBatchImpl;

  factory _ImportBatch.fromJson(Map<String, dynamic> json) =
      _$ImportBatchImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  String get source; // TODO: constrain to enum values
  @override
  String? get fileName;
  @override
  int get countInserted;
  @override
  int get countFailed;
  @override
  DateTime get startedAt;
  @override
  DateTime? get finishedAt;
  @override
  String? get log;

  /// Create a copy of ImportBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportBatchImplCopyWith<_$ImportBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
