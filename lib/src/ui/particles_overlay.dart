import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/judgement.dart';

class ParticlesOverlay extends StatefulWidget {
  const ParticlesOverlay({super.key, required this.events});

  final ValueNotifier<ParticleEvent?> events;

  @override
  State<ParticlesOverlay> createState() => _ParticlesOverlayState();
}

class _ParticlesOverlayState extends State<ParticlesOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  ParticleEvent? _event;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    widget.events.addListener(_onEvent);
  }

  void _onEvent() {
    final ParticleEvent? e = widget.events.value;
    if (e == null) return;
    _event = e;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    widget.events.removeListener(_onEvent);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, _) {
          final ParticleEvent? e = _event;
          if (e == null || _c.value == 0) return const SizedBox.shrink();
          return CustomPaint(
            painter: _ParticlesPainter(
              t: _c.value,
              color: _colorFor(e.j),
              seed: e.seed,
              intensity: e.intensity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Color _colorFor(HitJudgement j) => switch (j) {
        HitJudgement.ultra => const Color(0xFFFFE082),
        HitJudgement.perfect => const Color(0xFF2CFF7B),
        HitJudgement.good => Colors.orangeAccent,
        HitJudgement.ok => Colors.white70,
        HitJudgement.graze => const Color(0xFF9E9E9E),
        HitJudgement.rim => const Color(0xFF6D8A96),
        HitJudgement.edge => const Color(0xFF5C6B73),
        HitJudgement.miss => Colors.redAccent,
      };
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.t, required this.color, required this.seed, required this.intensity});

  final double t; // 0..1
  final Color color;
  final int seed;
  final double intensity; // 0.8..1.6

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);

    // Expanding shockwave.
    final Paint wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 * intensity
      ..color = color.withOpacity((1 - t) * 0.55);
    canvas.drawCircle(c, 30 + (220 * intensity) * t, wave);

    // Simple burst dots.
    final math.Random r = math.Random(seed);
    final int n = (18 * intensity).round().clamp(12, 48);
    for (int i = 0; i < n; i++) {
      final double a = r.nextDouble() * math.pi * 2;
      final double sp = (40 + r.nextDouble() * 180) * intensity;
      final double rad = (2 + r.nextDouble() * 3) * (0.85 + 0.25 * intensity);
      final double dist = sp * Curves.easeOut.transform(t);
      final Offset p = c + Offset(math.cos(a), math.sin(a)) * dist;
      final Paint dot = Paint()..color = color.withOpacity((1 - t) * 0.9);
      canvas.drawCircle(p, rad, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color || oldDelegate.seed != seed;
  }
}

class ParticleEvent {
  const ParticleEvent({required this.j, required this.seed, required this.intensity});

  final HitJudgement j;
  final int seed;
  final double intensity;
}

ValueNotifier<ParticleEvent?> particleEventsNotifier() => ValueNotifier<ParticleEvent?>(null);

void emitParticleEvent(ValueNotifier<ParticleEvent?> n, HitJudgement j, int seed, {required double intensity}) {
  n.value = ParticleEvent(j: j, seed: seed, intensity: intensity);
}

