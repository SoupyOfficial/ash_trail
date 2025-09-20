// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_sort.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogSort {
  LogSortField get field => throw _privateConstructorUsedError;
  LogSortOrder get order => throw _privateConstructorUsedError;

  /// Create a copy of LogSort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogSortCopyWith<LogSort> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogSortCopyWith<$Res> {
  factory $LogSortCopyWith(LogSort value, $Res Function(LogSort) then) =
      _$LogSortCopyWithImpl<$Res, LogSort>;
  @useResult
  $Res call({LogSortField field, LogSortOrder order});
}

/// @nodoc
class _$LogSortCopyWithImpl<$Res, $Val extends LogSort>
    implements $LogSortCopyWith<$Res> {
  _$LogSortCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogSort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? order = null,
  }) {
    return _then(_value.copyWith(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as LogSortField,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as LogSortOrder,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogSortImplCopyWith<$Res> implements $LogSortCopyWith<$Res> {
  factory _$$LogSortImplCopyWith(
          _$LogSortImpl value, $Res Function(_$LogSortImpl) then) =
      __$$LogSortImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LogSortField field, LogSortOrder order});
}

/// @nodoc
class __$$LogSortImplCopyWithImpl<$Res>
    extends _$LogSortCopyWithImpl<$Res, _$LogSortImpl>
    implements _$$LogSortImplCopyWith<$Res> {
  __$$LogSortImplCopyWithImpl(
      _$LogSortImpl _value, $Res Function(_$LogSortImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogSort
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? order = null,
  }) {
    return _then(_$LogSortImpl(
      field: null == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as LogSortField,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as LogSortOrder,
    ));
  }
}

/// @nodoc

class _$LogSortImpl extends _LogSort {
  const _$LogSortImpl(
      {this.field = LogSortField.timestamp,
      this.order = LogSortOrder.descending})
      : super._();

  @override
  @JsonKey()
  final LogSortField field;
  @override
  @JsonKey()
  final LogSortOrder order;

  @override
  String toString() {
    return 'LogSort(field: $field, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogSortImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field, order);

  /// Create a copy of LogSort
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogSortImplCopyWith<_$LogSortImpl> get copyWith =>
      __$$LogSortImplCopyWithImpl<_$LogSortImpl>(this, _$identity);
}

abstract class _LogSort extends LogSort {
  const factory _LogSort({final LogSortField field, final LogSortOrder order}) =
      _$LogSortImpl;
  const _LogSort._() : super._();

  @override
  LogSortField get field;
  @override
  LogSortOrder get order;

  /// Create a copy of LogSort
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogSortImplCopyWith<_$LogSortImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
