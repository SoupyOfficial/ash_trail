import 'package:flutter/material.dart';
import 'skeleton_container.dart';

/// Skeleton loading state for chart views
class SkeletonChart extends StatelessWidget {
  const SkeletonChart({
    super.key,
    this.height = 300.0,
    this.showLegend = true,
    this.barCount = 7,
  });

  final double height;
  final bool showLegend;
  final int barCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            SkeletonContainer(
              height: 20,
              width: 150,
              child: const SizedBox(),
            ),
            const SizedBox(height: 16),

            // Chart area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  // Reserve more space for labels and prevent overflow
                  final chartHeight =
                      (availableHeight - 60).clamp(50.0, availableHeight);

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Y-axis labels
                      SizedBox(
                        height: availableHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) => SkeletonContainer(
                              height: 12,
                              width: 30,
                              child: const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Chart bars
                      Expanded(
                        child: SizedBox(
                          height: availableHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(barCount, (index) {
                              // Vary bar heights to simulate real chart
                              final heights = [
                                0.6,
                                0.4,
                                0.7,
                                0.3,
                                0.5,
                                0.4,
                                0.2
                              ];
                              final normalizedHeight =
                                  heights[index % heights.length];

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SkeletonContainer(
                                        height: (chartHeight * normalizedHeight)
                                            .clamp(20.0, chartHeight),
                                        width: double.infinity,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(4),
                                        ),
                                        child: const SizedBox(),
                                      ),
                                      const SizedBox(
                                          height: 4), // Reduced spacing
                                      // X-axis label
                                      SkeletonContainer(
                                        height: 10, // Reduced height
                                        width: double.infinity,
                                        child: const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            if (showLegend) ...[
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonContainer(
                    height: 12,
                    width: 12,
                    borderRadius: BorderRadius.circular(6),
                    child: const SizedBox(),
                  ),
                  const SizedBox(width: 8),
                  SkeletonContainer(
                    height: 14,
                    width: 80,
                    child: const SizedBox(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
