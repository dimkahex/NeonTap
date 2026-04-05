import '../../l10n/app_localizations.dart';
import '../game/judgement.dart';

extension HitJudgementL10n on HitJudgement {
  String locLabel(AppLocalizations l10n) {
    return switch (this) {
      HitJudgement.perfect => l10n.judgementPerfect,
      HitJudgement.cool => l10n.judgementCool,
      HitJudgement.good => l10n.judgementGood,
      HitJudgement.ok => l10n.judgementOk,
      HitJudgement.miss => l10n.judgementMiss,
    };
  }
}
