import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Thin stroke for the shrinking **main** ring — above particles; keeps distract motion, not a thick “target”.
class MainRingHudPainter extends CustomPainter {
  MainRingHudPainter({
    required this.radius,
    required this.maxRadius,
    required this.pulse,
    required this.centerOffset,
  });

  final double radius;
  final double maxRadius;
  final double pulse;
  final Offset centerOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double r = radius.clamp(0.0, maxRadius);
    if (r < 1.5) return;

    final double progress = 1.0 - (r / maxRadius);
    const Color start = Color(0xFF35E6FF);
    const Color end = Color(0xFFFF3355);
    final Color core = Color.lerp(start, end, progress) ?? start;

    final double distract = 1.0 + (0.06 * math.sin(pulse * math.pi * 2));
    final double rd = r * distract;

    final Paint silhouette = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = const Color(0xFF010203).withValues(alpha: 0.55);
    canvas.drawCircle(c, rd, silhouette);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = core.withValues(alpha: 0.98);
    canvas.drawCircle(c, rd, ring);

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.88);
    canvas.drawCircle(c, rd, rim);
  }

  @override
  bool shouldRepaint(covariant MainRingHudPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.pulse != pulse ||
        oldDelegate.centerOffset != centerOffset;
  }
}
