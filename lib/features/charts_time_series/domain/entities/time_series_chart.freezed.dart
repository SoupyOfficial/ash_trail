// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_series_chart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimeSeriesChart _$TimeSeriesChartFromJson(Map<String, dynamic> json) {
  return _TimeSeriesChart.fromJson(json);
}

/// @nodoc
mixin _$TimeSeriesChart {
  /// Unique identifier for this chart
  String get id => throw _privateConstructorUsedError;

  /// Account this chart belongs to
  String get accountId => throw _privateConstructorUsedError;

  /// Human-readable title for the chart
  String get title => throw _privateConstructorUsedError;

  /// Time range start (inclusive)
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Time range end (inclusive)
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Aggregation level for data points
  ChartAggregation get aggregation => throw _privateConstructorUsedError;

  /// Metric being displayed
  ChartMetric get metric => throw _privateConstructorUsedError;

  /// Smoothing applied to the data
  ChartSmoothing get smoothing => throw _privateConstructorUsedError;

  /// Data points for the chart
  List<ChartDataPoint> get dataPoints => throw _privateConstructorUsedError;

  /// Window size for moving average (if applicable)
  int? get smoothingWindow => throw _privateConstructorUsedError;

  /// Tags to filter by (null means all tags)
  List<String>? get visibleTags => throw _privateConstructorUsedError;

  /// When this chart was generated
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeSeriesChartCopyWith<TimeSeriesChart> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSeriesChartCopyWith<$Res> {
  factory $TimeSeriesChartCopyWith(
          TimeSeriesChart value, $Res Function(TimeSeriesChart) then) =
      _$TimeSeriesChartCopyWithImpl<$Res, TimeSeriesChart>;
  @useResult
  $Res call(
      {String id,
      String accountId,
      String title,
      DateTime startDate,
      DateTime endDate,
      ChartAggregation aggregation,
      ChartMetric metric,
      ChartSmoothing smoothing,
      List<ChartDataPoint> dataPoints,
      int? smoothingWindow,
      List<String>? visibleTags,
      DateTime createdAt});
}

/// @nodoc
class _$TimeSeriesChartCopyWithImpl<$Res, $Val extends TimeSeriesChart>
    implements $TimeSeriesChartCopyWith<$Res> {
  _$TimeSeriesChartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
              as ChartAggregation,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as ChartMetric,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as ChartSmoothing,
      dataPoints: null == dataPoints
          ? _value.dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
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
abstract class _$$TimeSeriesChartImplCopyWith<$Res>
    implements $TimeSeriesChartCopyWith<$Res> {
  factory _$$TimeSeriesChartImplCopyWith(_$TimeSeriesChartImpl value,
          $Res Function(_$TimeSeriesChartImpl) then) =
      __$$TimeSeriesChartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String accountId,
      String title,
      DateTime startDate,
      DateTime endDate,
      ChartAggregation aggregation,
      ChartMetric metric,
      ChartSmoothing smoothing,
      List<ChartDataPoint> dataPoints,
      int? smoothingWindow,
      List<String>? visibleTags,
      DateTime createdAt});
}

/// @nodoc
class __$$TimeSeriesChartImplCopyWithImpl<$Res>
    extends _$TimeSeriesChartCopyWithImpl<$Res, _$TimeSeriesChartImpl>
    implements _$$TimeSeriesChartImplCopyWith<$Res> {
  __$$TimeSeriesChartImplCopyWithImpl(
      _$TimeSeriesChartImpl _value, $Res Function(_$TimeSeriesChartImpl) _then)
      : super(_value, _then);

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
    return _then(_$TimeSeriesChartImpl(
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
              as ChartAggregation,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as ChartMetric,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as ChartSmoothing,
      dataPoints: null == dataPoints
          ? _value._dataPoints
          : dataPoints // ignore: cast_nullable_to_non_nullable
              as List<ChartDataPoint>,
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
class _$TimeSeriesChartImpl extends _TimeSeriesChart {
  const _$TimeSeriesChartImpl(
      {required this.id,
      required this.accountId,
      required this.title,
      required this.startDate,
      required this.endDate,
      required this.aggregation,
      required this.metric,
      required this.smoothing,
      required final List<ChartDataPoint> dataPoints,
      this.smoothingWindow,
      final List<String>? visibleTags,
      required this.createdAt})
      : _dataPoints = dataPoints,
        _visibleTags = visibleTags,
        super._();

  factory _$TimeSeriesChartImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSeriesChartImplFromJson(json);

  /// Unique identifier for this chart
  @override
  final String id;

  /// Account this chart belongs to
  @override
  final String accountId;

  /// Human-readable title for the chart
  @override
  final String title;

  /// Time range start (inclusive)
  @override
  final DateTime startDate;

  /// Time range end (inclusive)
  @override
  final DateTime endDate;

  /// Aggregation level for data points
  @override
  final ChartAggregation aggregation;

  /// Metric being displayed
  @override
  final ChartMetric metric;

  /// Smoothing applied to the data
  @override
  final ChartSmoothing smoothing;

  /// Data points for the chart
  final List<ChartDataPoint> _dataPoints;

  /// Data points for the chart
  @override
  List<ChartDataPoint> get dataPoints {
    if (_dataPoints is EqualUnmodifiableListView) return _dataPoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dataPoints);
  }

  /// Window size for moving average (if applicable)
  @override
  final int? smoothingWindow;

  /// Tags to filter by (null means all tags)
  final List<String>? _visibleTags;

  /// Tags to filter by (null means all tags)
  @override
  List<String>? get visibleTags {
    final value = _visibleTags;
    if (value == null) return null;
    if (_visibleTags is EqualUnmodifiableListView) return _visibleTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// When this chart was generated
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TimeSeriesChart(id: $id, accountId: $accountId, title: $title, startDate: $startDate, endDate: $endDate, aggregation: $aggregation, metric: $metric, smoothing: $smoothing, dataPoints: $dataPoints, smoothingWindow: $smoothingWindow, visibleTags: $visibleTags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSeriesChartImpl &&
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

  @JsonKey(ignore: true)
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

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSeriesChartImplCopyWith<_$TimeSeriesChartImpl> get copyWith =>
      __$$TimeSeriesChartImplCopyWithImpl<_$TimeSeriesChartImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSeriesChartImplToJson(
      this,
    );
  }
}

abstract class _TimeSeriesChart extends TimeSeriesChart {
  const factory _TimeSeriesChart(
      {required final String id,
      required final String accountId,
      required final String title,
      required final DateTime startDate,
      required final DateTime endDate,
      required final ChartAggregation aggregation,
      required final ChartMetric metric,
      required final ChartSmoothing smoothing,
      required final List<ChartDataPoint> dataPoints,
      final int? smoothingWindow,
      final List<String>? visibleTags,
      required final DateTime createdAt}) = _$TimeSeriesChartImpl;
  const _TimeSeriesChart._() : super._();

  factory _TimeSeriesChart.fromJson(Map<String, dynamic> json) =
      _$TimeSeriesChartImpl.fromJson;

  @override

  /// Unique identifier for this chart
  String get id;
  @override

  /// Account this chart belongs to
  String get accountId;
  @override

  /// Human-readable title for the chart
  String get title;
  @override

  /// Time range start (inclusive)
  DateTime get startDate;
  @override

  /// Time range end (inclusive)
  DateTime get endDate;
  @override

  /// Aggregation level for data points
  ChartAggregation get aggregation;
  @override

  /// Metric being displayed
  ChartMetric get metric;
  @override

  /// Smoothing applied to the data
  ChartSmoothing get smoothing;
  @override

  /// Data points for the chart
  List<ChartDataPoint> get dataPoints;
  @override

  /// Window size for moving average (if applicable)
  int? get smoothingWindow;
  @override

  /// Tags to filter by (null means all tags)
  List<String>? get visibleTags;
  @override

  /// When this chart was generated
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TimeSeriesChartImplCopyWith<_$TimeSeriesChartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChartConfig _$ChartConfigFromJson(Map<String, dynamic> json) {
  return _ChartConfig.fromJson(json);
}

/// @nodoc
mixin _$ChartConfig {
  /// Account to fetch data for
  String get accountId => throw _privateConstructorUsedError;

  /// Time range start
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Time range end
  DateTime get endDate => throw _privateConstructorUsedError;

  /// How to aggregate the data
  ChartAggregation get aggregation => throw _privateConstructorUsedError;

  /// Which metric to display
  ChartMetric get metric => throw _privateConstructorUsedError;

  /// How to smooth the data
  ChartSmoothing get smoothing => throw _privateConstructorUsedError;

  /// Moving average window size
  int get smoothingWindow => throw _privateConstructorUsedError;

  /// Filter by specific tags (null = all tags)
  List<String>? get visibleTags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChartConfigCopyWith<ChartConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChartConfigCopyWith<$Res> {
  factory $ChartConfigCopyWith(
          ChartConfig value, $Res Function(ChartConfig) then) =
      _$ChartConfigCopyWithImpl<$Res, ChartConfig>;
  @useResult
  $Res call(
      {String accountId,
      DateTime startDate,
      DateTime endDate,
      ChartAggregation aggregation,
      ChartMetric metric,
      ChartSmoothing smoothing,
      int smoothingWindow,
      List<String>? visibleTags});
}

/// @nodoc
class _$ChartConfigCopyWithImpl<$Res, $Val extends ChartConfig>
    implements $ChartConfigCopyWith<$Res> {
  _$ChartConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? aggregation = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? smoothingWindow = null,
    Object? visibleTags = freezed,
  }) {
    return _then(_value.copyWith(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
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
              as ChartAggregation,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as ChartMetric,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as ChartSmoothing,
      smoothingWindow: null == smoothingWindow
          ? _value.smoothingWindow
          : smoothingWindow // ignore: cast_nullable_to_non_nullable
              as int,
      visibleTags: freezed == visibleTags
          ? _value.visibleTags
          : visibleTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChartConfigImplCopyWith<$Res>
    implements $ChartConfigCopyWith<$Res> {
  factory _$$ChartConfigImplCopyWith(
          _$ChartConfigImpl value, $Res Function(_$ChartConfigImpl) then) =
      __$$ChartConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accountId,
      DateTime startDate,
      DateTime endDate,
      ChartAggregation aggregation,
      ChartMetric metric,
      ChartSmoothing smoothing,
      int smoothingWindow,
      List<String>? visibleTags});
}

/// @nodoc
class __$$ChartConfigImplCopyWithImpl<$Res>
    extends _$ChartConfigCopyWithImpl<$Res, _$ChartConfigImpl>
    implements _$$ChartConfigImplCopyWith<$Res> {
  __$$ChartConfigImplCopyWithImpl(
      _$ChartConfigImpl _value, $Res Function(_$ChartConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accountId = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? aggregation = null,
    Object? metric = null,
    Object? smoothing = null,
    Object? smoothingWindow = null,
    Object? visibleTags = freezed,
  }) {
    return _then(_$ChartConfigImpl(
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
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
              as ChartAggregation,
      metric: null == metric
          ? _value.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as ChartMetric,
      smoothing: null == smoothing
          ? _value.smoothing
          : smoothing // ignore: cast_nullable_to_non_nullable
              as ChartSmoothing,
      smoothingWindow: null == smoothingWindow
          ? _value.smoothingWindow
          : smoothingWindow // ignore: cast_nullable_to_non_nullable
              as int,
      visibleTags: freezed == visibleTags
          ? _value._visibleTags
          : visibleTags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChartConfigImpl extends _ChartConfig {
  const _$ChartConfigImpl(
      {required this.accountId,
      required this.startDate,
      required this.endDate,
      required this.aggregation,
      required this.metric,
      required this.smoothing,
      this.smoothingWindow = 7,
      final List<String>? visibleTags})
      : _visibleTags = visibleTags,
        super._();

  factory _$ChartConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChartConfigImplFromJson(json);

  /// Account to fetch data for
  @override
  final String accountId;

  /// Time range start
  @override
  final DateTime startDate;

  /// Time range end
  @override
  final DateTime endDate;

  /// How to aggregate the data
  @override
  final ChartAggregation aggregation;

  /// Which metric to display
  @override
  final ChartMetric metric;

  /// How to smooth the data
  @override
  final ChartSmoothing smoothing;

  /// Moving average window size
  @override
  @JsonKey()
  final int smoothingWindow;

  /// Filter by specific tags (null = all tags)
  final List<String>? _visibleTags;

  /// Filter by specific tags (null = all tags)
  @override
  List<String>? get visibleTags {
    final value = _visibleTags;
    if (value == null) return null;
    if (_visibleTags is EqualUnmodifiableListView) return _visibleTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ChartConfig(accountId: $accountId, startDate: $startDate, endDate: $endDate, aggregation: $aggregation, metric: $metric, smoothing: $smoothing, smoothingWindow: $smoothingWindow, visibleTags: $visibleTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChartConfigImpl &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.aggregation, aggregation) ||
                other.aggregation == aggregation) &&
            (identical(other.metric, metric) || other.metric == metric) &&
            (identical(other.smoothing, smoothing) ||
                other.smoothing == smoothing) &&
            (identical(other.smoothingWindow, smoothingWindow) ||
                other.smoothingWindow == smoothingWindow) &&
            const DeepCollectionEquality()
                .equals(other._visibleTags, _visibleTags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      accountId,
      startDate,
      endDate,
      aggregation,
      metric,
      smoothing,
      smoothingWindow,
      const DeepCollectionEquality().hash(_visibleTags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChartConfigImplCopyWith<_$ChartConfigImpl> get copyWith =>
      __$$ChartConfigImplCopyWithImpl<_$ChartConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChartConfigImplToJson(
      this,
    );
  }
}

abstract class _ChartConfig extends ChartConfig {
  const factory _ChartConfig(
      {required final String accountId,
      required final DateTime startDate,
      required final DateTime endDate,
      required final ChartAggregation aggregation,
      required final ChartMetric metric,
      required final ChartSmoothing smoothing,
      final int smoothingWindow,
      final List<String>? visibleTags}) = _$ChartConfigImpl;
  const _ChartConfig._() : super._();

  factory _ChartConfig.fromJson(Map<String, dynamic> json) =
      _$ChartConfigImpl.fromJson;

  @override

  /// Account to fetch data for
  String get accountId;
  @override

  /// Time range start
  DateTime get startDate;
  @override

  /// Time range end
  DateTime get endDate;
  @override

  /// How to aggregate the data
  ChartAggregation get aggregation;
  @override

  /// Which metric to display
  ChartMetric get metric;
  @override

  /// How to smooth the data
  ChartSmoothing get smoothing;
  @override

  /// Moving average window size
  int get smoothingWindow;
  @override

  /// Filter by specific tags (null = all tags)
  List<String>? get visibleTags;
  @override
  @JsonKey(ignore: true)
  _$$ChartConfigImplCopyWith<_$ChartConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
