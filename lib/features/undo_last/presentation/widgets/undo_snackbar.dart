// iOS-style undo snackbar widget
// Provides accessible, animated bottom toast for undo functionality

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/undo_last_providers.dart';

/// iOS-style undo snackbar that appears from the bottom
/// Features countdown timer, accessibility support, and safe area awareness
class UndoSnackbar extends ConsumerStatefulWidget {
  final String accountId;
  final VoidCallback? onUndoPressed;
  final VoidCallback? onDismissed;
  final Duration displayDuration;
  final EdgeInsets? margin;

  const UndoSnackbar({
    super.key,
    required this.accountId,
    this.onUndoPressed,
    this.onDismissed,
    this.displayDuration = const Duration(seconds: 6),
    this.margin,
  });

  @override
  ConsumerState<UndoSnackbar> createState() => _UndoSnackbarState();
}

class _UndoSnackbarState extends ConsumerState<UndoSnackbar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Timer? _countdownTimer;
  int _remainingSeconds = 6;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.displayDuration.inSeconds;

    // Initialize slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start the countdown timer
    _startCountdown();

    // Animate in
    _showSnackbar();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          _hideSnackbar();
        }
      },
    );
  }

  void _showSnackbar() {
    setState(() {
      _isVisible = true;
    });
    _slideController.forward();

    // Announce to screen readers
    SemanticsService.announce(
      'Log created. Undo available for $_remainingSeconds seconds',
      TextDirection.ltr,
    );
  }

  void _hideSnackbar() async {
    if (!_isVisible) return;

    setState(() {
      _isVisible = false;
    });

    await _slideController.reverse();
    widget.onDismissed?.call();
  }

  void _handleUndo() async {
    _countdownTimer?.cancel();

    // Execute undo operation
    final notifier =
        ref.read(undoLastLogNotifierProvider(widget.accountId).notifier);
    await notifier.executeUndo();

    // Announce success to screen readers
    SemanticsService.announce(
      'Log undone successfully',
      TextDirection.ltr,
    );

    widget.onUndoPressed?.call();
    _hideSnackbar();
  }

  void _handleDismiss() {
    _countdownTimer?.cancel();
    _hideSnackbar();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final undoState = ref.watch(undoLastLogNotifierProvider(widget.accountId));

    return SafeArea(
      child: Padding(
        padding: widget.margin ??
            const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12.0),
            color: colorScheme.inverseSurface,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 56.0, // Minimum touch target
                maxWidth: 400.0, // Reasonable max width
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success/check icon
                  Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.onInverseSurface,
                    size: 20.0,
                    semanticLabel: 'Log created',
                  ),

                  const SizedBox(width: 12.0),

                  // Message text with countdown
                  Expanded(
                    child: Text(
                      'Hit logged • ${_remainingSeconds}s',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      semanticsLabel:
                          'Hit logged. $_remainingSeconds seconds remaining to undo.',
                    ),
                  ),

                  const SizedBox(width: 16.0),

                  // Undo button
                  undoState.when(
                    data: (_) => _buildUndoButton(colorScheme, false),
                    loading: () => _buildUndoButton(colorScheme, true),
                    error: (error, stack) =>
                        _buildUndoButton(colorScheme, false),
                  ),

                  const SizedBox(width: 8.0),

                  // Dismiss button
                  _buildDismissButton(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUndoButton(ColorScheme colorScheme, bool isLoading) {
    return SizedBox(
      height: 48.0, // Minimum touch target
      child: TextButton(
        onPressed: isLoading ? null : _handleUndo,
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onInverseSurface,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          minimumSize: const Size(48.0, 48.0), // Accessibility requirement
        ),
        child: isLoading
            ? SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: colorScheme.onInverseSurface,
                ),
              )
            : Text(
                'UNDO',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0,
                ),
                semanticsLabel: 'Undo last log',
              ),
      ),
    );
  }

  Widget _buildDismissButton(ColorScheme colorScheme) {
    return SizedBox(
      width: 48.0, // Minimum touch target
      height: 48.0,
      child: IconButton(
        onPressed: _handleDismiss,
        icon: Icon(
          Icons.close,
          color: colorScheme.onInverseSurface.withOpacity(0.7),
          size: 18.0,
        ),
        tooltip: 'Dismiss',
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// Utility function to show the undo snackbar
/// Returns a controller that can be used to manage the snackbar
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showUndoSnackbar(
  BuildContext context, {
  required String accountId,
  VoidCallback? onUndoPressed,
  VoidCallback? onDismissed,
  Duration duration = const Duration(seconds: 6),
}) {
  final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  if (scaffoldMessenger == null) return null;

  // Clear any existing snackbars first
  scaffoldMessenger.clearSnackBars();

  return scaffoldMessenger.showSnackBar(
    SnackBar(
      content: UndoSnackbar(
        accountId: accountId,
        onUndoPressed: onUndoPressed,
        onDismissed: onDismissed,
        displayDuration: duration,
      ),
      duration: duration,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16.0),
    ),
  );
}
