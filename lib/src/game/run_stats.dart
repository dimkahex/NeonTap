import 'package:flutter/foundation.dart';

/// Per-run hit distribution — common in rhythm games (osu!, Taiko, mobile tap runners).
@immutable
class JudgementBreakdown {
  const JudgementBreakdown({
    this.ultra = 0,
    this.perfect = 0,
    this.good = 0,
    this.ok = 0,
    this.graze = 0,
  });

  final int ultra;
  final int perfect;
  final int good;
  final int ok;
  final int graze;

  int get totalHits => ultra + perfect + good + ok + graze;

  /// One miss ends the run — used for a simple accuracy readout.
  double get accuracyPercent => totalHits <= 0 ? 0 : (100.0 * totalHits / (totalHits + 1));
}
