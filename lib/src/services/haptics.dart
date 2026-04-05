import 'package:flutter/services.dart';

import '../game/judgement.dart';

class Haptics {
  static Future<void> forJudgement(HitJudgement j) async {
    switch (j) {
      case HitJudgement.perfect:
        return HapticFeedback.heavyImpact();
      case HitJudgement.cool:
        return HapticFeedback.mediumImpact();
      case HitJudgement.good:
        return HapticFeedback.lightImpact();
      case HitJudgement.ok:
        return HapticFeedback.selectionClick();
      case HitJudgement.miss:
        return HapticFeedback.vibrate();
    }
  }
}
