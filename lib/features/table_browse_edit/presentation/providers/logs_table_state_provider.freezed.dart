// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logs_table_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogsTableState {
// Filter and sort state
  LogFilter get filter => throw _privateConstructorUsedError;
  LogSort get sort => throw _privateConstructorUsedError; // Pagination state
  int get pageSize => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalLogs =>
      throw _privateConstructorUsedError; // Selection state for multi-select operations
  Set<String> get selectedLogIds =>
      throw _privateConstructorUsedError; // Loading states
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError; // Error state
  String? get error => throw _privateConstructorUsedError; // Account context
  String get accountId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LogsTableStateCopyWith<LogsTableState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogsTableStateCopyWith<$Res> {
  factory $LogsTableStateCopyWith(
          LogsTableState value, $Res Function(LogsTableState) then) =
      _$LogsTableStateCopyWithImpl<$Res, LogsTableState>;
  @useResult
  $Res call(
      {LogFilter filter,
      LogSort sort,
      int pageSize,
      int currentPage,
      int totalLogs,
      Set<String> selectedLogIds,
      bool isLoading,
      bool isRefreshing,
      String? error,
      String accountId});

  $LogFilterCopyWith<$Res> get filter;
  $LogSortCopyWith<$Res> get sort;
}

/// @nodoc
class _$LogsTableStateCopyWithImpl<$Res, $Val extends LogsTableState>
    implements $LogsTableStateCopyWith<$Res> {
  _$LogsTableStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
    Object? sort = null,
    Object? pageSize = null,
    Object? currentPage = null,
    Object? totalLogs = null,
    Object? selectedLogIds = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? accountId = null,
  }) {
    return _then(_value.copyWith(
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as LogFilter,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as LogSort,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalLogs: null == totalLogs
          ? _value.totalLogs
          : totalLogs // ignore: cast_nullable_to_non_nullable
              as int,
      selectedLogIds: null == selectedLogIds
          ? _value.selectedLogIds
          : selectedLogIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LogFilterCopyWith<$Res> get filter {
    return $LogFilterCopyWith<$Res>(_value.filter, (value) {
      return _then(_value.copyWith(filter: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LogSortCopyWith<$Res> get sort {
    return $LogSortCopyWith<$Res>(_value.sort, (value) {
      return _then(_value.copyWith(sort: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LogsTableStateImplCopyWith<$Res>
    implements $LogsTableStateCopyWith<$Res> {
  factory _$$LogsTableStateImplCopyWith(_$LogsTableStateImpl value,
          $Res Function(_$LogsTableStateImpl) then) =
      __$$LogsTableStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LogFilter filter,
      LogSort sort,
      int pageSize,
      int currentPage,
      int totalLogs,
      Set<String> selectedLogIds,
      bool isLoading,
      bool isRefreshing,
      String? error,
      String accountId});

  @override
  $LogFilterCopyWith<$Res> get filter;
  @override
  $LogSortCopyWith<$Res> get sort;
}

/// @nodoc
class __$$LogsTableStateImplCopyWithImpl<$Res>
    extends _$LogsTableStateCopyWithImpl<$Res, _$LogsTableStateImpl>
    implements _$$LogsTableStateImplCopyWith<$Res> {
  __$$LogsTableStateImplCopyWithImpl(
      _$LogsTableStateImpl _value, $Res Function(_$LogsTableStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filter = null,
    Object? sort = null,
    Object? pageSize = null,
    Object? currentPage = null,
    Object? totalLogs = null,
    Object? selectedLogIds = null,
    Object? isLoading = null,
    Object? isRefreshing = null,
    Object? error = freezed,
    Object? accountId = null,
  }) {
    return _then(_$LogsTableStateImpl(
      filter: null == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as LogFilter,
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as LogSort,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      totalLogs: null == totalLogs
          ? _value.totalLogs
          : totalLogs // ignore: cast_nullable_to_non_nullable
              as int,
      selectedLogIds: null == selectedLogIds
          ? _value._selectedLogIds
          : selectedLogIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LogsTableStateImpl extends _LogsTableState {
  const _$LogsTableStateImpl(
      {this.filter = const LogFilter(),
      this.sort = LogSort.defaultSort,
      this.pageSize = 50,
      this.currentPage = 0,
      this.totalLogs = 0,
      final Set<String> selectedLogIds = const {},
      this.isLoading = false,
      this.isRefreshing = false,
      this.error,
      required this.accountId})
      : _selectedLogIds = selectedLogIds,
        super._();

// Filter and sort state
  @override
  @JsonKey()
  final LogFilter filter;
  @override
  @JsonKey()
  final LogSort sort;
// Pagination state
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalLogs;
// Selection state for multi-select operations
  final Set<String> _selectedLogIds;
// Selection state for multi-select operations
  @override
  @JsonKey()
  Set<String> get selectedLogIds {
    if (_selectedLogIds is EqualUnmodifiableSetView) return _selectedLogIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_selectedLogIds);
  }

// Loading states
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isRefreshing;
// Error state
  @override
  final String? error;
// Account context
  @override
  final String accountId;

  @override
  String toString() {
    return 'LogsTableState(filter: $filter, sort: $sort, pageSize: $pageSize, currentPage: $currentPage, totalLogs: $totalLogs, selectedLogIds: $selectedLogIds, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogsTableStateImpl &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalLogs, totalLogs) ||
                other.totalLogs == totalLogs) &&
            const DeepCollectionEquality()
                .equals(other._selectedLogIds, _selectedLogIds) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      filter,
      sort,
      pageSize,
      currentPage,
      totalLogs,
      const DeepCollectionEquality().hash(_selectedLogIds),
      isLoading,
      isRefreshing,
      error,
      accountId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogsTableStateImplCopyWith<_$LogsTableStateImpl> get copyWith =>
      __$$LogsTableStateImplCopyWithImpl<_$LogsTableStateImpl>(
          this, _$identity);
}

abstract class _LogsTableState extends LogsTableState {
  const factory _LogsTableState(
      {final LogFilter filter,
      final LogSort sort,
      final int pageSize,
      final int currentPage,
      final int totalLogs,
      final Set<String> selectedLogIds,
      final bool isLoading,
      final bool isRefreshing,
      final String? error,
      required final String accountId}) = _$LogsTableStateImpl;
  const _LogsTableState._() : super._();

  @override // Filter and sort state
  LogFilter get filter;
  @override
  LogSort get sort;
  @override // Pagination state
  int get pageSize;
  @override
  int get currentPage;
  @override
  int get totalLogs;
  @override // Selection state for multi-select operations
  Set<String> get selectedLogIds;
  @override // Loading states
  bool get isLoading;
  @override
  bool get isRefreshing;
  @override // Error state
  String? get error;
  @override // Account context
  String get accountId;
  @override
  @JsonKey(ignore: true)
  _$$LogsTableStateImplCopyWith<_$LogsTableStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
