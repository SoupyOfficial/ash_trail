// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reachability_audit_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReachabilityAuditReport {
  String get id => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get screenName => throw _privateConstructorUsedError;
  Size get screenSize => throw _privateConstructorUsedError;
  List<UiElement> get elements => throw _privateConstructorUsedError;
  List<ReachabilityZone> get zones => throw _privateConstructorUsedError;
  AuditSummary get summary => throw _privateConstructorUsedError;
  List<AuditRecommendation>? get recommendations =>
      throw _privateConstructorUsedError;

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReachabilityAuditReportCopyWith<ReachabilityAuditReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReachabilityAuditReportCopyWith<$Res> {
  factory $ReachabilityAuditReportCopyWith(ReachabilityAuditReport value,
          $Res Function(ReachabilityAuditReport) then) =
      _$ReachabilityAuditReportCopyWithImpl<$Res, ReachabilityAuditReport>;
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String screenName,
      Size screenSize,
      List<UiElement> elements,
      List<ReachabilityZone> zones,
      AuditSummary summary,
      List<AuditRecommendation>? recommendations});

  $AuditSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$ReachabilityAuditReportCopyWithImpl<$Res,
        $Val extends ReachabilityAuditReport>
    implements $ReachabilityAuditReportCopyWith<$Res> {
  _$ReachabilityAuditReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? screenName = null,
    Object? screenSize = null,
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
      screenSize: null == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as Size,
      elements: null == elements
          ? _value.elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<UiElement>,
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<ReachabilityZone>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as AuditSummary,
      recommendations: freezed == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<AuditRecommendation>?,
    ) as $Val);
  }

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AuditSummaryCopyWith<$Res> get summary {
    return $AuditSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReachabilityAuditReportImplCopyWith<$Res>
    implements $ReachabilityAuditReportCopyWith<$Res> {
  factory _$$ReachabilityAuditReportImplCopyWith(
          _$ReachabilityAuditReportImpl value,
          $Res Function(_$ReachabilityAuditReportImpl) then) =
      __$$ReachabilityAuditReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime timestamp,
      String screenName,
      Size screenSize,
      List<UiElement> elements,
      List<ReachabilityZone> zones,
      AuditSummary summary,
      List<AuditRecommendation>? recommendations});

  @override
  $AuditSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$ReachabilityAuditReportImplCopyWithImpl<$Res>
    extends _$ReachabilityAuditReportCopyWithImpl<$Res,
        _$ReachabilityAuditReportImpl>
    implements _$$ReachabilityAuditReportImplCopyWith<$Res> {
  __$$ReachabilityAuditReportImplCopyWithImpl(
      _$ReachabilityAuditReportImpl _value,
      $Res Function(_$ReachabilityAuditReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? timestamp = null,
    Object? screenName = null,
    Object? screenSize = null,
    Object? elements = null,
    Object? zones = null,
    Object? summary = null,
    Object? recommendations = freezed,
  }) {
    return _then(_$ReachabilityAuditReportImpl(
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
      screenSize: null == screenSize
          ? _value.screenSize
          : screenSize // ignore: cast_nullable_to_non_nullable
              as Size,
      elements: null == elements
          ? _value._elements
          : elements // ignore: cast_nullable_to_non_nullable
              as List<UiElement>,
      zones: null == zones
          ? _value._zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<ReachabilityZone>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as AuditSummary,
      recommendations: freezed == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<AuditRecommendation>?,
    ));
  }
}

/// @nodoc

class _$ReachabilityAuditReportImpl extends _ReachabilityAuditReport {
  const _$ReachabilityAuditReportImpl(
      {required this.id,
      required this.timestamp,
      required this.screenName,
      required this.screenSize,
      required final List<UiElement> elements,
      required final List<ReachabilityZone> zones,
      required this.summary,
      final List<AuditRecommendation>? recommendations})
      : _elements = elements,
        _zones = zones,
        _recommendations = recommendations,
        super._();

  @override
  final String id;
  @override
  final DateTime timestamp;
  @override
  final String screenName;
  @override
  final Size screenSize;
  final List<UiElement> _elements;
  @override
  List<UiElement> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  final List<ReachabilityZone> _zones;
  @override
  List<ReachabilityZone> get zones {
    if (_zones is EqualUnmodifiableListView) return _zones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_zones);
  }

  @override
  final AuditSummary summary;
  final List<AuditRecommendation>? _recommendations;
  @override
  List<AuditRecommendation>? get recommendations {
    final value = _recommendations;
    if (value == null) return null;
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ReachabilityAuditReport(id: $id, timestamp: $timestamp, screenName: $screenName, screenSize: $screenSize, elements: $elements, zones: $zones, summary: $summary, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReachabilityAuditReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.screenName, screenName) ||
                other.screenName == screenName) &&
            (identical(other.screenSize, screenSize) ||
                other.screenSize == screenSize) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            const DeepCollectionEquality().equals(other._zones, _zones) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      timestamp,
      screenName,
      screenSize,
      const DeepCollectionEquality().hash(_elements),
      const DeepCollectionEquality().hash(_zones),
      summary,
      const DeepCollectionEquality().hash(_recommendations));

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReachabilityAuditReportImplCopyWith<_$ReachabilityAuditReportImpl>
      get copyWith => __$$ReachabilityAuditReportImplCopyWithImpl<
          _$ReachabilityAuditReportImpl>(this, _$identity);
}

abstract class _ReachabilityAuditReport extends ReachabilityAuditReport {
  const factory _ReachabilityAuditReport(
          {required final String id,
          required final DateTime timestamp,
          required final String screenName,
          required final Size screenSize,
          required final List<UiElement> elements,
          required final List<ReachabilityZone> zones,
          required final AuditSummary summary,
          final List<AuditRecommendation>? recommendations}) =
      _$ReachabilityAuditReportImpl;
  const _ReachabilityAuditReport._() : super._();

  @override
  String get id;
  @override
  DateTime get timestamp;
  @override
  String get screenName;
  @override
  Size get screenSize;
  @override
  List<UiElement> get elements;
  @override
  List<ReachabilityZone> get zones;
  @override
  AuditSummary get summary;
  @override
  List<AuditRecommendation>? get recommendations;

  /// Create a copy of ReachabilityAuditReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReachabilityAuditReportImplCopyWith<_$ReachabilityAuditReportImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuditSummary {
  int get totalElements => throw _privateConstructorUsedError;
  int get interactiveElements => throw _privateConstructorUsedError;
  int get elementsInEasyReach => throw _privateConstructorUsedError;
  int get elementsWithIssues => throw _privateConstructorUsedError;
  double get avgTouchTargetSize => throw _privateConstructorUsedError;
  int get accessibilityIssues => throw _privateConstructorUsedError;

  /// Create a copy of AuditSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditSummaryCopyWith<AuditSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditSummaryCopyWith<$Res> {
  factory $AuditSummaryCopyWith(
          AuditSummary value, $Res Function(AuditSummary) then) =
      _$AuditSummaryCopyWithImpl<$Res, AuditSummary>;
  @useResult
  $Res call(
      {int totalElements,
      int interactiveElements,
      int elementsInEasyReach,
      int elementsWithIssues,
      double avgTouchTargetSize,
      int accessibilityIssues});
}

/// @nodoc
class _$AuditSummaryCopyWithImpl<$Res, $Val extends AuditSummary>
    implements $AuditSummaryCopyWith<$Res> {
  _$AuditSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalElements = null,
    Object? interactiveElements = null,
    Object? elementsInEasyReach = null,
    Object? elementsWithIssues = null,
    Object? avgTouchTargetSize = null,
    Object? accessibilityIssues = null,
  }) {
    return _then(_value.copyWith(
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      interactiveElements: null == interactiveElements
          ? _value.interactiveElements
          : interactiveElements // ignore: cast_nullable_to_non_nullable
              as int,
      elementsInEasyReach: null == elementsInEasyReach
          ? _value.elementsInEasyReach
          : elementsInEasyReach // ignore: cast_nullable_to_non_nullable
              as int,
      elementsWithIssues: null == elementsWithIssues
          ? _value.elementsWithIssues
          : elementsWithIssues // ignore: cast_nullable_to_non_nullable
              as int,
      avgTouchTargetSize: null == avgTouchTargetSize
          ? _value.avgTouchTargetSize
          : avgTouchTargetSize // ignore: cast_nullable_to_non_nullable
              as double,
      accessibilityIssues: null == accessibilityIssues
          ? _value.accessibilityIssues
          : accessibilityIssues // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditSummaryImplCopyWith<$Res>
    implements $AuditSummaryCopyWith<$Res> {
  factory _$$AuditSummaryImplCopyWith(
          _$AuditSummaryImpl value, $Res Function(_$AuditSummaryImpl) then) =
      __$$AuditSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalElements,
      int interactiveElements,
      int elementsInEasyReach,
      int elementsWithIssues,
      double avgTouchTargetSize,
      int accessibilityIssues});
}

/// @nodoc
class __$$AuditSummaryImplCopyWithImpl<$Res>
    extends _$AuditSummaryCopyWithImpl<$Res, _$AuditSummaryImpl>
    implements _$$AuditSummaryImplCopyWith<$Res> {
  __$$AuditSummaryImplCopyWithImpl(
      _$AuditSummaryImpl _value, $Res Function(_$AuditSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalElements = null,
    Object? interactiveElements = null,
    Object? elementsInEasyReach = null,
    Object? elementsWithIssues = null,
    Object? avgTouchTargetSize = null,
    Object? accessibilityIssues = null,
  }) {
    return _then(_$AuditSummaryImpl(
      totalElements: null == totalElements
          ? _value.totalElements
          : totalElements // ignore: cast_nullable_to_non_nullable
              as int,
      interactiveElements: null == interactiveElements
          ? _value.interactiveElements
          : interactiveElements // ignore: cast_nullable_to_non_nullable
              as int,
      elementsInEasyReach: null == elementsInEasyReach
          ? _value.elementsInEasyReach
          : elementsInEasyReach // ignore: cast_nullable_to_non_nullable
              as int,
      elementsWithIssues: null == elementsWithIssues
          ? _value.elementsWithIssues
          : elementsWithIssues // ignore: cast_nullable_to_non_nullable
              as int,
      avgTouchTargetSize: null == avgTouchTargetSize
          ? _value.avgTouchTargetSize
          : avgTouchTargetSize // ignore: cast_nullable_to_non_nullable
              as double,
      accessibilityIssues: null == accessibilityIssues
          ? _value.accessibilityIssues
          : accessibilityIssues // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AuditSummaryImpl implements _AuditSummary {
  const _$AuditSummaryImpl(
      {required this.totalElements,
      required this.interactiveElements,
      required this.elementsInEasyReach,
      required this.elementsWithIssues,
      required this.avgTouchTargetSize,
      required this.accessibilityIssues});

  @override
  final int totalElements;
  @override
  final int interactiveElements;
  @override
  final int elementsInEasyReach;
  @override
  final int elementsWithIssues;
  @override
  final double avgTouchTargetSize;
  @override
  final int accessibilityIssues;

  @override
  String toString() {
    return 'AuditSummary(totalElements: $totalElements, interactiveElements: $interactiveElements, elementsInEasyReach: $elementsInEasyReach, elementsWithIssues: $elementsWithIssues, avgTouchTargetSize: $avgTouchTargetSize, accessibilityIssues: $accessibilityIssues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditSummaryImpl &&
            (identical(other.totalElements, totalElements) ||
                other.totalElements == totalElements) &&
            (identical(other.interactiveElements, interactiveElements) ||
                other.interactiveElements == interactiveElements) &&
            (identical(other.elementsInEasyReach, elementsInEasyReach) ||
                other.elementsInEasyReach == elementsInEasyReach) &&
            (identical(other.elementsWithIssues, elementsWithIssues) ||
                other.elementsWithIssues == elementsWithIssues) &&
            (identical(other.avgTouchTargetSize, avgTouchTargetSize) ||
                other.avgTouchTargetSize == avgTouchTargetSize) &&
            (identical(other.accessibilityIssues, accessibilityIssues) ||
                other.accessibilityIssues == accessibilityIssues));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalElements,
      interactiveElements,
      elementsInEasyReach,
      elementsWithIssues,
      avgTouchTargetSize,
      accessibilityIssues);

  /// Create a copy of AuditSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditSummaryImplCopyWith<_$AuditSummaryImpl> get copyWith =>
      __$$AuditSummaryImplCopyWithImpl<_$AuditSummaryImpl>(this, _$identity);
}

abstract class _AuditSummary implements AuditSummary {
  const factory _AuditSummary(
      {required final int totalElements,
      required final int interactiveElements,
      required final int elementsInEasyReach,
      required final int elementsWithIssues,
      required final double avgTouchTargetSize,
      required final int accessibilityIssues}) = _$AuditSummaryImpl;

  @override
  int get totalElements;
  @override
  int get interactiveElements;
  @override
  int get elementsInEasyReach;
  @override
  int get elementsWithIssues;
  @override
  double get avgTouchTargetSize;
  @override
  int get accessibilityIssues;

  /// Create a copy of AuditSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditSummaryImplCopyWith<_$AuditSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AuditRecommendation {
  String get elementId => throw _privateConstructorUsedError;
  RecommendationType get type => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get suggestedFix => throw _privateConstructorUsedError;

  /// Create a copy of AuditRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditRecommendationCopyWith<AuditRecommendation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditRecommendationCopyWith<$Res> {
  factory $AuditRecommendationCopyWith(
          AuditRecommendation value, $Res Function(AuditRecommendation) then) =
      _$AuditRecommendationCopyWithImpl<$Res, AuditRecommendation>;
  @useResult
  $Res call(
      {String elementId,
      RecommendationType type,
      String description,
      int priority,
      String? suggestedFix});
}

/// @nodoc
class _$AuditRecommendationCopyWithImpl<$Res, $Val extends AuditRecommendation>
    implements $AuditRecommendationCopyWith<$Res> {
  _$AuditRecommendationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elementId = null,
    Object? type = null,
    Object? description = null,
    Object? priority = null,
    Object? suggestedFix = freezed,
  }) {
    return _then(_value.copyWith(
      elementId: null == elementId
          ? _value.elementId
          : elementId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedFix: freezed == suggestedFix
          ? _value.suggestedFix
          : suggestedFix // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditRecommendationImplCopyWith<$Res>
    implements $AuditRecommendationCopyWith<$Res> {
  factory _$$AuditRecommendationImplCopyWith(_$AuditRecommendationImpl value,
          $Res Function(_$AuditRecommendationImpl) then) =
      __$$AuditRecommendationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String elementId,
      RecommendationType type,
      String description,
      int priority,
      String? suggestedFix});
}

/// @nodoc
class __$$AuditRecommendationImplCopyWithImpl<$Res>
    extends _$AuditRecommendationCopyWithImpl<$Res, _$AuditRecommendationImpl>
    implements _$$AuditRecommendationImplCopyWith<$Res> {
  __$$AuditRecommendationImplCopyWithImpl(_$AuditRecommendationImpl _value,
      $Res Function(_$AuditRecommendationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? elementId = null,
    Object? type = null,
    Object? description = null,
    Object? priority = null,
    Object? suggestedFix = freezed,
  }) {
    return _then(_$AuditRecommendationImpl(
      elementId: null == elementId
          ? _value.elementId
          : elementId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RecommendationType,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      suggestedFix: freezed == suggestedFix
          ? _value.suggestedFix
          : suggestedFix // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AuditRecommendationImpl implements _AuditRecommendation {
  const _$AuditRecommendationImpl(
      {required this.elementId,
      required this.type,
      required this.description,
      required this.priority,
      this.suggestedFix});

  @override
  final String elementId;
  @override
  final RecommendationType type;
  @override
  final String description;
  @override
  final int priority;
  @override
  final String? suggestedFix;

  @override
  String toString() {
    return 'AuditRecommendation(elementId: $elementId, type: $type, description: $description, priority: $priority, suggestedFix: $suggestedFix)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditRecommendationImpl &&
            (identical(other.elementId, elementId) ||
                other.elementId == elementId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.suggestedFix, suggestedFix) ||
                other.suggestedFix == suggestedFix));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, elementId, type, description, priority, suggestedFix);

  /// Create a copy of AuditRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditRecommendationImplCopyWith<_$AuditRecommendationImpl> get copyWith =>
      __$$AuditRecommendationImplCopyWithImpl<_$AuditRecommendationImpl>(
          this, _$identity);
}

abstract class _AuditRecommendation implements AuditRecommendation {
  const factory _AuditRecommendation(
      {required final String elementId,
      required final RecommendationType type,
      required final String description,
      required final int priority,
      final String? suggestedFix}) = _$AuditRecommendationImpl;

  @override
  String get elementId;
  @override
  RecommendationType get type;
  @override
  String get description;
  @override
  int get priority;
  @override
  String? get suggestedFix;

  /// Create a copy of AuditRecommendation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditRecommendationImplCopyWith<_$AuditRecommendationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
