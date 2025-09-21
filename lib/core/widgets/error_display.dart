// Error Display Widget - Shows error states with retry functionality
// Provides consistent error handling UI across the app

import 'package:flutter/material.dart';

/// Widget that displays error information with optional retry functionality
class ErrorDisplay extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final List<Widget>? actions;
  final IconData? icon;

  const ErrorDisplay({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon ?? Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        if (actions != null) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: actions!,
          ),
        ],
      ],
    );
  }
}
