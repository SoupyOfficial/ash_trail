import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/error_boundary_provider.dart';
import 'error_fallback_widget.dart';

/// Global error boundary widget that catches and handles uncaught UI errors.
/// Wraps the app or specific subtrees to provide error recovery functionality.
class ErrorBoundaryWidget extends ConsumerStatefulWidget {
  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.onError,
  });

  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;

  @override
  ConsumerState<ErrorBoundaryWidget> createState() =>
      _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends ConsumerState<ErrorBoundaryWidget> {
  late final ErrorWidgetBuilder _originalErrorBuilder;

  @override
  void initState() {
    super.initState();

    // Store the original error widget builder
    _originalErrorBuilder = ErrorWidget.builder;

    // Set our custom error widget builder
    ErrorWidget.builder = _buildErrorWidget;
  }

  @override
  void dispose() {
    // Restore the original error widget builder
    ErrorWidget.builder = _originalErrorBuilder;
    super.dispose();
  }

  Widget _buildErrorWidget(FlutterErrorDetails details) {
    // Capture the error in our error boundary system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureError(details.exception, details.stack ?? StackTrace.current);
    });

    // Return our custom error fallback widget
    return ErrorFallbackWidget(
      error: details.exception,
      stackTrace: details.stack,
      onRestart: _handleRestart,
      onCopyLogs: _handleCopyLogs,
    );
  }

  void _captureError(Object error, StackTrace stackTrace) {
    // Call the optional error callback
    widget.onError?.call(error, stackTrace);

    // Capture error in our error boundary controller
    ref
        .read(errorBoundaryControllerProvider.notifier)
        .captureError(error, stackTrace);
  }

  void _handleRestart() {
    // Reset the error boundary state
    ref.read(errorBoundaryControllerProvider.notifier).reset();

    // Force a rebuild by setting state
    setState(() {});
  }

  void _handleCopyLogs() {
    // Share diagnostics using the error boundary controller
    ref.read(errorBoundaryControllerProvider.notifier).shareDiagnostics();
  }

  @override
  Widget build(BuildContext context) {
    final errorBoundaryState = ref.watch(errorBoundaryControllerProvider);

    return switch (errorBoundaryState) {
      ErrorBoundaryStateNormal() => widget.child,
      ErrorBoundaryStateError() => ErrorFallbackWidget(
          error: Exception(errorBoundaryState.errorEvent.message),
          stackTrace: null,
          onRestart: _handleRestart,
          onCopyLogs: _handleCopyLogs,
        ),
    };
  }
}

/// Extension to easily wrap widgets with error boundary
extension ErrorBoundaryExtension on Widget {
  /// Wraps this widget with an error boundary
  Widget withErrorBoundary({
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return ErrorBoundaryWidget(
      onError: onError,
      child: this,
    );
  }
}
