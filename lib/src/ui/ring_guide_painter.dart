import 'package:flutter/material.dart';

/// Highlights the valid tap band (ring) when "aim mode" is active.
class RingGuidePainter extends CustomPainter {
  RingGuidePainter({
    required this.centerOffset,
    required this.ringRadius,
    required this.halfWidth,
    required this.opacity,
  });

  final Offset centerOffset;
  final double ringRadius;
  final double halfWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;

    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = halfWidth * 2
      ..color = const Color(0xFF35E6FF).withOpacity(0.18 * opacity);

    canvas.drawCircle(c, ringRadius, band);

    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(0.45 * opacity);
    canvas.drawCircle(c, ringRadius, edge);
  }

  @override
  bool shouldRepaint(covariant RingGuidePainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.halfWidth != halfWidth ||
        oldDelegate.opacity != opacity;
  }
}
