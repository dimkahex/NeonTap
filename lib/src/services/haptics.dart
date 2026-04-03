import 'package:flutter/services.dart';

import '../game/judgement.dart';

class Haptics {
  static Future<void> forJudgement(HitJudgement j) async {
    // Keep it simple and consistent across platforms.
    switch (j) {
      case HitJudgement.ultra:
        return HapticFeedback.heavyImpact();
      case HitJudgement.perfect:
        return HapticFeedback.mediumImpact();
      case HitJudgement.good:
        return HapticFeedback.lightImpact();
      case HitJudgement.ok:
        return HapticFeedback.selectionClick();
      case HitJudgement.graze:
      case HitJudgement.rim:
      case HitJudgement.edge:
        return HapticFeedback.selectionClick();
      case HitJudgement.miss:
        return HapticFeedback.vibrate();
    }
  }
}

