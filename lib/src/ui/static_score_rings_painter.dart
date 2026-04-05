import 'package:flutter/material.dart';

/// Fixed-radius timing circles — must match `_rPerfect` / `_rGood` / `_rOkOuter` in `game_screen.dart`.
class StaticScoreRingsPainter extends CustomPainter {
  StaticScoreRingsPainter({required this.centerOffset});

  final Offset centerOffset;

  static const double _rPerfect = 30;
  static const double _rGood = 52;
  static const double _rOk = 140;

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
      _rOk,
      core: const Color(0xFFE0F7FF),
      glow: const Color(0xFFB388FF),
      lineWidth: 2.35,
    );
    _neonRing(
      canvas,
      c,
      _rGood,
      core: const Color(0xFFFFA726),
      glow: const Color(0xFFFF6D00),
      lineWidth: 2.5,
    );
    _neonRing(
      canvas,
      c,
      _rPerfect,
      core: const Color(0xFFFFF59D),
      glow: const Color(0xFFFFEA00),
      lineWidth: 2.8,
    );
  }

  @override
  bool shouldRepaint(covariant StaticScoreRingsPainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset;
  }
}
