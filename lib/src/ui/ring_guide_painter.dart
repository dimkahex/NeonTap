import 'package:flutter/material.dart';

/// Highlights tap bands: tight ring + several wide scoring shells (GRAZE / RIM / EDGE).
class RingGuidePainter extends CustomPainter {
  RingGuidePainter({
    required this.centerOffset,
    required this.ringRadius,
    required this.halfWidth,
    required this.opacity,
    required this.bandGrazeOuter,
    required this.bandRimOuter,
    required this.bandEdgeOuter,
  });

  final Offset centerOffset;
  final double ringRadius;
  final double halfWidth;
  final double opacity;
  final double bandGrazeOuter;
  final double bandRimOuter;
  final double bandEdgeOuter;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double r = ringRadius;

    void strokePair(double outer, double alphaMul, Color color) {
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: alphaMul * opacity);
      final double inR = r - outer;
      if (inR > 2) {
        canvas.drawCircle(c, inR, p);
      }
      canvas.drawCircle(c, r + outer, p);
    }

    // Outermost shells first (dimmer).
    strokePair(bandEdgeOuter, 0.10, const Color(0xFF90A4AE));
    strokePair(bandRimOuter, 0.12, const Color(0xFF78909C));
    strokePair(bandGrazeOuter, 0.14, const Color(0xFF78909C));

    if (bandGrazeOuter > halfWidth + 0.5) {
      final Paint wideBand = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (bandGrazeOuter - halfWidth) * 2
        ..color = const Color(0xFF78909C).withValues(alpha: 0.10 * opacity);
      canvas.drawCircle(c, r, wideBand);
    }

    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = halfWidth * 2
      ..color = const Color(0xFF35E6FF).withValues(alpha: 0.18 * opacity);

    canvas.drawCircle(c, r, band);

    final Paint edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.45 * opacity);
    canvas.drawCircle(c, r, edge);
  }

  @override
  bool shouldRepaint(covariant RingGuidePainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset ||
        oldDelegate.ringRadius != ringRadius ||
        oldDelegate.halfWidth != halfWidth ||
        oldDelegate.opacity != opacity ||
        oldDelegate.bandGrazeOuter != bandGrazeOuter ||
        oldDelegate.bandRimOuter != bandRimOuter ||
        oldDelegate.bandEdgeOuter != bandEdgeOuter;
  }
}
