import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'spiral_theme.dart';

class SpiralOverlay extends StatefulWidget {
  const SpiralOverlay({
    super.key,
    required this.shrinkSmoothPhase,
    required this.centerOffset,
    required this.enabled,
    required this.intensity,
    required this.score,
  });

  /// Same shrink cycle as the ring — [CurvedAnimation] with ease for smooth motion.
  final Animation<double> shrinkSmoothPhase;
  final ValueNotifier<Offset> centerOffset;
  final bool enabled;
  final double intensity;
  final int score;

  @override
  State<SpiralOverlay> createState() => _SpiralOverlayState();
}

class _SpiralOverlayState extends State<SpiralOverlay> with SingleTickerProviderStateMixin {
  /// Very slow secondary motion so the spiral feels alive without fighting the main beat.
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(vsync: this, duration: const Duration(milliseconds: 8200))..repeat();
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.intensity <= 0) return const SizedBox.shrink();
    final SpiralTheme theme = SpiralTheme.forScore(widget.score);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            widget.shrinkSmoothPhase,
            _breath,
            widget.centerOffset,
          ]),
          builder: (BuildContext context, _) {
            final double t = widget.shrinkSmoothPhase.value.clamp(0.0, 1.0);
            final double wobble = 0.055 * math.sin(_breath.value * math.pi * 2);
            final double phase = (t + wobble).clamp(0.0, 1.0);
            return CustomPaint(
              isComplex: true,
              willChange: true,
              painter: _HypnoticSpiralPainter(
                phase: phase,
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

/// Hypnotic vortex — lightweight; phase driven by shrink cycle for smooth sync with the ring.
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
          const Color(0xFF05060A).withValues(alpha: 0.55),
        ],
        stops: const <double>[0.45, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, vignette);

    final double rot = phase * math.pi * 2 * (0.55 + 0.65 * intensity) * theme.twistSign;
    final double v = theme.variant * 0.22;
    final double turns = 6.8 + 5.5 * intensity + theme.tier * 0.55 + theme.turnsBias + v;
    final double thetaMax = math.pi * 2 * turns;

    final double a = 6.0 + theme.variant * 1.2;
    final double b = (maxR - a) / thetaMax;

    final double voidR = 14.0 + 4.0 * intensity;
    canvas.drawCircle(
      c,
      voidR,
      Paint()..color = const Color(0xFF020308),
    );

    final int steps = (160 + 110 * intensity + theme.tier * 18).clamp(120, 300).round();
    final double twist = rot * (1.12 + v);

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

      final double bandPhase = (th0 / (math.pi * 0.42)) + phase * 6.2 + theme.tier * 1.7 + theme.variant * 0.9;
      final bool darkBand = (bandPhase.floor() & 1) == 0;

      final Color base = darkBand ? theme.secondary : theme.primary;
      final double rib = 0.55 + 0.45 * math.sin(th0 * 0.35 + phase * math.pi * 2);
      final Color strokeColor = Color.lerp(base, theme.glow, darkBand ? 0.0 : 0.22 * rib)!.withValues(
        alpha: darkBand ? (0.22 + 0.12 * intensity) : (0.42 + 0.18 * intensity),
      );

      seg
        ..color = strokeColor
        ..strokeWidth = (2.0 + 2.4 * intensity + theme.tier * 0.3) * (darkBand ? 0.85 : 1.05);
      canvas.drawLine(p0, p1, seg);
    }

    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          theme.glow.withValues(alpha: 0.14 + 0.10 * intensity),
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
        oldDelegate.theme.tier != theme.tier ||
        oldDelegate.theme.variant != theme.variant ||
        oldDelegate.theme.primary != theme.primary;
  }
}
