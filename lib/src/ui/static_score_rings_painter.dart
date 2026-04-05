import 'package:flutter/material.dart';

/// Fixed-radius **timing** circles (distance from center) — same thresholds as [HitJudgement]
/// in `game_screen.dart` (`_judge`): ULTRA / PERFECT / GOOD / OK boundaries.
/// Thin strokes, drawn above particles so score tiers stay readable.
class StaticScoreRingsPainter extends CustomPainter {
  StaticScoreRingsPainter({required this.centerOffset});

  final Offset centerOffset;

  /// Must stay in sync with `_judge` distance thresholds in `game_screen.dart`.
  static const double _rUltra = 28;
  static const double _rPerfect = 48;
  static const double _rGood = 72;
  static const double _rOk = 110;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;

    void thinRing(double radius, Color color, {double width = 1.45}) {
      if (radius < 2) return;
      final Paint shadow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width + 2.2
        ..color = const Color(0xFF000000).withValues(alpha: 0.62);
      final Paint line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color;
      canvas.drawCircle(c, radius, shadow);
      canvas.drawCircle(c, radius, line);
    }

    // Outside → inside so inner rings stay crisp on top.
    thinRing(_rOk, const Color(0xFFE0E0E0), width: 1.35);
    thinRing(_rGood, const Color(0xFFFF9100), width: 1.45);
    thinRing(_rPerfect, const Color(0xFF2CFF7B), width: 1.5);
    thinRing(_rUltra, const Color(0xFFFFE082), width: 1.55);
  }

  @override
  bool shouldRepaint(covariant StaticScoreRingsPainter oldDelegate) {
    return oldDelegate.centerOffset != centerOffset;
  }
}
