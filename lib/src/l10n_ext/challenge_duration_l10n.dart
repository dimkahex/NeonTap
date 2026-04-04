import '../../l10n/app_localizations.dart';
import '../models/challenge.dart';

extension ChallengeDurationL10n on ChallengeDuration {
  String locLabel(AppLocalizations l10n) {
    return switch (this) {
      ChallengeDuration.day1 => l10n.durationDay1,
      ChallengeDuration.day2 => l10n.durationDay2,
      ChallengeDuration.week1 => l10n.durationWeek1,
    };
  }
}
