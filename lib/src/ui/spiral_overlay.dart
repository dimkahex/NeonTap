import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'spiral_theme.dart';

class SpiralOverlay extends StatefulWidget {
  const SpiralOverlay({
    super.key,
    required this.centerOffset,
    required this.enabled,
    required this.intensity,
    required this.score,
  });

  final ValueNotifier<Offset> centerOffset;
  final bool enabled;
  final double intensity; // 0..1
  final int score;

  @override
  State<SpiralOverlay> createState() => _SpiralOverlayState();
}

class _SpiralOverlayState extends State<SpiralOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // Slightly slower loop = fewer repaints per second for the same smoothness feel.
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.intensity <= 0) return const SizedBox.shrink();
    final SpiralTheme theme = SpiralTheme.forScore(widget.score);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_c, widget.centerOffset]),
          builder: (BuildContext context, _) {
            return CustomPaint(
              isComplex: true,
              willChange: true,
              painter: _HypnoticSpiralPainter(
                phase: _c.value,
                centerOffset: widget.centerOffset.value,
                intensity: widget.intensity,
                theme: theme,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

/// Hypnotic vortex — kept lightweight: few segments, no blur filters, reused [Paint].
class _HypnoticSpiralPainter extends CustomPainter {
  _HypnoticSpiralPainter({
    required this.phase,
    required this.centerOffset,
    required this.intensity,
    required this.theme,
  });

  final double phase;
  final Offset centerOffset;
  final double intensity;
  final SpiralTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double maxR = math.min(size.width, size.height) * 0.58;

    final Rect bounds = Offset.zero & size;
    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (c.dx / size.width) * 2 - 1,
          (c.dy / size.height) * 2 - 1,
        ),
        radius: 1.05,
        colors: <Color>[
          Colors.transparent,
          const Color(0xFF05060A).withOpacity(0.55),
        ],
        stops: const <double>[0.45, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, vignette);

    final double rot = phase * math.pi * 2 * (0.55 + 0.65 * intensity);
    final double turns = 7.0 + 6.0 * intensity + theme.tier * 0.6;
    final double thetaMax = math.pi * 2 * turns;

    final double a = 6.0;
    final double b = (maxR - a) / thetaMax;

    final double voidR = 14.0 + 4.0 * intensity;
    canvas.drawCircle(
      c,
      voidR,
      Paint()..color = const Color(0xFF020308),
    );

    // Was ~950–1600 segments/frame — kills mobile GPU. Cap for smooth 60fps.
    final int steps = (160 + 110 * intensity + theme.tier * 18).clamp(120, 300).round();
    final double twist = rot * 1.15;

    final Paint seg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < steps; i++) {
      final double t0 = i / steps;
      final double t1 = (i + 1) / steps;
      final double th0 = thetaMax * t0;
      final double th1 = thetaMax * t1;

      final double r0 = a + b * th0;
      final double r1 = a + b * th1;

      final double ang0 = th0 + twist;
      final double ang1 = th1 + twist;

      final Offset p0 = c + Offset(math.cos(ang0), math.sin(ang0)) * r0;
      final Offset p1 = c + Offset(math.cos(ang1), math.sin(ang1)) * r1;

      final double bandPhase = (th0 / (math.pi * 0.42)) + phase * 6.2 + theme.tier * 1.7;
      final bool darkBand = (bandPhase.floor() & 1) == 0;

      final Color base = darkBand ? theme.secondary : theme.primary;
      final double rib = 0.55 + 0.45 * math.sin(th0 * 0.35 + phase * math.pi * 2);
      final Color strokeColor = Color.lerp(base, theme.glow, darkBand ? 0.0 : 0.22 * rib)!.withOpacity(
        darkBand ? (0.22 + 0.12 * intensity) : (0.42 + 0.18 * intensity),
      );

      seg
        ..color = strokeColor
        ..strokeWidth = (2.0 + 2.4 * intensity + theme.tier * 0.3) * (darkBand ? 0.85 : 1.05);
      canvas.drawLine(p0, p1, seg);
    }

    // Soft rim without MaskFilter.blur (blur was the main GPU cost here).
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          theme.glow.withOpacity(0.14 + 0.10 * intensity),
          Colors.transparent,
        ],
        stops: const <double>[0.35, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: maxR * 0.95));
    canvas.drawCircle(c, maxR * 0.95, glow);
  }

  @override
  bool shouldRepaint(covariant _HypnoticSpiralPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.centerOffset != centerOffset ||
        oldDelegate.intensity != intensity ||
        oldDelegate.theme.tier != theme.tier;
  }
}
