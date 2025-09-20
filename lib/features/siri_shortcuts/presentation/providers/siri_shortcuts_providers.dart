// Providers for Siri shortcuts state management.
// Integrates use cases with UI through Riverpod providers.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/siri_shortcuts_entity.dart';
import '../../domain/entities/siri_shortcut_type.dart';
import '../../domain/repositories/siri_shortcuts_repository.dart';
import '../../domain/usecases/donate_shortcuts_use_case.dart';
import '../../domain/usecases/get_siri_shortcuts_use_case.dart';
import '../../domain/usecases/handle_shortcut_invocation_use_case.dart';
import '../../data/repositories/siri_shortcuts_repository_impl.dart';
import '../../data/datasources/siri_shortcuts_local_data_source.dart';
import '../../data/datasources/siri_shortcuts_remote_data_source.dart';

// Repository provider
final siriShortcutsRepositoryProvider = Provider<SiriShortcutsRepository>((ref) {
  // In production, this should be overridden in main.dart
  throw UnimplementedError(
    'siriShortcutsRepositoryProvider must be overridden with a concrete implementation. '
    'Make sure to call createSiriShortcutsRepositoryOverride() in your ProviderScope overrides.',
  );
});

// Use case providers
final donateShortcutsUseCaseProvider = Provider<DonateShortcutsUseCase>((ref) {
  return DonateShortcutsUseCase(ref.watch(siriShortcutsRepositoryProvider));
});

final getSiriShortcutsUseCaseProvider = Provider<GetSiriShortcutsUseCase>((ref) {
  return GetSiriShortcutsUseCase(ref.watch(siriShortcutsRepositoryProvider));
});

final handleShortcutInvocationUseCaseProvider = Provider<HandleShortcutInvocationUseCase>((ref) {
  return HandleShortcutInvocationUseCase(ref.watch(siriShortcutsRepositoryProvider));
});

// Siri shortcuts list provider
final siriShortcutsListProvider = FutureProvider<List<SiriShortcutsEntity>>((ref) async {
  final useCase = ref.watch(getSiriShortcutsUseCaseProvider);
  final result = await useCase.call();
  
  return result.fold(
    (failure) => throw Exception(failure.displayMessage),
    (shortcuts) => shortcuts,
  );
});

// Siri shortcuts support provider
final siriShortcutsSupportProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(siriShortcutsRepositoryProvider);
  final result = await repository.isSiriShortcutsSupported();
  
  return result.fold(
    (failure) => false,
    (isSupported) => isSupported,
  );
});

// Controller for managing shortcuts
final siriShortcutsControllerProvider = 
    StateNotifierProvider<SiriShortcutsController, SiriShortcutsState>((ref) {
  return SiriShortcutsController(ref);
});

// State classes for the controller
enum SiriShortcutsStatus {
  initial,
  loading,
  loaded,
  error,
}

class SiriShortcutsState {
  const SiriShortcutsState({
    this.status = SiriShortcutsStatus.initial,
    this.shortcuts = const [],
    this.isSupported = false,
    this.errorMessage,
    this.isDonating = false,
  });

  final SiriShortcutsStatus status;
  final List<SiriShortcutsEntity> shortcuts;
  final bool isSupported;
  final String? errorMessage;
  final bool isDonating;

  SiriShortcutsState copyWith({
    SiriShortcutsStatus? status,
    List<SiriShortcutsEntity>? shortcuts,
    bool? isSupported,
    String? errorMessage,
    bool? isDonating,
  }) {
    return SiriShortcutsState(
      status: status ?? this.status,
      shortcuts: shortcuts ?? this.shortcuts,
      isSupported: isSupported ?? this.isSupported,
      errorMessage: errorMessage ?? this.errorMessage,
      isDonating: isDonating ?? this.isDonating,
    );
  }
}

class SiriShortcutsController extends StateNotifier<SiriShortcutsState> {
  SiriShortcutsController(this._ref) : super(const SiriShortcutsState()) {
    _loadShortcuts();
  }

  final Ref _ref;

  /// Load shortcuts and check platform support
  Future<void> _loadShortcuts() async {
    state = state.copyWith(status: SiriShortcutsStatus.loading);

    try {
      // Check platform support
      final repository = _ref.read(siriShortcutsRepositoryProvider);
      final supportResult = await repository.isSiriShortcutsSupported();
      final isSupported = supportResult.fold(
        (failure) => false,
        (supported) => supported,
      );

      // Load shortcuts
      final useCase = _ref.read(getSiriShortcutsUseCaseProvider);
      final result = await useCase.call();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: SiriShortcutsStatus.error,
            errorMessage: failure.displayMessage,
            isSupported: isSupported,
          );
        },
        (shortcuts) {
          state = state.copyWith(
            status: SiriShortcutsStatus.loaded,
            shortcuts: shortcuts,
            isSupported: isSupported,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: SiriShortcutsStatus.error,
        errorMessage: 'Failed to load shortcuts: $e',
      );
    }
  }

  /// Donate shortcuts to Siri
  Future<void> donateShortcuts() async {
    if (!state.isSupported) return;

    state = state.copyWith(isDonating: true);

    try {
      final useCase = _ref.read(donateShortcutsUseCaseProvider);
      final result = await useCase.call();

      result.fold(
        (failure) {
          state = state.copyWith(
            isDonating: false,
            errorMessage: failure.displayMessage,
          );
        },
        (_) {
          state = state.copyWith(isDonating: false);
          // Reload shortcuts to reflect donation status
          _loadShortcuts();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDonating: false,
        errorMessage: 'Failed to donate shortcuts: $e',
      );
    }
  }

  /// Handle shortcut invocation and get route
  Future<String?> handleShortcutInvocation(SiriShortcutType type) async {
    try {
      final useCase = _ref.read(handleShortcutInvocationUseCaseProvider);
      final result = await useCase.call(type);

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: failure.displayMessage);
          return null;
        },
        (route) => route,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to handle shortcut: $e');
      return null;
    }
  }

  /// Refresh shortcuts
  void refresh() {
    _loadShortcuts();
  }
}

// Provider override helper for dependency injection
Override createSiriShortcutsRepositoryOverride(SharedPreferences prefs) {
  final localDataSource = SiriShortcutsLocalDataSourceImpl(prefs);
  const remoteDataSource = SiriShortcutsRemoteDataSourceImpl();
  
  return siriShortcutsRepositoryProvider.overrideWithValue(
    SiriShortcutsRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    ),
  );
}