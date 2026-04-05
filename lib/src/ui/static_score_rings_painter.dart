import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/timing_thresholds.dart';

/// Киберпанк-мишень: насыщенные неоновые кольца (cyan / magenta / золото / hot pink) + тёмная внешняя зона MISS.
/// Радиусы совпадают с [TimingThresholds].
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

  /// Двойное свечение границы — «трубка» неона.
  static void _cyberEdge(Canvas canvas, Offset c, double radius, Color core, Color glow) {
    if (radius < 2) return;
    final Paint bloom = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = glow.withValues(alpha: 0.45);
    final Paint mid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..color = core.withValues(alpha: 0.55);
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = Color.lerp(core, Colors.white, 0.35)!.withValues(alpha: 0.75);
    canvas.drawCircle(c, radius, bloom);
    canvas.drawCircle(c, radius, mid);
    canvas.drawCircle(c, radius, line);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double maxR = math.min(size.width, size.height) * 0.48;

    // Внешний MISS — глубокий фиолетово-чёрный «void».
    _fillAnnulus(
      canvas,
      c,
      maxR,
      TimingThresholds.rOkOuter,
      const Color(0xFF120018).withValues(alpha: 0.55),
    );
    _cyberEdge(
      canvas,
      c,
      TimingThresholds.rOkOuter,
      const Color(0xFF00E5FF),
      const Color(0xFF00FFC6),
    );

    // OK — электрический циан / мята.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rOkOuter,
      TimingThresholds.rGoodOuter,
      const Color(0xFF00FFC6).withValues(alpha: 0.18),
    );

    // GOOD — неоновый магента / фуксия.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rGoodOuter,
      TimingThresholds.rCoolOuter,
      const Color(0xFFFF00AA).withValues(alpha: 0.2),
    );
    _cyberEdge(
      canvas,
      c,
      TimingThresholds.rGoodOuter,
      const Color(0xFFFF2BD6),
      const Color(0xFFFF00AA),
    );

    // COOL — кислотное золото / янтарь.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rCoolOuter,
      TimingThresholds.rPerfectOuter,
      const Color(0xFFFFEA00).withValues(alpha: 0.2),
    );
    _cyberEdge(
      canvas,
      c,
      TimingThresholds.rCoolOuter,
      const Color(0xFFFFF59D),
      const Color(0xFFFFEA00),
    );

    // PERFECT — hot pink / плазма.
    _fillAnnulus(
      canvas,
      c,
      TimingThresholds.rPerfectOuter,
      TimingThresholds.rCenterMiss,
      const Color(0xFFFF0080).withValues(alpha: 0.22),
    );
    _cyberEdge(
      canvas,
      c,
      TimingThresholds.rPerfectOuter,
      const Color(0xFFFF66CC),
      const Color(0xFFFF0080),
    );

    // Центральная дыра MISS — чёрный + фиолетовый ободок.
    canvas.drawCircle(
      c,
      TimingThresholds.rCenterMiss,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF030008).withValues(alpha: 0.94),
    );
    final Paint rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF6A00FF).withValues(alpha: 0.65);
    canvas.drawCircle(c, TimingThresholds.rCenterMiss, rim);
    final Paint rimInner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.35);
    canvas.drawCircle(c, TimingThresholds.rCenterMiss * 0.92, rimInner);
  }

  @override
  bool shouldRepaint(covariant StaticScoreRingsPainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset;
  }
}
