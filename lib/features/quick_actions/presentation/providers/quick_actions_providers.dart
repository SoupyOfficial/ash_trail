// Riverpod providers for quick actions feature
// Wires domain layer use cases with presentation layer

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/initialize_quick_actions_use_case.dart';
import '../../domain/usecases/listen_quick_actions_use_case.dart';
import '../../domain/repositories/quick_actions_repository.dart';
import '../../domain/entities/quick_action_entity.dart';
import '../../data/repositories/quick_actions_repository_impl.dart';
import '../../data/datasources/quick_actions_data_source.dart';

// Data source provider
final quickActionsDataSourceProvider = Provider<QuickActionsDataSource>((ref) {
  return QuickActionsDataSourceImpl();
});

// Repository provider
final quickActionsRepositoryProvider = Provider<QuickActionsRepository>((ref) {
  final dataSource = ref.watch(quickActionsDataSourceProvider);
  return QuickActionsRepositoryImpl(dataSource);
});

// Use case providers
final initializeQuickActionsUseCaseProvider =
    Provider<InitializeQuickActionsUseCase>((ref) {
  final repository = ref.watch(quickActionsRepositoryProvider);
  return InitializeQuickActionsUseCase(repository);
});

final listenQuickActionsUseCaseProvider =
    Provider<ListenQuickActionsUseCase>((ref) {
  final repository = ref.watch(quickActionsRepositoryProvider);
  return ListenQuickActionsUseCase(repository);
});

// Provider for quick actions stream
final quickActionsStreamProvider = StreamProvider<QuickActionEntity>((ref) {
  final useCase = ref.watch(listenQuickActionsUseCaseProvider);
  final result = useCase.call();

  return result.fold(
    (failure) => Stream.error(failure),
    (stream) => stream,
  );
});

// Controller for quick actions initialization
final quickActionsControllerProvider =
    StateNotifierProvider<QuickActionsController, AsyncValue<void>>((ref) {
  return QuickActionsController(ref);
});

class QuickActionsController extends StateNotifier<AsyncValue<void>> {
  QuickActionsController(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  final Ref _ref;

  Future<void> _initialize() async {
    try {
      final useCase = _ref.read(initializeQuickActionsUseCaseProvider);
      final result = await useCase.call();

      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = const AsyncValue.data(null),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
