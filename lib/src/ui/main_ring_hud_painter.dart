import 'package:flutter/material.dart';

/// Shrinking **play** ring — drawn at the **same** geometric radius used for hit tests (no wobble).
/// Magenta glow so it stays distinct from static tier rings.
class MainRingHudPainter extends CustomPainter {
  MainRingHudPainter({
    required this.radius,
    required this.maxRadius,
    required this.centerOffset,
  });

  final double radius;
  final double maxRadius;
  final Offset centerOffset;

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

    final Paint signature = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = _signatureGlow.withValues(alpha: 0.34);
    canvas.drawCircle(c, r, signature);

    final Paint signature2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = _signatureGlow.withValues(alpha: 0.55);
    canvas.drawCircle(c, r, signature2);

    final Paint silhouette = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = const Color(0xFF020308).withValues(alpha: 0.62);
    canvas.drawCircle(c, r, silhouette);

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = core.withValues(alpha: 1.0);
    canvas.drawCircle(c, r, ring);

    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(c, r, rim);
  }

  @override
  bool shouldRepaint(covariant MainRingHudPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.centerOffset != centerOffset;
  }
}
