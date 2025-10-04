// Riverpod providers for logs table browse and edit functionality
// Manages repository dependencies, use cases, and state for table operations

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../capture_hit/presentation/providers/smoke_log_local_datasource_provider.dart';
import '../../data/datasources/logs_table_datasource_fallback.dart';
import '../../data/datasources/logs_table_local_datasource.dart';
import '../../data/datasources/logs_table_remote_datasource.dart';
import '../../data/repositories/logs_table_repository_impl.dart';
import '../../domain/entities/log_filter.dart';
import '../../domain/entities/log_sort.dart';
import '../../domain/repositories/logs_table_repository.dart';
import '../../domain/usecases/delete_smoke_log_usecase.dart';
import '../../domain/usecases/add_tags_to_logs_batch_usecase.dart';
import '../../domain/usecases/remove_tags_from_logs_batch_usecase.dart';
import '../../domain/usecases/get_filter_options_usecase.dart';
import '../../domain/usecases/get_filtered_sorted_logs_usecase.dart';
import '../../domain/usecases/get_logs_count_usecase.dart';
import '../../domain/usecases/get_smoke_log_by_id_usecase.dart';
import '../../domain/usecases/update_smoke_log_usecase.dart';

/// Data source providers - Abstract interfaces
/// These should be overridden in main.dart with concrete implementations
final logsTableLocalDataSourceProvider =
    FutureProvider<LogsTableLocalDataSource>((ref) async {
  final smokeLogLocal = await ref.watch(smokeLogLocalDataSourceProvider.future);
  return LogsTableLocalDataSourceFallback(
    smokeLogLocalDataSource: smokeLogLocal,
  );
});

final logsTableRemoteDataSourceProvider =
    Provider<LogsTableRemoteDataSource>((ref) {
  return const LogsTableRemoteDataSourceNoop();
});

/// Repository implementation provider
final logsTableRepositoryProvider =
    FutureProvider<LogsTableRepository>((ref) async {
  final local = await ref.watch(logsTableLocalDataSourceProvider.future);
  final remote = ref.watch(logsTableRemoteDataSourceProvider);

  return LogsTableRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

/// Use case providers
final getFilteredSortedLogsUseCaseProvider =
    FutureProvider<GetFilteredSortedLogsUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return GetFilteredSortedLogsUseCase(repository: repository);
});

final getLogsCountUseCaseProvider =
    FutureProvider<GetLogsCountUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return GetLogsCountUseCase(repository: repository);
});

final updateSmokeLogUseCaseProvider =
    FutureProvider<UpdateSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return UpdateSmokeLogUseCase(repository: repository);
});

final deleteSmokeLogUseCaseProvider =
    FutureProvider<DeleteSmokeLogUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return DeleteSmokeLogUseCase(repository: repository);
});

final deleteSmokeLogsBatchUseCaseProvider =
    FutureProvider<DeleteSmokeLogsBatchUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return DeleteSmokeLogsBatchUseCase(repository: repository);
});

final addTagsToLogsBatchUseCaseProvider =
    FutureProvider<AddTagsToLogsBatchUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return AddTagsToLogsBatchUseCase(repository: repository);
});

final removeTagsFromLogsBatchUseCaseProvider =
    FutureProvider<RemoveTagsFromLogsBatchUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return RemoveTagsFromLogsBatchUseCase(repository: repository);
});

final getSmokeLogByIdUseCaseProvider =
    FutureProvider<GetSmokeLogByIdUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return GetSmokeLogByIdUseCase(repository: repository);
});

final getUsedMethodIdsUseCaseProvider =
    FutureProvider<GetUsedMethodIdsUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return GetUsedMethodIdsUseCase(repository: repository);
});

final getUsedTagIdsUseCaseProvider =
    FutureProvider<GetUsedTagIdsUseCase>((ref) async {
  final repository = await ref.watch(logsTableRepositoryProvider.future);
  return GetUsedTagIdsUseCase(repository: repository);
});

/// Filter options providers
/// These provide the available options for filtering

/// Get method IDs that have been used in logs for filter dropdown
final usedMethodIdsProvider =
    FutureProvider.family<List<String>, String>((ref, accountId) async {
  final useCase = await ref.watch(getUsedMethodIdsUseCaseProvider.future);
  final result = await useCase(accountId: accountId);

  return result.fold(
    (failure) => throw failure,
    (methodIds) => methodIds,
  );
});

/// Get tag IDs that have been used in logs for filter chips
final usedTagIdsProvider =
    FutureProvider.family<List<String>, String>((ref, accountId) async {
  final useCase = await ref.watch(getUsedTagIdsUseCaseProvider.future);
  final result = await useCase(accountId: accountId);

  return result.fold(
    (failure) => throw failure,
    (tagIds) => tagIds,
  );
});

/// Parameters for logs table query
/// Used to encapsulate all query parameters in a single object
class LogsTableParams {
  final String accountId;
  final LogFilter? filter;
  final LogSort? sort;
  final int? limit;
  final int? offset;

  const LogsTableParams({
    required this.accountId,
    this.filter,
    this.sort,
    this.limit,
    this.offset,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogsTableParams &&
          runtimeType == other.runtimeType &&
          accountId == other.accountId &&
          filter == other.filter &&
          sort == other.sort &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      accountId.hashCode ^
      filter.hashCode ^
      sort.hashCode ^
      limit.hashCode ^
      offset.hashCode;
}

/// Filtered and sorted logs provider
/// Returns paginated logs based on current filter and sort criteria
final filteredSortedLogsProvider =
    FutureProvider.family<List<SmokeLog>, LogsTableParams>((ref, params) async {
  final useCase = await ref.watch(getFilteredSortedLogsUseCaseProvider.future);
  final result = await useCase(
    accountId: params.accountId,
    filter: params.filter,
    sort: params.sort,
    limit: params.limit,
    offset: params.offset,
  );

  return result.fold(
    (failure) => throw failure,
    (logs) => logs,
  );
});

/// Logs count provider for pagination
/// Returns total count of logs matching current filter criteria
final logsCountProvider =
    FutureProvider.family<int, LogsTableParams>((ref, params) async {
  final useCase = await ref.watch(getLogsCountUseCaseProvider.future);
  final result = await useCase(
    accountId: params.accountId,
    filter: params.filter,
  );

  return result.fold(
    (failure) => throw failure,
    (count) => count,
  );
});

/// Single log provider by ID
/// Used for edit modal and detailed views
final smokeLogByIdProvider =
    FutureProvider.family<SmokeLog, ({String id, String accountId})>(
        (ref, params) async {
  final useCase = await ref.watch(getSmokeLogByIdUseCaseProvider.future);
  final result = await useCase(
    smokeLogId: params.id,
    accountId: params.accountId,
  );

  return result.fold(
    (failure) => throw failure,
    (log) => log,
  );
});

/// Table state provider
/// Manages current filter, sort, and pagination state
/// This will be implemented in a separate state provider file
