import 'package:flutter/material.dart';

import '../game/timing_thresholds.dart';

/// Fixed reference circles — same radii as [TimingThresholds]. Innermost = PERFECT threshold.
class StaticScoreRingsPainter extends CustomPainter {
  StaticScoreRingsPainter({required this.centerOffset});

  final Offset centerOffset;

  static void _neonRing(
    Canvas canvas,
    Offset c,
    double radius, {
    required Color core,
    required Color glow,
    double lineWidth = 2.6,
  }) {
    if (radius < 2) return;
    final Paint outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = glow.withValues(alpha: 0.22);
    final Paint midGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = glow.withValues(alpha: 0.45);
    final Paint shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth + 2.4
      ..color = const Color(0xFF050508).withValues(alpha: 0.75);
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..color = core;

    canvas.drawCircle(c, radius, outerGlow);
    canvas.drawCircle(c, radius, midGlow);
    canvas.drawCircle(c, radius, shadow);
    canvas.drawCircle(c, radius, line);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;

    _neonRing(
      canvas,
      c,
      TimingThresholds.rOkOuter,
      core: const Color(0xFFE0F7FF),
      glow: const Color(0xFFB388FF),
      lineWidth: 2.35,
    );
    _neonRing(
      canvas,
      c,
      TimingThresholds.rGood,
      core: const Color(0xFFFFA726),
      glow: const Color(0xFFFF6D00),
      lineWidth: 2.5,
    );
    _neonRing(
      canvas,
      c,
      TimingThresholds.rPerfect,
      core: const Color(0xFFFFF59D),
      glow: const Color(0xFFFFEA00),
      lineWidth: 3.0,
    );

    // Crisp PERFECT boundary — when the play ring shrinks *inside* this circle, timing is PERFECT.
    final Paint crisp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(c, TimingThresholds.rPerfect, crisp);
    final Paint inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFFFEA00).withValues(alpha: 0.9);
    canvas.drawCircle(c, TimingThresholds.rPerfect, inner);
  }

  @override
  bool shouldRepaint(covariant StaticScoreRingsPainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset;
  }
}
