import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Palette + spiral geometry variant — shifts with score epochs and random seeds.
class SpiralTheme {
  const SpiralTheme({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.tier,
    required this.variant,
    required this.twistSign,
    required this.turnsBias,
  });

  final Color primary;
  final Color secondary;
  final Color glow;
  final int tier;
  /// 0..3 — different spiral “personalities”.
  final int variant;
  final double twistSign;
  final double turnsBias;

  static const Color _voidBlack = Color(0xFF05060A);

  static SpiralTheme forScore(int score) {
    final int epoch = score ~/ 48;
    final math.Random rng = math.Random(epoch * 10007 + 1337);
    final int palette = rng.nextInt(_palettes.length);
    final (Color p, Color g) = _palettes[palette];
    final int tier = (score / 120).floor().clamp(0, 4);
    final int variant = rng.nextInt(4);
    final double twistSign = rng.nextBool() ? 1.0 : -1.0;
    final double turnsBias = rng.nextDouble() * 1.4;

    return SpiralTheme(
      primary: p,
      secondary: _voidBlack,
      glow: g,
      tier: tier,
      variant: variant,
      twistSign: twistSign,
      turnsBias: turnsBias,
    );
  }

  /// Preset neon pairs (primary stripe, glow accent).
  static final List<(Color, Color)> _palettes = <(Color, Color)>[
    (const Color(0xFF1A3A5C), const Color(0xFF35E6FF)),
    (const Color(0xFF1565C0), const Color(0xFF42A5F5)),
    (const Color(0xFF4A148C), const Color(0xFFE040FB)),
    (const Color(0xFF00695C), const Color(0xFF64FFDA)),
    (const Color(0xFFBF360C), const Color(0xFFFFAB40)),
    (const Color(0xFF880E4F), const Color(0xFFFF80AB)),
    (const Color(0xFF1B5E20), const Color(0xFF76FF03)),
    (const Color(0xFF37474F), const Color(0xFFB0BEC5)),
  ];
}
