import 'package:flutter/material.dart';

/// Highlights the valid tap band (ring) when "aim mode" is active.
/// Optional [wideHalfWidth] draws a faint outer graze band (wider tolerance).
class RingGuidePainter extends CustomPainter {
  RingGuidePainter({
    required this.centerOffset,
    required this.ringRadius,
    required this.halfWidth,
    required this.opacity,
    this.wideHalfWidth,
  });

  final Offset centerOffset;
  final double ringRadius;
  final double halfWidth;
  final double opacity;
  /// If larger than [halfWidth], draws an extra dim outer ring (GRAZE zone).
  final double? wideHalfWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;

    final double? wide = wideHalfWidth;
    if (wide != null && wide > halfWidth + 0.5) {
      final Paint wideBand = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (wide - halfWidth) * 2
        ..color = const Color(0xFF78909C).withValues(alpha: 0.12 * opacity);
      canvas.drawCircle(c, ringRadius, wideBand);
    }

    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = halfWidth * 2
      ..color = const Color(0xFF35E6FF).withValues(alpha: 0.18 * opacity);

    canvas.drawCircle(c, ringRadius, band);

    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.45 * opacity);
    canvas.drawCircle(c, ringRadius, edge);
  }

  @override
  bool shouldRepaint(covariant RingGuidePainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.halfWidth != halfWidth ||
        oldDelegate.opacity != opacity ||
        oldDelegate.wideHalfWidth != wideHalfWidth;
  }
}
