import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpiralOverlay extends StatefulWidget {
  const SpiralOverlay({
    super.key,
    required this.centerOffset,
    required this.enabled,
    required this.intensity,
  });

  final ValueNotifier<Offset> centerOffset;
  final bool enabled;
  final double intensity; // 0..1

  @override
  State<SpiralOverlay> createState() => _SpiralOverlayState();
}

class _SpiralOverlayState extends State<SpiralOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.intensity <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_c, widget.centerOffset]),
        builder: (BuildContext context, _) {
          return CustomPaint(
            painter: _SpiralPainter(
              phase: _c.value,
              centerOffset: widget.centerOffset.value,
              intensity: widget.intensity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SpiralPainter extends CustomPainter {
  _SpiralPainter({
    required this.phase,
    required this.centerOffset,
    required this.intensity,
  });

  final double phase; // 0..1
  final Offset centerOffset;
  final double intensity; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;

    // Archimedean spiral: r = a + b*theta
    final double maxR = math.min(size.width, size.height) * 0.62;
    final double turns = 7.5 + 6.0 * intensity; // more turns at higher difficulty
    final double thetaMax = math.pi * 2 * turns;

    final double rot = (phase * math.pi * 2) * (0.65 + 0.85 * intensity);
    final double a = 4.0;
    final double b = maxR / thetaMax;

    final Path p = Path();
    bool started = false;
    final int steps = (900 + 900 * intensity).round();
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double theta = thetaMax * t;
      final double r = a + b * theta;

      final double ang = theta + rot;
      final Offset pt = c + Offset(math.cos(ang), math.sin(ang)) * r;
      if (!started) {
        p.moveTo(pt.dx, pt.dy);
        started = true;
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }

    final double alpha = (0.06 + 0.16 * intensity).clamp(0.0, 0.22);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 + 1.2 * intensity
      ..color = const Color(0xFF35E6FF).withOpacity(alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, (3 + 10 * intensity).roundToDouble());

    // Double layer for that neon “infinite spiral” feel.
    canvas.drawPath(p, paint);
    canvas.drawPath(
      p,
      paint
        ..color = const Color(0xFFFF2ED1).withOpacity(alpha * 0.7)
        ..strokeWidth = 0.9 + 1.0 * intensity,
    );
  }

  @override
  bool shouldRepaint(covariant _SpiralPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.centerOffset != centerOffset ||
        oldDelegate.intensity != intensity;
  }
}

