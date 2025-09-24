// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_series_chart_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeSeriesChartDto _$TimeSeriesChartDtoFromJson(Map<String, dynamic> json) {
  return _TimeSeriesChartDto.fromJson(json);
}

/// @nodoc
mixin _$TimeSeriesChartDto {
  String get id => throw _privateConstructorUsedError;
  String get accountId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get aggregation => throw _privateConstructorUsedError;
  String get metric => throw _privateConstructorUsedError;
  String get smoothing => throw _privateConstructorUsedError;
  List<ChartDataPointDto> get dataPoints => throw _privateConstructorUsedError;
  int? get smoothingWindow => throw _privateConstructorUsedError;
  List<String>? get visibleTags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this TimeSeriesChartDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeSeriesChartDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSeriesChartDtoCopyWith<TimeSeriesChartDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSeriesChartDtoCopyWith<$Res> {
  factory $TimeSeriesChartDtoCopyWith(
          TimeSeriesChartDto value, $Res Function(TimeSeriesChartDto) then) =
      _$TimeSeriesChartDtoCopyWithImpl<$Res, TimeSeriesChartDto>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String title,
      DateTime startDate,
      DateTime endDate,
      String aggregation,
      String metric,
      String smoothing,
      List<ChartDataPointDto> dataPoints,
      int? smoothingWindow,
      List<String>? visibleTags,
      DateTime createdAt});
}

/// @nodoc
class _$TimeSeriesChartDtoCopyWithImpl<$Res, $Val extends TimeSeriesChartDto>
    implements $TimeSeriesChartDtoCopyWith<$Res> {
  _$TimeSeriesChartDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSeriesChartDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? aggregation = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? dataPoints = null,
    Object? smoothingWindow = freezed,
    Object? visibleTags = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      aggregation: null == aggregation
          ? _value.aggregation
          : aggregation // ignore: cast_nullable_to_non_nullable
              as String,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as String,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPointDto>,
      smoothingWindow: freezed == smoothingWindow
          ? _value.smoothingWindow
          : smoothingWindow // ignore: cast_nullable_to_non_nullable
              as int?,
      visibleTags: freezed == visibleTags
          ? _value.visibleTags
          : visibleTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSeriesChartDtoImplCopyWith<$Res>
    implements $TimeSeriesChartDtoCopyWith<$Res> {
  factory _$$TimeSeriesChartDtoImplCopyWith(_$TimeSeriesChartDtoImpl value,
          $Res Function(_$TimeSeriesChartDtoImpl) then) =
      __$$TimeSeriesChartDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String title,
      DateTime startDate,
      DateTime endDate,
      String aggregation,
      String metric,
      String smoothing,
      List<ChartDataPointDto> dataPoints,
      int? smoothingWindow,
      List<String>? visibleTags,
      DateTime createdAt});
}

/// @nodoc
class __$$TimeSeriesChartDtoImplCopyWithImpl<$Res>
    extends _$TimeSeriesChartDtoCopyWithImpl<$Res, _$TimeSeriesChartDtoImpl>
    implements _$$TimeSeriesChartDtoImplCopyWith<$Res> {
  __$$TimeSeriesChartDtoImplCopyWithImpl(_$TimeSeriesChartDtoImpl _value,
      $Res Function(_$TimeSeriesChartDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeSeriesChartDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? title = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? aggregation = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? dataPoints = null,
    Object? smoothingWindow = freezed,
    Object? visibleTags = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$TimeSeriesChartDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      aggregation: null == aggregation
          ? _value.aggregation
          : aggregation // ignore: cast_nullable_to_non_nullable
              as String,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as String,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as String,
      dataPoints: null == dataPoints
          ? _value._dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPointDto>,
      smoothingWindow: freezed == smoothingWindow
          ? _value.smoothingWindow
          : smoothingWindow // ignore: cast_nullable_to_non_nullable
              as int?,
      visibleTags: freezed == visibleTags
          ? _value._visibleTags
          : visibleTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSeriesChartDtoImpl implements _TimeSeriesChartDto {
  const _$TimeSeriesChartDtoImpl(
      {required this.id,
      required this.accountId,
      required this.title,
      required this.startDate,
      required this.endDate,
      required this.aggregation,
      required this.metric,
      required this.smoothing,
      required final List<ChartDataPointDto> dataPoints,
      this.smoothingWindow,
      final List<String>? visibleTags,
      required this.createdAt})
      : _dataPoints = dataPoints,
        _visibleTags = visibleTags;

  factory _$TimeSeriesChartDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSeriesChartDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String accountId;
  @override
  final String title;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String aggregation;
  @override
  final String metric;
  @override
  final String smoothing;
  final List<ChartDataPointDto> _dataPoints;
  @override
  List<ChartDataPointDto> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

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
  String toString() {
    return 'TimeSeriesChartDto(id: $id, accountId: $accountId, title: $title, startDate: $startDate, endDate: $endDate, aggregation: $aggregation, metric: $metric, smoothing: $smoothing, dataPoints: $dataPoints, smoothingWindow: $smoothingWindow, visibleTags: $visibleTags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSeriesChartDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.aggregation, aggregation) ||
                other.aggregation == aggregation) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.smoothing, smoothing) ||
                other.smoothing == smoothing) &&
            const DeepCollectionEquality()
                .equals(other._dataPoints, _dataPoints) &&
            (identical(other.smoothingWindow, smoothingWindow) ||
                other.smoothingWindow == smoothingWindow) &&
            const DeepCollectionEquality()
                .equals(other._visibleTags, _visibleTags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      accountId,
      title,
      startDate,
      endDate,
      aggregation,
      metric,
      smoothing,
      const DeepCollectionEquality().hash(_dataPoints),
      smoothingWindow,
      const DeepCollectionEquality().hash(_visibleTags),
      createdAt);

  /// Create a copy of TimeSeriesChartDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSeriesChartDtoImplCopyWith<_$TimeSeriesChartDtoImpl> get copyWith =>
      __$$TimeSeriesChartDtoImplCopyWithImpl<_$TimeSeriesChartDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSeriesChartDtoImplToJson(
      this,
    );
  }
}

abstract class _TimeSeriesChartDto implements TimeSeriesChartDto {
  const factory _TimeSeriesChartDto(
      {required final String id,
      required final String accountId,
      required final String title,
      required final DateTime startDate,
      required final DateTime endDate,
      required final String aggregation,
      required final String metric,
      required final String smoothing,
      required final List<ChartDataPointDto> dataPoints,
      final int? smoothingWindow,
      final List<String>? visibleTags,
      required final DateTime createdAt}) = _$TimeSeriesChartDtoImpl;

  factory _TimeSeriesChartDto.fromJson(Map<String, dynamic> json) =
      _$TimeSeriesChartDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get accountId;
  @override
  String get title;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get aggregation;
  @override
  String get metric;
  @override
  String get smoothing;
  @override
  List<ChartDataPointDto> get dataPoints;
  @override
  int? get smoothingWindow;
  @override
  List<String>? get visibleTags;
  @override
  DateTime get createdAt;

  /// Create a copy of TimeSeriesChartDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSeriesChartDtoImplCopyWith<_$TimeSeriesChartDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
