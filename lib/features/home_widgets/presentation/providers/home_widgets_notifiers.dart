// State management for home widgets using Riverpod with code generation.
// Provides reactive state for widget lists and individual widget operations.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/widget_data.dart';
import '../../domain/entities/widget_size.dart';
import '../../domain/entities/widget_tap_action.dart';
import '../../domain/usecases/base_usecase.dart';
import '../../domain/usecases/create_widget_usecase.dart';
import '../../domain/usecases/update_widget_stats_usecase.dart';
import 'home_widgets_providers.dart';

part 'home_widgets_notifiers.g.dart';

@riverpod
class HomeWidgetsList extends _$HomeWidgetsList {
  @override
  Future<List<WidgetData>> build(String accountId) async {
    final useCase = ref.watch(getAllWidgetsUseCaseProvider);
    final result = await useCase(AccountParams(accountId: accountId));

    return result.fold(
      (failure) => throw failure,
      (widgets) => widgets,
    );
  }

  /// Refreshes the widget list from remote sources
  Future<void> refresh() async {
    final accountId = await future.then((widgets) {
      return widgets.isNotEmpty ? widgets.first.accountId : '';
    }).onError((error, stackTrace) => '');

    if (accountId.isEmpty) return;

    state = const AsyncValue.loading();

    final refreshUseCase = ref.read(refreshWidgetDataUseCaseProvider);
    final result = await refreshUseCase(AccountParams(accountId: accountId));

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (widgets) => AsyncValue.data(widgets),
    );
  }

  /// Creates a new widget configuration
  Future<WidgetData?> createWidget({
    required String accountId,
    required WidgetSize size,
    required WidgetTapAction tapAction,
    bool? showStreak,
    bool? showLastSync,
  }) async {
    final createUseCase = ref.read(createWidgetUseCaseProvider);

    final params = CreateWidgetParams(
      accountId: accountId,
      size: size,
      tapAction: tapAction,
      showStreak: showStreak,
      showLastSync: showLastSync,
    );

    final result = await createUseCase(params);

    return result.fold(
      (failure) {
        // Handle error - could emit to error state or show snackbar
        return null;
      },
      (widget) {
        // Update local state optimistically
        state = state.whenData((widgets) => [...widgets, widget]);
        return widget;
      },
    );
  }

  /// Updates widget statistics
  Future<void> updateWidgetStats({
    required String widgetId,
    required int todayHitCount,
    required int currentStreak,
  }) async {
    final updateUseCase = ref.read(updateWidgetStatsUseCaseProvider);

    final params = UpdateWidgetStatsParams(
      widgetId: widgetId,
      todayHitCount: todayHitCount,
      currentStreak: currentStreak,
    );

    final result = await updateUseCase(params);

    result.fold(
      (failure) {
        // Handle error
      },
      (updatedWidget) {
        // Update local state
        state = state.whenData((widgets) {
          return widgets.map((widget) {
            return widget.id == widgetId ? updatedWidget : widget;
          }).toList();
        });
      },
    );
  }
}

@riverpod
class WidgetConfiguration extends _$WidgetConfiguration {
  @override
  WidgetConfigState build() {
    return const WidgetConfigState();
  }

  void updateSize(WidgetSize size) {
    state = state.copyWith(size: size);
  }

  void updateTapAction(WidgetTapAction action) {
    state = state.copyWith(tapAction: action);
  }

  void updateShowStreak(bool show) {
    state = state.copyWith(showStreak: show);
  }

  void updateShowLastSync(bool show) {
    state = state.copyWith(showLastSync: show);
  }

  void reset() {
    state = const WidgetConfigState();
  }
}

/// State class for widget configuration
class WidgetConfigState {
  const WidgetConfigState({
    this.size = WidgetSize.medium,
    this.tapAction = WidgetTapAction.openApp,
    this.showStreak = false,
    this.showLastSync = true,
  });

  final WidgetSize size;
  final WidgetTapAction tapAction;
  final bool showStreak;
  final bool showLastSync;

  WidgetConfigState copyWith({
    WidgetSize? size,
    WidgetTapAction? tapAction,
    bool? showStreak,
    bool? showLastSync,
  }) {
    return WidgetConfigState(
      size: size ?? this.size,
      tapAction: tapAction ?? this.tapAction,
      showStreak: showStreak ?? this.showStreak,
      showLastSync: showLastSync ?? this.showLastSync,
    );
  }
}
