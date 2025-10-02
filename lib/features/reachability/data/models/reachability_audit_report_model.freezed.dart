// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reachability_audit_report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReachabilityAuditReportModel _$ReachabilityAuditReportModelFromJson(
    Map<String, dynamic> json) {
  return _ReachabilityAuditReportModel.fromJson(json);
}

/// @nodoc
mixin _$ReachabilityAuditReportModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get screenName => throw _privateConstructorUsedError;
  double get screenWidth => throw _privateConstructorUsedError;
  double get screenHeight => throw _privateConstructorUsedError;
  List<UiElementModel> get elements => throw _privateConstructorUsedError;
  List<ReachabilityZoneModel> get zones => throw _privateConstructorUsedError;
  AuditSummaryModel get summary => throw _privateConstructorUsedError;
  List<AuditRecommendationModel>? get recommendations =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReachabilityAuditReportModelCopyWith<ReachabilityAuditReportModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReachabilityAuditReportModelCopyWith<$Res> {
  factory $ReachabilityAuditReportModelCopyWith(
          ReachabilityAuditReportModel value,
          $Res Function(ReachabilityAuditReportModel) then) =
      _$ReachabilityAuditReportModelCopyWithImpl<$Res,
          ReachabilityAuditReportModel>;
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String screenName,
      double screenWidth,
      double screenHeight,
      List<UiElementModel> elements,
      List<ReachabilityZoneModel> zones,
      AuditSummaryModel summary,
      List<AuditRecommendationModel>? recommendations});

  $AuditSummaryModelCopyWith<$Res> get summary;
}

/// @nodoc
class _$ReachabilityAuditReportModelCopyWithImpl<$Res,
        $Val extends ReachabilityAuditReportModel>
    implements $ReachabilityAuditReportModelCopyWith<$Res> {
  _$ReachabilityAuditReportModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? screenName = null,
    Object? screenWidth = null,
    Object? screenHeight = null,
    Object? elements = null,
    Object? zones = null,
    Object? summary = null,
    Object? recommendations = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      screenName: null == screenName
          ? _value.screenName
          : screenName // ignore: cast_nullable_to_non_nullable
              as String,
      screenWidth: null == screenWidth
          ? _value.screenWidth
          : screenWidth // ignore: cast_nullable_to_non_nullable
              as double,
      screenHeight: null == screenHeight
          ? _value.screenHeight
          : screenHeight // ignore: cast_nullable_to_non_nullable
              as double,
      elements: null == elements
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<UiElementModel>,
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<ReachabilityZoneModel>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as AuditSummaryModel,
      recommendations: freezed == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<AuditRecommendationModel>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AuditSummaryModelCopyWith<$Res> get summary {
    return $AuditSummaryModelCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReachabilityAuditReportModelImplCopyWith<$Res>
    implements $ReachabilityAuditReportModelCopyWith<$Res> {
  factory _$$ReachabilityAuditReportModelImplCopyWith(
          _$ReachabilityAuditReportModelImpl value,
          $Res Function(_$ReachabilityAuditReportModelImpl) then) =
      __$$ReachabilityAuditReportModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String screenName,
      double screenWidth,
      double screenHeight,
      List<UiElementModel> elements,
      List<ReachabilityZoneModel> zones,
      AuditSummaryModel summary,
      List<AuditRecommendationModel>? recommendations});

  @override
  $AuditSummaryModelCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ReachabilityAuditReportModelImplCopyWithImpl<$Res>
    extends _$ReachabilityAuditReportModelCopyWithImpl<$Res,
        _$ReachabilityAuditReportModelImpl>
    implements _$$ReachabilityAuditReportModelImplCopyWith<$Res> {
  __$$ReachabilityAuditReportModelImplCopyWithImpl(
      _$ReachabilityAuditReportModelImpl _value,
      $Res Function(_$ReachabilityAuditReportModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? screenName = null,
    Object? screenWidth = null,
    Object? screenHeight = null,
    Object? elements = null,
    Object? zones = null,
    Object? summary = null,
    Object? recommendations = freezed,
  }) {
    return _then(_$ReachabilityAuditReportModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      screenName: null == screenName
          ? _value.screenName
          : screenName // ignore: cast_nullable_to_non_nullable
              as String,
      screenWidth: null == screenWidth
          ? _value.screenWidth
          : screenWidth // ignore: cast_nullable_to_non_nullable
              as double,
      screenHeight: null == screenHeight
          ? _value.screenHeight
          : screenHeight // ignore: cast_nullable_to_non_nullable
              as double,
      elements: null == elements
          ? _value._elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<UiElementModel>,
      zones: null == zones
          ? _value._zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<ReachabilityZoneModel>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as AuditSummaryModel,
      recommendations: freezed == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<AuditRecommendationModel>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReachabilityAuditReportModelImpl extends _ReachabilityAuditReportModel {
  const _$ReachabilityAuditReportModelImpl(
      {required this.id,
      required this.timestamp,
      required this.screenName,
      required this.screenWidth,
      required this.screenHeight,
      required final List<UiElementModel> elements,
      required final List<ReachabilityZoneModel> zones,
      required this.summary,
      final List<AuditRecommendationModel>? recommendations})
      : _elements = elements,
        _zones = zones,
        _recommendations = recommendations,
        super._();

  factory _$ReachabilityAuditReportModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ReachabilityAuditReportModelImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime timestamp;
  @override
  final String screenName;
  @override
  final double screenWidth;
  @override
  final double screenHeight;
  final List<UiElementModel> _elements;
  @override
  List<UiElementModel> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  final List<ReachabilityZoneModel> _zones;
  @override
  List<ReachabilityZoneModel> get zones {
    if (_zones is EqualUnmodifiableListView) return _zones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_zones);
  }

  @override
  final AuditSummaryModel summary;
  final List<AuditRecommendationModel>? _recommendations;
  @override
  List<AuditRecommendationModel>? get recommendations {
    final value = _recommendations;
    if (value == null) return null;
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ReachabilityAuditReportModel(id: $id, timestamp: $timestamp, screenName: $screenName, screenWidth: $screenWidth, screenHeight: $screenHeight, elements: $elements, zones: $zones, summary: $summary, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReachabilityAuditReportModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.screenName, screenName) ||
                other.screenName == screenName) &&
            (identical(other.screenWidth, screenWidth) ||
                other.screenWidth == screenWidth) &&
            (identical(other.screenHeight, screenHeight) ||
                other.screenHeight == screenHeight) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            const DeepCollectionEquality().equals(other._zones, _zones) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      timestamp,
      screenName,
      screenWidth,
      screenHeight,
      const DeepCollectionEquality().hash(_elements),
      const DeepCollectionEquality().hash(_zones),
      summary,
      const DeepCollectionEquality().hash(_recommendations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReachabilityAuditReportModelImplCopyWith<
          _$ReachabilityAuditReportModelImpl>
      get copyWith => __$$ReachabilityAuditReportModelImplCopyWithImpl<
          _$ReachabilityAuditReportModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReachabilityAuditReportModelImplToJson(
      this,
    );
  }
}

abstract class _ReachabilityAuditReportModel
    extends ReachabilityAuditReportModel {
  const factory _ReachabilityAuditReportModel(
          {required final String id,
          required final DateTime timestamp,
          required final String screenName,
          required final double screenWidth,
          required final double screenHeight,
          required final List<UiElementModel> elements,
          required final List<ReachabilityZoneModel> zones,
          required final AuditSummaryModel summary,
          final List<AuditRecommendationModel>? recommendations}) =
      _$ReachabilityAuditReportModelImpl;
  const _ReachabilityAuditReportModel._() : super._();

  factory _ReachabilityAuditReportModel.fromJson(Map<String, dynamic> json) =
      _$ReachabilityAuditReportModelImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  String get screenName;
  @override
  double get screenWidth;
  @override
  double get screenHeight;
  @override
  List<UiElementModel> get elements;
  @override
  List<ReachabilityZoneModel> get zones;
  @override
  AuditSummaryModel get summary;
  @override
  List<AuditRecommendationModel>? get recommendations;
  @override
  @JsonKey(ignore: true)
  _$$ReachabilityAuditReportModelImplCopyWith<
          _$ReachabilityAuditReportModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
