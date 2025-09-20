// Reachability zone overlay widget
// Visual overlay showing thumb reach zones on the screen

import 'package:flutter/material.dart';
import '../../domain/entities/reachability_zone.dart';

class ReachabilityZoneOverlay extends StatelessWidget {
  const ReachabilityZoneOverlay({
    super.key,
    required this.zones,
    this.showLabels = true,
    this.opacity = 0.3,
  });

  final List<ReachabilityZone> zones;
  final bool showLabels;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ReachabilityZonePainter(
        zones: zones,
        showLabels: showLabels,
        opacity: opacity,
        textDirection: Directionality.of(context),
      ),
      size: Size.infinite,
    );
  }
}

class _ReachabilityZonePainter extends CustomPainter {
  const _ReachabilityZonePainter({
    required this.zones,
    required this.showLabels,
    required this.opacity,
    required this.textDirection,
  });

  final List<ReachabilityZone> zones;
  final bool showLabels;
  final double opacity;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Sort zones by difficulty (easy zones on top)
    final sortedZones = [...zones]..sort((a, b) {
        final order = {
          ReachabilityLevel.unreachable: 0,
          ReachabilityLevel.difficult: 1,
          ReachabilityLevel.moderate: 2,
          ReachabilityLevel.easy: 3,
        };
        return order[a.level]!.compareTo(order[b.level]!);
      });

    for (final zone in sortedZones) {
      _paintZone(canvas, size, zone, paint);
      if (showLabels) {
        _paintLabel(canvas, size, zone);
      }
    }
  }

  void _paintZone(
      Canvas canvas, Size size, ReachabilityZone zone, Paint paint) {
    // Scale zone bounds to canvas size
    final scaledBounds = Rect.fromLTWH(
      zone.bounds.left * (size.width / zone.bounds.width).clamp(0.0, 1.0),
      zone.bounds.top * (size.height / zone.bounds.height).clamp(0.0, 1.0),
      zone.bounds.width * (size.width / zone.bounds.width).clamp(0.0, 1.0),
      zone.bounds.height * (size.height / zone.bounds.height).clamp(0.0, 1.0),
    );

    // If zone bounds seem invalid, use percentage of screen
    final bounds = scaledBounds.width <= 0 || scaledBounds.height <= 0
        ? _getZoneBoundsForScreen(zone, size)
        : scaledBounds;

    // Fill zone with color
    paint.color = Color(zone.level.colorValue).withOpacity(opacity);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(bounds, paint);

    // Draw zone border
    paint.color = Color(zone.level.colorValue);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawRect(bounds, paint);
  }

  void _paintLabel(Canvas canvas, Size size, ReachabilityZone zone) {
    final bounds = _getZoneBoundsForScreen(zone, size);

    if (bounds.height < 40) return; // Skip labels for small zones

    final textPainter = TextPainter(
      text: TextSpan(
        text: zone.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
      textDirection: textDirection,
    );

    textPainter.layout();

    final labelPosition = Offset(
      bounds.left + (bounds.width - textPainter.width) / 2,
      bounds.top + (bounds.height - textPainter.height) / 2,
    );

    // Draw background for better readability
    final backgroundRect = Rect.fromLTWH(
      labelPosition.dx - 8,
      labelPosition.dy - 4,
      textPainter.width + 16,
      textPainter.height + 8,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)),
      backgroundPaint,
    );

    textPainter.paint(canvas, labelPosition);
  }

  Rect _getZoneBoundsForScreen(ReachabilityZone zone, Size size) {
    // Define zone boundaries based on ergonomics (percentage of screen)
    return switch (zone.level) {
      ReachabilityLevel.easy => Rect.fromLTWH(
          0,
          size.height * 0.4, // Bottom 60%
          size.width,
          size.height * 0.6,
        ),
      ReachabilityLevel.moderate => Rect.fromLTWH(
          0,
          size.height * 0.2, // 20-40% from top
          size.width,
          size.height * 0.2,
        ),
      ReachabilityLevel.difficult => Rect.fromLTWH(
          0,
          size.height * 0.05, // 5-20% from top
          size.width,
          size.height * 0.15,
        ),
      ReachabilityLevel.unreachable => Rect.fromLTWH(
          0,
          0, // Top 5%
          size.width,
          size.height * 0.05,
        ),
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _ReachabilityZonePainter ||
        oldDelegate.zones != zones ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.opacity != opacity;
  }
}

/// Widget that shows reachability zones with additional information
class ReachabilityZoneInfo extends StatelessWidget {
  const ReachabilityZoneInfo({
    super.key,
    required this.zones,
  });

  final List<ReachabilityZone> zones;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reachability Zones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...zones.map((zone) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ZoneInfoCard(zone: zone),
            )),
      ],
    );
  }
}

class _ZoneInfoCard extends StatelessWidget {
  const _ZoneInfoCard({required this.zone});

  final ReachabilityZone zone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(zone.level.colorValue),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zone.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    zone.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              zone.level.displayName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Color(zone.level.colorValue),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
