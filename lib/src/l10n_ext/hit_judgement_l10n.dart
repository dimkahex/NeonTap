import '../../l10n/app_localizations.dart';
import '../game/judgement.dart';

extension HitJudgementL10n on HitJudgement {
  String locLabel(AppLocalizations l10n) {
    return switch (this) {
      HitJudgement.graze => l10n.judgementGraze,
      HitJudgement.rim => l10n.judgementRim,
      HitJudgement.edge => l10n.judgementEdge,
      HitJudgement.ok => l10n.judgementOk,
      HitJudgement.ultra => l10n.judgementUltra,
      HitJudgement.perfect => l10n.judgementPerfect,
      HitJudgement.good => l10n.judgementGood,
      HitJudgement.miss => l10n.judgementMiss,
    };
  }
}
