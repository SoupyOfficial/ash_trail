import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/skeleton_providers.dart';

/// Widget that ensures loading states are shown for minimum duration
/// and handles smooth transitions to prevent layout shift
class LoadingStateHandler extends ConsumerStatefulWidget {
  const LoadingStateHandler({
    super.key,
    required this.isLoading,
    required this.child,
    required this.loadingWidget,
    this.transitionDuration = const Duration(milliseconds: 200),
  });

  final bool isLoading;
  final Widget child;
  final Widget loadingWidget;
  final Duration transitionDuration;

  @override
  ConsumerState<LoadingStateHandler> createState() =>
      _LoadingStateHandlerState();
}

class _LoadingStateHandlerState extends ConsumerState<LoadingStateHandler>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isInternalLoading = false;
  DateTime? _loadingStartTime;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _isInternalLoading = widget.isLoading;
    if (widget.isLoading) {
      _loadingStartTime = DateTime.now();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(LoadingStateHandler oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        // Started loading
        _loadingStartTime = DateTime.now();
        _isInternalLoading = true;
        _animationController.reverse();
      } else {
        // Finished loading - check minimum duration
        _checkMinimumDurationAndShowContent();
      }
    }
  }

  void _checkMinimumDurationAndShowContent() {
    if (_loadingStartTime == null) {
      _showContent();
      return;
    }

    final minDuration = ref.read(minimumLoadingDurationProvider);
    final elapsed = DateTime.now().difference(_loadingStartTime!);

    if (elapsed >= minDuration) {
      _showContent();
    } else {
      final remaining = minDuration - elapsed;
      _delayTimer?.cancel();
      _delayTimer = Timer(remaining, () {
        if (mounted && !widget.isLoading) {
          _showContent();
        }
      });
    }
  }

  void _showContent() {
    if (mounted) {
      setState(() {
        _isInternalLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (_isInternalLoading) {
          return widget.loadingWidget;
        }

        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
