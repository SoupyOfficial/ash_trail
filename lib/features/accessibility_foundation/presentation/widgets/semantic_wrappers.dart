// Spec Header:
// Semantic Wrappers - Accessibility Foundation Components
// Provides semantic meaning and accessibility compliance for common UI patterns.
// Assumption: VoiceOver/TalkBack actions and proper focus traversal are critical.

import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';

/// A button wrapper that ensures accessibility compliance with proper semantics
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.minTapTarget = 48.0,
    this.isDestructive = false,
    this.excludeSemantics = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final double minTapTarget;
  final bool isDestructive;
  final bool excludeSemantics;

  @override
  Widget build(BuildContext context) {
    final effectiveMinSize = AccessibilityService.getEffectiveMinTapTarget(
      context,
      baseSize: minTapTarget,
    );

    Widget button = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: effectiveMinSize,
        minHeight: effectiveMinSize,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: child,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (!excludeSemantics) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: onPressed != null,
        child: button,
      );
    }

    return button;
  }
}

/// Enhanced record button with accessibility support for VoiceOver rotor actions
class AccessibleRecordButton extends StatelessWidget {
  const AccessibleRecordButton({
    super.key,
    required this.onPressed,
    required this.onLongPress,
    this.isRecording = false,
    this.semanticLabel,
    this.recordingLabel = 'Recording in progress',
    this.minTapTarget = 56.0,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isRecording;
  final String? semanticLabel;
  final String recordingLabel;
  final double minTapTarget;

  @override
  Widget build(BuildContext context) {
    final effectiveMinSize = AccessibilityService.getEffectiveMinTapTarget(
      context,
      baseSize: minTapTarget,
    );

    final defaultLabel = isRecording
        ? recordingLabel
        : 'Record smoking hit. Tap for quick log, hold for timed recording.';

    return Semantics(
      label: semanticLabel ?? defaultLabel,
      button: true,
      enabled: onPressed != null,
      hint: isRecording
          ? 'Release to complete recording'
          : 'Double tap to activate',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: effectiveMinSize,
          minHeight: effectiveMinSize,
        ),
        child: GestureDetector(
          onTap: onPressed,
          onLongPress: onLongPress,
          child: Container(
            width: effectiveMinSize,
            height: effectiveMinSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              isRecording ? Icons.stop : Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
              size: effectiveMinSize * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item with proper semantic labels and VoiceOver support
class AccessibleNavigationItem extends StatelessWidget {
  const AccessibleNavigationItem({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.badgeCount,
    this.semanticLabel,
    this.minTapTarget = 48.0,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final int? badgeCount;
  final String? semanticLabel;
  final double minTapTarget;

  @override
  Widget build(BuildContext context) {
    final effectiveMinSize = AccessibilityService.getEffectiveMinTapTarget(
      context,
      baseSize: minTapTarget,
    );

    String effectiveLabel = semanticLabel ?? label;
    if (badgeCount != null && badgeCount! > 0) {
      effectiveLabel += ', $badgeCount unread';
    }
    if (isSelected) {
      effectiveLabel += ', selected';
    }

    return Semantics(
      label: effectiveLabel,
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: effectiveMinSize,
            minHeight: effectiveMinSize,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    if (badgeCount != null && badgeCount! > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Badge(
                          label: Text('$badgeCount'),
                          isLabelVisible: true,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// List item with VoiceOver rotor actions for log entries
class AccessibleLogRow extends StatelessWidget {
  const AccessibleLogRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.semanticLabel,
    this.minTapTarget = 48.0,
  });

  final String title;
  final String subtitle;
  final String timestamp;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final String? semanticLabel;
  final double minTapTarget;

  @override
  Widget build(BuildContext context) {
    final effectiveMinSize = AccessibilityService.getEffectiveMinTapTarget(
      context,
      baseSize: minTapTarget,
    );

    final effectiveLabel = semanticLabel ??
        '$title, $subtitle, $timestamp${onTap != null ? '. Double tap to open.' : ''}';

    return Semantics(
      label: effectiveLabel,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: effectiveMinSize,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timestamp,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (onEdit != null || onDelete != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit',
                              constraints: BoxConstraints(
                                minWidth: effectiveMinSize * 0.6,
                                minHeight: effectiveMinSize * 0.6,
                              ),
                            ),
                          if (onDelete != null)
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete',
                              constraints: BoxConstraints(
                                minWidth: effectiveMinSize * 0.6,
                                minHeight: effectiveMinSize * 0.6,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A wrapper that ensures proper focus order and traversal
class AccessibleFocusTraversalGroup extends StatelessWidget {
  const AccessibleFocusTraversalGroup({
    super.key,
    required this.child,
    this.policy,
  });

  final Widget child;
  final FocusTraversalPolicy? policy;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      child: child,
    );
  }
}
