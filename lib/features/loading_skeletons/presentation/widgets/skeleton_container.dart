import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/skeleton_providers.dart';

/// Base skeleton container that provides consistent styling and animation
class SkeletonContainer extends ConsumerStatefulWidget {
  const SkeletonContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
  });

  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  ConsumerState<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends ConsumerState<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).accessibleNavigation;
    final duration = ref.watch(skeletonAnimationDurationProvider);

    // Update animation duration if it changed
    if (_animationController.duration != duration) {
      _animationController.duration = duration;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
      ),
      child: reduceMotion
          ? _buildReducedMotionSkeleton()
          : _buildAnimatedSkeleton(),
    );
  }

  Widget _buildReducedMotionSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.6),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
      ),
      child: widget.child,
    );
  }

  Widget _buildAnimatedSkeleton() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(_animation.value * 0.6),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
          ),
          child: widget.child,
        );
      },
    );
  }
}
