import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Гипнотическая спираль: фаза, оттенок, покачивание; ранний гейм — больше лёгких вариаций,
/// с прогрессом — доп. обводка и плотность штриха.
class SpiralOverlay extends StatefulWidget {
  const SpiralOverlay({
    super.key,
    required this.centerOffset,
    required this.enabled,
    required this.intensity,
    required this.score,
    this.stage = 1,
    this.progression = 0,
  });

  final ValueNotifier<Offset> centerOffset;
  final bool enabled;
  final double intensity;
  final int score;
  /// Этап сложности (1..14) — влияет на «насыщенность» узора.
  final int stage;
  /// 0..1 — насколько включены усложняющие эффекты (от счёта).
  final double progression;

  @override
  State<SpiralOverlay> createState() => _SpiralOverlayState();
}

class _SpiralOverlayState extends State<SpiralOverlay> with TickerProviderStateMixin {
  late final AnimationController _flow;
  late final AnimationController _hue;
  late final AnimationController _pan;
  /// Медленное «дыхание» яркости — лёгкая живая подпорка в начале забега.
  late final AnimationController _breath;
  /// Вторичная фаза — чаще смена «характера» линии на низком счёте.
  late final AnimationController _ripple;

  Offset _smoothShift = Offset.zero;

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(vsync: this, duration: const Duration(seconds: 38))..repeat();
    _hue = AnimationController(vsync: this, duration: const Duration(seconds: 52))..repeat();
    _pan = AnimationController(vsync: this, duration: const Duration(seconds: 13))..repeat();
    _breath = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _ripple = AnimationController(vsync: this, duration: const Duration(seconds: 19))..repeat();
  }

  @override
  void dispose() {
    _flow.dispose();
    _hue.dispose();
    _pan.dispose();
    _breath.dispose();
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || widget.intensity <= 0) return const SizedBox.shrink();

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            _flow,
            _hue,
            _pan,
            _breath,
            _ripple,
            widget.centerOffset,
          ]),
          builder: (BuildContext context, _) {
            final double flow = _flow.value;
            final double hueT = _hue.value;
            final double panT = _pan.value * math.pi * 2;
            final double breath = _breath.value;
            final double ripple = _ripple.value;

            final double prog = widget.progression.clamp(0.0, 1.0);
            // В начале — шире покачивание и мягче «скука»; позже — сдержаннее.
            final double early = 1.0 + (1.0 - prog) * 0.42;
            final double spiralPanX =
                (math.sin(panT * 0.82) * 20.0 + math.sin(flow * math.pi * 2 * 0.92) * 4.6) * early +
                    math.sin(ripple * math.pi * 2 * 1.35) * (3.8 + (1.0 - prog) * 6.2);
            final double spiralPanY =
                (math.cos(panT * 0.96) * 4.4 + math.sin(flow * math.pi * 2 * 0.58) * 2.4) * early +
                    math.cos(ripple * math.pi * 2 * 1.12) * (2.0 + (1.0 - prog) * 4.0);

            final Offset targetShift = Offset(spiralPanX, spiralPanY);
            _smoothShift = Offset.lerp(_smoothShift, targetShift, 0.075)!;
            final Offset spiralShift = _smoothShift;

            final double twistSign = math.sin(flow * math.pi * 2 * 0.62) >= 0 ? 1.0 : -1.0;

            final double phase = flow;

            // Чаще смена узора в первые минуты счёта (раньше было /120).
            final int tier = (widget.score / 48).floor().clamp(0, 9);
            final int stageClamped = widget.stage.clamp(1, 14);

            final Color primary = HSVColor.fromAHSV(1, (hueT * 360) % 360, 0.58, 0.44).toColor();
            final Color glow = HSVColor.fromAHSV(1, (hueT * 360 + 48) % 360, 0.82, 1.0).toColor();
            const Color secondary = Color(0xFF05060A);

            final double breathMul = 0.92 + 0.14 * math.sin(breath * math.pi * 2);

            return CustomPaint(
              isComplex: true,
              willChange: true,
              painter: _HypnoticSpiralPainter(
                phase: phase,
                centerOffset: widget.centerOffset.value + spiralShift,
                intensity: widget.intensity * breathMul,
                primary: primary,
                secondary: secondary,
                glow: glow,
                tier: tier,
                twistSign: twistSign,
                progression: prog,
                stage: stageClamped,
                ripplePhase: ripple,
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
    required this.progression,
    required this.stage,
    required this.ripplePhase,
  });

  final double phase;
  final Offset centerOffset;
  final double intensity;
  final Color primary;
  final Color secondary;
  final Color glow;
  final int tier;
  final double twistSign;
  final double progression;
  final int stage;
  final double ripplePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2) + centerOffset;
    final double maxR = math.min(size.width, size.height) * 0.58;

    final Rect bounds = Offset.zero & size;
    final double vig = 0.48 + 0.12 * progression + (stage / 14) * 0.08;
    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (c.dx / size.width) * 2 - 1,
          (c.dy / size.height) * 2 - 1,
        ),
        radius: 1.05,
        colors: <Color>[
          Colors.transparent,
          const Color(0xFF05060A).withValues(alpha: vig),
        ],
        stops: const <double>[0.45, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds, vignette);

    final double rot = phase * math.pi * 2 * (0.55 + 0.65 * intensity) * twistSign;
    final double v = (tier * 0.18) % 1.0;
    final double progTurns = 1.4 * progression + (stage / 14) * 0.45;
    final double turns = 6.8 + 5.5 * intensity + tier * 0.62 + v * 1.2 + progTurns * 2.1;
    final double thetaMax = math.pi * 2 * turns;

    final double a = 6.0 + (tier % 3) * 1.1 + progression * 2.2;
    final double b = (maxR - a) / thetaMax;

    final double voidR = 14.0 + 4.0 * intensity + progression * 3.0;
    canvas.drawCircle(
      c,
      voidR,
      Paint()..color = const Color(0xFF020308),
    );

    // 90Hz-friendly: keep the spiral smooth but cheaper per frame.
    // We rely on stroke width + glow to mask lower segment count.
    final int steps = (140 + 80 * intensity + tier * 16 + (progression * 40).round()).clamp(100, 260).round();
    final double twist = rot * (1.12 + v * 0.15 + progression * 0.22);

    final Paint seg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double strokeBoost = 1.0 + progression * 0.55 + (stage / 14) * 0.2;
    final double alphaBoost = 0.08 * progression + 0.04 * (stage / 14);

    // Avoid per-segment sin/cos for the spiral geometry by stepping angle iteratively.
    final double dTh = thetaMax / steps;
    final double cosD = math.cos(dTh);
    final double sinD = math.sin(dTh);
    final double dr = b * dTh;

    double th0 = 0.0;
    double r0 = a;
    double cosA = math.cos(twist);
    double sinA = math.sin(twist);

    for (int i = 0; i < steps; i++) {
      final double th1 = th0 + dTh;
      final double r1 = r0 + dr;
      final double cosA1 = cosA * cosD - sinA * sinD;
      final double sinA1 = sinA * cosD + cosA * sinD;

      final Offset p0 = c + Offset(cosA, sinA) * r0;
      final Offset p1 = c + Offset(cosA1, sinA1) * r1;

      final double bandPhase = (th0 / (math.pi * 0.42)) + phase * 6.2 + tier * 1.7 + ripplePhase * 4.2;
      final bool darkBand = (bandPhase.floor() & 1) == 0;

      final Color base = darkBand ? secondary : primary;
      final double rib = 0.55 + 0.45 * math.sin(th0 * 0.35 + phase * math.pi * 2);
      final Color strokeColor = Color.lerp(base, glow, darkBand ? 0.0 : 0.22 * rib)!.withValues(
        alpha: darkBand
            ? (0.22 + 0.12 * intensity + alphaBoost * 0.5)
            : (0.42 + 0.18 * intensity + alphaBoost),
      );

      seg
        ..color = strokeColor
        ..strokeWidth =
            (2.0 + 2.4 * intensity + tier * 0.28 + progression * 1.6) * (darkBand ? 0.85 : 1.05) * strokeBoost;
      canvas.drawLine(p0, p1, seg);

      th0 = th1;
      r0 = r1;
      cosA = cosA1;
      sinA = sinA1;
    }

    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          glow.withValues(alpha: 0.14 + 0.10 * intensity + 0.08 * progression),
          Colors.transparent,
        ],
        stops: const <double>[0.35, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: maxR * 0.95));
    canvas.drawCircle(c, maxR * 0.95, glowPaint);

    // Доп. кольцо-эхо при прогрессе — без второй полной спирали (дешево по GPU).
    if (progression > 0.28) {
      final double wobble = math.sin(phase * math.pi * 2 * 1.4) * 0.04;
      final Paint echo = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1 + progression * 2.4
        ..color = glow.withValues(alpha: 0.06 + progression * 0.14);
      canvas.drawCircle(c, maxR * (0.68 + wobble), echo);
    }

    if (progression > 0.55) {
      final Paint echo2 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 + (progression - 0.55) * 2.0
        ..color = primary.withValues(alpha: 0.05 + (progression - 0.55) * 0.12);
      canvas.drawCircle(c, maxR * (0.88 + 0.02 * math.sin(ripplePhase * math.pi * 2)), echo2);
    }
  }

  @override
  bool shouldRepaint(covariant _HypnoticSpiralPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.centerOffset != centerOffset ||
        oldDelegate.intensity != intensity ||
        oldDelegate.primary != primary ||
        oldDelegate.glow != glow ||
        oldDelegate.tier != tier ||
        oldDelegate.twistSign != twistSign ||
        oldDelegate.progression != progression ||
        oldDelegate.stage != stage ||
        oldDelegate.ripplePhase != ripplePhase;
  }
}
