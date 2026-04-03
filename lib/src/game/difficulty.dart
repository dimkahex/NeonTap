import 'dart:math' as math;

/// Tuning inspired by common patterns in arcade runners and rhythm games:
/// discrete **stages** (milestones), **smooth** interpolation between them (no harsh jumps),
/// late-game **soft floor** on window time (endless pressure without going instant),
/// and **combo cap** / **visual noise** gated by stage — same ideas as tiered approach rate + unlocks.
class Difficulty {
  const Difficulty({
    required this.shrinkSeconds,
    required this.comboMaxPow,
    required this.pulseDistract,
    required this.stage,
  });

  /// Time for one full shrink cycle (larger = easier timing).
  final double shrinkSeconds;
  /// Max combo exponent 0..4 → multiplier 1..16 (clamped by stage).
  final int comboMaxPow;
  final bool pulseDistract;
  /// 1-based stage — rough analog of "wave" / difficulty tier in casual skill games.
  final int stage;
}

/// Score at each checkpoint — between checkpoints shrink duration eases from one target to the next.
const List<int> _milestones = <int>[
  0,
  35,
  90,
  180,
  320,
  520,
  750,
  1100,
];

/// Target shrink duration (seconds) at each milestone — slow tutorial → tense late game.
const List<double> _secondsAtMilestone = <double>[
  4.25,
  3.55,
  2.95,
  2.40,
  1.95,
  1.55,
  1.22,
  0.95,
];

double _smoothstep(double t) {
  final double x = t.clamp(0.0, 1.0);
  return x * x * (3.0 - 2.0 * x);
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

double _shrinkSecondsForScore(int score) {
  if (score <= _milestones.first) {
    return _secondsAtMilestone.first;
  }
  final int lastM = _milestones.last;
  if (score >= lastM) {
    final double over = (score - lastM) / 2800.0;
    return (_secondsAtMilestone.last * math.exp(-over * 0.9)).clamp(0.80, 1.05);
  }
  for (int i = 0; i < _milestones.length - 1; i++) {
    final int a = _milestones[i];
    final int b = _milestones[i + 1];
    if (score >= a && score < b) {
      final double u = (score - a) / (b - a);
      final double t = _smoothstep(u);
      return _lerp(_secondsAtMilestone[i], _secondsAtMilestone[i + 1], t);
    }
  }
  return _secondsAtMilestone.last;
}

int _stageForScore(int score) {
  if (score >= _milestones.last) {
    return _milestones.length;
  }
  for (int i = 0; i < _milestones.length - 1; i++) {
    if (score >= _milestones[i] && score < _milestones[i + 1]) {
      return i + 1;
    }
  }
  return 1;
}

int _comboMaxPowForStage(int stage) {
  if (stage <= 2) {
    return 2;
  }
  if (stage <= 4) {
    return 3;
  }
  return 4;
}

bool _pulseDistractFor(int score, int stage) {
  return stage >= 5 || score >= 340;
}

Difficulty difficultyForScore(int score) {
  final int stage = _stageForScore(score);
  return Difficulty(
    shrinkSeconds: _shrinkSecondsForScore(score),
    comboMaxPow: _comboMaxPowForStage(stage),
    pulseDistract: _pulseDistractFor(score, stage),
    stage: stage,
  );
}
