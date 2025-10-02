import 'package:flutter/material.dart';

/// A skeleton widget that mimics text content
/// Uses a simple container instead of SkeletonContainer to be const-compatible
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.6),
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
    );
  }
}
