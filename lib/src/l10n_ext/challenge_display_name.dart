import '../../l10n/app_localizations.dart';

/// [ChallengeService] stores fallback opponent label as `Player` in RTDB.
String challengePersonName(AppLocalizations l10n, String name) {
  if (name == 'Player') {
    return l10n.defaultPlayerName;
  }
  return name;
}
