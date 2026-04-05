import 'dart:math' as math;

import 'package:flutter/material.dart';

/// High-contrast stroke for the shrinking **main** ring — drawn above particles/overlays
/// so timing stays readable while distract pulse and VFX still run underneath.
class MainRingHudPainter extends CustomPainter {
  MainRingHudPainter({
    required this.radius,
    required this.maxRadius,
    required this.pulse,
    required this.centerOffset,
  });

  final double radius;
  final double maxRadius;
  /// Same distract channel as [NeonCirclePainter] (0 when pulse distract is off).
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

    // Dark backing — reads on bright spiral bands and particle bursts.
    final Paint silhouette = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..color = const Color(0xFF010203).withValues(alpha: 0.72);
    canvas.drawCircle(c, rd, silhouette);

    final Paint midGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = core.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(c, rd, midGlow);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..color = core.withValues(alpha: 1.0);
    canvas.drawCircle(c, rd, ring);

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withValues(alpha: 0.92);
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
