import '../../l10n/app_localizations.dart';
import '../models/leaderboard_entry.dart';
import '../services/friends_service.dart';

String leaderboardDisplayName(AppLocalizations l10n, LeaderboardEntry entry) {
  final String n = entry.displayName;
  if (n == FriendsService.kLeaderboardYouMarker) {
    return l10n.leaderboardNameYou;
  }
  if (n == FriendsService.kLeaderboardMissingMarker) {
    return l10n.leaderboardNameNotInTable;
  }
  if (n == 'Player') {
    return l10n.defaultPlayerName;
  }
  return n;
}
