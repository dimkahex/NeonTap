import 'package:flutter/foundation.dart';

/// Per-run hit distribution.
@immutable
class JudgementBreakdown {
  const JudgementBreakdown({
    this.perfect = 0,
    this.cool = 0,
    this.good = 0,
    this.ok = 0,
  });

  final int perfect;
  final int cool;
  final int good;
  final int ok;

  int get totalHits => perfect + cool + good + ok;

  /// One miss ends the run — used for a simple accuracy readout.
  double get accuracyPercent => totalHits <= 0 ? 0 : (100.0 * totalHits / (totalHits + 1));
}
