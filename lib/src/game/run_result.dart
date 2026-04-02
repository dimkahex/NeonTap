import 'package:flutter/foundation.dart';

@immutable
class RunResult {
  const RunResult({
    required this.score,
    required this.bestCombo,
    required this.isNewBestScore,
    required this.bestScore,
    required this.rankEstimate,
  });

  final int score;
  final int bestCombo;
  final bool isNewBestScore;
  final int bestScore;
  final int rankEstimate;
}

