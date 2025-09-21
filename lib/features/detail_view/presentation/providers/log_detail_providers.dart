// Riverpod providers for log detail feature
// Manages state and dependencies for log detail view

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/log_detail_entity.dart';
import '../../domain/repositories/log_detail_repository.dart';
import '../../domain/usecases/get_log_detail_usecase.dart';
import '../../domain/usecases/refresh_log_detail_usecase.dart';
import '../../data/repositories/log_detail_repository_impl.dart';
import '../../data/datasources/mock_log_detail_datasource.dart';
import '../../../../core/failures/app_failure.dart';

part 'log_detail_providers.g.dart';

/// Repository provider
@Riverpod(keepAlive: true)
LogDetailRepository logDetailRepository(LogDetailRepositoryRef ref) {
  return LogDetailRepositoryImpl(
    localDataSource: MockLogDetailLocalDataSource(),
    remoteDataSource: MockLogDetailRemoteDataSource(),
  );
}

/// Use case providers
@Riverpod(keepAlive: true)
GetLogDetailUseCase getLogDetailUseCase(GetLogDetailUseCaseRef ref) {
  return GetLogDetailUseCase(ref.watch(logDetailRepositoryProvider));
}

@Riverpod(keepAlive: true)
RefreshLogDetailUseCase refreshLogDetailUseCase(RefreshLogDetailUseCaseRef ref) {
  return RefreshLogDetailUseCase(ref.watch(logDetailRepositoryProvider));
}

/// Log detail state provider
@riverpod
class LogDetailNotifier extends _$LogDetailNotifier {
  @override
  Future<LogDetailEntity> build(String logId) async {
    final useCase = ref.read(getLogDetailUseCaseProvider);
    final result = await useCase(GetLogDetailParams(logId: logId));
    
    return result.fold(
      (failure) => throw failure,
      (entity) => entity,
    );
  }

  /// Refresh the log detail from remote source
  Future<void> refresh() async {
    final logId = state.value?.log.id;
    if (logId == null) return;

    state = const AsyncValue.loading();
    
    final useCase = ref.read(refreshLogDetailUseCaseProvider);
    final result = await useCase(RefreshLogDetailParams(logId: logId));
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (entity) => AsyncValue.data(entity),
    );
  }

  /// Check if log exists
  Future<bool> logExists(String logId) async {
    final repository = ref.read(logDetailRepositoryProvider);
    final result = await repository.logExists(logId);
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }
}

/// Convenience provider for error handling
@riverpod
String? logDetailError(LogDetailErrorRef ref, String logId) {
  final asyncValue = ref.watch(logDetailNotifierProvider(logId));
  return asyncValue.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error is AppFailure 
        ? error.displayMessage 
        : 'An unexpected error occurred',
  );
}