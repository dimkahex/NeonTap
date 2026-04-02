class Difficulty {
  const Difficulty({
    required this.shrinkSeconds,
    required this.comboMaxPow,
    required this.pulseDistract,
  });

  final double shrinkSeconds;
  final int comboMaxPow; // 0..4 => x1..x16
  final bool pulseDistract;
}

Difficulty difficultyForScore(int score) {
  // Base curve: speed increases roughly linearly every ~25 points.
  final double t = (score / 450.0).clamp(0.0, 1.0);
  final double seconds = (3.0 - 1.6 * t).clamp(1.4, 3.0);

  final int comboPow = switch (score) {
    < 50 => 0,
    < 150 => 1,
    < 400 => 2,
    _ => 3,
  };

  return Difficulty(
    shrinkSeconds: seconds,
    comboMaxPow: comboPow,
    pulseDistract: score >= 400,
  );
}

