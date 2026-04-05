import 'package:flutter/material.dart';

/// Thin guide for **обод** + GRAZE / RIM / EDGE shells (relative to shrinking ring radius).
/// Drawn above static score rings; avoids heavy fills that read as “extra” targets.
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

    void strokePair({
      required double outer,
      required double alphaMul,
      required Color color,
      double strokeW = 1.9,
    }) {
      void one(double radiusPx) {
        if (radiusPx <= 1) return;
        final Paint sh = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW + 1.6
          ..color = const Color(0xFF000000).withValues(alpha: 0.42 * opacity * alphaMul);
        canvas.drawCircle(c, radiusPx, sh);
        final Paint p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..color = color.withValues(alpha: 0.92 * alphaMul * opacity);
        canvas.drawCircle(c, radiusPx, p);
      }

      final double inR = r - outer;
      if (inR > 2) {
        one(inR);
      }
      one(r + outer);
    }

    strokePair(outer: bandEdgeOuter, alphaMul: 1.0, color: const Color(0xFFB0BEC5), strokeW: 1.85);
    strokePair(outer: bandRimOuter, alphaMul: 1.0, color: const Color(0xFFFFB74D), strokeW: 1.85);
    strokePair(outer: bandGrazeOuter, alphaMul: 1.0, color: const Color(0xFF69F0AE), strokeW: 1.95);

    // Main band: two thin rims (no thick “tube”).
    final Paint rimInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withValues(alpha: 0.92 * opacity);
    final double ri = (r - halfWidth).clamp(0.0, double.infinity);
    final double ro = r + halfWidth;
    if (ri > 2) {
      canvas.drawCircle(c, ri, rimInner);
    }
    canvas.drawCircle(c, ro, rimInner);

    final Paint mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = const Color(0xFFFFEA00).withValues(alpha: 0.82 * opacity);
    canvas.drawCircle(c, r, mid);
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
