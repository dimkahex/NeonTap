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
      case HitJudgement.miss:
        return HapticFeedback.vibrate();
    }
  }
}

