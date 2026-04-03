import 'package:flutter/material.dart';

/// Visual palette for the hypnotic spiral — changes with difficulty (score).
class SpiralTheme {
  const SpiralTheme({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.tier,
  });

  final Color primary;
  final Color secondary;
  final Color glow;
  final int tier;

  /// 0 = off / minimal, 1 = mid, 2 = hard, 3 = extreme
  static SpiralTheme forScore(int score) {
    if (score < 150) {
      return const SpiralTheme(
        primary: Color(0xFF1A3A5C),
        secondary: Color(0xFF05060A),
        glow: Color(0xFF35E6FF),
        tier: 0,
      );
    }
    if (score < 250) {
      return const SpiralTheme(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF05060A),
        glow: Color(0xFF42A5F5),
        tier: 1,
      );
    }
    if (score < 400) {
      return const SpiralTheme(
        primary: Color(0xFF7B1FA2),
        secondary: Color(0xFF05060A),
        glow: Color(0xFFE040FB),
        tier: 2,
      );
    }
    return const SpiralTheme(
      primary: Color(0xFFD32F2F),
      secondary: Color(0xFF05060A),
      glow: Color(0xFFFF5252),
      tier: 3,
    );
  }
}
