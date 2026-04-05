import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeonCirclePainter extends CustomPainter {
  NeonCirclePainter({
    required this.radius,
    required this.maxRadius,
    required this.pulse,
    required this.missFlash,
    required this.centerOffset,
    this.ringAimMode = false,
    this.hideMainRingStroke = false,
  });

  final double radius;
  final double maxRadius;
  final double pulse; // 0..1
  final double missFlash; // 0..1
  final Offset centerOffset;
  /// When true, fades static **timing** circles (center distance) so **обод** overlay reads clearer.
  final bool ringAimMode;
  /// When true, main shrinking ring is drawn by [MainRingHudPainter] above VFX.
  final bool hideMainRingStroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final Rect bounds = Offset.zero & size;

    final Paint bgGlow = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[
          Color(0x202CFF7B),
          Color(0x00000000),
        ],
        stops: <double>[0.0, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, bgGlow);

    final double r = radius.clamp(0.0, maxRadius);
    final double progress = 1.0 - (r / maxRadius); // 0 at start, 1 at center

    // Color shifts cyan -> pink/red as it shrinks.
    final Color start = const Color(0xFF35E6FF);
    final Color end = const Color(0xFFFF3355);
    final Color core = Color.lerp(start, end, progress) ?? start;

    final double distract = 1.0 + (0.06 * math.sin(pulse * math.pi * 2));

    // Zone rings — timing (distance to center); dimmed in ring-aim mode vs. обод overlay.
    final double g = ringAimMode ? 0.42 : 1.0;
    _ring(canvas, c, 72, Colors.orangeAccent.withOpacity(0.42 * g));
    _ring(canvas, c, 48, const Color(0xFF2CFF7B).withOpacity(0.52 * g));
    _ring(canvas, c, 28, const Color(0xFFFFE082).withOpacity(0.62 * g), width: 2.8);
    _ring(canvas, c, 110, Colors.white.withOpacity(0.16 * g), width: 1.8);

    if (!hideMainRingStroke) {
      final Paint outerGlow = Paint()
        ..color = core.withOpacity(0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

      final Paint ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = core.withOpacity(0.95);

      canvas.drawCircle(c, r * 1.02 * distract, outerGlow);
      canvas.drawCircle(c, r * distract, ring);
    }

    if (missFlash > 0) {
      final Paint miss = Paint()..color = Colors.redAccent.withOpacity(0.35 * missFlash);
      canvas.drawRect(bounds, miss);
    }
  }

  void _ring(Canvas canvas, Offset c, double rr, Color color, {double width = 2}) {
    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    canvas.drawCircle(c, rr, p);
  }

  @override
  bool shouldRepaint(covariant NeonCirclePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.maxRadius != maxRadius ||
        oldDelegate.pulse != pulse ||
        oldDelegate.missFlash != missFlash ||
        oldDelegate.centerOffset != centerOffset ||
        oldDelegate.ringAimMode != ringAimMode ||
        oldDelegate.hideMainRingStroke != hideMainRingStroke;
  }
}

