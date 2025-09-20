// Inline edit snackbar that extends the undo snackbar with quick controls

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/smoke_log.dart';
import '../../../capture_hit/presentation/providers/smoke_log_providers.dart';
import '../providers/edit_inline_snackbar_providers.dart';

/// A composable widget that shows Undo + inline editing controls
/// within the snackbar duration window.
class InlineEditSnackbar extends ConsumerStatefulWidget {
  final String accountId;
  final SmokeLog createdLog;
  final Duration displayDuration;
  final VoidCallback? onSaved;

  const InlineEditSnackbar({
    super.key,
    required this.accountId,
    required this.createdLog,
    this.displayDuration = const Duration(seconds: 6),
    this.onSaved,
  });

  @override
  ConsumerState<InlineEditSnackbar> createState() => _InlineEditSnackbarState();
}

class _InlineEditSnackbarState extends ConsumerState<InlineEditSnackbar>
    with TickerProviderStateMixin {
  Timer? _countdownTimer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.displayDuration.inSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Prevent setState after dispose and avoid negative countdown
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_remaining <= 0) {
        t.cancel();
        return;
      }
      setState(() {
        _remaining = (_remaining - 1).clamp(0, 1 << 31);
      });
      if (_remaining <= 0) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final editState = ref.watch(
      inlineEditControllerProvider(widget.createdLog),
    );
    final controller = ref.read(
      inlineEditControllerProvider(widget.createdLog).notifier,
    );

    return Material(
      color: colorScheme.inverseSurface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 18, color: colorScheme.onInverseSurface),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hit logged • ${_remaining}s',
                    style: TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Keep a slim Undo button for parity
                TextButton(
                  onPressed: () async {
                    try {
                      final notifier = ref.read(
                          undoSmokeLogProvider(widget.accountId).notifier);
                      await notifier.undoLast(accountId: widget.accountId);
                    } catch (_) {
                      // Failure handled by provider; keep UI simple here
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onInverseSurface,
                    minimumSize: const Size(48, 40),
                  ),
                  child: const Text('UNDO'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (editState != null) ...[
              Row(
                children: [
                  _StepButton(
                    icon: Icons.remove,
                    onPressed: () => controller.decrementDuration(5000),
                    color: colorScheme.onInverseSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(editState.adjustedDurationMs / 1000).toStringAsFixed(0)}s',
                    style: TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StepButton(
                    icon: Icons.add,
                    onPressed: () => controller.incrementDuration(5000),
                    color: colorScheme.onInverseSurface,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: editState.isSaving
                        ? null
                        : () async {
                            final saved = await controller.save();
                            if (saved != null) {
                              widget.onSaved?.call();
                              if (mounted)
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                            }
                          },
                    icon: editState.isSaving
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onInverseSurface,
                            ),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onInverseSurface,
                      minimumSize: const Size(64, 40),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: editState.notes,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Add a note…',
                  hintStyle: TextStyle(
                      color: colorScheme.onInverseSurface.withOpacity(0.7)),
                  filled: true,
                  fillColor: colorScheme.onInverseSurface.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: colorScheme.onInverseSurface.withOpacity(0.2)),
                  ),
                ),
                style: TextStyle(color: colorScheme.onInverseSurface),
                onChanged: controller.setNotes,
              ),
              if (editState.error != null) ...[
                const SizedBox(height: 6),
                Text(
                  editState.error!.displayMessage,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  const _StepButton(
      {required this.icon, required this.onPressed, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

/// Helper to show the inline snackbar using ScaffoldMessenger
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    showInlineEditSnackbar(
  BuildContext context, {
  required String accountId,
  required SmokeLog createdLog,
  Duration duration = const Duration(seconds: 6),
  VoidCallback? onSaved,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return null;

  messenger.clearSnackBars();

  return messenger.showSnackBar(
    SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      content: InlineEditSnackbar(
        accountId: accountId,
        createdLog: createdLog,
        displayDuration: duration,
        onSaved: onSaved,
      ),
    ),
  );
}
