import 'package:flutter/material.dart';

/// A skeleton widget that mimics circular content like avatars or buttons
/// Uses a simple container instead of SkeletonContainer to be const-compatible
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}
