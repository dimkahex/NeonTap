import 'package:flutter/material.dart';

ThemeData buildNeonTheme(TextTheme baseText) {
  const Color bg = Color(0xFF05060A);
  const Color neonCyan = Color(0xFF35E6FF);
  const Color neonPink = Color(0xFFFF2ED1);
  const Color neonGreen = Color(0xFF2CFF7B);
  const Color neonGold = Color(0xFFFFE082);

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF0A0D14),
      primary: neonCyan,
      secondary: neonPink,
      tertiary: neonGreen,
      onSurface: Colors.white,
    ),
    textTheme: baseText.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    dividerColor: Colors.white12,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: neonCyan, width: 1.2),
        ),
        textStyle: baseText.titleMedium?.copyWith(letterSpacing: 1.2),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      NeonColors(
        bg: bg,
        neonCyan: neonCyan,
        neonPink: neonPink,
        neonGreen: neonGreen,
        neonGold: neonGold,
      ),
    ],
  );
}

class NeonColors extends ThemeExtension<NeonColors> {
  const NeonColors({
    required this.bg,
    required this.neonCyan,
    required this.neonPink,
    required this.neonGreen,
    required this.neonGold,
  });

  final Color bg;
  final Color neonCyan;
  final Color neonPink;
  final Color neonGreen;
  final Color neonGold;

  @override
  NeonColors copyWith({
    Color? bg,
    Color? neonCyan,
    Color? neonPink,
    Color? neonGreen,
    Color? neonGold,
  }) {
    return NeonColors(
      bg: bg ?? this.bg,
      neonCyan: neonCyan ?? this.neonCyan,
      neonPink: neonPink ?? this.neonPink,
      neonGreen: neonGreen ?? this.neonGreen,
      neonGold: neonGold ?? this.neonGold,
    );
  }

  @override
  NeonColors lerp(ThemeExtension<NeonColors>? other, double t) {
    if (other is! NeonColors) return this;
    return NeonColors(
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      neonCyan: Color.lerp(neonCyan, other.neonCyan, t) ?? neonCyan,
      neonPink: Color.lerp(neonPink, other.neonPink, t) ?? neonPink,
      neonGreen: Color.lerp(neonGreen, other.neonGreen, t) ?? neonGreen,
      neonGold: Color.lerp(neonGold, other.neonGold, t) ?? neonGold,
    );
  }
}

