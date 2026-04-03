import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/judgement.dart';

class FloatingPointsOverlay extends StatefulWidget {
  const FloatingPointsOverlay({
    super.key,
    required this.events,
    required this.centerOffset,
  });

  final ValueNotifier<FloatingPointsEvent?> events;
  final ValueNotifier<Offset> centerOffset;

  @override
  State<FloatingPointsOverlay> createState() => _FloatingPointsOverlayState();
}

class _FloatingPointsOverlayState extends State<FloatingPointsOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<_FloatingPoints> _items = <_FloatingPoints>[];

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_onTick)
      ..repeat();
    widget.events.addListener(_onEvent);
  }

  @override
  void dispose() {
    widget.events.removeListener(_onEvent);
    _ticker.dispose();
    super.dispose();
  }

  void _onEvent() {
    final FloatingPointsEvent? e = widget.events.value;
    if (e == null) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    _items.add(
      _FloatingPoints(
        createdAtMs: now,
        value: e.value,
        j: e.j,
        seed: e.seed,
      ),
    );
  }

  void _onTick() {
    if (_items.isEmpty) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    _items.removeWhere((_) => (now - _.createdAtMs) > _.ttlMs);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();

    final Offset base = Offset(MediaQuery.sizeOf(context).width / 2, MediaQuery.sizeOf(context).height / 2) +
        widget.centerOffset.value;

    return IgnorePointer(
      child: Stack(
        children: _items.map((_) {
          final int now = DateTime.now().millisecondsSinceEpoch;
          final double t = ((now - _.createdAtMs) / _.ttlMs).clamp(0.0, 1.0);
          final double ease = Curves.easeOutCubic.transform(t);
          final double fade = (1.0 - Curves.easeIn.transform(t)).clamp(0.0, 1.0);

          final math.Random r = math.Random(_.seed);
          final double xJitter = (r.nextDouble() - 0.5) * 40;

          final Offset p = base + Offset(xJitter, -140 * ease);

          final TextStyle style = _styleFor(context, _.j).copyWith(
            color: _styleFor(context, _.j).color?.withOpacity(fade),
          );

          final double scale = (1.15 - 0.15 * t).clamp(0.9, 1.2);

          return Positioned(
            left: p.dx,
            top: p.dy,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.centerLeft,
              child: Text(
                '+${_.value}',
                style: style,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  TextStyle _styleFor(BuildContext context, HitJudgement j) {
    final TextStyle base =
        Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.6) ??
            const TextStyle(fontSize: 26, fontWeight: FontWeight.w900);

    return switch (j) {
      HitJudgement.ultra => base.copyWith(
          fontSize: 34,
          color: const Color(0xFFFFE082),
          shadows: const <Shadow>[Shadow(color: Color(0xAAFFE082), blurRadius: 24)],
        ),
      HitJudgement.perfect => base.copyWith(
          fontSize: 30,
          color: const Color(0xFF2CFF7B),
          shadows: const <Shadow>[Shadow(color: Color(0x992CFF7B), blurRadius: 18)],
        ),
      HitJudgement.good => base.copyWith(
          fontSize: 26,
          color: Colors.orangeAccent,
          shadows: const <Shadow>[Shadow(color: Color(0x88FFB74D), blurRadius: 14)],
        ),
      HitJudgement.ok => base.copyWith(
          fontSize: 22,
          color: Colors.white70,
          shadows: const <Shadow>[Shadow(color: Color(0x8835E6FF), blurRadius: 10)],
        ),
      HitJudgement.graze => base.copyWith(
          fontSize: 18,
          color: const Color(0xFF78909C),
          shadows: const <Shadow>[Shadow(color: Color(0x66445566), blurRadius: 8)],
        ),
      HitJudgement.miss => base.copyWith(
          fontSize: 24,
          color: Colors.redAccent,
          shadows: const <Shadow>[Shadow(color: Color(0x88FF3355), blurRadius: 14)],
        ),
    };
  }
}

class FloatingPointsEvent {
  const FloatingPointsEvent({
    required this.value,
    required this.j,
    required this.seed,
  });

  final int value;
  final HitJudgement j;
  final int seed;
}

ValueNotifier<FloatingPointsEvent?> floatingPointsNotifier() => ValueNotifier<FloatingPointsEvent?>(null);

void emitFloatingPoints(ValueNotifier<FloatingPointsEvent?> n, {required int value, required HitJudgement j, required int seed}) {
  n.value = FloatingPointsEvent(value: value, j: j, seed: seed);
}

class _FloatingPoints {
  const _FloatingPoints({
    required this.createdAtMs,
    required this.value,
    required this.j,
    required this.seed,
  });

  final int createdAtMs;
  final int value;
  final HitJudgement j;
  final int seed;

  int get ttlMs => 620;
}

