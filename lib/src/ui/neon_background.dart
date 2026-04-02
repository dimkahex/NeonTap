import 'dart:ui';

import 'package:flutter/material.dart';

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.35),
          radius: 1.2,
          colors: <Color>[
            Color(0xFF0C1230),
            Color(0xFF05060A),
          ],
          stops: <double>[0.0, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Subtle bloom overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.20,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFF35E6FF),
                          Color(0x00FFFFFF),
                          Color(0xFFFF2ED1),
                        ],
                        stops: <double>[0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

