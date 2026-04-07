import '../../l10n/app_localizations.dart';
import '../models/challenge.dart';

extension ChallengeDurationL10n on ChallengeDuration {
  String locLabel(AppLocalizations l10n) {
    return switch (this) {
      ChallengeDuration.hour1 => l10n.durationHour1,
      ChallengeDuration.hour6 => l10n.durationHour6,
      ChallengeDuration.day1 => l10n.durationDay1,
    };
  }
}
