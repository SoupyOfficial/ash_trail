import 'package:flutter/material.dart';
import 'package:ash_trail/features/loading_skeletons/presentation/widgets/skeleton_container.dart';

/// Simplified skeleton chart widget that handles constraints better
class SkeletonChartSimple extends StatelessWidget {
  const SkeletonChartSimple({
    super.key,
    this.height = 200.0,
    this.barCount = 7,
    this.showLegend = false,
  });

  final double height;
  final int barCount;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          const SkeletonContainer(
            height: 16,
            width: 120,
            child: SizedBox(),
          ),
          const SizedBox(height: 12),

          // Chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => const SkeletonContainer(
                        height: 10,
                        width: 25,
                        child: SizedBox(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Chart bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(barCount, (index) {
                      // Vary bar heights to simulate real chart
                      final heights = [0.6, 0.4, 0.7, 0.3, 0.5, 0.4, 0.2];
                      final normalizedHeight = heights[index % heights.length];

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: SkeletonContainer(
                                  height: 60 * normalizedHeight,
                                  width: double.infinity,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(2),
                                  ),
                                  child: const SizedBox(),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // X-axis label
                              const SkeletonContainer(
                                height: 8,
                                width: double.infinity,
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Legend (optional)
          if (showLegend) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkeletonContainer(
                        height: 8,
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                        child: const SizedBox(),
                      ),
                      const SizedBox(width: 4),
                      const SkeletonContainer(
                        height: 8,
                        width: 40,
                        child: SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
