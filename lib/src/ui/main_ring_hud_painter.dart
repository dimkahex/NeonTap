import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shrinking **play** ring — magenta signature glow so it never reads as a static tier ring.
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

  /// Hot accent — not used by static score rings (green/gold/orange/violet tiers).
  static const Color _signatureGlow = Color(0xFFFF2BD6);

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

    final Paint signature = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = _signatureGlow.withValues(alpha: 0.34);
    canvas.drawCircle(c, rd, signature);

    final Paint signature2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = _signatureGlow.withValues(alpha: 0.55);
    canvas.drawCircle(c, rd, signature2);

    final Paint silhouette = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = const Color(0xFF020308).withValues(alpha: 0.62);
    canvas.drawCircle(c, rd, silhouette);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = core.withValues(alpha: 1.0);
    canvas.drawCircle(c, rd, ring);

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..color = Colors.white.withValues(alpha: 0.95);
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
