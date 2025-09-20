import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget displayed when an error occurs in the error boundary.
/// Provides options to restart the app or copy diagnostic logs.
class ErrorFallbackWidget extends StatelessWidget {
  const ErrorFallbackWidget({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRestart,
    required this.onCopyLogs,
    this.isDevelopment = false,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRestart;
  final VoidCallback onCopyLogs;
  final bool isDevelopment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                  semanticLabel: 'Error icon',
                ),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'The app encountered an unexpected error. You can restart the app or share diagnostic information.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (isDevelopment) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Development Error Details:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          error.toString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                  ),
                        ),
                        if (stackTrace != null) ...[
                          const SizedBox(height: 8),
                          SelectableText(
                            stackTrace.toString(),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                    ),
                            maxLines: 10,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onRestart();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Restart'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          minimumSize: const Size(120, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onCopyLogs();
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Copy Logs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                          side: BorderSide(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          minimumSize: const Size(120, 48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'If this problem persists, please contact support.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
