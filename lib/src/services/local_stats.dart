import 'package:shared_preferences/shared_preferences.dart';

class LocalStats {
  static const String _kBestScore = 'best_score';
  static const String _kBestCombo = 'best_combo';
  static const String _kTotalRuns = 'total_runs';

  static Future<(int bestScore, int bestCombo)> getBest() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (
      prefs.getInt(_kBestScore) ?? 0,
      prefs.getInt(_kBestCombo) ?? 0,
    );
  }

  static Future<(int bestScore, int bestCombo, bool newBest)> updateBestIfNeeded({
    required int score,
    required int bestCombo,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int prevBestScore = prefs.getInt(_kBestScore) ?? 0;
    final int prevBestCombo = prefs.getInt(_kBestCombo) ?? 0;

    final bool newBestScore = score > prevBestScore;
    final int nextBestScore = newBestScore ? score : prevBestScore;
    final int nextBestCombo = bestCombo > prevBestCombo ? bestCombo : prevBestCombo;

    if (nextBestScore != prevBestScore) {
      await prefs.setInt(_kBestScore, nextBestScore);
    }
    if (nextBestCombo != prevBestCombo) {
      await prefs.setInt(_kBestCombo, nextBestCombo);
    }

    return (nextBestScore, nextBestCombo, newBestScore);
  }

  /// Increments completed-run counter; returns new total (this run’s index).
  static Future<int> incrementTotalRuns() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int n = (prefs.getInt(_kTotalRuns) ?? 0) + 1;
    await prefs.setInt(_kTotalRuns, n);
    return n;
  }
}

