import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/breakpoint.dart';
import '../../domain/entities/layout_config.dart';

/// Provider for current layout configuration
final layoutConfigProvider = Provider<LayoutConfig>((ref) {
  return const LayoutConfig();
});

/// Provider for current screen breakpoint
final breakpointProvider = Provider<Breakpoint>((ref) {
  // This is overridden in widget context - see BreakpointBuilder
  throw UnimplementedError(
      'Breakpoint provider must be overridden in widget tree');
});

/// Provider for current screen size information
final screenSizeProvider = Provider<Size>((ref) {
  // This is overridden in widget context - see BreakpointBuilder
  throw UnimplementedError(
      'Screen size provider must be overridden in widget tree');
});

/// Layout state that combines breakpoint and configuration
class LayoutState {
  const LayoutState({
    required this.breakpoint,
    required this.config,
    required this.screenSize,
  });

  final Breakpoint breakpoint;
  final LayoutConfig config;
  final Size screenSize;

  /// Whether the current layout is wide
  bool get isWide => breakpoint.isWide;

  /// Whether the current layout is compact
  bool get isCompact => breakpoint.isCompact;

  /// Whether dual-pane layout is supported
  bool get supportsDualPane => breakpoint.supportsDualPane;

  /// Appropriate padding for current breakpoint
  EdgeInsets get padding => config.paddingFor(breakpoint);

  /// Constrained content width
  double get contentWidth => config.constrainContentWidth(screenSize.width);

  /// Available width for content
  double get availableWidth => screenSize.width;

  /// Available height for content
  double get availableHeight => screenSize.height;
}

/// Provider for combined layout state
final layoutStateProvider = Provider<LayoutState>((ref) {
  final breakpoint = ref.watch(breakpointProvider);
  final config = ref.watch(layoutConfigProvider);
  final screenSize = ref.watch(screenSizeProvider);

  return LayoutState(
    breakpoint: breakpoint,
    config: config,
    screenSize: screenSize,
  );
});
