import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Highlights tap bands: main **обод** (full timing score) + outer shells GRAZE / RIM / EDGE.
/// Filled annuli + dark outlines so zones read clearly on spiral/particles.
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

  static void _annulusFill(Canvas canvas, Offset c, double rInner, double rOuter, Paint paint) {
    final double ri = rInner.clamp(0.0, rOuter);
    final double ro = rOuter;
    if (ro <= ri + 0.5) return;
    final Path path = Path()
      ..addOval(Rect.fromCircle(center: c, radius: ro))
      ..addOval(Rect.fromCircle(center: c, radius: ri))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  /// Symmetric shells: [r−dOut..r−dIn] and [r+dIn..r+dOut] from center.
  void _pairShells(
    Canvas canvas,
    Offset c,
    double r,
    double dIn,
    double dOut,
    Color rgb,
    double fillAlpha,
  ) {
    final Paint p = Paint()
      ..style = PaintingStyle.fill
      ..color = rgb.withValues(alpha: fillAlpha * opacity);
    _annulusFill(canvas, c, r - dOut, r - dIn, p);
    _annulusFill(canvas, c, r + dIn, r + dOut, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double r = ringRadius;

    // Fills: outside → inside so inner band stays on top.
    _pairShells(canvas, c, r, bandRimOuter, bandEdgeOuter, const Color(0xFF90A4AE), 0.40);
    _pairShells(canvas, c, r, bandGrazeOuter, bandRimOuter, const Color(0xFFFF6D00), 0.38);
    _pairShells(canvas, c, r, halfWidth, bandGrazeOuter, const Color(0xFF00C853), 0.36);

    final Paint mainFill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00B8D4).withValues(alpha: 0.42 * opacity);
    _annulusFill(canvas, c, math.max(0.0, r - halfWidth), r + halfWidth, mainFill);

    void strokePair({
      required double outer,
      required double alphaMul,
      required Color color,
      double strokeW = 2.4,
    }) {
      void one(double radiusPx) {
        if (radiusPx <= 1) return;
        final Paint sh = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW + 2.8
          ..color = const Color(0xFF000000).withValues(alpha: 0.55 * opacity * alphaMul);
        canvas.drawCircle(c, radiusPx, sh);
        final Paint p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..color = color.withValues(alpha: math.min(1.0, 0.92 * alphaMul) * opacity);
        canvas.drawCircle(c, radiusPx, p);
      }

      final double inR = r - outer;
      if (inR > 2) {
        one(inR);
      }
      one(r + outer);
    }

    // EDGE → RIM → GRAZE — strong rims.
    strokePair(outer: bandEdgeOuter, alphaMul: 1.0, color: const Color(0xFFECEFF1), strokeW: 4.2);
    strokePair(outer: bandRimOuter, alphaMul: 1.0, color: const Color(0xFFFFAB40), strokeW: 4.0);
    strokePair(outer: bandGrazeOuter, alphaMul: 1.0, color: const Color(0xFF69F0AE), strokeW: 4.2);

    // Main target band — glow + fill + crisp edges.
    final double bandW = halfWidth * 2;
    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandW + 18
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.52 * opacity);
    canvas.drawCircle(c, r, glow);

    final Paint band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandW
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.72 * opacity);
    canvas.drawCircle(c, r, band);

    final Paint rimInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..color = Colors.white.withValues(alpha: 0.97 * opacity);
    final double ri = (r - halfWidth).clamp(0.0, double.infinity);
    final double ro = r + halfWidth;
    if (ri > 2) {
      canvas.drawCircle(c, ri, rimInner);
    }
    canvas.drawCircle(c, ro, rimInner);

    final Paint mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFFFFEA00).withValues(alpha: 0.95 * opacity);
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
