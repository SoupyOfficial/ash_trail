import 'package:flutter/material.dart';
import 'skeleton_container.dart';

/// Skeleton loading state for list views
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.spacing = 8.0,
    this.showAvatar = true,
    this.showSubtitle = true,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;
  final bool showAvatar;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => _SkeletonListItem(
        height: itemHeight,
        showAvatar: showAvatar,
        showSubtitle: showSubtitle,
      ),
    );
  }
}

class _SkeletonListItem extends StatelessWidget {
  const _SkeletonListItem({
    required this.height,
    required this.showAvatar,
    required this.showSubtitle,
  });

  final double height;
  final bool showAvatar;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (showAvatar) ...[
              SkeletonContainer(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonContainer(
                    height: 16,
                    width: double.infinity,
                    child: const SizedBox(),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 8),
                    SkeletonContainer(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SkeletonContainer(
              width: 60,
              height: 20,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
