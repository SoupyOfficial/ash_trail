import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/design_constants.dart';

/// Compact stat card widget for displaying single metrics
/// Used by many home widget types (hits today, duration, etc.)
class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Widget? trendWidget;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? accentColor;
  final bool reduceMotion;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trendWidget,
    this.onTap,
    this.onLongPress,
    this.accentColor,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = accentColor ?? colorScheme.primary;

    // Derive borderRadius from CardTheme so settings slider is respected.
    final cardShape = Theme.of(context).cardTheme.shape;
    final baseBorderRadius =
        cardShape is RoundedRectangleBorder
            ? cardShape.borderRadius as BorderRadius
            : BorderRadii.md;

    return Card(
      margin: EdgeInsets.zero,
      // elevation inherited from CardTheme
      shape: RoundedRectangleBorder(
        borderRadius: baseBorderRadius,
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap:
            onTap != null
                ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
                : null,
        onLongPress:
            onLongPress != null
                ? () {
                  HapticFeedback.mediumImpact();
                  onLongPress!();
                }
                : null,
        borderRadius: baseBorderRadius,
        child: Padding(
          padding: Paddings.md,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title with optional icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: IconSize.sm.value,
                      color: effectiveColor.withOpacity(0.7),
                    ),
                    SizedBox(width: Spacing.xs.value),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.sm.value),
              // Value - large and prominent
              AnimatedSwitcher(
                duration: resolveAnimationDuration(
                  AnimationDuration.fast.duration,
                  reduceMotion || MediaQuery.of(context).disableAnimations,
                ),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.95,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  value,
                  key: ValueKey<String>(value),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (subtitle != null || trendWidget != null) ...[
                SizedBox(height: Spacing.xs.value),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (subtitle != null)
                      Flexible(
                        child: Text(
                          subtitle!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (trendWidget != null) ...[
                      SizedBox(width: Spacing.xs.value),
                      trendWidget!,
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Trend indicator widget showing percentage change
class TrendIndicator extends StatelessWidget {
  final double percentChange;
  final bool
  invertColors; // If true, positive = bad (red), negative = good (green)
  final String suffix; // Unit suffix (default: '%')

  /// Short contextual label shown after the percentage, e.g. "vs yesterday".
  /// When null the indicator shows only the percentage.
  final String? comparisonLabel;

  const TrendIndicator({
    super.key,
    required this.percentChange,
    this.invertColors = false,
    this.suffix = '%',
    this.comparisonLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (percentChange == 0) {
      return const SizedBox.shrink();
    }

    final isUp = percentChange > 0;
    final colorScheme = Theme.of(context).colorScheme;

    // By default: up = red (more usage), down = green (less usage)
    // If invertColors: up = green (good), down = red (bad)
    final Color color;
    if (invertColors) {
      color = isUp ? Colors.green : colorScheme.error;
    } else {
      color = isUp ? colorScheme.error : Colors.green;
    }

    final icon = isUp ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${isUp ? '+' : ''}${percentChange.abs().toStringAsFixed(0)}$suffix',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (comparisonLabel != null) ...[
            const SizedBox(width: 3),
            Text(
              comparisonLabel!,
              style: TextStyle(
                fontSize: 9,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A row of compact stat cards
class StatCardRow extends StatelessWidget {
  final List<Widget> children;

  const StatCardRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map((child) => Expanded(child: child))
          .toList()
          .fold<List<Widget>>([], (list, child) {
            if (list.isNotEmpty) {
              list.add(SizedBox(width: Spacing.sm.value));
            }
            list.add(child);
            return list;
          }),
    );
  }
}
