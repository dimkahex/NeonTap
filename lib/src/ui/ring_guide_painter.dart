import 'package:flutter/material.dart';

/// Highlights tap bands: main **обод** (full timing score) + outer shells GRAZE / RIM / EDGE.
/// Drawn **above** the shrinking ring so targets stay readable.
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
      double strokeW = 2.4,
    }) {
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..color = color.withValues(alpha: alphaMul * opacity);
      final double inR = r - outer;
      if (inR > 2) {
        canvas.drawCircle(c, inR, p);
      }
      canvas.drawCircle(c, r + outer, p);
    }

    // Outermost shells first (EDGE → RIM → GRAZE): clearer hue separation.
    strokePair(outer: bandEdgeOuter, alphaMul: 0.38, color: const Color(0xFFB0BEC5), strokeW: 2.6);
    strokePair(outer: bandRimOuter, alphaMul: 0.42, color: const Color(0xFFFFB74D), strokeW: 2.6);
    strokePair(outer: bandGrazeOuter, alphaMul: 0.46, color: const Color(0xFF69F0AE), strokeW: 2.8);

    // Wide shell fill (readability between the two circles of each shell).
    if (bandGrazeOuter > halfWidth + 0.5) {
      final Paint shellFill = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (bandGrazeOuter - halfWidth) * 2
        ..color = const Color(0xFF546E7A).withValues(alpha: 0.22 * opacity);
      canvas.drawCircle(c, r, shellFill);
    }

    // Main target band — glow + fill + crisp edges (где нужно попасть для ULTRA…OK).
    final double bandW = halfWidth * 2;
    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandW + 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.28 * opacity);
    canvas.drawCircle(c, r, glow);

    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandW
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.40 * opacity);
    canvas.drawCircle(c, r, band);

    final Paint rimInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..color = Colors.white.withValues(alpha: 0.88 * opacity);
    final double ri = (r - halfWidth).clamp(0.0, double.infinity);
    final double ro = r + halfWidth;
    if (ri > 2) {
      canvas.drawCircle(c, ri, rimInner);
    }
    canvas.drawCircle(c, ro, rimInner);

    final Paint mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFFFFEA00).withValues(alpha: 0.75 * opacity);
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
