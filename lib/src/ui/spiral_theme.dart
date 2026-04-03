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

  static SpiralTheme forScore(int score) {
    if (score < 40) {
      return const SpiralTheme(
        primary: Color(0xFF1A3A5C),
        secondary: Color(0xFF05060A),
        glow: Color(0xFF35E6FF),
        tier: 0,
      );
    }
    if (score < 120) {
      return const SpiralTheme(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF05060A),
        glow: Color(0xFF42A5F5),
        tier: 1,
      );
    }
    if (score < 280) {
      return const SpiralTheme(
        primary: Color(0xFF7B1FA2),
        secondary: Color(0xFF05060A),
        glow: Color(0xFFE040FB),
        tier: 2,
      );
    }
    if (score < 400) {
      return const SpiralTheme(
        primary: Color(0xFFC62828),
        secondary: Color(0xFF05060A),
        glow: Color(0xFFFF8A80),
        tier: 3,
      );
    }
    return const SpiralTheme(
      primary: Color(0xFFD32F2F),
      secondary: Color(0xFF05060A),
      glow: Color(0xFFFF5252),
      tier: 4,
    );
  }
}
