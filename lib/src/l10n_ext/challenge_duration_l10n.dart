import '../../l10n/app_localizations.dart';
import '../models/challenge.dart';

extension ChallengeDurationL10n on ChallengeDuration {
  String locLabel(AppLocalizations l10n) {
    return switch (this) {
      ChallengeDuration.hour1 => l10n.durationHour1,
      ChallengeDuration.hour2 => l10n.durationHour2,
      ChallengeDuration.hour6 => l10n.durationHour6,
    };
  }
}
