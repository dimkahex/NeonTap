import 'package:flutter/foundation.dart';

import 'run_stats.dart';

@immutable
class RunResult {
  const RunResult({
    required this.score,
    required this.bestCombo,
    required this.isNewBestScore,
    required this.bestScore,
    required this.rankEstimate,
    this.breakdown = const JudgementBreakdown(),
    this.lifetimeRunIndex = 0,
  });

  final int score;
  final int bestCombo;
  final bool isNewBestScore;
  final int bestScore;
  final int rankEstimate;
  final JudgementBreakdown breakdown;
  /// Total completed runs all-time after this one (for "run #N" feel).
  final int lifetimeRunIndex;
}

