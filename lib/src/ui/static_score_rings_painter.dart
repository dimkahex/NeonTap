import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/timing_thresholds.dart';

/// Мишень из полупрозрачных неоновых колец — те же радиуды, что и [TimingThresholds].
/// Снаружи внутрь: внешний MISS → OK (зелёный) → GOOD → COOL → PERFECT → центральная дыра MISS.
class StaticScoreRingsPainter extends CustomPainter {
  StaticScoreRingsPainter({required this.centerOffset});

  final Offset centerOffset;

  static Path _annulus(Offset c, double outerR, double innerR) {
    final Path outer = Path()..addOval(Rect.fromCircle(center: c, radius: outerR));
    final Path inner = Path()..addOval(Rect.fromCircle(center: c, radius: innerR));
    return Path.combine(ui.PathOperation.difference, outer, inner);
  }

  static void _fillAnnulus(
    Canvas canvas,
    Offset c,
    double outerR,
    double innerR,
    Color fill,
  ) {
    if (outerR <= innerR + 0.5) return;
    final Path p = _annulus(c, outerR, innerR);
    canvas.drawPath(
      p,
      Paint()
        ..style = PaintingStyle.fill
        ..color = fill,
    );
  }

  static void _neonEdge(Canvas canvas, Offset c, double radius, Color core, Color glow) {
    if (radius < 2) return;
    final Paint soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = glow.withValues(alpha: 0.35);
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = core.withValues(alpha: 0.55);
    canvas.drawCircle(c, radius, soft);
    canvas.drawCircle(c, radius, line);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double maxR = math.min(size.width, size.height) * 0.48;

    // Внешняя чёрная зона (MISS) — тёмный полупрозрачный слой.
    _fillAnnulus(
      canvas,
      c,
      maxR,
      TimingThresholds.rOkOuter,
      const Color(0xFF050508).withValues(alpha: 0.42),
    );

    // OK — зелёный неон.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rOkOuter,
      TimingThresholds.rGoodOuter,
      const Color(0xFF2EE85A).withValues(alpha: 0.14),
    );
    _neonEdge(canvas, c, TimingThresholds.rOkOuter, const Color(0xFF66FF88), const Color(0xFF2EE85A));
    _neonEdge(canvas, c, TimingThresholds.rGoodOuter, const Color(0xFFFFB74D), const Color(0xFFFF8A25));

    // GOOD — оранжевый.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rGoodOuter,
      TimingThresholds.rCoolOuter,
      const Color(0xFFFF8A25).withValues(alpha: 0.16),
    );

    // COOL — жёлтый.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rCoolOuter,
      TimingThresholds.rPerfectOuter,
      const Color(0xFFFFEA4D).withValues(alpha: 0.15),
    );
    _neonEdge(canvas, c, TimingThresholds.rCoolOuter, const Color(0xFFFFEE58), const Color(0xFFFFEA00));

    // PERFECT — красно-розовый неон.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rPerfectOuter,
      TimingThresholds.rCenterMiss,
      const Color(0xFFFF3355).withValues(alpha: 0.17),
    );
    _neonEdge(canvas, c, TimingThresholds.rPerfectOuter, const Color(0xFFFF8A80), const Color(0xFFFF3355));

    // Центральная «дыра» — MISS.
    canvas.drawCircle(
      c,
      TimingThresholds.rCenterMiss,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF020208).withValues(alpha: 0.92),
    );
    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xFF1A1A22).withValues(alpha: 0.9);
    canvas.drawCircle(c, TimingThresholds.rCenterMiss, rim);
  }

  @override
  bool shouldRepaint(covariant StaticScoreRingsPainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset;
  }
}
