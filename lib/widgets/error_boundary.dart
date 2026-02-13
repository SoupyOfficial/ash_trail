import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import '../services/error_reporting_service.dart';

/// Catches build errors in child widget tree, reports them, and shows a fallback UI.
///
/// Wrap major screen sections in `ErrorBoundary(child: ...)` to prevent
/// a single widget error from taking down the entire screen.
///
/// Uses Flutter's [ErrorWidget.builder] mechanism — when a child widget's
/// `build()` throws, the framework replaces it with the error widget. This
/// widget intercepts that by wrapping children and catching errors during build.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? fallbackBuilder;

  const ErrorBoundary({super.key, required this.child, this.fallbackBuilder});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  static final _log = AppLogger.logger('ErrorBoundary');
  Object? _error;

  @override
  void initState() {
    super.initState();
    _error = null;
  }

  void _retry() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(_error!, _retry);
      }
      return _DefaultErrorCard(error: _error!, onRetry: _retry);
    }

    try {
      return widget.child;
    } catch (e, st) {
      _log.e('ErrorBoundary caught build error', error: e, stackTrace: st);
      ErrorReportingService.instance.reportException(
        e,
        stackTrace: st,
        context: 'ErrorBoundary',
      );
      // Schedule the error state update after the current build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = e);
      });
      return const SizedBox.shrink();
    }
  }
}

class _DefaultErrorCard extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              'This section encountered an error',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The rest of the app should work normally.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
