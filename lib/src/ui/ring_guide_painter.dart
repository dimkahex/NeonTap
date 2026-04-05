import 'package:flutter/material.dart';

/// Subtle guide for обод + shells after score 35 — intentionally **muted** so the play ring stays dominant.
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
      required Color color,
      double strokeW = 0.85,
    }) {
      void one(double radiusPx) {
        if (radiusPx <= 1) return;
        final Paint p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..color = color.withValues(alpha: 0.5 * opacity);
        canvas.drawCircle(c, radiusPx, p);
      }

      final double inR = r - outer;
      if (inR > 2) {
        one(inR);
      }
      one(r + outer);
    }

    strokePair(outer: bandEdgeOuter, color: const Color(0xFF90A4AE), strokeW: 0.8);
    strokePair(outer: bandRimOuter, color: const Color(0xFFFFB74D), strokeW: 0.8);
    strokePair(outer: bandGrazeOuter, color: const Color(0xFF81C784), strokeW: 0.85);

    final Paint rimInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = Colors.white.withValues(alpha: 0.45 * opacity);
    final double ri = (r - halfWidth).clamp(0.0, double.infinity);
    final double ro = r + halfWidth;
    if (ri > 2) {
      canvas.drawCircle(c, ri, rimInner);
    }
    canvas.drawCircle(c, ro, rimInner);

    final Paint mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..color = const Color(0xFFFFEE58).withValues(alpha: 0.42 * opacity);
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
