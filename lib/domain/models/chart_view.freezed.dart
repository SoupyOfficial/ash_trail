// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chart_view.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChartView _$ChartViewFromJson(Map<String, dynamic> json) {
  return _ChartView.fromJson(json);
}

/// @nodoc
mixin _$ChartView {
  String get id => throw _privateConstructorUsedError;
  String get accountId =>
      throw _privateConstructorUsedError; // TODO: FK to Account
  String get title => throw _privateConstructorUsedError;
  String get range =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  DateTime? get customStart => throw _privateConstructorUsedError;
  DateTime? get customEnd => throw _privateConstructorUsedError;
  String get groupBy =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get metric =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  String get smoothing =>
      throw _privateConstructorUsedError; // TODO: constrain to enum values
  int? get smoothingWindow => throw _privateConstructorUsedError;
  List<String>? get visibleTags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChartView to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChartView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChartViewCopyWith<ChartView> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartViewCopyWith<$Res> {
  factory $ChartViewCopyWith(ChartView value, $Res Function(ChartView) then) =
      _$ChartViewCopyWithImpl<$Res, ChartView>;
  @useResult
  $Res call({
    String id,
    String accountId,
    String title,
    String range,
    DateTime? customStart,
    DateTime? customEnd,
    String groupBy,
    String metric,
    String smoothing,
    int? smoothingWindow,
    List<String>? visibleTags,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ChartViewCopyWithImpl<$Res, $Val extends ChartView>
    implements $ChartViewCopyWith<$Res> {
  _$ChartViewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChartView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? title = null,
    Object? range = null,
    Object? customStart = freezed,
    Object? customEnd = freezed,
    Object? groupBy = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? smoothingWindow = freezed,
    Object? visibleTags = freezed,
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
                null == accountId
                    ? _value.accountId
                    : accountId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            range:
                null == range
                    ? _value.range
                    : range // ignore: cast_nullable_to_non_nullable
                        as String,
            customStart:
                freezed == customStart
                    ? _value.customStart
                    : customStart // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            customEnd:
                freezed == customEnd
                    ? _value.customEnd
                    : customEnd // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            groupBy:
                null == groupBy
                    ? _value.groupBy
                    : groupBy // ignore: cast_nullable_to_non_nullable
                        as String,
            metric:
                null == metric
                    ? _value.metric
                    : metric // ignore: cast_nullable_to_non_nullable
                        as String,
            smoothing:
                null == smoothing
                    ? _value.smoothing
                    : smoothing // ignore: cast_nullable_to_non_nullable
                        as String,
            smoothingWindow:
                freezed == smoothingWindow
                    ? _value.smoothingWindow
                    : smoothingWindow // ignore: cast_nullable_to_non_nullable
                        as int?,
            visibleTags:
                freezed == visibleTags
                    ? _value.visibleTags
                    : visibleTags // ignore: cast_nullable_to_non_nullable
                        as List<String>?,
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
abstract class _$$ChartViewImplCopyWith<$Res>
    implements $ChartViewCopyWith<$Res> {
  factory _$$ChartViewImplCopyWith(
    _$ChartViewImpl value,
    $Res Function(_$ChartViewImpl) then,
  ) = __$$ChartViewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String accountId,
    String title,
    String range,
    DateTime? customStart,
    DateTime? customEnd,
    String groupBy,
    String metric,
    String smoothing,
    int? smoothingWindow,
    List<String>? visibleTags,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ChartViewImplCopyWithImpl<$Res>
    extends _$ChartViewCopyWithImpl<$Res, _$ChartViewImpl>
    implements _$$ChartViewImplCopyWith<$Res> {
  __$$ChartViewImplCopyWithImpl(
    _$ChartViewImpl _value,
    $Res Function(_$ChartViewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChartView
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? title = null,
    Object? range = null,
    Object? customStart = freezed,
    Object? customEnd = freezed,
    Object? groupBy = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? smoothingWindow = freezed,
    Object? visibleTags = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ChartViewImpl(
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
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        range:
            null == range
                ? _value.range
                : range // ignore: cast_nullable_to_non_nullable
                    as String,
        customStart:
            freezed == customStart
                ? _value.customStart
                : customStart // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        customEnd:
            freezed == customEnd
                ? _value.customEnd
                : customEnd // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        groupBy:
            null == groupBy
                ? _value.groupBy
                : groupBy // ignore: cast_nullable_to_non_nullable
                    as String,
        metric:
            null == metric
                ? _value.metric
                : metric // ignore: cast_nullable_to_non_nullable
                    as String,
        smoothing:
            null == smoothing
                ? _value.smoothing
                : smoothing // ignore: cast_nullable_to_non_nullable
                    as String,
        smoothingWindow:
            freezed == smoothingWindow
                ? _value.smoothingWindow
                : smoothingWindow // ignore: cast_nullable_to_non_nullable
                    as int?,
        visibleTags:
            freezed == visibleTags
                ? _value._visibleTags
                : visibleTags // ignore: cast_nullable_to_non_nullable
                    as List<String>?,
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
@JsonSerializable()
class _$ChartViewImpl implements _ChartView {
  const _$ChartViewImpl({
    required this.id,
    required this.accountId,
    required this.title,
    required this.range,
    this.customStart,
    this.customEnd,
    required this.groupBy,
    required this.metric,
    required this.smoothing,
    this.smoothingWindow,
    final List<String>? visibleTags,
    required this.createdAt,
    required this.updatedAt,
  }) : _visibleTags = visibleTags;

  factory _$ChartViewImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartViewImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  // TODO: FK to Account
  @override
  final String title;
  @override
  final String range;
  // TODO: constrain to enum values
  @override
  final DateTime? customStart;
  @override
  final DateTime? customEnd;
  @override
  final String groupBy;
  // TODO: constrain to enum values
  @override
  final String metric;
  // TODO: constrain to enum values
  @override
  final String smoothing;
  // TODO: constrain to enum values
  @override
  final int? smoothingWindow;
  final List<String>? _visibleTags;
  @override
  List<String>? get visibleTags {
    final value = _visibleTags;
    if (value == null) return null;
    if (_visibleTags is EqualUnmodifiableListView) return _visibleTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ChartView(id: $id, accountId: $accountId, title: $title, range: $range, customStart: $customStart, customEnd: $customEnd, groupBy: $groupBy, metric: $metric, smoothing: $smoothing, smoothingWindow: $smoothingWindow, visibleTags: $visibleTags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartViewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.range, range) || other.range == range) &&
            (identical(other.customStart, customStart) ||
                other.customStart == customStart) &&
            (identical(other.customEnd, customEnd) ||
                other.customEnd == customEnd) &&
            (identical(other.groupBy, groupBy) || other.groupBy == groupBy) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.smoothing, smoothing) ||
                other.smoothing == smoothing) &&
            (identical(other.smoothingWindow, smoothingWindow) ||
                other.smoothingWindow == smoothingWindow) &&
            const DeepCollectionEquality().equals(
              other._visibleTags,
              _visibleTags,
            ) &&
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
    title,
    range,
    customStart,
    customEnd,
    groupBy,
    metric,
    smoothing,
    smoothingWindow,
    const DeepCollectionEquality().hash(_visibleTags),
    createdAt,
    updatedAt,
  );

  /// Create a copy of ChartView
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartViewImplCopyWith<_$ChartViewImpl> get copyWith =>
      __$$ChartViewImplCopyWithImpl<_$ChartViewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartViewImplToJson(this);
  }
}

abstract class _ChartView implements ChartView {
  const factory _ChartView({
    required final String id,
    required final String accountId,
    required final String title,
    required final String range,
    final DateTime? customStart,
    final DateTime? customEnd,
    required final String groupBy,
    required final String metric,
    required final String smoothing,
    final int? smoothingWindow,
    final List<String>? visibleTags,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ChartViewImpl;

  factory _ChartView.fromJson(Map<String, dynamic> json) =
      _$ChartViewImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId; // TODO: FK to Account
  @override
  String get title;
  @override
  String get range; // TODO: constrain to enum values
  @override
  DateTime? get customStart;
  @override
  DateTime? get customEnd;
  @override
  String get groupBy; // TODO: constrain to enum values
  @override
  String get metric; // TODO: constrain to enum values
  @override
  String get smoothing; // TODO: constrain to enum values
  @override
  int? get smoothingWindow;
  @override
  List<String>? get visibleTags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of ChartView
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChartViewImplCopyWith<_$ChartViewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
