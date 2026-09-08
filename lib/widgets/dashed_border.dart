import 'package:flutter/material.dart';

/// Draws a dashed rounded-rectangle border around [child].
///
/// Flutter's [Border] can't do dashes, and the "+ Add New" category pill needs
/// them, so the outline is stroked by hand from the rounded-rect path.
class DashedBorder extends StatelessWidget {
  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 9999,
    this.strokeWidth = 1,
    this.dashLength = 4,
    this.gapLength = 3,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    if (rect.width <= 0 || rect.height <= 0) return;

    // A pill radius (9999) must be clamped to half the shorter side.
    final effectiveRadius =
        radius.clamp(0.0, rect.shortestSide / 2).toDouble();
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(effectiveRadius)),
      );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final step = dashLength + gapLength;
    for (final metric in path.computeMetrics()) {
      for (double start = 0; start < metric.length; start += step) {
        final end = (start + dashLength).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) {
    return old.color != color ||
        old.radius != radius ||
        old.strokeWidth != strokeWidth ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength;
  }
}
