import 'dart:math' as math;
import 'dart:ui' show HSVColor;

import 'package:flutter/material.dart';

/// Hypnotic spiral — continuous motion while the game runs: hue drift, direction sway, horizontal pan.
class SpiralOverlay extends StatefulWidget {
  const SpiralOverlay({
    super.key,
    required this.centerOffset,
    required this.enabled,
    required this.intensity,
    required this.score,
  });

  /// Gameplay circle center (drift at high score).
  final ValueNotifier<Offset> centerOffset;
  final bool enabled;
  final double intensity;
  final int score;

  @override
  State<SpiralOverlay> createState() => _SpiralOverlayState();
}

class _SpiralOverlayState extends State<SpiralOverlay> with TickerProviderStateMixin {
  /// Main rotation / spiral phase — never tied to shrink cycle.
  late final AnimationController _flow;
  /// Slow hue cycle for gradient color drift.
  late final AnimationController _hue;
  /// Lateral & slight vertical sway (left–right emphasis).
  late final AnimationController _pan;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(vsync: this, duration: const Duration(seconds: 38))..repeat();
    _hue = AnimationController(vsync: this, duration: const Duration(seconds: 52))..repeat();
    _pan = AnimationController(vsync: this, duration: const Duration(seconds: 13))..repeat();
  }

  @override
  void dispose() {
    _flow.dispose();
    _hue.dispose();
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.intensity <= 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[_flow, _hue, _pan, widget.centerOffset]),
          builder: (BuildContext context, _) {
            final double flow = _flow.value;
            final double hueT = _hue.value;
            final double panT = _pan.value * math.pi * 2;

            // Smooth left–right + tiny vertical — independent of gameplay drift amplitude.
            final double spiralPanX = math.sin(panT * 0.95) * 22.0 + math.sin(flow * math.pi * 2 * 1.3) * 6.0;
            final double spiralPanY = math.cos(panT * 1.1) * 5.0 + math.sin(flow * math.pi * 2 * 0.7) * 3.0;
            final Offset spiralShift = Offset(spiralPanX, spiralPanY);

            // Direction slowly oscillates (no hard stops).
            // Direction flips; magnitude stays full so rotation never "stops".
            final double twistSign = math.sin(flow * math.pi * 2 * 0.62) >= 0 ? 1.0 : -1.0;

            final double phase = flow;

            final int tier = (widget.score / 120).floor().clamp(0, 4);

            final Color primary = HSVColor.fromAHSV(1, (hueT * 360) % 360, 0.58, 0.44).toColor();
            final Color glow = HSVColor.fromAHSV(1, (hueT * 360 + 48) % 360, 0.82, 1.0).toColor();
            const Color secondary = Color(0xFF05060A);

            return CustomPaint(
              isComplex: true,
              willChange: true,
              painter: _HypnoticSpiralPainter(
                phase: phase,
                centerOffset: widget.centerOffset.value + spiralShift,
                intensity: widget.intensity,
                primary: primary,
                secondary: secondary,
                glow: glow,
                tier: tier,
                twistSign: twistSign,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _HypnoticSpiralPainter extends CustomPainter {
  _HypnoticSpiralPainter({
    required this.phase,
    required this.centerOffset,
    required this.intensity,
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.tier,
    required this.twistSign,
  });

  final double phase;
  final Offset centerOffset;
  final double intensity;
  final Color primary;
  final Color secondary;
  final Color glow;
  final int tier;
  final double twistSign;

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

    final double rot = phase * math.pi * 2 * (0.55 + 0.65 * intensity) * twistSign;
    final double v = (tier * 0.22) % 1.0;
    final double turns = 6.8 + 5.5 * intensity + tier * 0.55 + v * 1.2;
    final double thetaMax = math.pi * 2 * turns;

    final double a = 6.0 + (tier % 3) * 1.1;
    final double b = (maxR - a) / thetaMax;

    final double voidR = 14.0 + 4.0 * intensity;
    canvas.drawCircle(
      c,
      voidR,
      Paint()..color = const Color(0xFF020308),
    );

    final int steps = (160 + 110 * intensity + tier * 18).clamp(120, 300).round();
    final double twist = rot * (1.12 + v * 0.15);

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

      final double bandPhase = (th0 / (math.pi * 0.42)) + phase * 6.2 + tier * 1.7;
      final bool darkBand = (bandPhase.floor() & 1) == 0;

      final Color base = darkBand ? secondary : primary;
      final double rib = 0.55 + 0.45 * math.sin(th0 * 0.35 + phase * math.pi * 2);
      final Color strokeColor = Color.lerp(base, glow, darkBand ? 0.0 : 0.22 * rib)!.withValues(
        alpha: darkBand ? (0.22 + 0.12 * intensity) : (0.42 + 0.18 * intensity),
      );

      seg
        ..color = strokeColor
        ..strokeWidth = (2.0 + 2.4 * intensity + tier * 0.3) * (darkBand ? 0.85 : 1.05);
      canvas.drawLine(p0, p1, seg);
    }

    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          glow.withValues(alpha: 0.14 + 0.10 * intensity),
          Colors.transparent,
        ],
        stops: const <double>[0.35, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: maxR * 0.95));
    canvas.drawCircle(c, maxR * 0.95, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HypnoticSpiralPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.centerOffset != centerOffset ||
        oldDelegate.intensity != intensity ||
        oldDelegate.primary != primary ||
        oldDelegate.glow != glow ||
        oldDelegate.tier != tier ||
        oldDelegate.twistSign != twistSign;
  }
}
